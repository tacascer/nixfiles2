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
  interFont = {
    package = pkgs.inter;
    name = "Inter";
  };
  robotoSlabFont = {
    package = pkgs.roboto-slab;
    name = "Roboto Slab";
  };
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
      # Plasma defaults to kde, which the Home Manager Qt target does not support.
      targets.qt.platform = lib.mkForce "qtct";
      inherit (selectedTheme) base16Scheme polarity;
      image = selectedTheme.wallpaper;
      imageScalingMode = "fill";

      fonts = {
        serif = robotoSlabFont;
        sansSerif = interFont;
        monospace = hackFont;
      };
    };

    home-manager.users.${config.custom.homeManager.username} =
      { config, ... }:
      {
        programs.zellij.settings.theme = "stylix";
        stylix.targets.starship.enable = false;

        # The pinned Stylix Rofi target still uses the deprecated programs.rofi.font.
        # Keep its font styling through Home Manager's replacement option.
        stylix.targets.rofi.fonts.enable = false;
        programs.rofi.settings.font =
          lib.mkIf (config.stylix.enable && config.stylix.targets.rofi.enable && config.stylix.fonts.enable)
            "${config.stylix.fonts.monospace.name} ${toString config.stylix.fonts.sizes.popups}";
      };
  };
}
