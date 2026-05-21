{ username, ... }:

{
  imports = [
    ../../shared/configuration/darwin.nix
  ];

  myModules._1password.enable = true;
  myModules.firefox.enable = true;
  myModules.mullvad.enable = true;

  homebrew = {
    enable = true;
    user = username;
    casks = [
      "affinity-designer" # Professional graphic design software
      "discord" # Group chat and VoIP application
      "folx" # Download manager and torrent client
      "ghostty" # Platform-native terminal emulator
      "steam" # Video game distribution platform
      "whatsapp" # Messaging and calling
    ];
  };
}
