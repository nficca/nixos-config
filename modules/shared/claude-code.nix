{
  config,
  lib,
  pkgs,
  username,
  mkRepoSymlink,
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
      {
        home.packages = [ pkgs.claude-code ];

        home.file.".claude/settings.json".source =
          mkRepoSymlink config "dotfiles/claude/settings.json";
        home.file.".claude/statusline.sh".source =
          mkRepoSymlink config "dotfiles/claude/statusline.sh";
      };
  };
}
