{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  # Locally built fix for vscode-langservers-extracted; the package file has the
  # full rationale and a note on when to drop it.
  #
  # Tripwire: the broken release is pinned at 4.10.0 and the VSCodium-sourced
  # rework re-based the version (to 1.121.x), so "no longer 4.10.0" is the
  # signal that the fix has reached our channel. Warn on every rebuild once that
  # happens so we remember to delete the local build and revert to upstream.
  vscode-langservers-extracted =
    lib.warnIf (pkgs.vscode-langservers-extracted.version != "4.10.0")
      ''
        vscode-langservers-extracted in nixpkgs is now ${pkgs.vscode-langservers-extracted.version}, no longer the broken 4.10.0.
        The upstream Node 24 fix has likely landed: delete
        modules/shared/dev-tools/vscode-langservers-extracted.nix and use
        pkgs.vscode-langservers-extracted in this module instead.
      ''
      (pkgs.callPackage ./vscode-langservers-extracted.nix { });
in
{
  options.myModules.dev-tools.enable = lib.mkEnableOption "language servers, formatters, and build tools";

  config = lib.mkIf config.myModules.dev-tools.enable {
    home-manager.users.${username}.home.packages =
      (with pkgs; [
        cmake # Cross-platform build system generator
        clang-tools # clangd LSP + clang-format
        cmake-language-server
        kdePackages.qtdeclarative # QML language tooling
        lua-language-server
        nil # Nix LSP
        nixfmt # Nix formatter
        prettier # JS/TS/CSS/HTML/JSON/YAML formatter
        ron-lsp # RON (Rusty Object Notation) LSP
        ruby-lsp
        typescript-language-server
      ])
      ++ [
        # Built locally from VSCodium, see ./vscode-langservers-extracted.nix.
        vscode-langservers-extracted # HTML/CSS/JSON/ESLint LSPs
      ]
      ++ lib.optionals pkgs.stdenv.isLinux (with pkgs; [
        heaptrack # Heap memory profiler
        # valgrind is marked broken on Darwin in nixpkgs.
        valgrind # Memory profiler
      ]);
  };
}
