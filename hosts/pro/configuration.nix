{ username, ... }:

{
  imports = [
    ../../shared/configuration/darwin.nix
  ];

  myModules._1password.enable = true;
  myModules.dropbox.enable = true;
  myModules.firefox.enable = true;

  homebrew = {
    enable = true;
    user = username;
    casks = [
      "ghostty" # Platform-native terminal emulator
      "whatsapp" # Messaging and calling
      "notion" # Note-taking and organization tool
    ];
  };
}
