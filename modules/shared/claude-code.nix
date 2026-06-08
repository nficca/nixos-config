{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  cfg = config.myModules.claude-code;
in
{
  options.myModules.claude-code.enable = lib.mkEnableOption "Claude Code CLI with user settings and statusline";

  config = lib.mkIf cfg.enable {
    home-manager.users.${username} =
      { config, ... }:
      let
        dotfiles = "${config.home.homeDirectory}/dev/nficca/nixos-config/dotfiles/claude";
      in
      {
        home.packages = [ pkgs.claude-code ];

        home.file.".claude/settings.json".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfiles}/settings.json";
        home.file.".claude/statusline.sh".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfiles}/statusline.sh";
      };
  };
}
