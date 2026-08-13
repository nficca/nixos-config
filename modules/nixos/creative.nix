{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  cfg = config.myModules.creative;

  # fmt 12.2 no longer exposes fmt::format through fmt/core.h.
  # https://github.com/NixOS/nixpkgs/issues/552132
  #
  # Fixed on nixpkgs master but not yet in nixpkgs-unstable:
  # https://github.com/NixOS/nixpkgs/pull/552085
  #
  # The warning is a recheck prompt. If a newer aseprite still needs this,
  # bump the version in the condition.
  aseprite =
    lib.warnIf
      (pkgs.aseprite.version != "1.3.18.1" || lib.hasInfix "fmt/format.h" pkgs.aseprite.postPatch)
      "recheck whether the aseprite fmt override in modules/nixos/creative.nix is still needed"
      (
        pkgs.aseprite.overrideAttrs (old: {
          postPatch = old.postPatch + ''
            substituteInPlace src/app/i18n/strings.h \
              --replace-fail '"fmt/core.h"' '"fmt/format.h"'
          '';
        })
      );
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
      home-manager.users.${username}.home.packages = [ aseprite ];
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
