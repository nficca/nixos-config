{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkMerge;
  inherit (pkgs.stdenv) isDarwin isLinux;
in
{
  options.myPrograms.steam.enable = mkEnableOption "Steam";

  config = mkIf config.myPrograms.spotify.enable (mkMerge [
    (mkIf isLinux { 
      # Steam needs to be installed as a system-level program because
      # it requires extra priviledges to open firewall ports.
      programs.steam = {
        enable = true;
        # Open ports in the firewall for Steam Remote Play
        remotePlay.openFirewall = true;
        # Open ports in the firewall for Source Dedicated Server
        dedicatedServer.openFirewall = true;
        # Open ports in the firewall for Steam Local Network Game Transfers
        localNetworkGameTransfers.openFirewall = true;
      };
    })
    (mkIf isDarwin { homebrew.casks = [ "steam" ]; })
  ]);
}
