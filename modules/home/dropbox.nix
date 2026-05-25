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
  options.myModules.dropbox.enable = lib.mkEnableOption "Dropbox client with autostart via systemd user service (Linux only; on Darwin enable myModules.dropbox.enable at the system layer instead for the homebrew cask)";

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.enable || isLinux;
          message = "myModules.dropbox.enable on home-manager is Linux-only. On Darwin, enable myModules.dropbox.enable at the system layer instead (homebrew cask).";
        }
      ];
    }

    (lib.mkIf (cfg.enable && isLinux) {
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
  ];
}
