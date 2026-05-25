{
  config,
  lib,
  username,
  ...
}:

let
  cfg = config.myModules.audio;
in
{
  options.myModules.audio = {
    enable = lib.mkEnableOption "PipeWire audio stack with ALSA and PulseAudio compatibility, plus rtkit for realtime scheduling";
    userTools.enable = lib.mkEnableOption "User-space audio control tools via home-manager: pavucontrol (PulseAudio mixer) and playerctl (MPRIS media control)";
  };

  config = lib.mkIf cfg.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Fan out to home-manager so the user tools toggle drives both layers.
    home-manager.users.${username}.myModules.audio.userTools.enable = cfg.userTools.enable;
  };
}
