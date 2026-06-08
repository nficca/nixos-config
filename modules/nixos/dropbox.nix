{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  options.myModules.dropbox.enable = lib.mkEnableOption "Dropbox client: nixpkgs package with a systemd user service, plus LAN sync firewall ports";

  config = lib.mkIf config.myModules.dropbox.enable {
    # Dropbox listens on TCP/UDP 17500 to discover other clients on the local
    # network and bypass cloud round-tripping for same-LAN sync.
    networking.firewall.allowedTCPPorts = [ 17500 ];
    networking.firewall.allowedUDPPorts = [ 17500 ];

    home-manager.users.${username} = {
      home.packages = [ pkgs.dropbox ];

      systemd.user.services.dropbox = {
        Unit.Description = "Dropbox";
        Service = {
          ExecStart = "${pkgs.dropbox}/bin/dropbox";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "default.target" ];
      };
    };
  };
}
