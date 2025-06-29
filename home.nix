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

  # Install packages that don't have home-manager modules.
  # I.e. if the package can't be installed via something
  # like `programs.<name>.enable = true;` then it can
  # probably be installed as a package in this list.
  home.packages = with pkgs; [
    _1password-gui
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Chrome
  programs.google-chrome.enable = true;

  # Git
  programs.git.enable = true;
  programs.git.userEmail = "nicficca@gmail.com";
  programs.git.userName = "Nic Ficca";
  programs.git.delta.enable = true;

  # Github CLI
  programs.gh.enable = true;

  # Dropbox
  services.dropbox.enable = true;
}
