{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myModules.neovim.enable = lib.mkEnableOption "Neovim with treesitter plugins and dotfiles";

  config = lib.mkIf config.myModules.neovim.enable {
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
}
