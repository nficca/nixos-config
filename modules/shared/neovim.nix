{
  config,
  lib,
  pkgs,
  username,
  mkRepoSymlink,
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
          # Load HM's generated initLua via --cmd wrapper arg instead of
          # writing ~/.config/nvim/init.lua, so it doesn't collide with the
          # whole-directory symlink set below.
          sideloadInitLua = true;
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

        xdg.configFile.nvim.source = mkRepoSymlink config "dotfiles/nvim";
      };
  };
}
