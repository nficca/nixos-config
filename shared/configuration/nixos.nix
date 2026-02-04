{ username, pkgs, ... }:

{
  imports = [ ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    isNormalUser = true;
    description = "Nic";
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
    ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;

  environment.variables = {
    EDITOR = "vim";
  };

  environment.systemPackages = with pkgs; [
    dua # Disk usage analyzer
    git # Version control system
    vim # Text editor
    wget # Network file downloader
    perf # Linux profiling with performance counters
    gnumake # Widely used build automation tool
    gcc # GNU compiler collection
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable experimental features
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    "pipe-operators"
  ];

  # Create /bin/bash symlink for scripts that use #!/bin/bash shebang
  system.activationScripts.binbash = {
    text = ''
      mkdir -p /bin
      ln -sf ${pkgs.bash}/bin/bash /bin/bash
    '';
  };

  # Manage containers, pods, and images with podman.
  # A drop-in replacement for docker.
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;

    # Required for containers under podman-compose to be able to communicate
    defaultNetwork.settings.dns_enabled = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
