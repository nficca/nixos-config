{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myModules.mpv;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  options.myModules.mpv.enable = lib.mkEnableOption "mpv with xdg mime defaults for common video formats (Linux-only)";

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.enable || isLinux;
          message = "myModules.mpv.enable is set on a non-Linux platform. The mpv module is Linux-only (xdg.mimeApps is freedesktop-specific).";
        }
      ];
    }

    (lib.mkIf (cfg.enable && isLinux) {
      home.packages = [ pkgs.mpv ];

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "video/mp4" = "mpv.desktop";
          "video/x-matroska" = "mpv.desktop";
          "video/webm" = "mpv.desktop";
          "video/quicktime" = "mpv.desktop";
          "video/x-msvideo" = "mpv.desktop";
          "video/mpeg" = "mpv.desktop";
          "video/x-flv" = "mpv.desktop";
          "video/x-m4v" = "mpv.desktop";
          "video/x-ms-wmv" = "mpv.desktop";
          "video/3gpp" = "mpv.desktop";
          "video/ogg" = "mpv.desktop";
          "video/avi" = "mpv.desktop";
          "video/mkv" = "mpv.desktop";
        };
      };
    })
  ];
}
