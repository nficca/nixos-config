# This is a shared module intended to contain system-level configuration
# that is common in both NIxOS and nix-darwin systems. As such, it is
# recommended that the configurations here are kept minimal so as not to
# introduce cross-platform incompatibilities.

{ common, pkgs, ... }:

let
  platformImports =
    if pkgs.stdenv.isDarwin then
      [ ./systems/darwin.nix ]
    else if pkgs.stdenv.isLinux then
      [ ./systems/nixos.nix ]
    else
      [ ];

  imports = [ ] ++ platformImports;
in
{
  inherit imports;

  users.users."${common.username}".shell = pkgs.zsh;
  programs.zsh.enable = true;

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
