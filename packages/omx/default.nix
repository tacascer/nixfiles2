{ pkgs, inputs, ... }:
let
  packageMeta = builtins.fromJSON (builtins.readFile "${inputs.omx}/package.json");
in
pkgs.buildNpmPackage {
  pname = packageMeta.name;
  version = packageMeta.version;
  src = inputs.omx;

  npmDepsHash = "sha256-gGlxQLwp0NBsc/SBUEwJJYPMUKre+txgG8SCIBK7NcA=";
  npmFlags = [ "--ignore-scripts" ];
}
