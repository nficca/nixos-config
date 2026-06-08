{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  options.myModules.mpv.enable = lib.mkEnableOption "mpv with xdg mime defaults for common video formats";

  config = lib.mkIf config.myModules.mpv.enable {
    home-manager.users.${username} = {
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
    };
  };
}
