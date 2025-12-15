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
    aseprite # Pixel art editor
    discord # Group chat
    heaptrack # Heap memory profiler
    kdePackages.ktorrent # BitTorrent client
    ldtk # 2D level editor
    mullvad-browser # Privacy-focused web browser
    pgcli # Postgres client interface
    podman-compose # Docker-compose with podman
    postgresql # Relational database system
    slack # Team communication
    wireguard-tools # Tools for WireGuard VPN
  ];

  # Ghostty
  programs.ghostty.enable = true;

  # Visual Studio Code
  programs.vscode.enable = true;

  # Google Chrome
  programs.google-chrome.enable = true;
}
