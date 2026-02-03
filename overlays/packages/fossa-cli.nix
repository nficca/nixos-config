{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

let
  version = "3.15.5";

  packageData = {
    "x86_64-linux" = {
      inherit version;
      os = "linux";
      arch = "amd64";
      sha256 = "0y57vyzi6q1949zyfkmai6ppjd5lzx4mam34bdbzxz6ribg0rl2g";
    };
    "aarch64-linux" = {
      inherit version;
      os = "linux";
      arch = "arm64";
      sha256 = "0px2z02pbf8s2qc3v6cf8wiygdxmw2sfrdrabww8qqisfc1wxhpl";
    };
    "x86_64-darwin" = {
      inherit version;
      os = "darwin";
      arch = "amd64";
      sha256 = "0i59742w68fb5h646wnqxih445zf4akg8r0fybrgszwpwymss1kr";
    };
    "aarch64-darwin" = {
      inherit version;
      os = "darwin";
      arch = "arm64";
      sha256 = "10fqzz2yfx1n2bdww61p1yj8id3d7hqrnm8f2wq1lihsznhrrxdh";
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
