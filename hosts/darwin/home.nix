{ common, ... }:

{
  imports = [
    ../../shared/home
  ];

  home.username = common.username;
}
