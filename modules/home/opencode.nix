{
  pkgs,
  opencodePackage,
  ohMyOpencodePackage,
  ohMyOpencodeAssets,
  ohMyOpenAgentSettings ? null,
  ...
}:
let
  jsonFormat = pkgs.formats.json { };
  ohMyOpencodePluginEntry = "file://${ohMyOpencodePackage}/lib/oh-my-opencode/dist/index.js";
  ohMyOpencodeSchema = "${ohMyOpencodePackage}/lib/oh-my-opencode/dist/oh-my-opencode.schema.json";
  primaryModel = "openai/gpt-5.5";
  primaryReasoning = "high";
  fastModel = "openai/gpt-5.4-mini";
  fastReasoning = "low";
  quickModel = "openai/gpt-5.4-mini";
  quickReasoning = "none";
  defaultOhMyOpenAgentSettings = {
    "$schema" = ohMyOpencodeSchema;
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
    package = opencodePackage;
    extraPackages = [ pkgs.bun ];
    context = ./claude-home-instructions.md;
    settings = {
      plugin = [ ohMyOpencodePluginEntry ];
    };
    commands = ohMyOpencodeAssets + "/.opencode/command";
    skills = ohMyOpencodeAssets + "/.opencode/skills";
  };

  xdg.configFile."opencode/oh-my-openagent.json".source = pluginConfigFile;
}
