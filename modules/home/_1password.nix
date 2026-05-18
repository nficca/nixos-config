{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myModules._1password.enable = lib.mkEnableOption "1Password CLI";

  config = lib.mkIf config.myModules._1password.enable {
    home.packages = [ pkgs._1password-cli ];
  };
}
