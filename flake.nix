{
  description = "Nic's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # Manage user configuration with home-manager.
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      globals = import ./globals.nix;
    in
    {
      nixosConfigurations."${globals.host}" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
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
    };
}
