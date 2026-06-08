{ username, ... }:

{
  home.stateVersion = "25.05";
  home.username = username;
  programs.home-manager.enable = true;

  myModules = {
    _1password.enable = true;
    claude-code.enable = true;
    dev-tools.enable = true;
    direnv.enable = true;
    ghostty.enable = true;
    git.enable = true;
    neovim.enable = true;
    shell.enable = true;
    starship.enable = true;
    tmux.enable = true;
    user-packages.enable = true;
  };
}
