{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myModules.video-editing.enable = lib.mkEnableOption "Video editing tools: kdenlive (non-linear editor) and losslesscut-bin (lossless trim/cut for capture review)";

  config = lib.mkIf config.myModules.video-editing.enable {
    home.packages = with pkgs; [
      kdePackages.kdenlive
      losslesscut-bin
    ];
  };
}
