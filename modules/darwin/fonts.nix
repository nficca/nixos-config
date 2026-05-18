{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myModules.fonts.enable = lib.mkEnableOption "system fonts (JetBrains Mono Nerd Font)";

  config = lib.mkIf config.myModules.fonts.enable {
    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };
}
