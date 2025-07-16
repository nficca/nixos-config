{ common, pkgs, ... }:

{
  imports = [
    ../../shared/home
  ];

  home.username = common.username;

  # Install packages
  home.packages = with pkgs; [
    claude-code # Agentic AI assistant
  ];
}
