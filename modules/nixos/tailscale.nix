{
  config,
  lib,
  ...
}:

{
  options.myModules.tailscale.enable = lib.mkEnableOption "Tailscale mesh VPN with the tailnet interface trusted by the firewall";

  config = lib.mkIf config.myModules.tailscale.enable {
    services.tailscale = {
      enable = true;
      # Opens UDP 41641 so peers can reach this node directly instead of
      # falling back to a DERP relay.
      openFirewall = true;
    };

    # Gate tailnet access at the firewall rather than binding services to the
    # tailnet address: an address bind races the interface coming up at boot,
    # a firewall rule does not. This trusts every port on the interface, not
    # just SSH, which is the usual Tailscale trust model.
    networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];
  };
}
