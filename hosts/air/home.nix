{ pkgs, ... }:

{
  imports = [
    ../../shared/home
  ];

  home.packages = with pkgs; [
    maestral # Dropbox client
  ];

  myModules.ghostty.enable = true;
}
