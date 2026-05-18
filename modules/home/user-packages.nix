{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myModules.user-packages.enable = lib.mkEnableOption "baseline user-level CLI tools";

  config = lib.mkIf config.myModules.user-packages.enable {
    home.packages = with pkgs; [
      jless # JSON viewer
      jq # Flexible CLI JSON processor
      lazygit # Terminal UI for git commands
      nh # Modern helper utility for nix commands. https://github.com/nix-community/nh
      pv # Pipeline progress monitoring
      ripgrep # Fast recursive grep
      tree # Depth-indented directory listing
      xh # Tool for sending HTTP requests
    ];

    programs.bat = {
      enable = true;
      # bat --list-themes for other options.
      config.theme = "Coldark-Dark";
    };
  };
}
