{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myModules.nimbalyst;

  version = "0.60.1";

  src = pkgs.fetchurl {
    url = "https://github.com/nimbalyst/nimbalyst/releases/download/v${version}/Nimbalyst-Linux.AppImage";
    hash = "sha512-cxfRfOXfBEYodWWh3a4pwWbmZPmm6CdVdhOhJpf2quvRCsqkDxI8ImEvPoh3d0dOSCF3q/FlPF47h4rQEv6MxQ==";
  };

  appimageContents = pkgs.appimageTools.extractType2 {
    pname = "nimbalyst";
    inherit version src;
  };

  nimbalyst = pkgs.appimageTools.wrapType2 {
    pname = "nimbalyst";
    inherit version src;

    extraInstallCommands = lib.optionalString cfg.extractIcon ''
      # electron-builder ships a top-level <name>.png in the AppImage root;
      # this is the icon DMS/desktop entries resolve via XDG_DATA_DIRS.
      for png in ${appimageContents}/*.png; do
        install -Dm644 "$png" "$out/share/pixmaps/nimbalyst.png"
        break
      done

      if [ -d ${appimageContents}/usr/share/icons ]; then
        mkdir -p "$out/share/icons"
        cp -r ${appimageContents}/usr/share/icons/. "$out/share/icons/"
      fi
    '';
  };
in
{
  options.myModules.nimbalyst = {
    enable = lib.mkEnableOption "Nimbalyst desktop GUI for parallel Claude Code and Codex sessions";
    extractIcon = lib.mkEnableOption "extracting the Nimbalyst icon from the AppImage";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ nimbalyst ];

    xdg.desktopEntries.nimbalyst = {
      name = "Nimbalyst";
      genericName = "AI Coding Workspace";
      comment = "Visual workspace for parallel Claude Code and Codex sessions";
      exec = "nimbalyst %U";
      icon = if cfg.extractIcon then "nimbalyst" else null;
      terminal = false;
      categories = [
        "Development"
        "IDE"
      ];
    };
  };
}
