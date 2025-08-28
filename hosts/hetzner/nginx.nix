{ ... }:

{
  services.nginx = {
    enable = true;
    virtualHosts."nicficca.com" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/public";
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    # Accept the CA’s terms of service. The default provider is Let’s Encrypt, you can find their ToS at https://letsencrypt.org/repository/.
    acceptTerms = true;
    # Optional: You can configure the email address used with Let's Encrypt.
    # This way you get renewal reminders (automated by NixOS) as well as expiration emails.
    defaults.email = "nicficca@gmail.com";
  };
}
