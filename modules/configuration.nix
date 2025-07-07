{ globals, pkgs, ... }:

{
  users.users."${globals.username}".shell = pkgs.zsh;

  environment.variables = import ../shared/environment-variables.nix;

  environment.systemPackages = import ../shared/packages.nix {
    inherit pkgs;
  };

  fonts.packages = import ../shared/fonts.nix {
    inherit pkgs;
  };

}
