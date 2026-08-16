{
  config,
  lib,
  pkgs,
  username,
  mkRepoSymlink,
  ...
}:

let
  voxtype = pkgs.voxtype-vulkan;
in
{
  options.myModules.voxtype.enable = lib.mkEnableOption "voxtype push-to-talk voice typing daemon (Vulkan-accelerated whisper)";

  config = lib.mkIf config.myModules.voxtype.enable {
    home-manager.users.${username} =
      { config, ... }:
      {
        home.packages = [ voxtype ];

        xdg.configFile."voxtype/config.toml".source =
          mkRepoSymlink config "dotfiles/voxtype/config.toml";

        # nixpkgs builds only the quickshell OSD frontend and ships none of its
        # QML, so the tree comes from the package's own source.
        home.file.".local/share/voxtype/quickshell".source = "${voxtype.src}/quickshell";

        # nixpkgs ships no unit for voxtype; this mirrors upstream's
        # packaging/systemd/voxtype.service. The whisper model is not in the
        # store, so `voxtype setup --download` has to have been run once or the
        # daemon restart-loops.
        systemd.user.services.voxtype = {
          Unit = {
            Description = "voxtype voice typing daemon";
            PartOf = [ "graphical-session.target" ];
            After = [
              "graphical-session.target"
              "pipewire.service"
            ];
          };
          Service = {
            ExecStart = "${voxtype}/bin/voxtype -q daemon";
            Restart = "on-failure";
            RestartSec = 5;
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
  };
}
