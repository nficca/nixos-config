{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myModules.prismlauncher.enable = lib.mkEnableOption "prismlauncher (open-source Minecraft launcher)";

  config = lib.mkIf config.myModules.prismlauncher.enable {
    home.packages = [ pkgs.prismlauncher ];
  };
}
