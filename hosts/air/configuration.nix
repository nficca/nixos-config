{ username, ... }:

{
  imports = [
    ../../shared/configuration/darwin.nix
  ];

  myModules._1password.enable = true;

  homebrew = {
    enable = true;
    user = username;
    casks = [
      "affinity-designer" # Professional graphic design software
      "discord" # Group chat and VoIP application
      "firefox" # Web browser
      "folx" # Download manager and torrent client
      "ghostty" # Platform-native terminal emulator
      "mullvad-vpn" # Privacy-focused VPN
      "steam" # Video game distribution platform
      "whatsapp" # Messaging and calling
    ];
  };
}
