{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  cfg = config.myModules.podman;
in
{
  options.myModules.podman = {
    enable = lib.mkEnableOption "podman container runtime as a drop-in for docker";
    compose.enable = lib.mkEnableOption "podman-compose CLI (docker-compose-equivalent on top of podman)";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;

        # Required for containers under podman-compose to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };

      users.users.${username}.extraGroups = [ "podman" ];
    })

    (lib.mkIf cfg.compose.enable {
      environment.systemPackages = [ pkgs.podman-compose ];
    })
  ];
}
