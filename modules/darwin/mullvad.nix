{
  config,
  lib,
  ...
}:

{
  options.myModules.mullvad.enable = lib.mkEnableOption "Mullvad VPN via homebrew cask";

  config = lib.mkIf config.myModules.mullvad.enable {
    homebrew.casks = [ "mullvad-vpn" ];
  };
}
