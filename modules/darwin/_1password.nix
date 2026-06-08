{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  cfg = config.myModules._1password;
in
{
  options.myModules._1password = {
    cli.enable = lib.mkEnableOption "1Password CLI (op)";
    app.enable = lib.mkEnableOption "1Password GUI app via homebrew cask";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.cli.enable {
      home-manager.users.${username} = {
        home.packages = [ pkgs._1password-cli ];
      };
    })

    # macOS GUI apps don't integrate well when installed via nixpkgs (Launchpad,
    # Dock, Spotlight), so 1Password is delivered as a homebrew cask.
    (lib.mkIf cfg.app.enable {
      homebrew.casks = [ "1password" ];
    })
  ];
}
