{
  config,
  lib,
  ...
}:

{
  options.myModules.discord.enable = lib.mkEnableOption "Discord desktop client via homebrew cask";

  config = lib.mkIf config.myModules.discord.enable {
    homebrew.casks = [ "discord" ];
  };
}
