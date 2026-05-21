{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myModules.networkmanager;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  options.myModules.networkmanager.applet.enable = lib.mkEnableOption "nm-applet GTK indicator as a systemd user service";

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.applet.enable || isLinux;
          message = "myModules.networkmanager.applet.enable is set on a non-Linux platform. The nm-applet module is Linux-only.";
        }
      ];
    }

    (lib.mkIf (cfg.applet.enable && isLinux) {
      home.packages = [ pkgs.networkmanagerapplet ];

      systemd.user.services.nm-applet = {
        Unit = {
          Description = "NetworkManager Applet";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
          Restart = "on-failure";
          Environment = "PATH=${pkgs.networkmanagerapplet}/bin";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    })
  ];
}
