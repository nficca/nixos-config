{
  description = "Haskell development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
          name = "haskell";
          packages = with pkgs; [
            zlib
            bzip2
            haskell.compiler.ghc984Binary
            cabal-install
            haskell-language-server
            hlint
            fourmolu
          ];
          buildInputs = [
          ];
        };
      }
    );
}
