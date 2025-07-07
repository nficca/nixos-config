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

    # Use homebrew to manage software on Darwin systems.
    # This is especially useful for managing macOS GUI applications,
    # as they are often broken or otherwise not available in nixpkgs.
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

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
      flake-utils,
      home-manager,
      nix-homebrew,
      homebrew-bundle,
      homebrew-core,
      homebrew-cask,
      nil,
      ...
    }:
    let
      globals = import ./globals.nix;
      nixosSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";
      systems = [
        nixosSystem
        darwinSystem
      ];
    in
    {
      nixosConfigurations."${globals.host}" = nixpkgs.lib.nixosSystem {
        system = nixosSystem;
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
              imports = [ ./hosts/nixos/home.nix ];
            };
          }
        ];
      };

      darwinConfigurations."Nics-MacBook-Air" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit globals; };
        modules = [
          ./hosts/darwin/configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = { inherit globals; };
              useGlobalPkgs = true;
              useUserPackages = true;
              users."${globals.username}" = {
                imports = [ ./hosts/darwin/home.nix ];
              };
            };
          }
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              user = globals.username;
              enable = true;
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
              };
              mutableTaps = false;
              autoMigrate = true;
            };
            homebrew = {
              enable = true;
              user = globals.username;
              casks = [
                "google-chrome"
              ];
            };
          }

        ];
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
