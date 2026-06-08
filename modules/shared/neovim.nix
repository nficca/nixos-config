{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  cfg = config.myModules.neovim;
in
{
  options.myModules.neovim.enable = lib.mkEnableOption "Neovim with treesitter plugins and dotfiles";

  config = lib.mkIf cfg.enable {
    home-manager.users.${username} =
      { config, ... }:
      {
        programs.neovim = {
          enable = true;
          withRuby = false;
          withPython3 = false;
          plugins = with pkgs.vimPlugins; [
            (nvim-treesitter.withPlugins (p: with p; [
              bash
              c
              cmake
              cpp
              css
              go
              html
              javascript
              json
              lua
              markdown
              markdown_inline
              nix
              qmljs
              ruby
              rust
              typescript
            ]))
            nvim-treesitter-textobjects
          ];
        };

        xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/dev/nficca/nixos-config/dotfiles/nvim";
      };
  };
}
