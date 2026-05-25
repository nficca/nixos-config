{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myModules.creative.enable = lib.mkEnableOption "Game art tooling: aseprite (pixel art editor) and ldtk (2D level editor)";

  config = lib.mkIf config.myModules.creative.enable {
    home.packages = with pkgs; [
      aseprite
      ldtk
    ];
  };
}
