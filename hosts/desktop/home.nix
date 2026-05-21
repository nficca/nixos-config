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
      mpv # Minimalist scriptable video player
      mullvad-browser # Privacy-focused web browser
      nautilus # GNOME file manager
      networkmanagerapplet # NetworkManager GUI (nm-connection-editor)
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

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "org.gnome.Nautilus.desktop";
      "video/mp4" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "video/mpeg" = "mpv.desktop";
      "video/x-flv" = "mpv.desktop";
      "video/x-m4v" = "mpv.desktop";
      "video/x-ms-wmv" = "mpv.desktop";
      "video/3gpp" = "mpv.desktop";
      "video/ogg" = "mpv.desktop";
      "video/avi" = "mpv.desktop";
      "video/mkv" = "mpv.desktop";
    };
  };

  myModules.ghostty.enable = true;
  myModules.firefox.enable = true;
  myModules.firefox.profileHandler.enable = true;

  myModules.gtk-theme.enable = true;

  # Kubernetes CLI
  programs.k9s.enable = true;

  # Define user services that should be managed by systemd.
  #
  # In home-manager, systemd user services are defined using the same schema as
  # systemd unit files. That is, the [Unit], [Service], and [Install] sections
  # in unit files correlate to the attributes of the same name here. Note that
  # the attributes must follow the same capitalization and naming conventions
  # used in systemd unit files. More details can be found in the
  # systemd.service(5) manpage: `man systemd.service`.
  #
  # To interact with user-specific systemd services, use the `--user` flag with
  # the `systemctl` command. For example, to check the status of a user service:
  #
  # $ systemctl --user status my-cool-user-service
  #
  # To view logs for a specific user service, use `journalctl` with the
  # `--user-unit` option:
  #
  # $ journalctl --user-unit my-cool-user-service
  #
  # To list all active user units:
  #
  # $ systemctl --user list-units
  systemd.user.services = {
    nm-applet = {
      Unit = {
        Description = "NetworkManager Applet";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
        Restart = "on-failure";
        Environment = "PATH=${pkgs.networkmanagerapplet}/bin";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

  };
}
