{
  config,
  lib,
  pkgs,
  username,
  mkRepoSymlink,
  ...
}:

let
  cfg = config.myModules.herdr;
in
{
  options.myModules.herdr.enable = lib.mkEnableOption "herdr agent multiplexer with user config";

  config = lib.mkIf cfg.enable {
    home-manager.users.${username} =
      { config, ... }:
      {
        home.packages = [ pkgs.herdr ];

        xdg.configFile."herdr/config.toml".source =
          mkRepoSymlink config "dotfiles/herdr/config.toml";
      };
  };
}
