{ inputs, config, ... }:
let
  manifest = builtins.fromJSON (
    builtins.readFile "${inputs.matt-pocock-skills}/.claude-plugin/plugin.json"
  );
in
{
  home-manager.extraSpecialArgs.mattPocockPlugin = inputs.matt-pocock-skills;

  # Codex and OpenCode both discover this location. The release manifest is
  # the allowlist, excluding misc and in-progress skills. Link whole directories
  # to preserve upstream resources and Codex invocation policies.
  home-manager.users.${config.custom.homeManager.username}.home.file = builtins.listToAttrs (
    map (path: {
      name = ".agents/skills/${builtins.baseNameOf path}";
      value.source = "${inputs.matt-pocock-skills}/${path}";
    }) manifest.skills
  );
}
