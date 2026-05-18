{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myModules.system-packages.enable = lib.mkEnableOption "baseline system packages and EDITOR default";

  config = lib.mkIf config.myModules.system-packages.enable {
    environment.variables.EDITOR = "vim";

    environment.systemPackages = with pkgs; [
      dua # Disk usage analyzer
      file # Show the type of a file
      gcc # GNU compiler collection
      git # Version control system
      gnumake # Widely used build automation tool
      musl # Better libc implementation
      perf # Linux profiling with performance counters
      vim # Text editor
      wget # Network file downloader
    ];
  };
}
