{ pkgs, ... }:

{
  imports = [
    ../../shared/home
  ];

  home.packages = with pkgs; [
    maestral # Dropbox client
  ];

  programs.k9s.enable = true;
}
