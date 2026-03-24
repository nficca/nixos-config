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
    claude-code # Agentic coding tool for the terminal
    cmake # Cross-platform build system generator
    jless # JSON viewer
    jq # Flexible CLI JSON processor
    lazygit # Terminal UI for git commands
    opencode # Open-source agentic coding tool for the terminal
    tree # Depth-indented directory listing
    xh # Tool for sending HTTP requests

    ## Common language support packages ##
    clang-tools
    cmake-language-server
    kdePackages.qtdeclarative
    lua-language-server
    nil
    nixfmt
    nodePackages.prettier
    typescript-language-server
    valgrind
    vscode-langservers-extracted
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # ZSH
  programs.zsh.enable = true;
  programs.zsh.history.size = 25000;
  programs.zsh.history.expireDuplicatesFirst = true;
  programs.zsh.history.ignoreAllDups = true;
  programs.zsh.autosuggestion.enable = true;

  programs.zsh.initContent = ''
    # Remove Homebrew from PATH and re-add it to the end. This ensures that, if
    # Homebrew is installed, its binaries are available but do not override the
    # binaries provided by nixpkgs.
    export PATH="$(echo "$PATH" | tr ':' '\n' | grep -v '^/opt/homebrew/bin$' | grep -v '^/opt/homebrew/sbin$' | paste -sd ':' -)"
    export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"

    # nix develop sets $SHELL to bash even when any-nix-shell spawns zsh.
    # Override it so that programs like nvim and tmux use the correct shell.
    export SHELL="$(command -v zsh)"

    # any-nix-shell creates wrapper functions around `nix` and `nix-shell` so
    # that commands like `nix-shell` and `nix develop` will use zsh instead of
    # bash.
    ${pkgs.any-nix-shell}/bin/any-nix-shell zsh | source /dev/stdin
  '';

  # Starship
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;

  # FZF
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;

  # tmux
  programs.tmux.enable = true;
  programs.tmux.terminal = "xterm-256color";

  # Ripgrep
  programs.ripgrep.enable = true;

  # Zoxide
  programs.zoxide.enable = true;
  programs.zoxide.enableZshIntegration = true;

  # Git
  programs.git.enable = true;
  programs.git.lfs.enable = true;
  programs.git.ignores = [
    "/.worktrees"
    "**/.claude/settings.local.json"
  ];
  programs.git.settings.user.email = "nicficca@gmail.com";
  programs.git.settings.user.name = "Nic Ficca";
  programs.git.settings.init.defaultBranch = "main";
  programs.git.includes = [ { path = "~/.config/git/themes.gitconfig"; } ];

  # Delta
  programs.delta.enable = true;
  programs.delta.enableGitIntegration = true;
  programs.delta.options = {
    # All features are defined in ~/.config/git/themes.gitconfig, which should
    # be symlinked from share/home/dotfiles/git/themes.gitconfig.
    features = "weeping-willow";
  };

  # Bat
  programs.bat.enable = true;
  programs.bat.config = {
    # bat --list-themes for other options
    theme = "Coldark-Dark";
  };

  # Github CLI
  programs.gh.enable = true;

  # Neovim
  programs.neovim.enable = true;

  # Direnv
  programs.direnv.enable = true;
}
