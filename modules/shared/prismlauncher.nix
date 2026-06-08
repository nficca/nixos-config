{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  options.myModules.prismlauncher.enable = lib.mkEnableOption "prismlauncher (open-source Minecraft launcher)";

  config = lib.mkIf config.myModules.prismlauncher.enable {
    home-manager.users.${username} = {
      home.packages = [ pkgs.prismlauncher ];
    };
  };
}
