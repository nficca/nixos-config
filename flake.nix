{
  description = "Nic's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Manage macOS
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Manage user configuration with home-manager.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pure nix flake utility functions
    flake-utils.url = "github:numtide/flake-utils";

    # Nix language server support. Useful when editing Nix files
    # with an editor that supports LSP.
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      home-manager,
      flake-utils,
      nil,
      ...
    }:
    let
      globals = import ./globals.nix;
      linuxSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";
      systems = [
        linuxSystem
        darwinSystem
      ];
    in
    {
      nixosConfigurations."${globals.host}" = nixpkgs.lib.nixosSystem {
        system = linuxSystem;
        specialArgs = { inherit globals; };
        modules = [
          ./hosts/desktop/configuration.nix

          # Configure home-manager as a module so that it is applied
          # whenever system configuration changes are applied.
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit globals; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."${globals.username}" = {
              imports = [ ./home.nix ];
            };
          }
        ];
      };

      darwinConfigurations."Nics-MacBook-Air" = nix-darwin.lib.darwinSystem {
        modules = [ ./hosts/air/configuration.nix ];
      };
    }
    // flake-utils.lib.eachSystemPassThrough systems (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # Dev-shell for editing Nix files in this repository with LSP
        # support and formatting.
        devShells."${system}".default = pkgs.mkShell {
          buildInputs = [
            nil.packages.${system}.default
            pkgs.nixfmt-rfc-style
          ];
        };
      }
    );
}
