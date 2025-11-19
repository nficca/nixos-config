# This module creates a user-level flakes registry based on the flakes
# defined in the `dev-flakes` input.
#
# The `dev-flakes` input should be a directory containing one subdirectory for
# each flake, where the name of the directory is the name of the flake. E.g.
#
# ```
# dev-flakes
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
# Where the `flake-name` is the name of the sub-directory in `dev-flakes`
# containing the flake.

{ lib, dev-flakes ? null, ... }:

let
  # All immediate entries in the dev-flakes input directory.
  # If dev-flakes is not available (e.g., during bootstrap), use empty set.
  entries = if dev-flakes != null then builtins.readDir dev-flakes else {};

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
      path = "${dev-flakes}/${name}";
    };
  };
in
{
  nix.registry = lib.genAttrs flakes mkEntry;
}
