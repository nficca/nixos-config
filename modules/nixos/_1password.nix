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
    app.enable = lib.mkEnableOption "1Password GUI app via programs._1password-gui with polkit integration";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.cli.enable {
      home-manager.users.${username} = {
        home.packages = [ pkgs._1password-cli ];
      };
    })

    (lib.mkIf cfg.app.enable {
      programs._1password.enable = true;
      programs._1password-gui = {
        enable = true;
        polkitPolicyOwners = [ username ];
      };
    })
  ];
}
