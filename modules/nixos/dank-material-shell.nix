{
  config,
  lib,
  username,
  ...
}:

let
  cfg = config.myModules.dank-material-shell;
in
{
  options.myModules.dank-material-shell.enable = lib.mkEnableOption "DankMaterialShell desktop shell (greeter at system layer, plus user-level shell/launcher/wallpapers/lock/idle via home-manager)";

  config = lib.mkIf cfg.enable {
    # dankgreeter uses greetd internally, bypassing xsession-wrapper. This
    # means the niri systemd-aware patch is not needed at the greeter layer.
    programs.dank-material-shell.greeter = {
      enable = true;
      compositor.name = "niri";
    };

    home-manager.users.${username} =
      { config, ... }:
      let
        dotfiles = "${config.home.homeDirectory}/dev/nficca/nixos-config/dotfiles/DankMaterialShell";
      in
      {
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
      };
  };
}
