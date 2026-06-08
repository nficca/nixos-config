{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  options.myModules.spotify.enable = lib.mkEnableOption "Spotify desktop client via nixpkgs";

  config = lib.mkIf config.myModules.spotify.enable {
    home-manager.users.${username} = {
      home.packages = [ pkgs.spotify ];
    };
  };
}
