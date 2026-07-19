{ inputs, ... }:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.dms;
in
{
  options.custom.dms.wallpaper = lib.mkOption {
    type = lib.types.str;
    description = "Absolute path to the wallpaper image managed by DankMaterialShell.";
  };

  config.home-manager.users.${config.custom.homeManager.username} = {
    imports = [ inputs.dms.homeModules.dank-material-shell ];

    programs.dank-material-shell = {
      enable = true;
      package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;

      systemd = {
        enable = true;
        target = "niri.service";
      };

      enableDynamicTheming = true;

      settings = {
        currentThemeName = "dynamic";
        currentThemeCategory = "dynamic";
        screenPreferences.wallpaper = [ "all" ];
        wallpaperFillMode = "Fill";
      };

      session.wallpaperPath = cfg.wallpaper;
    };
  };
}
