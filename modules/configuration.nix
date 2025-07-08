# This is a shared module intended to contain system-level configuration
# that is common in both NIxOS and nix-darwin systems. As such, it is
# recommended that the configurations here are kept minimal so as not to
# introduce cross-platform incompatibilities.

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
