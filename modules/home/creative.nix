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
    gameArt.enable = lib.mkEnableOption "Game art tooling: aseprite (pixel art editor) and ldtk (2D level editor)";
    videoEditing.enable = lib.mkEnableOption "Video editing tools: kdenlive (non-linear editor) and losslesscut-bin (lossless trim/cut for capture review)";
    obs.enable = lib.mkEnableOption "OBS Studio with PipeWire audio capture and VAAPI plugins (system-level v4l2loopback for the virtual camera is driven by the NixOS counterpart)";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.gameArt.enable {
      home.packages = with pkgs; [
        aseprite
        ldtk
      ];
    })

    (lib.mkIf cfg.videoEditing.enable {
      home.packages = with pkgs; [
        kdePackages.kdenlive
        losslesscut-bin
      ];
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
