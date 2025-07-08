{
  config,
  pkgs,
  globals,
  ...
}:

let
  dotfiles = config.lib.file.mkOutOfStoreSymlink "/home/${globals.username}/dev/nficca/nixos-config/dotfiles";
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = globals.username;
  home.homeDirectory = "/home/${globals.username}";

  # Symlink dotfiles
  xdg.configFile = {
    nvim.source = "${dotfiles}/nvim";
    "Code/User/settings.json".source = "${dotfiles}/vscode/settings.json";
  };

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
  ];

  # Ghostty
  programs.ghostty.enable = true;
  programs.ghostty.settings.background-opacity = 0.70;
  programs.ghostty.settings.background-blur = 10;
  programs.ghostty.settings.font-family = "JetBrainsMono";
  programs.ghostty.settings.font-size = 14;
  programs.ghostty.settings.theme = "GitHub-Dark-High-Contrast";

  # Visual Studio Code
  programs.vscode.enable = true;
}
