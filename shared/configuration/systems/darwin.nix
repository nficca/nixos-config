{ common, ... }:

{
  # This appears to be necessary to get home-manager to work properly on
  # nix-darwin. On NixOS, we add the home directory in the home-manager
  # module via `home.homeDirectory`, but this will fail the rebuild on
  # Darwin.
  users.users.${common.username}.home = "/Users/nic";

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

  # *IMPORTANT*: Before deciding to install a pacakge or program via homebrew,
  # please first check if the same package is available in nixpkgs. Homebrew is
  # meant primarly to serve as a backup for packages that are either not available
  # in nixpkgs or are broken, which is not uncommon espcially for GUI macOS apps.
  #
  # It should be noted that this module should be included as a nix-darwin module.
  # While configuring homebrew is its intended purpose, it is effectively a normal
  # nix-darwin module and can configure any nix-darwin options
  #
  # See more:
  # https://nix-darwin.github.io/nix-darwin/manual/index.html#opt-homebrew.enable
  homebrew = {
    enable = true;
    user = common.username;
    casks = [
      "google-chrome" # Web browser
      "discord" # Group chat and VoIP application
      "1password" # Password manager
      "folx" # Download manager and torrent client
      "slack" # Team communication
      "steam" # Video game distribution platform
      "ghostty" # Platform-native terminal emulator
      "visual-studio-code" # Open-source code editor
      "notion" # Note-taking and organization tool
      "whatsapp" # Messaging and calling
    ];
  };
}
