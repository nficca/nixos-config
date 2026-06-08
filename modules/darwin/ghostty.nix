{
  config,
  lib,
  username,
  mkRepoSymlink,
  ...
}:

{
  options.myModules.ghostty.enable = lib.mkEnableOption "Ghostty terminal emulator via homebrew cask with user config";

  # On Darwin, ghostty is installed via homebrew cask because nixpkgs GUI
  # apps don't integrate with Launchpad, Dock, and Spotlight.
  config = lib.mkIf config.myModules.ghostty.enable {
    homebrew.casks = [ "ghostty" ];

    home-manager.users.${username} =
      { config, ... }:
      {
        xdg.configFile."ghostty/config".source =
          mkRepoSymlink config "dotfiles/ghostty/config";
        xdg.configFile."ghostty/darwin".source =
          mkRepoSymlink config "dotfiles/ghostty/darwin";
      };
  };
}
