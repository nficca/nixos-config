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

    environment.systemPackages =
      (with pkgs; [
        dua # Disk usage analyzer
        git # Version control system
        gnumake # Widely used build automation tool
        vim # Text editor
        wget # Network file downloader
      ])
      ++ lib.optionals pkgs.stdenv.isLinux (with pkgs; [
        file # Show the type of a file
        gcc # GNU compiler collection
        musl # Better libc implementation
        perf # Linux profiling with performance counters
      ]);
  };
}
