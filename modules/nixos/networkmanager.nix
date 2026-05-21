{
  config,
  lib,
  username,
  ...
}:

let
  cfg = config.myModules.networkmanager;
in
{
  options.myModules.networkmanager = {
    enable = lib.mkEnableOption "NetworkManager networking daemon";
    applet.enable = lib.mkEnableOption "nm-applet GTK indicator as a home-manager systemd user service (requires graphical session)";
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;

    # Fan out to the home-manager side so the applet toggle drives both layers.
    home-manager.users.${username}.myModules.networkmanager.applet.enable = cfg.applet.enable;
  };
}
