# This module defines system-level configurations.
# **IMPORTANT**: This module is intended to configure BOTH NixOS and macOS (Darwin).
# Any attributes defined here should be compatible with both systems.

{ globals, pkgs, ... }:

{
  users.users."${globals.username}".shell = pkgs.zsh;

  environment.variables = {
    EDITOR = "vim";
  };

  environment.systemPackages = with pkgs; [
    dua # Disk usage analyzer
    vim # Text editor
    wget # Network file downloader
  ];

  fonts.packages = with pkgs; [
    jetbrains-mono
  ];
}
