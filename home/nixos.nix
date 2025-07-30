{
  pkgs,
  common,
  ...
}:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = common.username;
  home.homeDirectory = "/home/${common.username}";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";

  # Install packages
  home.packages = with pkgs; [
    _1password-gui # Password manager
    maestral # Open source Dropbox client
    slack # Team communication
    discord # Group chat
    claude-code # Agentic AI assistant
    ldtk # 2D level editor
    aseprite # Pixel art editor
    jless # JSON viewer
  ];

  # Ghostty
  programs.ghostty.enable = true;

  # Visual Studio Code
  programs.vscode.enable = true;

  # Google Chrome
  programs.google-chrome.enable = true;
}
