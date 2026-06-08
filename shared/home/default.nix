# This is a shared module intended to contain home-manager configuration
# that is common between BOTH NixOS and nix-darwin systems.
#
# All of the configuration in this module should be compatible with NixOS
# and nix-darwin (macOS) systems. As such, it is recommended that the
# configurations here are kept minimal so as not to introduce cross-platform
# incompatibilities.

{ username, ... }:

{
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";

  home.username = username;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  myModules._1password.enable = true;
  myModules.claude-code.enable = true;
  myModules.dev-tools.enable = true;
  myModules.direnv.enable = true;
  myModules.git.enable = true;
  myModules.neovim.enable = true;
  myModules.shell.enable = true;
  myModules.starship.enable = true;
  myModules.tmux.enable = true;
  myModules.user-packages.enable = true;
}
