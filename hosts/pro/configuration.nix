{ username, ... }:

{
  imports = [
    ../../shared/configuration/darwin.nix
  ];

  myModules._1password.enable = true;
  myModules.dropbox.enable = true;
  myModules.firefox.enable = true;
  myModules.ghostty.enable = true;
  myModules.whatsapp.enable = true;

  homebrew = {
    enable = true;
    user = username;
    casks = [
      "notion" # Note-taking and organization tool
    ];
  };
}
