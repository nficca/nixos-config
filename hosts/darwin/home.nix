{ globals, ... }:

{
  imports = [
    ../../shared/home.nix
  ];

  home.username = globals.username;
}
