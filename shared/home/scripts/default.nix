{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Each script is read from a separate .sh file in this directory
    (writeShellScriptBin "rebuild" (builtins.readFile ./rebuild.sh))
    # (writeShellScriptBin "another-script" (builtins.readFile ./another-script.sh))
  ];
}
