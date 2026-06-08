{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  cfg = config.myModules.audio;
in
{
  options.myModules.audio = {
    enable = lib.mkEnableOption "PipeWire audio stack with ALSA and PulseAudio compatibility, plus rtkit for realtime scheduling";
    userTools.enable = lib.mkEnableOption "User-space audio control tools: pavucontrol and playerctl";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    })

    (lib.mkIf cfg.userTools.enable {
      home-manager.users.${username} = {
        home.packages = with pkgs; [
          pavucontrol
          playerctl
        ];
      };
    })
  ];
}
