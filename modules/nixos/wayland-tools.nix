{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  options.myModules.wayland-tools.enable = lib.mkEnableOption "Wayland CLI utilities: grim/slurp screenshots, wl-clipboard, and libnotify";

  config = lib.mkIf config.myModules.wayland-tools.enable {
    home-manager.users.${username} = {
      home.packages = with pkgs; [
        grim
        slurp
        wl-clipboard-rs
        libnotify
      ];
    };
  };
}
