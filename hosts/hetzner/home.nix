{
  username,
  ...
}:

{
  imports = [
    ../../shared/home
  ];

  home.homeDirectory = "/home/${username}";
}
