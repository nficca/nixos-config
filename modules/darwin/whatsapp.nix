{
  config,
  lib,
  ...
}:

{
  options.myModules.whatsapp.enable = lib.mkEnableOption "WhatsApp desktop client via homebrew cask";

  config = lib.mkIf config.myModules.whatsapp.enable {
    homebrew.casks = [ "whatsapp" ];
  };
}
