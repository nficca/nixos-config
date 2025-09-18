{ pkgs, ... }:

{
  imports = [
    ../../shared/home
  ];

  home.packages = with pkgs; [
    claude-code
  ];
}
