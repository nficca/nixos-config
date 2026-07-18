{
  config,
  lib,
  ...
}:

{
  options.myModules.xbox-controller.enable = lib.mkEnableOption "Xbox Elite Series 2 controller support over Bluetooth via the xpadneo driver";

  # The in-kernel xpad driver handles wired Xbox pads but is poor over
  # Bluetooth: no force feedback, no battery reporting, and wrong button
  # mapping. xpadneo is a Bluetooth-focused replacement that adds rumble,
  # trigger force feedback, battery level, correct axis ranges, hardware
  # profile switching, and exposes the Elite paddles as extra buttons. It
  # also flips on hardware.bluetooth.enable (already on via the bluetooth
  # module, so this is a harmless overlap).
  #
  # Custom paddle mappings and sensitivity curves cannot be uploaded from
  # Linux; configure those on Windows/Xbox first and they persist in the
  # controller's onboard memory and carry over here.
  #
  # See: https://atar-axis.github.io/xpadneo/
  config = lib.mkIf config.myModules.xbox-controller.enable {
    hardware.xpadneo.enable = true;
  };
}
