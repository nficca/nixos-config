{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  cfg = config.myModules.networkmanager;
in
{
  options.myModules.networkmanager = {
    enable = lib.mkEnableOption "NetworkManager networking daemon";
    applet.enable = lib.mkEnableOption "nm-applet GTK indicator as a systemd user service (requires graphical session)";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      networking.networkmanager.enable = true;
    })

    (lib.mkIf cfg.applet.enable {
      home-manager.users.${username} = {
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
      };
    })
  ];
}
