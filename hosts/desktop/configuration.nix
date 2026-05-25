{
  config,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../shared/configuration/nixos.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  myModules.amd-gpu.enable = true;
  myModules.obs.enable = true;
  myModules.podman.compose.enable = true;

  networking.hostName = "desktop";

  myModules.networkmanager.enable = true;
  myModules.networkmanager.applet.enable = true;
  myModules.wireguard.enable = true;

  myModules.bluetooth.enable = true;

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  myModules.niri.enable = true;
  myModules.dank-material-shell.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  myModules.printing.enable = true;
  myModules.audio.enable = true;

  myModules.mullvad.enable = true;
  myModules._1password.enable = true;

  myModules.steam.enable = true;

  # Run unpatched dynamic binaries on NixOS.
  programs.nix-ld.enable = true;

  myModules.dropbox.enable = true;
}
