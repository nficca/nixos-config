{
  config,
  lib,
  ...
}:

{
  options.myModules.ghostty.enable = lib.mkEnableOption "Ghostty terminal emulator via homebrew cask (the home-manager myModules.ghostty.enable manages config files)";

  # The home-manager ghostty module ships dotfiles for both Linux and Darwin,
  # but on Darwin the application itself comes from the homebrew cask because
  # nixpkgs GUI apps don't integrate with Launchpad, Dock, and Spotlight.
  config = lib.mkIf config.myModules.ghostty.enable {
    homebrew.casks = [ "ghostty" ];
  };
}
