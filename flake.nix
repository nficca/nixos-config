{
  description = "Nic's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Manage user configuration with home-manager.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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
      home-manager,
      nil,
      ...
    }:
    let
      globals = import ./globals.nix;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosConfigurations."${globals.host}" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit globals; };
        modules = [
          ./configuration.nix

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

      # Dev-shell for editing Nix files in this repository with LSP
      # support and formatting.
      devShells."${system}".default = pkgs.mkShell {
        buildInputs = [
          nil.packages.${system}.default
          pkgs.nixfmt-rfc-style
        ];
      };
    };
}
