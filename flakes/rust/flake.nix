{
  description = "Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      rust-overlay,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      {
        devShells.default =
          with pkgs;
          mkShell {
            name = "rust";
            packages = [
              evcxr
              rust-analyzer
            ];
            buildInputs = [
              openssl
              pkg-config
              bzip2
              (rust-bin.stable.latest.default.override {
                extensions = [ "rust-src" ];
                targets = [ "wasm32-unknown-unknown" ];
              })
            ];
            shellHook = ''
              export PATH="$HOME/.cargo/bin:$PATH"
            '';
          };
        RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
      }
    );
}
