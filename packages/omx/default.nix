{ pkgs, inputs, ... }:
let
  packageMeta = builtins.fromJSON (builtins.readFile "${inputs.omx}/package.json");
  nodeTarget =
    {
      x86_64-linux = {
        platform = "linux";
        arch = "x64";
      };
      aarch64-linux = {
        platform = "linux";
        arch = "arm64";
      };
      aarch64-darwin = {
        platform = "darwin";
        arch = "arm64";
      };
    }
    .${pkgs.stdenv.hostPlatform.system}
      or (throw "Unsupported OMX target system: ${pkgs.stdenv.hostPlatform.system}");

  exploreHarness = pkgs.rustPlatform.buildRustPackage {
    pname = "omx-explore-harness";
    version = packageMeta.version;
    src = inputs.omx;

    cargoLock.lockFile = "${inputs.omx}/Cargo.lock";
    cargoBuildFlags = [ "-p" "omx-explore-harness" ];

    doCheck = false;
  };
in
pkgs.buildNpmPackage {
  pname = packageMeta.name;
  version = packageMeta.version;
  src = inputs.omx;

  npmDepsHash = "sha256-gGlxQLwp0NBsc/SBUEwJJYPMUKre+txgG8SCIBK7NcA=";
  npmFlags = [ "--ignore-scripts" ];

  postInstall = ''
    bin_dir="$out/lib/node_modules/${packageMeta.name}/bin"
    mkdir -p "$bin_dir"
    cp ${exploreHarness}/bin/omx-explore-harness "$bin_dir/omx-explore-harness"
    chmod 755 "$bin_dir/omx-explore-harness"

    cat > "$bin_dir/omx-explore-harness.meta.json" <<EOF
    {
      "binaryName": "omx-explore-harness",
      "platform": "${nodeTarget.platform}",
      "arch": "${nodeTarget.arch}",
      "strategy": "nix-prebuilt"
    }
    EOF
  '';
}
