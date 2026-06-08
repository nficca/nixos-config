{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  cfg = config.myModules.gtk-theme;
in
{
  options.myModules.gtk-theme.enable = lib.mkEnableOption "WhiteSur-Dark GTK theme with Papirus-Dark icons and WhiteSur cursor for Linux desktop apps";

  config = lib.mkIf cfg.enable {
    home-manager.users.${username} =
      { config, ... }:
      {
        home.pointerCursor = {
          gtk.enable = true;
          x11.enable = true;
          name = "WhiteSur-cursors";
          package = pkgs.whitesur-cursors;
          size = 24;
        };

        gtk = {
          enable = true;
          theme = {
            name = "WhiteSur-Dark";
            package = pkgs.whitesur-gtk-theme;
          };
          iconTheme = {
            name = "Papirus-Dark";
            package = pkgs.papirus-icon-theme;
          };
          # Apply the same theme to GTK4 apps. The home-manager default for this
          # changes to `null` (libadwaita defaults) in stateVersion 26.05.
          gtk4.theme = config.gtk.theme;
        };
      };
  };
}
