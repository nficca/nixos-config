{
  config,
  username,
  pkgs,
  ...
}:

{
  home.stateVersion = "25.05";
  home.username = username;
  home.homeDirectory = "/home/${username}";
  programs.home-manager.enable = true;

  myModules = {
    _1password.enable = true;
    aws.enable = true;
    claude-code.enable = true;
    creative.aseprite.enable = true;
    creative.kdenlive.enable = true;
    creative.ldtk.enable = true;
    creative.losslesscut.enable = true;
    dank-material-shell.enable = true;
    dev-tools.enable = true;
    direnv.enable = true;
    dropbox.enable = true;
    firefox.enable = true;
    firefox.profileHandler.enable = true;
    ghostty.enable = true;
    git.enable = true;
    gtk-theme.enable = true;
    ktorrent.enable = true;
    kubernetes.enable = true;
    mpv.enable = true;
    mullvad.browser.enable = true;
    nautilus.enable = true;
    neovim.enable = true;
    niri.enable = true;
    postgres-cli.enable = true;
    prismlauncher.enable = true;
    shell.enable = true;
    spotify.enable = true;
    starship.enable = true;
    tmux.enable = true;
    user-packages.enable = true;
    vesktop.enable = true;
    wayland-tools.enable = true;
  };
}
