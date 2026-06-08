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

  home-manager.users.${username} = {
    home.stateVersion = "25.05";
    home.username = username;
    programs.home-manager.enable = true;
  };

  myModules = {
    _1password.cli.enable = true;
    _1password.app.enable = true;
    amd-gpu.enable = true;
    audio.enable = true;
    audio.userTools.enable = true;
    aws.enable = true;
    bluetooth.enable = true;
    claude-code.enable = true;
    creative.aseprite.enable = true;
    creative.kdenlive.enable = true;
    creative.ldtk.enable = true;
    creative.losslesscut.enable = true;
    creative.obs.enable = true;
    dank-material-shell.enable = true;
    dev-tools.enable = true;
    direnv.enable = true;
    dropbox.enable = true;
    firefox.enable = true;
    firefox.profileHandler.enable = true;
    fonts.enable = true;
    ghostty.enable = true;
    git.enable = true;
    gtk-theme.enable = true;
    ktorrent.enable = true;
    kubernetes.enable = true;
    mpv.enable = true;
    mullvad.enable = true;
    mullvad-browser.enable = true;
    nautilus.enable = true;
    neovim.enable = true;
    networkmanager.enable = true;
    networkmanager.applet.enable = true;
    niri.enable = true;
    podman.enable = true;
    podman.compose.enable = true;
    postgres-cli.enable = true;
    printing.enable = true;
    prismlauncher.enable = true;
    shell.enable = true;
    spotify.enable = true;
    starship.enable = true;
    steam.enable = true;
    system-packages.enable = true;
    tmux.enable = true;
    user-packages.enable = true;
    vesktop.enable = true;
    wayland-tools.enable = true;
    wireguard.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05";
}
