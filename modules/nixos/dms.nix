{ inputs, ... }:
{
  config,
  pkgs,
  ...
}:
{
  config.home-manager.users.${config.custom.homeManager.username} = {
    imports = [
      inputs.dms.homeModules.dank-material-shell
      inputs.dms.homeModules.niri
    ];

    # DMS requires a Boolean for this nullable Niri option.
    programs.niri.settings.layout.border.enable = false;

    home.sessionVariables.DMS_DISABLE_MATUGEN = "1";

    programs.dank-material-shell = {
      enable = true;
      package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
      enableDynamicTheming = false;

      niri = {
        enableSpawn = true;
        includes.filesToInclude = [
          "alttab"
          "binds"
          "cursor"
          "layout"
          "outputs"
          "windowrules"
          "wpblur"
        ];
      };

      settings = {
        screenPreferences.wallpaper = [ "all" ];
        wallpaperFillMode = "Fill";
        useAutoLocation = true;
      };
    };
  };
}
