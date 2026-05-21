{
  config,
  lib,
  ...
}:

{
  options.myModules.steam.enable = lib.mkEnableOption "Steam via homebrew cask";

  config = lib.mkIf config.myModules.steam.enable {
    homebrew.casks = [ "steam" ];
  };
}
