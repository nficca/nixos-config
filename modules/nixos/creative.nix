{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  cfg = config.myModules.creative;
in
{
  options.myModules.creative = {
    aseprite.enable = lib.mkEnableOption "aseprite (pixel art editor)";
    ldtk.enable = lib.mkEnableOption "ldtk (2D level editor)";
    kdenlive.enable = lib.mkEnableOption "kdenlive (non-linear video editor)";
    losslesscut.enable = lib.mkEnableOption "losslesscut (lossless trim/cut for video/audio, often used on capture review)";
    obs.enable = lib.mkEnableOption "OBS Studio with PipeWire audio capture and VAAPI plugins, plus v4l2loopback for the virtual camera";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.aseprite.enable {
      home-manager.users.${username}.home.packages = [ pkgs.aseprite ];
    })

    (lib.mkIf cfg.ldtk.enable {
      home-manager.users.${username}.home.packages = [ pkgs.ldtk ];
    })

    (lib.mkIf cfg.kdenlive.enable {
      home-manager.users.${username}.home.packages = [ pkgs.kdePackages.kdenlive ];
    })

    (lib.mkIf cfg.losslesscut.enable {
      home-manager.users.${username}.home.packages = [ pkgs.losslesscut-bin ];
    })

    (lib.mkIf cfg.obs.enable {
      # v4l2loopback for OBS Studio's virtual camera. Exposes a /dev/video device
      # that OBS can write to, which apps like Zoom/Meet/Discord/Firefox then see
      # as a regular webcam. exclusive_caps=1 is required for Chromium-based apps
      # to recognise the device.
      # See: https://wiki.nixos.org/wiki/OBS_Studio#Virtual_Camera_Support
      boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
      boot.kernelModules = [ "v4l2loopback" ];
      boot.extraModprobeConfig = ''
        options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
      '';

      # OBS Studio user-side. Screen capture goes through the PipeWire screencast
      # portal (the "Screen Capture (PipeWire)" source) since niri is not a
      # wlroots compositor, so wlrobs does not apply here. The portal backend is
      # configured at the system level.
      # See: https://wiki.nixos.org/wiki/OBS_Studio
      home-manager.users.${username}.programs.obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          obs-pipewire-audio-capture
          obs-vaapi
        ];
      };
    })
  ];
}
