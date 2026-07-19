{ inputs, ... }:
{ config, pkgs, ... }:
{
  home-manager.users.${config.custom.homeManager.username} = {
    imports = [ inputs.dms.homeModules.dank-material-shell ];

    programs.dank-material-shell = {
      enable = true;
      package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;

      systemd = {
        enable = true;
        target = "niri.service";
      };

      settings.screenPreferences.wallpaper = [ ];
    };
  };
}
