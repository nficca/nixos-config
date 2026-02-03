{ pkgs, ... }:

{
  imports = [
    ../../shared/home
  ];

  home.packages = with pkgs; [
    fossa-cli # Dependency analysis tool
  ];

  programs.k9s.enable = true;
}
