{
  username,
  ...
}:

{
  home.stateVersion = "25.05";
  home.username = username;
  home.homeDirectory = "/home/${username}";
  programs.home-manager.enable = true;

  myModules._1password.enable = true;
  myModules.claude-code.enable = true;
  myModules.dev-tools.enable = true;
  myModules.direnv.enable = true;
  myModules.git.enable = true;
  myModules.neovim.enable = true;
  myModules.shell.enable = true;
  myModules.starship.enable = true;
  myModules.tmux.enable = true;
  myModules.user-packages.enable = true;
}
