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

  # Install packages
  home.packages = (
    with pkgs;
    [
      aseprite # Pixel art editor
      heaptrack # Heap memory profiler
      kdePackages.kdenlive # Non-linear video editor
      kdePackages.ktorrent # BitTorrent client
      ldtk # 2D level editor
      losslesscut-bin # Lossless trim/cut for video/audio (great for OBS captures)
      mullvad-browser # Privacy-focused web browser
      nautilus # GNOME file manager
      pavucontrol # PulseAudio volume control
      playerctl # CLI media player control
      prismlauncher # Open-source minecraft launcher
      spotify # Play music from the Spotify music service
      unzip # Extraction utility for zip archives
      vesktop # Alternative Discord client
    ]
  );

  myModules.niri.enable = true;
  myModules.dank-material-shell.enable = true;
  myModules.dropbox.enable = true;
  myModules.mpv.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "org.gnome.Nautilus.desktop";
    };
  };

  myModules.ghostty.enable = true;
  myModules.firefox.enable = true;
  myModules.firefox.profileHandler.enable = true;

  myModules.gtk-theme.enable = true;
  myModules.kubernetes.enable = true;
  myModules.aws.enable = true;
  myModules.postgres-cli.enable = true;
  myModules.wayland-tools.enable = true;
}
