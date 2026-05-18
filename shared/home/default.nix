# This is a shared module intended to contain home-manager configuration
# that is common between BOTH NixOS and nix-darwin systems.
#
# All of the configuration in this module should be compatible with NixOS
# and nix-darwin (macOS) systems. As such, it is recommended that the
# configurations here are kept minimal so as not to introduce cross-platform
# incompatibilities.

{ username, pkgs, ... }:

{
  imports = [
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

  home.username = username;

  home.packages = with pkgs; [
    # Modern helper utility for nix commands.
    # See: https://github.com/nix-community/nh
    nh

    _1password-cli # CLI for 1Password
    cmake # Cross-platform build system generator
    jless # JSON viewer
    jq # Flexible CLI JSON processor
    lazygit # Terminal UI for git commands
    pv # Pipeline progress monitoring
    tree # Depth-indented directory listing
    xh # Tool for sending HTTP requests

    ## Common language support packages ##
    clang-tools
    cmake-language-server
    kdePackages.qtdeclarative
    lua-language-server
    nil
    nixfmt
    prettier
    ruby-lsp
    typescript-language-server
    valgrind
    vscode-langservers-extracted
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # tmux
  programs.tmux.enable = true;
  programs.tmux.terminal = "xterm-256color";

  # Ripgrep
  programs.ripgrep.enable = true;

  myModules.claude-code.enable = true;
  myModules.direnv.enable = true;
  myModules.git.enable = true;
  myModules.neovim.enable = true;
  myModules.shell.enable = true;
  myModules.starship.enable = true;
}
