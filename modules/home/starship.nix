{
  config,
  lib,
  ...
}:

let
  dotfiles = "${config.home.homeDirectory}/dev/nficca/nixos-config/shared/home/dotfiles/starship";
in
{
  options.myModules.starship.enable = lib.mkEnableOption "Starship prompt with zsh integration";

  config = lib.mkIf config.myModules.starship.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
    };

    xdg.configFile."starship.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/starship.toml";
  };
}
