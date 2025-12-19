{ pkgs, ... }:

{
  imports = [
    ../../shared/home
  ];

  programs.k9s.enable = true;
}
