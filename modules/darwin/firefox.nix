{
  config,
  lib,
  ...
}:

{
  options.myModules.firefox.enable = lib.mkEnableOption "Firefox browser via homebrew cask";

  config = lib.mkIf config.myModules.firefox.enable {
    homebrew.casks = [ "firefox" ];
  };
}
