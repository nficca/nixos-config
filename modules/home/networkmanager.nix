{
  config,
  lib,
  options,
  pkgs,
  ...
}:

let
  cfg = config.myModules.networkmanager;
  available = options ? systemd.user.services;
in
{
  options.myModules.networkmanager.applet.enable = lib.mkEnableOption "nm-applet GTK indicator as a systemd user service";

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.applet.enable || available;
          message = "myModules.networkmanager.applet.enable is set, but home-manager systemd.user.services is not in scope on this platform. The nm-applet module is Linux-only.";
        }
      ];
    }

    (lib.mkIf cfg.applet.enable (lib.optionalAttrs available {
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
    }))
  ];
}
