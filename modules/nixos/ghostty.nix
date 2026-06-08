{
  config,
  lib,
  pkgs,
  username,
  mkRepoSymlink,
  ghostty,
  ...
}:

{
  options.myModules.ghostty.enable = lib.mkEnableOption "Ghostty terminal emulator (built from the ghostty flake) with user config";

  # Ghostty is slow to release new versions in nixpkgs, so we use the flake
  # input to build from main and get timely protocol support
  # (e.g. ext-background-effect-v1).
  config = lib.mkIf config.myModules.ghostty.enable {
    home-manager.users.${username} =
      { config, ... }:
      {
        programs.ghostty = {
          enable = true;
          package = ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default;
        };

        xdg.configFile."ghostty/config".source =
          mkRepoSymlink config "dotfiles/ghostty/config";
        xdg.configFile."ghostty/linux".source =
          mkRepoSymlink config "dotfiles/ghostty/linux";
      };
  };
}
