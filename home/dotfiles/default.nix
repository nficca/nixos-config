# This module manages symlinks for dotfiles and other similar user-level program
# configurations. It is structured to work across different platforms, specifically
# macOS and Linux.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  dotfiles = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dev/nficca/nixos-config/home/dotfiles";
in
{
  # XDG_CONFIG_HOME symlinks
  xdg.configFile =
    lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {
      # MacOS
    }
    // lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
      # Linux
      "Code/User/settings.json".source = "${dotfiles}/vscode/settings.json";
    }
    // {
      # All platforms
      nvim.source = "${dotfiles}/nvim";
      ghostty.source = "${dotfiles}/ghostty";
      direnv.source = "${dotfiles}/direnv";
      "starship.toml".source = "${dotfiles}/starship/starship.toml";
    };

  # Other home directory symlinks
  home.file =
    lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {
      # MacOS
      "Library/Application Support/Code/User/settings.json".source = "${dotfiles}/vscode/settings.json";
    }
    // lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
      # Linux
    }
    // {
      # All platforms
    };
}
