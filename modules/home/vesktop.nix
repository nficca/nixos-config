{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myModules.vesktop.enable = lib.mkEnableOption "vesktop (alternative Discord client with Vencord built in)";

  config = lib.mkIf config.myModules.vesktop.enable {
    home.packages = [ pkgs.vesktop ];
  };
}
