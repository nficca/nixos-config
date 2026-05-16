{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Driven by modules/nixos/obs.nix: enabling the toggle there fans out to set
  # this one. Setting myModules.obs.enable here directly is supported but will
  # not bring in the system-level v4l2loopback kernel module needed for the
  # OBS virtual camera.
  options.myModules.obs.enable = lib.mkEnableOption "OBS Studio with PipeWire audio capture and VAAPI plugins";

  # OBS Studio. Screen capture goes through the PipeWire screencast portal (the
  # "Screen Capture (PipeWire)" source) since niri is not a wlroots compositor,
  # so wlrobs does not apply here. The portal backend is configured at the
  # system level.
  # See: https://wiki.nixos.org/wiki/OBS_Studio
  config = lib.mkIf config.myModules.obs.enable {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-pipewire-audio-capture
        obs-vaapi
      ];
    };
  };
}
