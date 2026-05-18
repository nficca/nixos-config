{
  config,
  lib,
  username,
  ...
}:

{
  options.myModules._1password.enable = lib.mkEnableOption "1Password GUI app and CLI integration";

  config = lib.mkIf config.myModules._1password.enable {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ username ];
    };
  };
}
