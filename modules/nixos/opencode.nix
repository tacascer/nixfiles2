{ config, ... }:
{
  home-manager.users.${config.custom.homeManager.username} =
    { ... }:
    {
      programs.opencode.enable = true;
    };
}
