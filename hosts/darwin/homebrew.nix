# This module is intended to configure homebrew on nix-darwin systems.
#
# See the relevant options:
# https://nix-darwin.github.io/nix-darwin/manual/index.html#opt-homebrew.enable
#
# *IMPORTANT*: Before deciding to install a pacakge or program via homebrew,
# please first check if the same package is available in nixpkgs. Homebrew is
# meant primarly to serve as a backup for packages that are either not available
# in nixpkgs or are broken, which is not uncommon espcially for GUI macOS apps.
#
# It should be noted that this module should be included as a nix-darwin module.
# While configuring homebrew is its intended purpose, it is effectively a normal
# nix-darwin module and can configure any nix-darwin options.

{ common, ... }:

{
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
