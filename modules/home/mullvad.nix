{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myModules.mullvad.browser.enable = lib.mkEnableOption "Mullvad Browser (privacy-focused Firefox derivative, developed by the Tor Project with Mullvad)";

  config = lib.mkIf config.myModules.mullvad.browser.enable {
    home.packages = [ pkgs.mullvad-browser ];
  };
}
