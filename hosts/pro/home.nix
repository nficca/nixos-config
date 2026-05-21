{ ... }:

{
  imports = [
    ../../shared/home
  ];

  myModules.dropbox.enable = true;
  myModules.ghostty.enable = true;

  programs.k9s.enable = true;
}
