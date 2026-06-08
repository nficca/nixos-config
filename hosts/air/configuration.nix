{ username, ... }:

{
  imports = [
    ../../shared/configuration/darwin.nix
  ];

  myModules._1password.enable = true;
  myModules.affinity-designer.enable = true;
  myModules.discord.enable = true;
  myModules.dropbox.enable = true;
  myModules.firefox.enable = true;
  myModules.folx.enable = true;
  myModules.ghostty.enable = true;
  myModules.mullvad.enable = true;
  myModules.steam.enable = true;
  myModules.whatsapp.enable = true;

  homebrew = {
    enable = true;
    user = username;
  };
}
