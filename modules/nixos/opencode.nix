{
  flake,
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.opencode;
  jsonFormat = pkgs.formats.json { };
  llmAgentsPackages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  ohMyOpencodePackage = llmAgentsPackages.oh-my-opencode;
in
{
  options.custom.opencode.ohMyOpenAgent.settings = lib.mkOption {
    type = lib.types.nullOr jsonFormat.type;
    default = null;
    description = ''
      Declarative contents for ~/.config/opencode/oh-my-openagent.json.
      Use this instead of the upstream interactive installer when you want to
      manage oh-my-openagent through Nix.
    '';
  };

  config = {
    home-manager.extraSpecialArgs = {
      opencodePackage = llmAgentsPackages.opencode;
      ohMyOpencodePackage = ohMyOpencodePackage;
      ohMyOpencodeAssets = ohMyOpencodePackage.src;
      ohMyOpenAgentSettings = cfg.ohMyOpenAgent.settings;
    };

    home-manager.users.${config.custom.homeManager.username}.imports = [
      flake.homeModules.opencode
    ];
  };
}
