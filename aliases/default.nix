{ lib, ... }:

lib.attrsets.mergeAttrsList [
  (import ./git.nix)
]
