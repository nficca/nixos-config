{
  username,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./nginx.nix
  ];

  networking.hostName = "hetzner";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

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

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  home-manager.users.${username} = {
    home.stateVersion = "25.05";
    home.username = username;
    home.homeDirectory = "/home/${username}";
    programs.home-manager.enable = true;
  };

  myModules = {
    _1password.cli.enable = true;
    claude-code.enable = true;
    dev-tools.enable = true;
    direnv.enable = true;
    fonts.enable = true;
    git.enable = true;
    neovim.enable = true;
    networkmanager.enable = true;
    podman.enable = true;
    server.enable = true;
    shell.enable = true;
    starship.enable = true;
    system-packages.enable = true;
    tmux.enable = true;
    user-packages.enable = true;
  };

  # Run a basic Minecraft server.
  services.my-nix-minecraft.servers.vanilla = {
    enable = true;
    symlinks = {
      "world/datapacks" = pkgs.runCommand "datapacks" {} ''
        mkdir -p $out
        for f in ${pkgs.fetchzip {
          url = "https://vanillatweaks.net/download/VanillaTweaks_d259703_UNZIP_ME.zip";
          hash = "sha256-9V84Wi9IEq3AQ/iPmvwYBegrdpH1ibsc2YZabWWgvlg=";
        }}/*; do
          ln -s "$f" $out/
        done
      '';
    };
  };

  system.stateVersion = "25.05";
}
