{
  config,
  pkgs,
  lib,
  username,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkMerge;
  inherit (pkgs.stdenv) isDarwin isLinux;
in
{
  options.myPrograms.spotify.enable = mkEnableOption "Spotify";

  config = mkIf config.myPrograms.spotify.enable (mkMerge [
    (mkIf isDarwin { homebrew.casks = [ "spotify" ]; })
    (mkIf isLinux { home-manager.users.${username}.home.packages = [ pkgs.spotify ]; })
  ]);
}
