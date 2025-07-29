{
  description = "FOSSA Core development environment";

  inputs = {
    # This pins nixpkgs to the specific commit containing nodejs 18.20.5.
    # If you want to change this, it might be useful to use https://lazamar.co.uk/nix-versions/
    # to find the commit that contains the version you want.
    nixpkgs.url = "github:NixOS/nixpkgs/c792c60b8a97daa7efe41a6e4954497ae410e0c1";
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
          name = "fossa-core";
          packages = with pkgs; [
            nodejs_18
          ];
          buildInputs = [ ];
        };
      }
    );
}
