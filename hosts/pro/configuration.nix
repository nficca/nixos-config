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
      "firefox" # Web browser
      "ghostty" # Platform-native terminal emulator
      "whatsapp" # Messaging and calling
      "notion" # Note-taking and organization tool
    ];
  };
}
