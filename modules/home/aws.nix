{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myModules.aws.enable = lib.mkEnableOption "AWS CLI tools: awscli plus saml2aws for SAML-based credential exchange";

  config = lib.mkIf config.myModules.aws.enable {
    home.packages = with pkgs; [
      awscli
      saml2aws
    ];
  };
}
