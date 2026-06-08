{
  config,
  lib,
  username,
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
      let
        dotfiles = "${config.home.homeDirectory}/dev/nficca/nixos-config/dotfiles/starship";
      in
      {
        programs.starship = {
          enable = true;
          enableZshIntegration = true;
        };

        xdg.configFile."starship.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfiles}/starship.toml";
      };
  };
}
