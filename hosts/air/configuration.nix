{ username, ... }:

{
  imports = [
    ../../shared/configuration/darwin.nix
  ];

  homebrew = {
    enable = true;
    user = username;
    casks = [
      "1password" # Password manager
      "affinity-designer" # Professional graphic design software
      "discord" # Group chat and VoIP application
      "folx" # Download manager and torrent client
      "ghostty" # Platform-native terminal emulator
      "google-chrome" # Web browser
      "mullvad-vpn" # Privacy-focused VPN
      "slack" # Team communication
      "steam" # Video game distribution platform
      "visual-studio-code" # Open-source code editor
      "whatsapp" # Messaging and calling
    ];
  };
}
