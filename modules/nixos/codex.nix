{
  flake,
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.codex;
  llmAgentsPackages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  codexPackage = llmAgentsPackages.codex;
  omxPackage = llmAgentsPackages.oh-my-codex;
  omxPackageRoot = "${omxPackage}/share/oh-my-codex";
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
      inherit codexPackage omxPackage omxPackageRoot;
      codexTrustedProjectsRelativeToHome = cfg.trustedProjectsRelativeToHome;
    };

    home-manager.users.${config.custom.homeManager.username}.imports = [
      flake.homeModules.codex
    ];
  };
}
