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

  home.username = username;

  home.packages = with pkgs; [
    # Modern helper utility for nix commands.
    # See: https://github.com/nix-community/nh
    nh

    _1password-cli # CLI for 1Password
    xh # Tool for sending HTTP requests
    jless # JSON viewer
    lazygit # Terminal UI for git commands
    maestral # Dropbox client
    cmake # Cross-platform build system generator
    claude-code # Terminal-based LLM agent
    libclang # C language tools
    jq # Flexible CLI JSON processor

    ## Common language support packages ##
    vscode-langservers-extracted
    lua-language-server
    nil
    nixfmt-rfc-style
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # ZSH
  programs.zsh.enable = true;
  programs.zsh.history.size = 25000;
  programs.zsh.history.expireDuplicatesFirst = true;
  programs.zsh.history.ignoreAllDups = true;
  programs.zsh.autosuggestion.enable = true;

  # When using Homebrew, ensure binaries at at the end of the PATH so that
  # nixpkgs binaries take precedence.
  #
  # If we have a package from both sources, we probably want to use the nixpkgs
  # copy. Ideally we uninstall the one we don't want, but in the case of
  # Homebrew, if said package is installed as a dependency of another formula
  # (one that _do_ want to keep), then it can't be removed.
  #
  # This is safe to add even if Homebrew is not installed (e.g. on Linux hosts).
  programs.zsh.initContent = ''
    # Remove Homebrew from PATH and re-add it to the end. This ensures that, if
    # Homebrew is installed, its binaries are available but do not override the
    # binaries provided by nixpkgs.
    export PATH="$(echo "$PATH" | tr ':' '\n' | grep -v '^/opt/homebrew/bin$' | grep -v '^/opt/homebrew/sbin$' | paste -sd ':' -)"
    export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"
  '';

  programs.zsh.plugins = [
    # Use vi features in zsh
    {
      name = "vi-mode";
      src = pkgs.zsh-vi-mode;
      file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
    }
  ];

  # Starship
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;

  # FZF
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;

  # Ripgrep
  programs.ripgrep.enable = true;

  # Zoxide
  programs.zoxide.enable = true;
  programs.zoxide.enableZshIntegration = true;

  # Git
  programs.git.enable = true;
  programs.git.lfs.enable = true;
  programs.git.settings.user.email = "nicficca@gmail.com";
  programs.git.settings.user.name = "Nic Ficca";
  programs.git.settings.init.defaultBranch = "main";

  # Delta
  programs.delta.enable = true;
  programs.delta.enableGitIntegration = true;

  # Github CLI
  programs.gh.enable = true;

  # Neovim
  programs.neovim.enable = true;

  # Direnv
  programs.direnv.enable = true;
}
