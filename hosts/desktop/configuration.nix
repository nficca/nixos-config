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

  # Disable suspend/hibernate on this desktop. The RX 9070 XT has unreliable
  # S3 resume on kernel 6.12 (MODE1 GPU resets, SMU version mismatches), and
  # amdgpu suspend/resume bugs are a known cross-kernel issue.
  # See: https://github.com/NixOS/nixpkgs/issues/223690
  # systemd.targets.sleep.enable = false;
  # systemd.targets.suspend.enable = false;
  # systemd.targets.hibernate.enable = false;
  # systemd.targets.hybrid-sleep.enable = false;

  # hardware.graphics.enable32bBit = true;

  networking.hostName = "desktop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  myModules.networkmanager.enable = true;
  myModules.networkmanager.applet.enable = true;
  myModules.wireguard.enable = true;

  myModules.bluetooth.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  # services.xserver.enable = true;

  myModules.niri.enable = true;
  myModules.dank-material-shell.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  myModules.printing.enable = true;
  myModules.audio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  myModules.mullvad.enable = true;
  myModules._1password.enable = true;

  myModules.steam.enable = true;

  # Run unpatched dynamic binaries on NixOS
  programs.nix-ld.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  myModules.dropbox.enable = true;
}
