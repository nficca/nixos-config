{
  config,
  lib,
  ...
}:

{
  options.myModules.earlyoom.enable = lib.mkEnableOption "earlyoom, which kills the largest process before memory exhaustion locks up the machine";

  config = lib.mkIf config.myModules.earlyoom.enable {
    services.earlyoom = {
      enable = true;
      freeMemThreshold = 10;
      freeMemKillThreshold = 5;

      # earlyoom acts only when available memory and free swap are both under
      # their thresholds. A process growing by gigabytes per second exhausts RAM
      # long before it fills 24 GB of swap, so a low swap threshold never
      # arrives in time. 100 reduces this half of the test to "any swap in use".
      # See: https://github.com/rfjakob/earlyoom#command-line-options
      freeSwapThreshold = 100;
      freeSwapKillThreshold = 100;

      enableNotifications = true;

      # Matched against /proc/<pid>/comm, which truncates to 15 characters.
      extraArgs = [
        "--prefer"
        "claude"

        # Killing the compositor or shell takes the session down with it.
        "--avoid"
        "(niri|niri-session|quickshell-wra|dbus-broker|systemd)$"
      ];
    };
  };
}
