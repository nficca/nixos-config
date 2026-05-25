{
  config,
  lib,
  username,
  ...
}:

{
  options.myModules.wireguard.enable = lib.mkEnableOption "WireGuard kernel support and wireguard-tools CLI";

  config = lib.mkIf config.myModules.wireguard.enable {
    networking.wireguard.enable = true;

    # Fan out to home-manager so the wg/wg-quick CLIs land in user PATH.
    home-manager.users.${username}.myModules.wireguard.enable = true;
  };
}
