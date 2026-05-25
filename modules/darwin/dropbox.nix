{
  config,
  lib,
  ...
}:

{
  options.myModules.dropbox.enable = lib.mkEnableOption "Dropbox client via homebrew cask";

  config = lib.mkIf config.myModules.dropbox.enable {
    homebrew.casks = [ "dropbox" ];
  };
}
