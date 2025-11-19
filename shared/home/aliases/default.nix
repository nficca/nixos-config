{ ... }:

{
  home.shellAliases = {
    # Git
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
}
