{
  config,
  lib,
  pkgs,
  ghostty ? null,
  ...
}:

let
  dotfiles = "${config.home.homeDirectory}/dev/nficca/nixos-config/shared/home/dotfiles/ghostty";
in
{
  options.myModules.ghostty.enable = lib.mkEnableOption "Ghostty terminal emulator with platform-specific config";

  config = lib.mkIf config.myModules.ghostty.enable (lib.mkMerge [
    {
      xdg.configFile."ghostty/config".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config";
    }

    # Ghostty is slow to release new versions in nixpkgs, so we use the flake
    # input to build from main and get timely protocol support
    # (e.g. ext-background-effect-v1).
    (lib.mkIf pkgs.stdenv.isLinux {
      programs.ghostty = {
        enable = true;
        package = ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default;
      };

      xdg.configFile."ghostty/linux".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfiles}/linux";
    })

    # On Darwin, ghostty is installed via homebrew cask because nixpkgs GUI
    # apps don't integrate with Launchpad, Dock, and Spotlight.
    (lib.mkIf pkgs.stdenv.isDarwin {
      xdg.configFile."ghostty/darwin".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfiles}/darwin";
    })
  ]);
}
