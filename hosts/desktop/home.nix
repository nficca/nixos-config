{
  config,
  username,
  pkgs,
  ...
}:

{
  imports = [
    ../../shared/home
  ];

  home.homeDirectory = "/home/${username}";

  myModules.niri.enable = true;
  myModules.dank-material-shell.enable = true;
  myModules.dropbox.enable = true;
  myModules.ktorrent.enable = true;
  myModules.mpv.enable = true;
  myModules.nautilus.enable = true;
  myModules.prismlauncher.enable = true;
  myModules.vesktop.enable = true;

  myModules.ghostty.enable = true;
  myModules.firefox.enable = true;
  myModules.firefox.profileHandler.enable = true;

  myModules.gtk-theme.enable = true;
  myModules.kubernetes.enable = true;
  myModules.aws.enable = true;
  myModules.creative.aseprite.enable = true;
  myModules.creative.ldtk.enable = true;
  myModules.creative.kdenlive.enable = true;
  myModules.creative.losslesscut.enable = true;
  myModules.mullvad.browser.enable = true;
  myModules.postgres-cli.enable = true;
  myModules.spotify.enable = true;
  myModules.wayland-tools.enable = true;
}
