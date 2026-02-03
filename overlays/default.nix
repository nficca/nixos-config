# This file defines overlays that extend nixpkgs with custom packages.
# Overlays are functions that take two arguments:
#   - final: the final, fully composed package set
#   - prev: the previous package set (before this overlay)

final: prev:

let
  inherit (prev) lib;

  # Read all .nix files in the packages directory
  packageDir = builtins.readDir ./packages;

  # Automatically import all .nix files as packages
  packages = lib.pipe packageDir [
    # Filter for regular .nix files
    (lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nix" name))
    # Convert each file to a package attribute
    (lib.mapAttrs' (name: _: {
      name = lib.removeSuffix ".nix" name;
      value = final.callPackage (./packages + "/${name}") { };
    }))
  ];
in
packages
