{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  options.myModules.ktorrent.enable = lib.mkEnableOption "ktorrent (KDE BitTorrent client)";

  config = lib.mkIf config.myModules.ktorrent.enable {
    home-manager.users.${username} = {
      home.packages = [ pkgs.kdePackages.ktorrent ];
    };
  };
}
