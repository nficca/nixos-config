{
  config,
  lib,
  username,
  mkRepoSymlink,
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
      {
        programs.direnv.enable = true;

        xdg.configFile.direnv.source = mkRepoSymlink config "dotfiles/direnv";
      };
  };
}
