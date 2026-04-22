{ flake, ... }:
{ config, pkgs, lib, ... }:
let
  cfg = config.custom.niri;
in
{
  options.custom.niri = {
    wallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Absolute path to wallpaper image. When set, swaybg is used to display it.";
    };
  };

  config = {
    programs.niri = {
      enable = true;
      package = flake.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    };
    services.displayManager.defaultSession = "niri";

    systemd.user.services.swaybg = lib.mkIf (cfg.wallpaper != null) {
      description = "Wallpaper daemon";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.swaybg} -i ${cfg.wallpaper} -m fill";
        Restart = "on-failure";
      };
    };
  };
}
