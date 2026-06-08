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

  myModules = {
    _1password.enable = true;
    dropbox.enable = true;
    firefox.enable = true;
    fonts.enable = true;
    ghostty.enable = true;
    notion.enable = true;
    system-packages.enable = true;
    whatsapp.enable = true;
  };

  # TODO: Set Git commit hash for darwin-version.
  system.configurationRevision = null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
