{
  config,
  lib,
  ...
}:

let
  dotfiles = "${config.home.homeDirectory}/dev/nficca/nixos-config/dotfiles/direnv";
in
{
  options.myModules.direnv.enable = lib.mkEnableOption "direnv with config";

  config = lib.mkIf config.myModules.direnv.enable {
    programs.direnv.enable = true;

    xdg.configFile.direnv.source =
      config.lib.file.mkOutOfStoreSymlink dotfiles;
  };
}
