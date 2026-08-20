{ config, ... }:

let
  planner = "http://127.0.0.1:${toString config.services.tiff-planner.port}";
in

{
  services.nginx = {
    enable = true;

    # A proxied request otherwise arrives with none of the original host,
    # scheme, or client address on it.
    recommendedProxySettings = true;

    # Keyed on the caller's address, which only nginx knows: behind a proxy the
    # app sees loopback. Rates sit well above human use, since one htmx click
    # fans out into several requests. `nodelay` serves a burst as it arrives.
    #
    # An empty key skips a limit, so the sign-in zone is keyed on one that goes
    # empty for reads. Only a submission sends mail.
    commonHttpConfig = ''
      map $request_method $tiff_login_key {
        default $binary_remote_addr;
        GET     "";
        HEAD    "";
      }

      limit_req_zone $binary_remote_addr zone=tiff_general:1m rate=120r/m;
      limit_req_zone $binary_remote_addr zone=tiff_cost:1m rate=60r/m;
      limit_req_zone $binary_remote_addr zone=tiff_solve:1m rate=20r/m;
      limit_req_zone $binary_remote_addr zone=tiff_accounts:1m rate=20r/m;
      limit_req_zone $tiff_login_key zone=tiff_login:1m rate=5r/m;
      limit_req_status 429;
    '';

    virtualHosts."nicficca.com" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/public";
    };

    virtualHosts."tiff.nicficca.com" = {
      enableACME = true;

      # The session cookie is Secure, so a browser served over plain HTTP drops
      # it and nobody stays signed in.
      forceSSL = true;

      extraConfig = ''
        limit_req zone=tiff_general burst=60 nodelay;
      '';

      locations."/".proxyPass = planner;

      # Minting a user and a plan for a caller with no cookie.
      locations."= /plans" = {
        proxyPass = planner;
        extraConfig = ''
          limit_req zone=tiff_accounts burst=10 nodelay;
        '';
      };

      # A solve is one button press. The id is matched loosely because the app
      # parses more than digits as a number.
      locations."~ ^/plans/[^/]+/solve$" = {
        proxyPass = planner;
        extraConfig = ''
          limit_req zone=tiff_solve burst=10 nodelay;
        '';
      };

      # Opening one film's other screenings fires a cost for each at once, up
      # to five in the 2026 schedule.
      locations."~ ^/plans/[^/]+/screenings/[^/]+/cost$" = {
        proxyPass = planner;
        extraConfig = ''
          limit_req zone=tiff_cost burst=30 nodelay;
        '';
      };

      # Sending a link spends the mail allowance. Naming a zone here stops the
      # server-level one applying, so general is repeated to bound form loads.
      locations."= /login" = {
        proxyPass = planner;
        extraConfig = ''
          limit_req zone=tiff_general burst=60 nodelay;
          limit_req zone=tiff_login burst=3 nodelay;
        '';
      };
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
