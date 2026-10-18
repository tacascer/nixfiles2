{
  flake,
  config,
  pkgs,
  ...
}:
let
  skills = flake.packages.${pkgs.stdenv.hostPlatform.system}.design-skills;
in
{
  home-manager.users.${config.custom.homeManager.username} = { config, ... }: {
    # Codex and OpenCode share the standard user-wide skill discovery directory.
    # Claude gets its provider-specific Impeccable bundle, without plugin hooks.
    home.file = builtins.listToAttrs (
      builtins.concatMap (name: [
        {
          name = ".agents/skills/${name}";
          value.source = "${skills}/share/agents/${name}";
        }
        {
          name = "${config.programs.claude-code.configDir}/skills/${name}";
          value.source = "${skills}/share/claude/${name}";
        }
      ]) skills.skillNames
    );
  };
}
