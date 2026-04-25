{
  flake,
  config,
  ...
}:
{
  config = {
    home-manager.users.${config.custom.homeManager.username}.imports = [
      flake.homeModules.yazi
    ];
  };
}
