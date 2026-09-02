{
  flake,
  config,
  inputs,
  pkgs,
  ...
}:
let
  llmAgentsPackages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home-manager.extraSpecialArgs = {
    opencodePackage = llmAgentsPackages.opencode;
  };

  home-manager.users.${config.custom.homeManager.username}.imports = [
    flake.homeModules.opencode
  ];
}
