# This is a shared module intended to contain home-manager configuration
# that is common between BOTH NixOS and nix-darwin systems.
#
# All of the configuration in this module should be compatible with NixOS
# and nix-darwin (macOS) systems. As such, it is recommended that the
# configurations here are kept minimal so as not to introduce cross-platform
# incompatibilities.

{ pkgs, ... }:

{
  imports = [
    ./aliases
    ./dotfiles
    ./registry
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    lazygit # Terminal UI for git commands
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # ZSH
  programs.zsh.enable = true;
  programs.zsh.history.size = 25000;
  programs.zsh.history.expireDuplicatesFirst = true;
  programs.zsh.history.ignoreAllDups = true;
  programs.zsh.autosuggestion.enable = true;

  # Starship
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;

  # FZF
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;

  # Git
  programs.git.enable = true;
  programs.git.userEmail = "nicficca@gmail.com";
  programs.git.userName = "Nic Ficca";
  programs.git.extraConfig.init.defaultBranch = "main";
  programs.git.delta.enable = true;

  # Github CLI
  programs.gh.enable = true;

  # Neovim
  programs.neovim.enable = true;

  # Direnv
  programs.direnv.enable = true;
}
