{ common, ... }:

{
  imports = [
    ../../shared/home.nix
  ];

  home.username = common.username;
}
