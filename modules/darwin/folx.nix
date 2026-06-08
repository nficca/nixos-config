{
  config,
  lib,
  ...
}:

{
  options.myModules.folx.enable = lib.mkEnableOption "Folx download manager and torrent client via homebrew cask";

  config = lib.mkIf config.myModules.folx.enable {
    homebrew.casks = [ "folx" ];
  };
}
