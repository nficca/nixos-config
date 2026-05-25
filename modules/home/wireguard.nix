{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myModules.wireguard.enable = lib.mkEnableOption "wireguard-tools (wg, wg-quick) in user PATH";

  config = lib.mkIf config.myModules.wireguard.enable {
    home.packages = [ pkgs.wireguard-tools ];
  };
}
