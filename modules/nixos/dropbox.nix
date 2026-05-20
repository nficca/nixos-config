{
  config,
  lib,
  ...
}:

{
  options.myModules.dropbox.enable = lib.mkEnableOption "Dropbox LAN sync firewall ports";

  # Dropbox listens on TCP/UDP 17500 to discover other clients on the local
  # network and bypass cloud round-tripping for same-LAN sync.
  config = lib.mkIf config.myModules.dropbox.enable {
    networking.firewall.allowedTCPPorts = [ 17500 ];
    networking.firewall.allowedUDPPorts = [ 17500 ];
  };
}
