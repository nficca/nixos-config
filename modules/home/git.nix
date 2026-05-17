{
  config,
  lib,
  ...
}:

let
  dotfiles = "${config.home.homeDirectory}/dev/nficca/nixos-config/shared/home/dotfiles/git";
in
{
  options.myModules.git = {
    enable = lib.mkEnableOption "git with delta diffing, mergiraf merge driver, and shell aliases";

    gh.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to install the GitHub CLI (gh) alongside git.";
    };
  };

  config = lib.mkIf config.myModules.git.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;
      ignores = [
        "/.worktrees"
        "**/.claude/settings.local.json"
      ];
      settings.user.email = "nicficca@gmail.com";
      settings.user.name = "Nic Ficca";
      settings.init.defaultBranch = "main";
      includes = [ { path = "~/.config/git/themes.gitconfig"; } ];
    };

    programs.mergiraf = {
      enable = true;
      enableGitIntegration = true;
    };

    # All delta features are defined in the symlinked themes.gitconfig.
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        features = "weeping-willow";
      };
    };

    programs.gh.enable = config.myModules.git.gh.enable;

    home.shellAliases = {
      ga = "git add";
      gaa = "git add --all";
      gap = "git add --patch";
      gc = "git commit --verbose";
      gcb = "git checkout -b";
      gco = "git checkout";
      gd = "git diff";
      gl = "git pull";
      glo = "git log --oneline";
      gp = "git push";
      gpsup = "git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD)";
      gst = "git status";
    };

    xdg.configFile."git/themes.gitconfig".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/themes.gitconfig";
  };
}
