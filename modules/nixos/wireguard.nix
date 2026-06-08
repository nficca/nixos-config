{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  options.myModules.wireguard.enable = lib.mkEnableOption "WireGuard kernel support plus wireguard-tools (wg, wg-quick) in user PATH";

  config = lib.mkIf config.myModules.wireguard.enable {
    networking.wireguard.enable = true;

    home-manager.users.${username} = {
      home.packages = [ pkgs.wireguard-tools ];
    };
  };
}
