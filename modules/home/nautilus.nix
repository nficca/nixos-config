{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myModules.nautilus;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  options.myModules.nautilus.enable = lib.mkEnableOption "nautilus (GNOME file manager) registered as the default handler for inode/directory (Linux-only)";

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.enable || isLinux;
          message = "myModules.nautilus.enable is Linux-only (GNOME file manager with xdg.mimeApps).";
        }
      ];
    }

    (lib.mkIf (cfg.enable && isLinux) {
      home.packages = [ pkgs.nautilus ];

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "inode/directory" = "org.gnome.Nautilus.desktop";
        };
      };
    })
  ];
}
