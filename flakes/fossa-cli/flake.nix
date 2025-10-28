{
  description = "FOSSA CLI development environment";

  inputs = {
    # Use https://lazamar.co.uk/nix-versions/ to find the commit that contains
    # the desired version of ghc.
    nixpkgs.url = "github:NixOS/nixpkgs/e6f23dc08d3624daab7094b701aa3954923c6bbb";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
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
            name = "fossa-cli";
            packages = [
              ghc
              cabal-install
              haskell-language-server
              haskellPackages.fourmolu
              haskellPackages.cabal-fmt
              haskellPackages.hlint
            ];
            buildInputs = [
              haskellPackages.lzma
              xz.dev
              libiconv
              openssl
              pkg-config
              bzip2
              zlib
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
