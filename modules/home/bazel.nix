{ pkgs, ... }:
let
  buildBuddyCredentialHelper = pkgs.writeShellApplication {
    name = "bazel-buildbuddy-credential-helper";
    runtimeInputs = [
      pkgs._1password-cli
      pkgs.jq
    ];
  };
in
{
}
