{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myModules.dropbox;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  options.myModules.dropbox.enable = lib.mkEnableOption "Cloud sync: native Dropbox with systemd autostart on Linux, Maestral on Darwin";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf isLinux {
      home.packages = [ pkgs.dropbox ];

      systemd.user.services.dropbox = {
        Unit.Description = "Dropbox";
        Service = {
          ExecStart = "${pkgs.dropbox}/bin/dropbox";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "default.target" ];
      };
    })

    (lib.mkIf (!isLinux) {
      home.packages = [ pkgs.maestral ];
    })
  ]);
}
