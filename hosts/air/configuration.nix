{ username, ... }:

{
  imports = [
    ../../shared/configuration/darwin.nix
  ];

  homebrew = {
    enable = true;
    user = username;
    casks = [
      "google-chrome" # Web browser
      "1password" # Password manager
      "slack" # Team communication
      "ghostty" # Platform-native terminal emulator
      "visual-studio-code" # Open-source code editor
      "whatsapp" # Messaging and calling
      "discord" # Group chat and VoIP application
      "folx" # Download manager and torrent client
      "steam" # Video game distribution platform
    ];
  };
}
