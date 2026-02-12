{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../shared/configuration/nixos.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Fix Intel Bluetooth HCI reset timeout issue
  # See: https://github.com/bluez/bluez/issues/1263
  boot.kernelParams = [ "btintel.enable_hci_reset=0" ];

  # The following is AMD GPU configuration per
  # https://nixos.wiki/wiki/AMD_GPU
  boot.initrd.kernelModules = [ "amdgpu" ];
  # hardware.graphics.enable32bBit = true;

  networking.hostName = "desktop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.wireguard.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  # services.xserver.enable = true;

  # Use ly login manager (TUI display manager)
  services.displayManager.ly = {
    enable = true;
    # Patch the xsession-wrapper to recognize other window compositors as
    # systemd-aware.
    #
    # NixOS display managers (including ly) use xsession-wrapper as a universal
    # session entry point for both X11 and Wayland sessions. The wrapper handles
    # environment setup, imports variables into systemd, and checks if the
    # session is systemd-aware. Without this patch, the wrapper determines that
    # our Wayland compositor (e.g. hyprland, niri, etc.) is not systemd-aware
    # and triggers nixos-fake-graphical-session.target. This is bad because that
    # target BindsTo graphical-session.target, causing it to start immediately
    # at login, before the compositor service is ready. This bypasses the
    # Before= ordering constraint in the compositor service, resulting in
    # autostart applications and other graphical services launching before the
    # compositor is running, which causes them to fail.
    #
    # Read more about this here:
    # https://github.com/YaLTeR/niri/issues/3177#issuecomment-3765266141
    #
    # Implementation: We use pkgs.runCommand to create a patched version of the
    # xsession-wrapper script. The original wrapper checks if
    # XDG_CURRENT_DESKTOP matches a hardcoded list of systemd-aware sessions in
    # a bash case statement. We use substituteInPlace to add whichever
    # compositors we might want to use to that pattern so that they are
    # recognized as systemd-aware. The --replace-fail flag ensures the build
    # fails if the pattern changes upstream, alerting us to update the patch.
    settings.setup_cmd =
      let
        xsession-wrapper =
          pkgs.runCommand "xsession-wrapper-fixed"
            {
              src = config.services.displayManager.sessionData.wrapper;
            }
            ''
              cp --preserve=mode $src $out
              substituteInPlace $out --replace-fail \
                "KDE|GNOME|Pantheon|X-NIXOS-SYSTEMD-AWARE" \
                "KDE|GNOME|Pantheon|X-NIXOS-SYSTEMD-AWARE|niri|Hyprland"
            '';
      in
      "${xsession-wrapper}";
  };

  # You should enable at least one desktop environment or compositor.
  #
  # KDE Plasma is a fully-fledged desktop environment that includes a window
  # compositor, taskbar, and many more standard applications. It's a good option
  # to get everything you need out of the box.
  services.desktopManager.plasma6.enable = false;
  # Niri is a scrollable-tiling Wayland compositor. It's just the compositor,
  # so everything else must be installed separately.
  programs.niri.enable = true;
  # Hyprland is a modern Wayland compositor with dynamic tiling and powerful
  # plugins. It's also just a compositor.
  programs.hyprland = {
    enable = true;
    # Use UWSM (Universal Wayland Session Manager) for proper systemd integration.
    # This ensures graphical-session.target starts/stops correctly on
    # login/logout.
    withUWSM = true;
  };

  # Hint electon apps to use wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    # Install xwayland-satellite for X11 app support in Niri
    xwayland-satellite
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable avahi local network service discovery.
  # This is useful for things like finding printers.
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.avahi.nssmdns6 = true;
  services.avahi.openFirewall = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable Mullvad VPN; this is a paid private VPN service for personal use.
  # See: https://mullvad.net/en
  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.package = pkgs.mullvad-vpn;

  # Install Steam
  # Ideally this would be done via home-manager or otherwise not
  # system-wide. Unfortunately, steam needs to do some specific
  # system configurations that home-manager doesn't have the
  # privileges to do.
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

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

  # Open ports in the firewall for Dropbox LAN sync
  networking.firewall.allowedTCPPorts = [ 17500 ];
  networking.firewall.allowedUDPPorts = [ 17500 ];
}
