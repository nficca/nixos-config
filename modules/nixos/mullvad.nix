{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myModules.mullvad.enable = lib.mkEnableOption "Mullvad VPN daemon and GUI";

  config = lib.mkIf config.myModules.mullvad.enable {
    services.mullvad-vpn.enable = true;
    services.mullvad-vpn.package = pkgs.mullvad-vpn;
  };
}
