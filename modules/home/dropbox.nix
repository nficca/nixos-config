{
  config,
  lib,
  options,
  pkgs,
  ...
}:

let
  cfg = config.myModules.dropbox;
  # home-manager's systemd.user is Linux-only (Darwin uses launchd), so guard
  # on the option being declared.
  available = options ? systemd.user.services;
in
{
  options.myModules.dropbox.enable = lib.mkEnableOption "Dropbox client with autostart via systemd user service";

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.enable || available;
          message = "myModules.dropbox.enable is set, but home-manager systemd.user.services is not in scope on this platform. The dropbox module is Linux-only.";
        }
      ];
    }

    (lib.mkIf cfg.enable (lib.optionalAttrs available {
      home.packages = [ pkgs.dropbox ];

      systemd.user.services.dropbox = {
        Unit.Description = "Dropbox";
        Service = {
          ExecStart = "${pkgs.dropbox}/bin/dropbox";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "default.target" ];
      };
    }))
  ];
}
