# This module creates a user-level flakes registry based on the flakes
# defined in the `flakes` directory.
#
# The flakes directory should contain one directory for each flake,
# where the name of the directory is the name of the flake. E.g.
#
# ```
# flakes
# ├── haskell
# │   ├── flake.lock
# │   └── flake.nix
# ├── node
# │   ├── flake.lock
# │   └── flake.nix
# ├── rust
# │   ├── flake.lock
# │   └── flake.nix
# ...
# ```
#
# With this registry, you can enter a dev shell for a flake by running:
# ```
# nix develop <flake-name>
# ```
# Where the `flake-name` is the name of the sub-directory in `flakes/`
# containing the flake. E.g., `nix develop rust` will enter the rust
# development environment defined in `flakes/rust/flake.nix`.

{ config, lib, ... }:

let
  # All immediate entries in the directory.
  entries = builtins.readDir ../../../flakes;

  # Filter out file entries. Flakes must be in defined in directories.
  flakes = builtins.filter (name: (builtins.getAttr name entries) == "directory") (
    builtins.attrNames entries
  );

  # Create a registry entry for each a flake of the given name.
  # See: https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-registry#registry-format
  mkEntry = name: {
    from = {
      type = "indirect";
      id = name;
    };
    to = {
      type = "path";
      path = "${config.home.homeDirectory}/dev/nficca/nixos-config/flakes/${name}";
    };
  };
in
{
  nix.registry = lib.genAttrs flakes mkEntry;
}
