{
  username,
  pkgs,
  ...
}:

{
  imports = [ ];

  users.users."${username}" = {
    home = "/Users/nic";
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;

  myModules.fonts.enable = true;
  myModules.system-packages.enable = true;

  # Casks are contributed by individual myModules.<name> darwin modules.
  homebrew = {
    enable = true;
    user = username;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # TODO: Set Git commit hash for darwin-version.
  system.configurationRevision = null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
