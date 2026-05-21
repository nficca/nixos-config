{
  config,
  lib,
  ...
}:

{
  options.myModules.printing.enable = lib.mkEnableOption "CUPS printing daemon plus Avahi/mDNS for network printer discovery";

  config = lib.mkIf config.myModules.printing.enable {
    services.printing.enable = true;

    # Avahi/mDNS is enabled here primarily so CUPS can discover IPP printers
    # advertised on the local network. Useful generally for any zeroconf
    # service discovery, but the printing flow is the main consumer.
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      openFirewall = true;
    };
  };
}
