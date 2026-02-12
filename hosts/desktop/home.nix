{
  username,
  pkgs,
  awww,
  qml-niri,
  ...
}:

{
  imports = [
    ../../shared/home
  ];

  home.homeDirectory = "/home/${username}";

  # Install packages
  home.packages =
    (with pkgs; [
      _1password-gui # Password manager
      aseprite # Pixel art editor
      awscli # Unified tool to manage AWS services
      discord # Group chat
      dropbox # Dropbox client
      fossa-cli # Dependency analysis tool
      fuzzel # Wayland application launcher
      heaptrack # Heap memory profiler
      kdePackages.ktorrent # BitTorrent client
      kubectl # Kubernetes CLI
      kubectx # Fast way to switch between clusters and namespaces in kubectl
      ldtk # 2D level editor
      libnotify # Simple library for testing desktop notifications
      mullvad-browser # Privacy-focused web browser
      networkmanagerapplet # NetworkManager GUI (nm-connection-editor)
      pavucontrol # PulseAudio volume control
      pgcli # Postgres client interface
      podman-compose # Docker-compose with podman
      postgresql # Relational database system
      saml2aws # CLI tool for getting AWS creds via SAML IDP
      slack # Team communication
      swayidle # Idle management daemon for wayland
      wireguard-tools # Tools for WireGuard VPN
    ])
    ++ [
      awww.packages.${pkgs.stdenv.hostPlatform.system}.awww # Wallpaper daemon for wayland
      qml-niri.packages.${pkgs.stdenv.hostPlatform.system}.quickshell # QML-based shell compositor
    ];

  # Screen locker
  programs.hyprlock.enable = true;

  # Ghostty
  programs.ghostty.enable = true;

  # Visual Studio Code
  programs.vscode.enable = true;

  # Zed
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "lua"
    ];
  };

  # Google Chrome
  programs.google-chrome.enable = true;

  # Kubernetes CLI
  programs.k9s.enable = true;

  # Cursor theme configuration
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "WhiteSur-cursors";
    package = pkgs.whitesur-cursors;
    size = 24;
  };

  # GTK configuration
  gtk = {
    enable = true;
    theme = {
      name = "WhiteSur-light";
      package = pkgs.whitesur-gtk-theme;
    };
    iconTheme = {
      name = "WhiteSur-light";
      package = pkgs.whitesur-icon-theme;
    };
  };

  # Qt configuration
  # qt = {
  #   enable = true;
  #   platformTheme.name = "qtct";
  #   style.name = "breeze";
  # };

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

    quickshell = {
      Unit = {
        Description = "Quickshell";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${qml-niri.packages.${pkgs.stdenv.hostPlatform.system}.quickshell}/bin/quickshell";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    dropbox = {
      Unit = {
        Description = "Dropbox";
      };
      Service = {
        ExecStart = "${pkgs.dropbox}/bin/dropbox";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
