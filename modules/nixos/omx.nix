{ inputs, ... }:
{ pkgs, ... }:
let
  llmAgentsPackages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  environment = {
    systemPackages = [ llmAgentsPackages.oh-my-codex ];
    variables.OMX_AUTO_UPDATE = "0";
  };
}
