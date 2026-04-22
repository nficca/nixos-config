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
    # Only listen locally; nginx handles TLS and external traffic.
    listen.ip = "127.0.0.1";
    options = {
      calibreLibrary = libraryPath;
      enableBookConversion = true;
      enableKepubify = true;
      enableBookUploading = true;
    };
  };

  # The NixOS module writes config_port (8083) to the database on every start,
  # but doesn't touch config_external_port. Without this, calibre-web appends
  # :8083 to all generated URLs (Kobo sync downloads, image URLs, etc.),
  # which the Kobo can't reach since nginx serves on 443.
  # This field isn't exposed in calibre-web's UI; sqlite is the only way.
  # https://github.com/janeczku/calibre-web/issues/1891
  systemd.services.calibre-web.serviceConfig.ExecStartPre =
    let
      appDb = "/var/lib/calibre-web/app.db";
    in
    pkgs.lib.mkAfter [
      (pkgs.writeShellScript "calibre-web-set-external-port" ''
        ${pkgs.sqlite}/bin/sqlite3 ${appDb} "UPDATE settings SET config_external_port = 443"
      '')
    ];

  # The calibre-web module's ExecStartPre asserts that metadata.db exists
  # in the library path and fails if it's missing. This oneshot service
  # initializes an empty library on first boot so calibre-web can start.
  systemd.services.calibre-library-init = {
    description = "Initialize Calibre library if it doesn't exist";
    wantedBy = [ "multi-user.target" ];
    before = [ "calibre-web.service" ];
    # Calibre's CLI tools link against Qt, which tries to connect to a
    # display server on startup. This tells Qt there's no screen.
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
      # These settings follow the calibre-web reverse proxy docs:
      # https://github.com/janeczku/calibre-web/wiki/Setup-Reverse-Proxy
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # Calibre-web reads X-Scheme (not X-Forwarded-Proto) to decide
        # whether to generate https:// or http:// download URLs.
        proxy_set_header X-Scheme $scheme;

        # The Kobo sync response includes the full Kobo store API config
        # and exceeds nginx's default 4k/8k header buffer, causing
        # "upstream sent too big header" errors without larger buffers.
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;

        client_max_body_size 200M;
      '';
    };
  };
}
