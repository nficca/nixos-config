{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  # steam-run's FHS ships GTK4 but not GTK3, while saml2aws's Playwright-downloaded
  # Firefox (the ubuntu20.04 fallback build) is linked against libgtk-3.so.0 and
  # fails to load XPCOM without it. Add gtk3 to the FHS library set explicitly.
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/st/steam/package.nix
  steam-run-gtk3 = (pkgs.steam.override { extraLibraries = p: [ p.gtk3 ]; }).run;

  # One-shot wrapper for the FOSSA EKS/SAML login.
  #
  # steam-run supplies the FHS environment that saml2aws's Playwright-downloaded
  # Firefox needs to run on NixOS.
  #
  # The mkdir is load-bearing: saml2aws persists the Google session to
  # ~/.aws/saml2aws/storageState.json and reloads it next run so an expired AWS
  # credential refresh skips the full Google login. saml2aws never creates that
  # directory itself, and Playwright's StorageState() write fails silently when
  # the parent is missing, so without this line every login starts cold.
  # https://github.com/Versent/saml2aws/blob/v2.36.19/pkg/provider/browser/browser.go
  aws-login = pkgs.writeShellScriptBin "aws-login" ''
    mkdir -p "$HOME/.aws/saml2aws"
    exec ${steam-run-gtk3}/bin/steam-run ${pkgs.saml2aws}/bin/saml2aws login \
      --profile root \
      --region us-west-2 \
      --disable-keychain \
      --browser-type firefox \
      "$@"
  '';
in
{
  options.myModules.aws.enable = lib.mkEnableOption "AWS CLI tools: awscli plus saml2aws for SAML-based credential exchange";

  config = lib.mkIf config.myModules.aws.enable {
    home-manager.users.${username} = {
      home.packages = with pkgs; [
        awscli
        saml2aws
        aws-login
      ];
    };
  };
}
