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
      "firefox" # Web browser
      "slack" # Team communication
      "ghostty" # Platform-native terminal emulator
      "whatsapp" # Messaging and calling
      "notion" # Note-taking and organization tool
    ];
  };
}
