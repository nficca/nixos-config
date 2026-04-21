{ pkgs, ... }:

let
  libraryPath = "/var/lib/calibre-web/library";
in
{
  # Calibre-Web includes jsonschema as an optional "kobo" extra,
  # but the NixOS module doesn't include it. We override the package
  # to add it so the Kobo sync API endpoints are available.
  services.calibre-web = {
    enable = true;
    package = pkgs.calibre-web.overridePythonAttrs (old: {
      dependencies = old.dependencies ++ pkgs.calibre-web.optional-dependencies.kobo;
    });
    listen.ip = "127.0.0.1";
    options = {
      calibreLibrary = libraryPath;
      enableBookConversion = true;
      enableKepubify = true;
      enableBookUploading = true;
    };
  };

  # The calibre-web module's ExecStartPre asserts that metadata.db exists
  # in the library path and fails if it's missing. This oneshot service
  # initializes an empty library on first boot so calibre-web can start.
  systemd.services.calibre-library-init = {
    description = "Initialize Calibre library if it doesn't exist";
    wantedBy = [ "multi-user.target" ];
    before = [ "calibre-web.service" ];
    environment.QT_QPA_PLATFORM = "offscreen";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "calibre-web";
      Group = "calibre-web";
      StateDirectory = "calibre-web";
      ExecStart = pkgs.writeShellScript "calibre-library-init" ''
        set -e
        if [ ! -f "${libraryPath}/metadata.db" ]; then
          mkdir -p "${libraryPath}"
          ${pkgs.calibre}/bin/calibredb --library-path="${libraryPath}" add -e
        fi
      '';
    };
  };

  services.nginx.virtualHosts."calibre.nicficca.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8083";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Script-Name "";
        client_max_body_size 200M;
      '';
    };
  };
}
