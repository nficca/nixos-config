{
  config,
  lib,
  options,
  ...
}:

let
  cfg = config.myModules.dank-material-shell;
  # programs.dank-material-shell is declared by dms.homeModules.default, which
  # is only imported into the NixOS home-manager (see flake.nix).
  available = options ? programs.dank-material-shell;
  dotfiles = "${config.home.homeDirectory}/dev/nficca/nixos-config/shared/home/dotfiles/DankMaterialShell";
in
{
  options.myModules.dank-material-shell.enable = lib.mkEnableOption "DankMaterialShell desktop shell (launcher, wallpapers, lock, idle)";

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.enable || available;
          message = "myModules.dank-material-shell.enable is set, but the DankMaterialShell home-manager module is not in scope on this platform. DMS is Linux-only.";
        }
      ];
    }

    (lib.mkIf cfg.enable (lib.optionalAttrs available {
      # The home-manager module handles quickshell, the systemd service, and packages.
      # After installing a plugin, it must be manually enabled in DMS Settings > Plugins.
      programs.dank-material-shell = {
        enable = true;
        systemd.enable = true;
        plugins.calculator.enable = true;
      };

      xdg.configFile."DankMaterialShell/settings.json".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfiles}/settings.json";
      xdg.configFile."DankMaterialShell/wallpapers".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfiles}/wallpapers";
    }))
  ];
}
