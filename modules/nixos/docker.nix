{
  flake,
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.docker ];

  virtualisation.docker.enable = true;

  users.users.${config.custom.homeManager.username}.extraGroups = [ "docker" ];

  home-manager.users.${config.custom.homeManager.username}.imports = [ flake.homeModules.docker ];
}
