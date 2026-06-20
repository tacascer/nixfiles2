{ pkgs, inputs, ... }:
let
  lib = pkgs.lib;
  packageMeta = builtins.fromJSON (builtins.readFile "${inputs.qmd}/package.json");
  nodejs = pkgs.nodejs_22;
  nodeSources = pkgs.srcOnly nodejs;
  pnpm = pkgs.pnpm_10;
  pythonEnv = pkgs.python3.withPackages (pythonPackages: [ pythonPackages.setuptools ]);
in
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "qmd";
  version = packageMeta.version;
  src = inputs.qmd;

  pnpmDeps = pkgs.fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-BH0ds7BbGZq1TPH38XR7KbyvWKUQvmQrr5b3sLMEaJc=";
  };

  nativeBuildInputs = [
    pnpm
    pkgs.pnpmConfigHook
    nodejs
    pkgs.node-gyp
    pkgs.pkg-config
    pkgs.makeWrapper
    pythonEnv
  ] ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    pkgs.darwin.cctools.libtool
  ];

  npm_config_build_from_source = "true";

  buildPhase = ''
    runHook preBuild

    pushd node_modules/.pnpm/better-sqlite3@*/node_modules/better-sqlite3
    npm run build-release --offline --nodedir="${nodeSources}"
    popd

    pnpm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/qmd" "$out/bin"
    cp -R bin dist node_modules package.json skills "$out/lib/qmd/"

    makeWrapper ${lib.getExe nodejs} "$out/bin/qmd" \
      --add-flags "$out/lib/qmd/${packageMeta.bin.qmd}" \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]}

    runHook postInstall
  '';

  meta = {
    description = packageMeta.description or "Query Markdown CLI";
    homepage = packageMeta.homepage or "https://github.com/tobi/qmd";
    license = lib.licenses.mit;
    mainProgram = "qmd";
    platforms = lib.platforms.unix;
  };
})
