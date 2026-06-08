{
  username,
  pkgs,
  ...
}:

{
  users.users."${username}" = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.settings.experimental-features = "nix-command flakes";

  # Casks are contributed by individual myModules.<name> darwin modules.
  homebrew = {
    enable = true;
    user = username;
  };

  home-manager.users.${username} = {
    home.stateVersion = "25.05";
    home.username = username;
    programs.home-manager.enable = true;
  };

  myModules = {
    _1password.cli.enable = true;
    _1password.app.enable = true;
    claude-code.enable = true;
    dev-tools.enable = true;
    direnv.enable = true;
    dropbox.enable = true;
    firefox.enable = true;
    fonts.enable = true;
    ghostty.enable = true;
    git.enable = true;
    kubernetes.enable = true;
    neovim.enable = true;
    notion.enable = true;
    shell.enable = true;
    starship.enable = true;
    system-packages.enable = true;
    tmux.enable = true;
    user-packages.enable = true;
    whatsapp.enable = true;
  };

  # TODO: Set Git commit hash for darwin-version.
  system.configurationRevision = null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
