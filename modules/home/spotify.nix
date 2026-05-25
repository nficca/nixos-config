{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myModules.spotify;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  options.myModules.spotify.enable = lib.mkEnableOption "Spotify desktop client (native package on Linux; on Darwin install via the homebrew cask module instead)";

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.enable || isLinux;
          message = "myModules.spotify.enable on home-manager is Linux-only. On Darwin, enable myModules.spotify.enable at the system layer instead (homebrew cask).";
        }
      ];
    }

    (lib.mkIf (cfg.enable && isLinux) {
      home.packages = [ pkgs.spotify ];
    })
  ];
}
