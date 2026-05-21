{
  config,
  lib,
  ...
}:

{
  options.myModules.steam.enable = lib.mkEnableOption "Steam with firewall openings for Remote Play, dedicated servers, and local-network game transfers";

  # Steam needs system-level configuration (udev rules, kernel modules,
  # firewall) that home-manager can't apply, so it ships at the system layer
  # rather than as a home package.
  config = lib.mkIf config.myModules.steam.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };
}
