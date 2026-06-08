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

  myModules._1password.enable = true;
  myModules.aws.enable = true;
  myModules.claude-code.enable = true;
  myModules.creative.aseprite.enable = true;
  myModules.creative.kdenlive.enable = true;
  myModules.creative.ldtk.enable = true;
  myModules.creative.losslesscut.enable = true;
  myModules.dank-material-shell.enable = true;
  myModules.dev-tools.enable = true;
  myModules.direnv.enable = true;
  myModules.dropbox.enable = true;
  myModules.firefox.enable = true;
  myModules.firefox.profileHandler.enable = true;
  myModules.ghostty.enable = true;
  myModules.git.enable = true;
  myModules.gtk-theme.enable = true;
  myModules.ktorrent.enable = true;
  myModules.kubernetes.enable = true;
  myModules.mpv.enable = true;
  myModules.mullvad.browser.enable = true;
  myModules.nautilus.enable = true;
  myModules.neovim.enable = true;
  myModules.niri.enable = true;
  myModules.postgres-cli.enable = true;
  myModules.prismlauncher.enable = true;
  myModules.shell.enable = true;
  myModules.spotify.enable = true;
  myModules.starship.enable = true;
  myModules.tmux.enable = true;
  myModules.user-packages.enable = true;
  myModules.vesktop.enable = true;
  myModules.wayland-tools.enable = true;
}
