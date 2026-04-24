{
  pkgs,
  ohMyOpenAgentSrc,
  ohMyOpenAgentSettings ? null,
  ...
}:
let
  packageMeta = builtins.fromJSON (builtins.readFile "${ohMyOpenAgentSrc}/package.json");
  jsonFormat = pkgs.formats.json { };
  primaryModel = "openai/gpt-5.4";
  fastModel = "openai/gpt-5.4-mini";
  quickModel = "openai/gpt-5.4-mini";
  defaultOhMyOpenAgentSettings = {
    "$schema" = "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json";
    agents = {
      hephaestus.model = primaryModel;
      oracle.model = primaryModel;
      librarian.model = fastModel;
      explore.model = fastModel;
      multimodal-looker.model = primaryModel;
      prometheus.model = primaryModel;
      metis.model = primaryModel;
      momus.model = primaryModel;
      atlas.model = primaryModel;
      sisyphus-junior.model = primaryModel;
      sisyphus.model = primaryModel;
      sisyphus.ultrawork.model = primaryModel;
    };
    categories = {
      visual-engineering.model = primaryModel;
      ultrabrain.model = primaryModel;
      deep.model = primaryModel;
      artistry.model = primaryModel;
      quick.model = quickModel;
      unspecified-low.model = quickModel;
      unspecified-high.model = primaryModel;
      writing.model = primaryModel;
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
    settings.plugin = [ "oh-my-openagent@${packageMeta.version}" ];
    commands = "${ohMyOpenAgentSrc}/.opencode/command";
    skills = "${ohMyOpenAgentSrc}/.opencode/skills";
  };

  xdg.configFile."opencode/oh-my-openagent.json".source = pluginConfigFile;
}
