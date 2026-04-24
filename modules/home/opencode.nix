{
  pkgs,
  ohMyOpenAgentSrc,
  ohMyOpenAgentSettings ? null,
  ...
}:
let
  packageMeta = builtins.fromJSON (builtins.readFile "${ohMyOpenAgentSrc}/package.json");
  jsonFormat = pkgs.formats.json { };
  defaultOhMyOpenAgentSettings = {
    "$schema" = "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json";
    agents = {
      hephaestus.model = "opencode/gpt-5-nano";
      oracle.model = "opencode/gpt-5-nano";
      librarian.model = "opencode/gpt-5-nano";
      explore.model = "opencode/gpt-5-nano";
      multimodal-looker.model = "opencode/gpt-5-nano";
      prometheus.model = "opencode/gpt-5-nano";
      metis.model = "opencode/gpt-5-nano";
      momus.model = "opencode/gpt-5-nano";
      atlas.model = "opencode/gpt-5-nano";
      sisyphus-junior.model = "opencode/gpt-5-nano";
      sisyphus.model = "opencode/gpt-5-nano";
      sisyphus.ultrawork.model = "opencode/gpt-5-nano";
    };
    categories = {
      visual-engineering.model = "opencode/gpt-5-nano";
      ultrabrain.model = "opencode/gpt-5-nano";
      deep.model = "opencode/gpt-5-nano";
      artistry.model = "opencode/gpt-5-nano";
      quick.model = "opencode/gpt-5-nano";
      unspecified-low.model = "opencode/gpt-5-nano";
      unspecified-high.model = "opencode/gpt-5-nano";
      writing.model = "opencode/gpt-5-nano";
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
