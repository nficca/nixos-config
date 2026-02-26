{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

let
  # Use nix-prefetch-url to get the sha256 values for each download after
  # updating this version.
  #
  # Example:
  # $ nix-prefetch-url https://github.com/fossas/fossa-cli/releases/download/v3.16.0/fossa_3.16.0_linux_amd64.tar.gz
  version = "3.16.0";

  packageData = {
    "x86_64-linux" = {
      inherit version;
      os = "linux";
      arch = "amd64";
      sha256 = "1kzrl748d6rp3qp2lq8aan483ny5bcayfjfx6lw0160ibwlg5r4n";
    };
    "aarch64-linux" = {
      inherit version;
      os = "linux";
      arch = "arm64";
      sha256 = "166hp2nx53af7r2l4axsgxxmkhnvmcvcf5b8pn13z939xw6db81h";
    };
    "x86_64-darwin" = {
      inherit version;
      os = "darwin";
      arch = "amd64";
      sha256 = "1lgia6c7jxcniclz4zwdx35mziji72rb3mwmw7k0al57p4h5qiyp";
    };
    "aarch64-darwin" = {
      inherit version;
      os = "darwin";
      arch = "arm64";
      sha256 = "0mh0vzn0q838b5lcli01896k70w7blz19lj93n195nysg3hp900m";
    };
  };

  package = packageData.${stdenv.system} or (throw "Unsupported platform: ${stdenv.system}");

  extension = if stdenv.isDarwin then "zip" else "tar.gz";
  filename = "fossa_${package.version}_${package.os}_${package.arch}.${extension}";
  url = "https://github.com/fossas/fossa-cli/releases/download/v${package.version}/${filename}";
in
stdenv.mkDerivation {
  pname = "fossa-cli";
  version = package.version;

  # Fetch the release archive from GitHub
  src = fetchurl {
    url = url;
    sha256 = package.sha256;
  };

  # Unzip is needed to extract Darwin (zip) releases
  nativeBuildInputs = lib.optionals stdenv.isDarwin [ unzip ];

  # The archive unpacks directly into the current directory (no subdirectory)
  sourceRoot = ".";

  # Install phase: extract and install the binary
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m755 -D fossa $out/bin/fossa

    runHook postInstall
  '';

  meta = with lib; {
    description = "Fast, portable and reliable dependency analysis for any codebase";
    homepage = "https://github.com/fossas/fossa-cli";
    license = licenses.cpal10;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    maintainers = [ ];
  };
}
