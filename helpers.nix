{ ... }:
let
  listModules =
    dir:
    builtins.map (filename: dir + "/${filename}") (
      builtins.filter (
        filename: filename != "default.nix" && builtins.match ".*\\.nix" filename != null
      ) (builtins.attrNames (builtins.readDir dir))
    );
in
{
  inherit listModules;
}
