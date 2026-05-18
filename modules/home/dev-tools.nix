{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myModules.dev-tools.enable = lib.mkEnableOption "language servers, formatters, and build tools";

  config = lib.mkIf config.myModules.dev-tools.enable {
    home.packages =
      (with pkgs; [
        cmake # Cross-platform build system generator
        clang-tools # clangd LSP + clang-format
        cmake-language-server
        kdePackages.qtdeclarative # QML language tooling
        lua-language-server
        nil # Nix LSP
        nixfmt # Nix formatter
        prettier # JS/TS/CSS/HTML/JSON/YAML formatter
        ruby-lsp
        typescript-language-server
        vscode-langservers-extracted # HTML/CSS/JSON/ESLint LSPs
      ])
      ++ lib.optionals pkgs.stdenv.isLinux (with pkgs; [
        # valgrind is marked broken on Darwin in nixpkgs.
        valgrind # Memory profiler
      ]);
  };
}
