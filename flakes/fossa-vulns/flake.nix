{
  description = "FOSSA Vulns development environment";

  inputs = {
    # This pins nixpkgs to a commit containing a specific version of nodejs.
    # If you want to change this version, it might be useful to use
    # https://lazamar.co.uk/nix-versions/ to find the commit that contains
    # the version you want.
    #
    # You may additionally have to change the specific package of node that
    # gets installed (in the packages list in the dev shell) in case the version
    # you're after is not in the main `nodejs` package but in another one like
    # `nodejs_18` or similar.
    nixpkgs.url = "github:NixOS/nixpkgs/55070e598e0e03d1d116c49b9eff322ef07c6ac6";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "fossa-vulns";
          packages = with pkgs; [
            nodejs
          ];
          buildInputs = [ ];
        };
      }
    );
}
