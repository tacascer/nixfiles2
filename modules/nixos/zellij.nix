{
  flake,
  config,
  lib,
  ...
}:
{
  options.custom.zellij.theme = lib.mkOption {
    type = lib.types.enum [
      "gruvbox-dark"
      "tokyo-night-storm"
    ];
    default = "gruvbox-dark";
    description = "Zellij color theme";
  };

  config.home-manager.users.${config.custom.homeManager.username} = {
    imports = [ flake.homeModules.zellij ];

    programs.zellij.settings.theme = config.custom.zellij.theme;
  };
}
