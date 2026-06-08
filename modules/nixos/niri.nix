{
  config,
  lib,
  pkgs,
  username,
  niri,
  ...
}:

{
  options.myModules.niri.enable = lib.mkEnableOption "niri scrollable-tiling Wayland compositor (system service plus user dotfiles)";

  config = lib.mkIf config.myModules.niri.enable {
    programs.niri = {
      enable = true;
      package = niri.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    };

    # XDG Desktop Portal provides a D-Bus API that apps use to interact with the
    # desktop (e.g. file chooser dialogs, "show in folder"). Portal backends
    # implement this API per desktop; the config below sets the preferred
    # backend for each portal interface.
    # See: https://www.mankier.com/5/portals.conf
    xdg.portal = {
      extraPortals = [
        pkgs.kdePackages.xdg-desktop-portal-kde
        # ScreenCast on niri is delegated to the GNOME portal backend, which
        # is what OBS PipeWire screen capture and browser screen-sharing use.
        # See: https://github.com/YaLTeR/niri/wiki/Important-Software#xdg-desktop-portal
        pkgs.xdg-desktop-portal-gnome
      ];
      config = {
        niri = {
          "org.freedesktop.impl.portal.FileChooser" = "kde";
          "org.freedesktop.impl.portal.ScreenCast" = "gnome";
        };
      };
    };

    # Hint electron apps to use wayland.
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # niri is not a wlroots compositor, so xwayland-satellite provides X11 app
    # support for clients that don't speak Wayland.
    environment.systemPackages = [ pkgs.xwayland-satellite ];

    home-manager.users.${username} =
      { config, ... }:
      let
        dotfiles = "${config.home.homeDirectory}/dev/nficca/nixos-config/dotfiles/niri";
      in
      {
        xdg.configFile.niri.source =
          config.lib.file.mkOutOfStoreSymlink dotfiles;
      };
  };
}
