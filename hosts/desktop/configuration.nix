{
  config,
  username,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "desktop";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users."${username}" = {
    isNormalUser = true;
    description = "Nic";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    "pipe-operators"
  ];

  # FUSE-backed /bin and /usr/bin so non-Nix scripts with FHS shebangs like
  # #!/bin/bash or #!/usr/bin/python3 resolve via the running shell's PATH.
  # See: https://github.com/Mic92/envfs
  services.envfs.enable = true;

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Run unpatched dynamic binaries on NixOS.
  programs.nix-ld.enable = true;

  myModules._1password.enable = true;
  myModules.amd-gpu.enable = true;
  myModules.audio.enable = true;
  myModules.audio.userTools.enable = true;
  myModules.bluetooth.enable = true;
  myModules.creative.obs.enable = true;
  myModules.dank-material-shell.enable = true;
  myModules.dropbox.enable = true;
  myModules.fonts.enable = true;
  myModules.mullvad.enable = true;
  myModules.networkmanager.enable = true;
  myModules.networkmanager.applet.enable = true;
  myModules.niri.enable = true;
  myModules.podman.enable = true;
  myModules.podman.compose.enable = true;
  myModules.printing.enable = true;
  myModules.steam.enable = true;
  myModules.system-packages.enable = true;
  myModules.wireguard.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05";
}
