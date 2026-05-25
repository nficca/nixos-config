{
  config,
  lib,
  ...
}:

{
  options.myModules.spotify.enable = lib.mkEnableOption "Spotify desktop client via homebrew cask";

  config = lib.mkIf config.myModules.spotify.enable {
    homebrew.casks = [ "spotify" ];
  };
}
