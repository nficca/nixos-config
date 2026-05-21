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
      awscli # Unified tool to manage AWS services
      grim # Screenshot utility for Wayland
      heaptrack # Heap memory profiler
      kdePackages.kdenlive # Non-linear video editor
      kdePackages.ktorrent # BitTorrent client
      kubectl # Kubernetes CLI
      kubectx # Fast way to switch between clusters and namespaces in kubectl
      ldtk # 2D level editor
      libnotify # Simple library for testing desktop notifications
      losslesscut-bin # Lossless trim/cut for video/audio (great for OBS captures)
      mullvad-browser # Privacy-focused web browser
      nautilus # GNOME file manager
      pavucontrol # PulseAudio volume control
      pgcli # Postgres client interface
      playerctl # CLI media player control
      postgresql # Relational database system
      prismlauncher # Open-source minecraft launcher
      saml2aws # CLI tool for getting AWS creds via SAML IDP
      slurp # Region selection for Wayland screenshots
      spotify # Play music from the Spotify music service
      unzip # Extraction utility for zip archives
      vesktop # Alternative Discord client
      wireguard-tools # Tools for WireGuard VPN
      wl-clipboard-rs # Command-line copy/paste utilities for Wayland
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

  # Kubernetes CLI
  programs.k9s.enable = true;
}
