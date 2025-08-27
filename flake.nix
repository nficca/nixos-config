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
      # My username is always "nic" on all systems.
      username = "nic";

      # This is the basic list of homebrew casks that will be installed
      # on all Darwin systems. Additional casks can be added on a per-host
      # basis.
      casks = [
        "google-chrome" # Web browser
        "1password" # Password manager
        "slack" # Team communication
        "ghostty" # Platform-native terminal emulator
        "visual-studio-code" # Open-source code editor
        "whatsapp" # Messaging and calling
      ];

      mkNixos =
        {
          modules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit username; };
          modules = [
            ./configuration/common.nix
            ./configuration/nixos.nix

            # Configure home-manager as a module so that it is applied
            # whenever system configuration changes are applied.
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = { inherit username; };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users."${username}" = {
                imports = [
                  ./home/common.nix
                  ./home/nixos.nix
                ];
              };
            }
          ]
          ++ modules;
        };

      mkDarwin =
        {
          extraCasks ? [ ],
        }:
        nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit username;
            casks = casks ++ extraCasks;
          };
          modules = [
            ./configuration/common.nix
            ./configuration/darwin.nix

            # Configure home-manager as a module so that it is applied
            # whenever system configuration changes are applied.
            # The additional benefit of this is that we can share some
            # home-manager configuration between NixOS and Darwin.
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = { inherit username; };
                useGlobalPkgs = true;
                useUserPackages = true;
                users."${username}" = {
                  imports = [
                    ./home/common.nix
                    ./home/darwin.nix
                  ];
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
        "desktop" = mkNixos { modules = [ ./hosts/deskop ]; };
        "hetzner" = mkNixos { modules = [ ./hosts/hetzner ]; };
      };

      darwinConfigurations = {
        "Nics-MacBook-Air" = mkDarwin {
          extraCasks = [
            "discord" # Group chat and VoIP application
            "folx" # Download manager and torrent client
            "steam" # Video game distribution platform
          ];
        };
        "Nics-MacBook-Pro" = mkDarwin {
          extraCasks = [
            "notion" # Note-taking and organization tool
          ];
        };
      };
    };
}
