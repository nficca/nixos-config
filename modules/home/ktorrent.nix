{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myModules.ktorrent.enable = lib.mkEnableOption "ktorrent (KDE BitTorrent client)";

  config = lib.mkIf config.myModules.ktorrent.enable {
    home.packages = [ pkgs.kdePackages.ktorrent ];
  };
}
