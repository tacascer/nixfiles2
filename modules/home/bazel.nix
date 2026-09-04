{ pkgs, ... }:
let
  buildBuddyCredentialHelper = pkgs.writeShellApplication {
    name = "bazel-buildbuddy-credential-helper";
    runtimeInputs = [
      pkgs._1password-cli
      pkgs.jq
    ];
    text = builtins.readFile ./bazel-buildbuddy-credential-helper.sh;
  };
in
{
  home.file.".bazelrc".text = ''
    common --credential_helper=remote.buildbuddy.io=${buildBuddyCredentialHelper}/bin/bazel-buildbuddy-credential-helper
  '';
}
