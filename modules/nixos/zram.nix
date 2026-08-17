{
  config,
  lib,
  ...
}:

{
  options.myModules.zram.enable = lib.mkEnableOption "zram compressed swap in RAM";

  config = lib.mkIf config.myModules.zram.enable {
    zramSwap = {
      enable = true;

      # Swapping to the NVMe is what makes the machine unresponsive under
      # pressure. Compressing in RAM keeps reclaim fast enough that earlyoom
      # still gets scheduled.
      algorithm = "zstd";
      memoryPercent = 50;
    };
  };
}
