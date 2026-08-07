{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  options.myModules.discord.enable = lib.mkEnableOption "Discord client";

  config = lib.mkIf config.myModules.discord.enable {
    home-manager.users.${username} = {
      home.packages = [ pkgs.discord ];
    };
  };
}
