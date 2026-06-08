{
  config,
  lib,
  ...
}:

let
  dotfiles = "${config.home.homeDirectory}/dev/nficca/nixos-config/dotfiles/niri";
in
{
  options.myModules.niri.enable = lib.mkEnableOption "niri user config (keybinds, layout, output rules)";

  config = lib.mkIf config.myModules.niri.enable {
    xdg.configFile.niri.source =
      config.lib.file.mkOutOfStoreSymlink dotfiles;
  };
}
