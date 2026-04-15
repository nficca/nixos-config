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
      "whatsapp" # Messaging and calling
      "notion" # Note-taking and organization tool
    ];
  };
}
