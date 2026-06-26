# vscode-langservers-extracted built locally from VSCodium's own server
# bundles.
#
# Why not pkgs.vscode-langservers-extracted: the 4.10.0 build in our pinned
# nixpkgs-unstable ships the json/html/css/eslint servers as a bundle that
# calls require() but that Node 24 loads as an ES module, so every server
# crashes on startup with "require is not defined in ES module scope". nixpkgs
# reworked the package to extract the servers from VSCodium instead
# (https://github.com/NixOS/nixpkgs/issues/531366, PR #531798). That fix is in
# nixos-unstable but has not reached our nixpkgs-unstable channel yet, so we
# build the reworked derivation here against our own pkgs.
#
# Verbatim copy of nixpkgs pkgs/by-name/vs/vscode-langservers-extracted.
# Remove this file and use pkgs.vscode-langservers-extracted once the channel
# ships >= 1.121.x.
{
  lib,
  stdenvNoCC,
  vscodium,
  vscode-extensions,
  nodejs-slim,
  makeBinaryWrapper,
  unzip,
  runCommandLocal,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (vscodium) version src;
  pname = "vscode-langservers-extracted";

  sourceRoot =
    if stdenvNoCC.hostPlatform.isDarwin then
      "VSCodium.app/Contents/Resources/app/extensions"
    else
      "resources/app/extensions";

  nativeBuildInputs = [
    makeBinaryWrapper
  ]
  # The Darwin release is a zip.
  # stdenv unpacks the Linux tarball (tar.gz) natively.
  ++ lib.optionals stdenvNoCC.hostPlatform.isDarwin [
    unzip
  ];

  __structuredAttrs = true;
  strictDeps = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    for language in css html json; do
      server="$language-language-features/server/dist/node/''${language}ServerMain.js"
      install -Dm644 "$server" \
        "$out/lib/extensions/$server"
      makeBinaryWrapper ${lib.getExe nodejs-slim} "$out/bin/vscode-$language-language-server" \
        --add-flag "$out/lib/extensions/$server"
    done

    server="eslint-language-features/server/out/eslintServer.js"
    install -Dm644 "${vscode-extensions.dbaeumer.vscode-eslint}/share/vscode/extensions/dbaeumer.vscode-eslint/server/out/eslintServer.js" \
      "$out/lib/extensions/$server"
    makeBinaryWrapper ${lib.getExe nodejs-slim} "$out/bin/vscode-eslint-language-server" \
      --add-flag "$out/lib/extensions/$server"

    # Use VSCodium bundled TypeScript
    mkdir -p "$out/lib/extensions/node_modules"
    cp -a node_modules/typescript "$out/lib/extensions/node_modules/typescript"

    runHook postInstall
  '';

  passthru.tests.initialization =
    runCommandLocal "vscode-langservers-extracted-initialization"
      {
        nativeBuildInputs = [ finalAttrs.finalPackage ];
      }
      ''
        request() {
          init_request='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"processId":null,"rootUri":null,"capabilities":{}}}'
          content_length=''${#init_request}
          printf "Content-Length: %d\r\n\r\n%s" "$content_length" "$init_request"
          sleep 1
        }

        for language in css html json eslint; do
          echo "Checking $language language server"
          response=$(request | timeout 3 "vscode-$language-language-server" --stdio) || true
          grep -q '"capabilities"' <<< "$response"
        done

        touch $out
      '';

  meta = {
    inherit (vscodium.meta) license platforms;
    description = "HTML/CSS/JSON/ESLint language servers extracted from vscode";
    maintainers = with lib.maintainers; [ lord-valen ];
  };
})
