# This is a shared module intended to contain system-level configuration
# that is common in both NIxOS and nix-darwin systems. As such, it is
# recommended that the configurations here are kept minimal so as not to
# introduce cross-platform incompatibilities.

{ username, pkgs, ... }:

{
  imports = [ ];

  users.users."${username}".shell = pkgs.zsh;
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;

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
