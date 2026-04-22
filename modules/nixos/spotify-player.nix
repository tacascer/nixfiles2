{ config, ... }:
{
  home-manager.users.${config.custom.homeManager.username} =
    { ... }:
    {
      programs.spotify-player.enable = true;
    };
}
