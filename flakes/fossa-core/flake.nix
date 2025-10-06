{
  description = "FOSSA Core development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
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
        pkgs = import nixpkgs { inherit system; };

        availableNode =
          if pkgs.lib.hasAttr "nodejs-22_x" pkgs then
            pkgs.nodejs-22_x
          else if pkgs.lib.hasAttr "nodejs_22" pkgs then
            pkgs.nodejs_22
          else if pkgs.lib.hasAttr "nodejs" pkgs then
            pkgs.nodejs
          else
            null;

        # If the selected package supports overrideAttrs we set version+src; otherwise we just use it as-is.
        node =
          if availableNode == null then
            abort "no nodejs package found in this nixpkgs"
          else if pkgs.lib.hasAttr "overrideAttrs" availableNode then
            availableNode.overrideAttrs (old: {
              version = "22.18.0";
              src = pkgs.fetchurl {
                url = "https://nodejs.org/dist/v22.18.0/node-v22.18.0.tar.gz";
                # fill the sha256 if you want nix to fetch/verify the source.
                sha256 = "26247ff9a75ac13f6dac7e07dca6172314554dcf20761675c5435f1e84e6c4b2";
              };
            })
          else
            # last-resort: use the package as-is (likely already the correct major)
            availableNode;
      in
      {
        packages.default = node;

        defaultPackage = self.packages.${system}.default;

        devShells.default = pkgs.mkShell {
          name = "fossa-core";
          buildInputs = [ node ];
        };
      }
    );
}
