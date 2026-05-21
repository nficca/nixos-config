{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myModules.amd-gpu.enable = lib.mkEnableOption "AMD GPU support: amdgpu in initrd, plus a kernel 6.12 pin to work around RX 9070 XT hard freezes on newer kernels";

  config = lib.mkIf config.myModules.amd-gpu.enable {
    # Pin to kernel 6.12 to test whether the kernel jump (6.12 -> 6.18/6.19)
    # is causing RX 9070 XT hard freezes.
    # See: ~/Dropbox/rx-9070-xt-crash-investigation.md
    boot.kernelPackages = pkgs.linuxPackages_6_12;

    # See: https://nixos.wiki/wiki/AMD_GPU
    boot.initrd.kernelModules = [ "amdgpu" ];
  };
}
