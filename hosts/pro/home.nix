{ pkgs, ... }:

{
  imports = [
    ../../shared/home
  ];

  home.packages = with pkgs; [
    fossa-cli # Dependency analysis tool
    maestral # Dropbox client
  ];

  programs.k9s.enable = true;
}
