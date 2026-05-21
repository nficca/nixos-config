{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myModules.kubernetes.enable = lib.mkEnableOption "Kubernetes tooling: kubectl, kubectx, and the k9s TUI";

  config = lib.mkIf config.myModules.kubernetes.enable {
    home.packages = with pkgs; [
      kubectl
      kubectx
    ];

    programs.k9s.enable = true;
  };
}
