{
  description = ''
    Nix development environment.

    This flake does not install the nix package manager itself
    (because how would you use this without already having Nix
    installed), but provides a useful development environment
    when working with the Nix language.

    Particularly, this includes the Nix language server, `nil`,
    as well as the `nixfmt` tool.
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nil,
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
          name = "nix";
          buildInputs = [
            nil.packages.${system}.default
            pkgs.nixfmt-rfc-style
          ];
        };
      }
    );
}
