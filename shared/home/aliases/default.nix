{ ... }:

{
  home.shellAliases = {
    # Git
    gaa = "git add --all";
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
