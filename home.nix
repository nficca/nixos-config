{ config, pkgs, ... }:

let
  username = "nic";
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = username;
  home.homeDirectory = "/home/${username}";

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
    _1password-gui
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Hyprland configuration
  programs.wofi.enable = true;
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    systemd.enable = true;
    systemd.enableXdgAutostart = true;
    systemd.variables = [ "--all" ];
    xwayland.enable = true;
    settings.exec-once = [
      "waybar"
      "wofi --show drun"
      "ghostty"
      "nm-applet --indicator"
    ];
  };
  programs.waybar.enable = true;
  programs.waybar.settings.mainBar = {
    layer = "top";
    position = "top";
    height = 30;
    modules-left = [ "hyprland/workspaces" ];
    modules-center = [ "hyprland/window" ];
    modules-right = [ "pulseaudio" "network" "battery" "tray" ];
  };

  # Chrome
  programs.google-chrome.enable = true;

  # Git
  programs.git.enable = true;
  programs.git.userEmail = "nicficca@gmail.com";
  programs.git.userName = "Nic Ficca";
  programs.git.delta.enable = true;

  # Github CLI
  programs.gh.enable = true;

  # Ghostty
  programs.ghostty.enable = true;
  programs.ghostty.settings.background-opacity = 0.85;
  programs.ghostty.settings.background-blur = 10;
  programs.ghostty.settings.font-family = "JetBrainsMono";
  programs.ghostty.settings.theme = "GitHub-Dark-High-Contrast";

  # ZSH
  programs.zsh.enable = true;
  programs.zsh.autosuggestion.enable = true;

  # Starship
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;

  # Dropbox
  services.dropbox.enable = true;
}
