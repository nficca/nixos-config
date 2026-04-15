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
      "firefox" # Web browser
      "folx" # Download manager and torrent client
      "ghostty" # Platform-native terminal emulator
      "mullvad-vpn" # Privacy-focused VPN
      "slack" # Team communication
      "steam" # Video game distribution platform
      "whatsapp" # Messaging and calling
    ];
  };
}
