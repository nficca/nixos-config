{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myModules.shell.enable = lib.mkEnableOption "interactive shell environment: zsh, fzf, zoxide, bat, and any-nix-shell";

  config = lib.mkIf config.myModules.shell.enable {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      history = {
        size = 25000;
        expireDuplicatesFirst = true;
        ignoreAllDups = true;
      };

      initContent = ''
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
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.bat = {
      enable = true;
      # bat --list-themes for other options.
      config.theme = "Coldark-Dark";
    };
  };
}
