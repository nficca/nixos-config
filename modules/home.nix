# This module defines user-level configurations via home-manager.
# **IMPORTANT**: This module is intended to configure BOTH NixOS and macOS (Darwin).
# Any attributes defined here should be compatible with both systems.

{ ... }:
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # ZSH
  programs.zsh.enable = true;
  programs.zsh.autosuggestion.enable = true;

  # Starship
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;

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
}
