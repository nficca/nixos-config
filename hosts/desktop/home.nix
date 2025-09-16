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
  ];

  # Ghostty
  programs.ghostty.enable = true;

  # Visual Studio Code
  programs.vscode.enable = true;

  # Google Chrome
  programs.google-chrome.enable = true;
}
