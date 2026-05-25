{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myModules.wayland-tools;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  options.myModules.wayland-tools.enable = lib.mkEnableOption "Wayland CLI utilities: grim/slurp screenshots, wl-clipboard, and libnotify";

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.enable || isLinux;
          message = "myModules.wayland-tools.enable is set on a non-Linux platform. The wayland-tools module is Linux-only.";
        }
      ];
    }

    (lib.mkIf (cfg.enable && isLinux) {
      home.packages = with pkgs; [
        grim
        slurp
        wl-clipboard-rs
        libnotify
      ];
    })
  ];
}
