{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../shared/configuration/nixos.nix
    ./nginx.nix
  ];

  myModules.server.enable = true;
  myModules.networkmanager.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "hetzner";

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Run a basic Minecraft server.
  services.my-nix-minecraft.servers.vanilla = {
    enable = true;
    symlinks = {
      "world/datapacks" = pkgs.runCommand "datapacks" {} ''
        mkdir -p $out
        for f in ${pkgs.fetchzip {
          url = "https://vanillatweaks.net/download/VanillaTweaks_d259703_UNZIP_ME.zip";
          hash = "sha256-9V84Wi9IEq3AQ/iPmvwYBegrdpH1ibsc2YZabWWgvlg=";
        }}/*; do
          ln -s "$f" $out/
        done
      '';
    };
  };
}
