{ globals, ... }:

{
  imports = [
    ../../modules/home.nix
  ];

  home.username = globals.username;
}
