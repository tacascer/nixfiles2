{ inputs, config, ... }:
{
  home-manager.users.${config.custom.homeManager.username} = { config, ... }: {
    home.file = {
      ".agents/skills/asd-ste100".source = inputs.asd-ste100-skill;
      "${config.programs.claude-code.configDir}/skills/asd-ste100".source = inputs.asd-ste100-skill;
    };
  };
}
