{
  username,
  pkgs,
  awww,
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
      fossa-cli # Dependency analysis tool
      fuzzel # Wayland application launcher
      heaptrack # Heap memory profiler
      kdePackages.ktorrent # BitTorrent client
      kubectl # Kubernetes CLI
      kubectx # Fast way to switch between clusters and namespaces in kubectl
      ldtk # 2D level editor
      mullvad-browser # Privacy-focused web browser
      pgcli # Postgres client interface
      podman-compose # Docker-compose with podman
      postgresql # Relational database system
      saml2aws # CLI tool for getting AWS creds via SAML IDP
      slack # Team communication
      swayidle # Idle management daemon for wayland
      waybar # Wayland status bar
      wireguard-tools # Tools for WireGuard VPN
    ])
    ++ [
      awww.packages.${pkgs.stdenv.hostPlatform.system}.awww # Wallpaper daemon for wayland
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
}
