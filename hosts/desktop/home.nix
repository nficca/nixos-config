{
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
  home.packages = with pkgs; [
    _1password-gui # Password manager
    slack # Team communication
    discord # Group chat
    ldtk # 2D level editor
    aseprite # Pixel art editor
    heaptrack # Heap memory profiler
    postgresql # Relational database system
    mullvad-browser # Privacy-focused web browser
    podman-compose # Docker-compose with podman
    wireguard-tools # Tools for WireGuard VPN
    pgcli # Postgres client interface
    kdePackages.ktorrent # BitTorrent client
  ];

  # Ghostty
  programs.ghostty.enable = true;

  # Visual Studio Code
  programs.vscode.enable = true;

  # Google Chrome
  programs.google-chrome.enable = true;
}
