{
  config,
  lib,
  pkgs,
  ...
}:

let
  dotfiles = "${config.home.homeDirectory}/dev/nficca/nixos-config/dotfiles/claude";
in
{
  options.myModules.claude-code.enable = lib.mkEnableOption "Claude Code CLI with user settings and statusline";

  config = lib.mkIf config.myModules.claude-code.enable {
    home.packages = [ pkgs.claude-code ];

    home.file.".claude/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/settings.json";
    home.file.".claude/statusline.sh".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/statusline.sh";
  };
}
