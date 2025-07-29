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
  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      home-manager,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      ...
    }:
    let
      common = import ./common.nix;

      mkDarwin =
        {
          modules ? [ ],
          home-modules ? [ ],
        }:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit common; };
          modules = [
            ./shared/configuration

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
                  imports = [ ./shared/home ] ++ home-modules;
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
          ]
          ++ modules;
        };

      mkNixos =
        {
          modules ? [ ],
          home-modules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit common; };
          modules = [
            ./shared/configuration

            # Configure home-manager as a module so that it is applied
            # whenever system configuration changes are applied.
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = { inherit common; };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users."${common.username}" = {
                imports = [ ./shared/home ] ++ home-modules;
              };
            }
          ]
          ++ modules;
        };

    in
    {
      nixosConfigurations = {
        "desktop" = mkNixos { };
      };

      darwinConfigurations = {
        "Nics-MacBook-Air" = mkDarwin { };
        "Nics-MacBook-Pro" = mkDarwin { };
      };
    };
}
