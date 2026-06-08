{
  config,
  lib,
  username,
  ...
}:

let
  cfg = config.myModules.direnv;
in
{
  options.myModules.direnv.enable = lib.mkEnableOption "direnv with config";

  config = lib.mkIf cfg.enable {
    home-manager.users.${username} =
      { config, ... }:
      let
        dotfiles = "${config.home.homeDirectory}/dev/nficca/nixos-config/dotfiles/direnv";
      in
      {
        programs.direnv.enable = true;

        xdg.configFile.direnv.source =
          config.lib.file.mkOutOfStoreSymlink dotfiles;
      };
  };
}
