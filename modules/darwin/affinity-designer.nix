{
  config,
  lib,
  ...
}:

{
  options.myModules.affinity-designer.enable = lib.mkEnableOption "Affinity Designer (professional vector graphic design) via homebrew cask";

  config = lib.mkIf config.myModules.affinity-designer.enable {
    homebrew.casks = [ "affinity-designer" ];
  };
}
