{
  description = "Nic's Nix Configuration";

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

    # Private development flakes for project-specific environments.
    dev-flakes = {
      url = "git+ssh://git@github.com/nficca/nixos-flakes.git";
      flake = false;
    };

    # Wallpaper daemon for Wayland
    awww.url = "git+https://codeberg.org/LGFae/awww";

    # Quickshell - QML-based shell compositor
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
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
      dev-flakes,
      awww,
      quickshell,
      ...
    }:
    let
      # My username is always "nic" on all systems.
      username = "nic";

      mkNixos =
        {
          config_module,
          home_module,
        }:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit username; };
          modules = [
            config_module

            # Configure nixpkgs with overlays
            {
              nixpkgs.overlays = [
                (import ./overlays)
              ];
            }

            # Configure home-manager as a module so that it is applied
            # whenever system configuration changes are applied.
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = { inherit username dev-flakes awww quickshell; };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users."${username}" = {
                imports = [ home_module ];
              };
            }
          ];
        };

      mkDarwin =
        {
          config_module,
          home_module,
        }:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit username; };
          modules = [
            config_module

            # Configure nixpkgs with overlays
            {
              nixpkgs.overlays = [
                (import ./overlays)
              ];
            }

            # Configure home-manager as a module so that it is applied
            # whenever system configuration changes are applied.
            # The additional benefit of this is that we can share some
            # home-manager configuration between NixOS and Darwin.
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = { inherit username dev-flakes; };
                useGlobalPkgs = true;
                useUserPackages = true;
                users."${username}" = {
                  imports = [ home_module ];
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
                user = username;
                enable = true;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        "desktop" = mkNixos {
          config_module = ./hosts/desktop/configuration.nix;
          home_module = ./hosts/desktop/home.nix;
        };

        "hetzner" = mkNixos {
          config_module = ./hosts/hetzner/configuration.nix;
          home_module = ./hosts/hetzner/home.nix;
        };
      };

      darwinConfigurations = {
        "Nics-MacBook-Air" = mkDarwin {
          config_module = ./hosts/air/configuration.nix;
          home_module = ./hosts/air/home.nix;
        };

        "Nics-MacBook-Pro" = mkDarwin {
          config_module = ./hosts/pro/configuration.nix;
          home_module = ./hosts/pro/home.nix;
        };
      };
    };
}
