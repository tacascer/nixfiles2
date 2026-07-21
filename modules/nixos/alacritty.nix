{
  flake,
  config,
  lib,
  ...
}:
let
  themes = {
    gruvbox-dark = "gruvbox_dark";
    tokyo-night-storm = "tokyo_night_storm";
  };
in
{
  options.custom.alacritty.theme = lib.mkOption {
    type = lib.types.enum (builtins.attrNames themes);
    default = "gruvbox-dark";
    description = "Alacritty color theme provided by alacritty-theme";
  };

  config.home-manager.users.${config.custom.homeManager.username} = {
    imports = [ flake.homeModules.alacritty ];

    programs.alacritty = {
      theme = themes.${config.custom.alacritty.theme};
      settings.font.normal.family = config.custom.font.family;
    };
  };
}
