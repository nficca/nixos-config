{
  config,
  lib,
  username,
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
      let
        dotfiles = "${config.home.homeDirectory}/dev/nficca/nixos-config/dotfiles/ghostty";
      in
      {
        xdg.configFile."ghostty/config".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config";
        xdg.configFile."ghostty/darwin".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfiles}/darwin";
      };
  };
}
