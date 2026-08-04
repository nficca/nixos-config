{
  config,
  lib,
  ...
}:

{
  options.myModules.tailscale.enable = lib.mkEnableOption "Tailscale mesh VPN menu bar app via homebrew cask";

  config = lib.mkIf config.myModules.tailscale.enable {
    # The `tailscale` token is the CLI-only formula; the macOS app is the
    # `tailscale-app` cask.
    homebrew.casks = [ "tailscale-app" ];
  };
}
