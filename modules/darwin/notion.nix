{
  config,
  lib,
  ...
}:

{
  options.myModules.notion.enable = lib.mkEnableOption "Notion note-taking and organization client via homebrew cask";

  config = lib.mkIf config.myModules.notion.enable {
    homebrew.casks = [ "notion" ];
  };
}
