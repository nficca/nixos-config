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
  vscode-langservers-extracted = pkgs.callPackage ./vscode-langservers-extracted.nix { };
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
