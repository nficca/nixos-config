{ ... }:

{
  imports = [
    ../../shared/configuration/darwin.nix
  ];

  myModules._1password.enable = true;
  myModules.dropbox.enable = true;
  myModules.firefox.enable = true;
  myModules.ghostty.enable = true;
  myModules.notion.enable = true;
  myModules.whatsapp.enable = true;
}
