{
  flake,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.codex;
  omxPackage = flake.packages.${pkgs.stdenv.hostPlatform.system}.omx;
in
{
  options.custom.codex.trustedProjectsRelativeToHome = lib.mkOption {
    type = with lib.types; listOf str;
    default = [ ];
    example = [
      "."
      "myNixOS"
      "Projects/gradle-build-scan-server"
      "Projects/bazel-repo"
    ];
    description = ''
      Codex trusted project paths, resolved relative to the Home Manager home directory.
      Set this from each host configuration; use "." to trust the home directory itself.
    '';
  };

  config = {
    home-manager.extraSpecialArgs = {
      inherit omxPackage;
      codexTrustedProjectsRelativeToHome = cfg.trustedProjectsRelativeToHome;
    };

    home-manager.users.${config.custom.homeManager.username}.imports = [
      flake.homeModules.codex
    ];
  };
}
