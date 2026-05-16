{
  config,
  lib,
  username,
  ...
}:

{
  options.myModules.obs.enable = lib.mkEnableOption "OBS Studio (v4l2loopback virtual camera at the system level, programs.obs-studio in home-manager)";

  config = lib.mkIf config.myModules.obs.enable {
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

    # Fan out to the home-manager side so a single toggle drives both layers.
    home-manager.users.${username}.myModules.obs.enable = true;
  };
}
