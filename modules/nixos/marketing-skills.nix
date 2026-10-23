{ inputs, config, ... }:
let
  source = inputs.marketing-skills;
  manifest = builtins.fromJSON (builtins.readFile "${source}/.claude-plugin/plugin.json");
  skillRoot = "${source}/${manifest.skills}";
  skillNames = builtins.filter (name: builtins.pathExists "${skillRoot}/${name}/SKILL.md") (
    builtins.attrNames (builtins.readDir skillRoot)
  );
in
{
  home-manager.users.${config.custom.homeManager.username} = { config, lib, ... }: {
    programs.claude-code.plugins.marketing-skills = source;

    home.file =
      builtins.listToAttrs (
        map (name: {
          name = ".agents/skills/${name}";
          value.source = "${skillRoot}/${name}";
        }) skillNames
      )
      // {
        # Preserve the plugin root for manifest-relative skills and tool references.
        "${config.programs.claude-code.configDir}/skills/marketing-skills".source = lib.mkForce source;
      };
  };
}
