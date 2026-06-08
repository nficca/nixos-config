{
  config,
  lib,
  username,
  mkRepoSymlink,
  ...
}:

let
  cfg = config.myModules.starship;
in
{
  options.myModules.starship.enable = lib.mkEnableOption "Starship prompt with zsh integration";

  config = lib.mkIf cfg.enable {
    home-manager.users.${username} =
      { config, ... }:
      {
        programs.starship = {
          enable = true;
          enableZshIntegration = true;
        };

        xdg.configFile."starship.toml".source =
          mkRepoSymlink config "dotfiles/starship/starship.toml";
      };
  };
}
