{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  options.myModules.vesktop.enable = lib.mkEnableOption "vesktop (alternative Discord client with Vencord built in)";

  config = lib.mkIf config.myModules.vesktop.enable {
    home-manager.users.${username} = {
      home.packages = [ pkgs.vesktop ];
    };
  };
}
