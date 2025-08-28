{
  username,
  pkgs,
  ...
}:

{
  imports = [ ];

  users.users."${username}".shell = pkgs.zsh;
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;

  environment.variables = {
    EDITOR = "vim";
  };

  environment.systemPackages = with pkgs; [
    dua # Disk usage analyzer
    git # Version control system
    vim # Text editor
    wget # Network file downloader
  ];

  fonts.packages = with pkgs; [
    jetbrains-mono
  ];

  # This appears to be necessary to get home-manager to work properly on
  # nix-darwin. On NixOS, we add the home directory in the home-manager
  # module via `home.homeDirectory`, but this will fail the rebuild on
  # Darwin.
  users.users.${username}.home = "/Users/nic";

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
