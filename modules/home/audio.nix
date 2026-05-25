{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myModules.audio;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  options.myModules.audio.userTools.enable = lib.mkEnableOption "User-space audio control tools: pavucontrol and playerctl";

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.userTools.enable || isLinux;
          message = "myModules.audio.userTools.enable is set on a non-Linux platform. The audio user-tools module is Linux-only.";
        }
      ];
    }

    (lib.mkIf (cfg.userTools.enable && isLinux) {
      home.packages = with pkgs; [
        pavucontrol
        playerctl
      ];
    })
  ];
}
