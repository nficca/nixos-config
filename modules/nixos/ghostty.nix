{
  config,
  lib,
  username,
  mkRepoSymlink,
  ...
}:

{
  options.myModules.ghostty.enable = lib.mkEnableOption "Ghostty terminal emulator with user config";

  config = lib.mkIf config.myModules.ghostty.enable {
    home-manager.users.${username} =
      { config, ... }:
      {
        programs.ghostty = {
          enable = true;
        };

        xdg.configFile."ghostty/config".source =
          mkRepoSymlink config "dotfiles/ghostty/config";
        xdg.configFile."ghostty/linux".source =
          mkRepoSymlink config "dotfiles/ghostty/linux";
      };
  };
}
