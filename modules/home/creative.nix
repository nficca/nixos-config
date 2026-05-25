{
  config,
  lib,
  pkgs,
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
    obs.enable = lib.mkEnableOption "OBS Studio with PipeWire audio capture and VAAPI plugins (system-level v4l2loopback for the virtual camera is driven by the NixOS counterpart)";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.aseprite.enable {
      home.packages = [ pkgs.aseprite ];
    })

    (lib.mkIf cfg.ldtk.enable {
      home.packages = [ pkgs.ldtk ];
    })

    (lib.mkIf cfg.kdenlive.enable {
      home.packages = [ pkgs.kdePackages.kdenlive ];
    })

    (lib.mkIf cfg.losslesscut.enable {
      home.packages = [ pkgs.losslesscut-bin ];
    })

    # OBS Studio. Screen capture goes through the PipeWire screencast portal
    # (the "Screen Capture (PipeWire)" source) since niri is not a wlroots
    # compositor, so wlrobs does not apply here. The portal backend is
    # configured at the system level.
    # See: https://wiki.nixos.org/wiki/OBS_Studio
    (lib.mkIf cfg.obs.enable {
      programs.obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          obs-pipewire-audio-capture
          obs-vaapi
        ];
      };
    })
  ];
}
