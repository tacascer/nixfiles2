{ pkgs, ... }:
pkgs.runCommand "bazel-buildbuddy-credential-helper-test"
  {
    nativeBuildInputs = [ pkgs.jq ];
    src = ../.;
  }
  ''
    bash "$src/tests/bazel-buildbuddy-credential-helper.sh"
    touch "$out"
  ''
