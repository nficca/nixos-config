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

    # The core formulae for homebrew.
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    # An extension of homebrew supporting the administration of GUI
    # macOS applications.
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
      homebrew-core,
      homebrew-cask,
      nil,
      ...
    }:
    let
      common = import ./common.nix;
      nixosSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";
      systems = [
        nixosSystem
        darwinSystem
      ];

      createDarwinConfiguration =
        {
          modules ? [ ],
          home-modules ? [ ],
        }:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit common; };
          modules = [
            # This is the main entry point for nix-darwin (system) configuration.
            ./hosts/darwin/configuration.nix

            # Configure home-manager as a module so that it is applied
            # whenever system configuration changes are applied.
            # The additional benefit of this is that we can share some
            # home-manager configuration between NixOS and Darwin.
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = { inherit common; };
                useGlobalPkgs = true;
                useUserPackages = true;
                users."${common.username}" = {
                  # This is the main entry point for home-manager (user) configuration.
                  imports = [ ./hosts/darwin/home.nix ] ++ home-modules;
                };
              };
            }

            # We use nix-homebrew to install and manage homebrew itself.
            # While nix-darwin has a configurable `homebrew` module, it
            # does not manage the actual installation of homebrew.
            # Importantly, it pins the homebrew installation as well as
            # any declaratively specified taps.
            #
            # Why do we still use homebrew despite having nixpkgs?
            # Unfortunately, many macOS/Darwin GUI applications do not work
            # properly when installed via nixpkgs. This is largely due to
            # difficulties with the generated app bundles in nixpkgs which
            # are either non-existent or don't play nice with the macOS GUI
            # (Launchpad, Dock, Spotlight, etc.).
            #
            # Read more:
            # - https://github.com/nix-darwin/nix-darwin/issues/214
            # - https://www.reddit.com/r/NixOS/comments/1lb8utt/nixdarwin_and_gui_applications/
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                user = common.username;
                enable = true;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }

            # This is the main entry point for homebrew (user) configuration.
            ./hosts/darwin/homebrew.nix
          ] ++ modules;
        };
    in
    {
      nixosConfigurations."desktop" = nixpkgs.lib.nixosSystem {
        system = nixosSystem;
        specialArgs = { inherit common; };
        modules = [
          # This is the main entry point for NixOS (system) configuration.
          ./hosts/nixos/configuration.nix

          # Configure home-manager as a module so that it is applied
          # whenever system configuration changes are applied.
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit common; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."${common.username}" = {
              # This is the main entry point for home-manager (user) configuration.
              imports = [ ./hosts/nixos/home.nix ];
            };
          }
        ];
      };

      darwinConfigurations = {
        "Nics-MacBook-Air" = createDarwinConfiguration { };
        "Nics-MacBook-Pro" = createDarwinConfiguration { };
      };
    }
    // flake-utils.lib.eachSystem systems (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # Dev-shell for editing Nix files in this repository with LSP
        # support and formatting. You can run the following to launch
        # the dev-shell:
        # ```shell
        # nix develop . -c $SHELL
        # ```
        # If you want to launch directly into an editor, you can run:
        # ```shell
        # # This is for VSCode but you can use any editor that supports LSP.
        # nix develop . -c $SHELL -c "code ."
        # ```
        devShells.default = pkgs.mkShell {
          buildInputs = [
            nil.packages.${system}.default
            pkgs.nixfmt-rfc-style
          ];
        };
      }
    );
}
