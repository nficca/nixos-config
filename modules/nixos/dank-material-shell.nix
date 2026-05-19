{
  config,
  lib,
  ...
}:

{
  options.myModules.dank-material-shell.enable = lib.mkEnableOption "DankMaterialShell greeter (login screen via greetd)";

  config = lib.mkIf config.myModules.dank-material-shell.enable {
    # dankgreeter uses greetd internally, bypassing xsession-wrapper. This
    # means the niri systemd-aware patch is not needed at the greeter layer.
    programs.dank-material-shell.greeter = {
      enable = true;
      compositor.name = "niri";
    };
  };
}
