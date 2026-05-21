{
  config,
  lib,
  ...
}:

{
  options.myModules.audio.enable = lib.mkEnableOption "PipeWire audio stack with ALSA and PulseAudio compatibility, plus rtkit for realtime scheduling";

  config = lib.mkIf config.myModules.audio.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
