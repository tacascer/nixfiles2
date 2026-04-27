{
  pkgs,
  ohMyOpenAgentSrc,
  ohMyOpenAgentSettings ? null,
  ...
}:
let
  packageMeta = builtins.fromJSON (builtins.readFile "${ohMyOpenAgentSrc}/package.json");
  jsonFormat = pkgs.formats.json { };
  primaryModel = "openai/gpt-5.5";
  primaryReasoning = "high";
  fastModel = "openai/gpt-5.5-mini";
  fastReasoning = "low";
  quickModel = "openai/gpt-5.5-mini";
  quickReasoning = "none";
  defaultOhMyOpenAgentSettings = {
    "$schema" = "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json";
    agents = {
      hephaestus.model = primaryModel;
      hephaestus.reasoningEffort = primaryReasoning;
      oracle.model = primaryModel;
      oracle.reasoningEffort = primaryReasoning;
      librarian.model = fastModel;
      librarian.reasoningEffort = fastReasoning;
      explore.model = fastModel;
      explore.reasoningEffort = fastReasoning;
      multimodal-looker.model = primaryModel;
      multimodal-looker.reasoningEffort = primaryReasoning;
      prometheus.model = primaryModel;
      prometheus.reasoningEffort = primaryReasoning;
      metis.model = primaryModel;
      metis.reasoningEffort = primaryReasoning;
      momus.model = primaryModel;
      momus.reasoningEffort = primaryReasoning;
      atlas.model = primaryModel;
      atlas.reasoningEffort = primaryReasoning;
      sisyphus-junior.model = primaryModel;
      sisyphus-junior.reasoningEffort = primaryReasoning;
      sisyphus.model = primaryModel;
      sisyphus.reasoningEffort = primaryReasoning;
      sisyphus.ultrawork.model = primaryModel;
      sisyphus.ultrawork.reasoningEffort = primaryReasoning;
    };
    categories = {
      visual-engineering.model = primaryModel;
      visual-engineering.reasoningEffort = primaryReasoning;
      ultrabrain.model = primaryModel;
      ultrabrain.reasoningEffort = primaryReasoning;
      deep.model = primaryModel;
      deep.reasoningEffort = primaryReasoning;
      artistry.model = primaryModel;
      artistry.reasoningEffort = primaryReasoning;
      quick.model = quickModel;
      quick.reasoningEffort = quickReasoning;
      unspecified-low.model = quickModel;
      unspecified-low.reasoningEffort = quickReasoning;
      unspecified-high.model = primaryModel;
      unspecified-high.reasoningEffort = primaryReasoning;
      writing.model = primaryModel;
      writing.reasoningEffort = primaryReasoning;
    };
  };
  effectiveOhMyOpenAgentSettings =
    if ohMyOpenAgentSettings == null then defaultOhMyOpenAgentSettings else ohMyOpenAgentSettings;
  pluginConfigFile = jsonFormat.generate "oh-my-openagent.json" effectiveOhMyOpenAgentSettings;
in
{
  programs.opencode = {
    enable = true;
    extraPackages = [ pkgs.bun ];
    settings = {
      plugin = [ "oh-my-openagent@${packageMeta.version}" ];
      instructions = [ "AGENTS.md" ];
    };
    commands = "${ohMyOpenAgentSrc}/.opencode/command";
    skills = "${ohMyOpenAgentSrc}/.opencode/skills";
  };

  xdg.configFile."opencode/AGENTS.md".source = ./claude-home-instructions.md;
  xdg.configFile."opencode/oh-my-openagent.json".source = pluginConfigFile;
}
