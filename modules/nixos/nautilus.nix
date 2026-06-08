{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  options.myModules.nautilus.enable = lib.mkEnableOption "nautilus (GNOME file manager) registered as the default handler for inode/directory";

  config = lib.mkIf config.myModules.nautilus.enable {
    home-manager.users.${username} = {
      home.packages = [ pkgs.nautilus ];

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "inode/directory" = "org.gnome.Nautilus.desktop";
        };
      };
    };
  };
}
