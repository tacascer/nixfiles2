{ inputs, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  themes = {
    gruvbox = {
      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
      polarity = "dark";
      wallpaper = inputs.wallpkgs.wallpapers.gruvbox.cafe.path;
    };
    tokyo-night-storm = {
      base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-storm.yaml";
      polarity = "dark";
      wallpaper = inputs.wallpkgs.wallpapers."tokyo-night"."tokyo_night-01".path;
    };
  };

  selectedTheme = themes.${config.custom.theme};
  hackFont = {
    package = pkgs.nerd-fonts.hack;
    name = "Hack Nerd Font";
  };
in
{
  imports = [ inputs.stylix.nixosModules.stylix ];

  options.custom.theme = lib.mkOption {
    type = lib.types.enum (builtins.attrNames themes);
    default = "gruvbox";
    description = "System-wide Stylix theme and wallpaper.";
  };

  config = {
    stylix = {
      enable = true;
      inherit (selectedTheme) base16Scheme polarity;
      image = selectedTheme.wallpaper;
      imageScalingMode = "fill";

      fonts = {
        serif = hackFont;
        sansSerif = hackFont;
        monospace = hackFont;
      };
    };

    home-manager.users.${config.custom.homeManager.username} = {
      programs.zellij.settings.theme = "stylix";
      stylix.targets.starship.enable = false;
    };
  };
}
