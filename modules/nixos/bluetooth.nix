{
  config,
  lib,
  ...
}:

{
  options.myModules.bluetooth.enable = lib.mkEnableOption "Bluetooth with blueman GUI and Intel adapter autosuspend workarounds";

  config = lib.mkIf config.myModules.bluetooth.enable {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    services.blueman.enable = true;

    # Disable USB autosuspend for Bluetooth at the driver level.
    #
    # Sometimes Bluetooth dies while actively in use. The kernel tries an HCI
    # reset to recover, but it fails and the only fix is a reboot. This param
    # disables USB autosuspend for the Bluetooth controller, which shouldn't
    # technically cause this issue but may somehow be related.
    #
    # Verify with: cat /sys/module/btusb/parameters/enable_autosuspend  # should be N
    #
    # References:
    # - https://github.com/bluez/bluez/issues/1263
    # - https://www.kernelconfig.io/config_bt_hcibtusb_autosuspend
    # - https://github.com/torvalds/linux/blob/23b0f90ba871f096474e1c27c3d14f455189d2d9/drivers/bluetooth/btusb.c#L35
    boot.kernelParams = [ "btusb.enable_autosuspend=0" ];

    # The kernel param above disables autosuspend at the driver level, but
    # the USB subsystem has its own runtime power management that can still
    # suspend the device. These rules disable that by setting:
    #
    #   power/autosuspend="-1"  Disable autosuspend delay (-1 = never suspend)
    #   power/control="on"      Keep device powered on (vs "auto" which allows suspend)
    #
    # The vendor/product IDs (8087:0a2a) identify the Intel Bluetooth adapter.
    # Find yours with: lsusb | grep -i bluetooth
    #
    # See: https://www.kernel.org/doc/Documentation/usb/power-management.txt
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="8087", ATTR{idProduct}=="0a2a", ATTR{power/autosuspend}="-1"
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="8087", ATTR{idProduct}=="0a2a", ATTR{power/control}="on"
    '';
  };
}
