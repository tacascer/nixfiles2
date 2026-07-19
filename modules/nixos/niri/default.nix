{ flake, inputs, ... }:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.niri;
  system = pkgs.stdenv.hostPlatform.system;
  packages = flake.packages.${system};
  has1Password = system == "x86_64-linux";

  unfreePkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  shortcuts = import ../../../packages/hotkey-cheatsheet/shortcuts.nix {
    inherit pkgs lib packages;
  };
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
    environment.variables.NOCTALIA_PAM_SERVICE = "noctalia-lock";

    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };
    security.pam.services.noctalia-lock = { };
    services.displayManager.defaultSession = "niri";

    home-manager.users.${config.custom.homeManager.username} =
      { config, ... }:
      {
        imports = [ inputs.niri.homeModules.config ];

        programs.niri = {
          package = pkgs.niri;
          settings = {
            outputs."DP-2".mode = {
              width = 2560;
              height = 1440;
              refresh = 164.835;
            };

            spawn-at-startup = [
              { argv = [ (lib.getExe packages.noctalia) ]; }
            ]
            ++ lib.optional has1Password {
              argv = [ "${unfreePkgs._1password-gui}/bin/1password" ];
            };

            input = {
              keyboard.xkb.layout = "us";
              focus-follows-mouse.enable = true;
              warp-mouse-to-focus = {
                enable = true;
                mode = "center-xy";
              };
              touchpad = {
                tap = true;
                natural-scroll = true;
              };
            };

            cursor = {
              hide-when-typing = true;
              hide-after-inactive-ms = 3000;
            };

            layout = {
              gaps = 10;
              preset-column-widths = [
                { proportion = 0.33; }
                { proportion = 0.5; }
                { proportion = 0.67; }
                { proportion = 1.0; }
              ];
              focus-ring = {
                width = 4;
                active.color = "#7fc8ff";
                inactive.color = "#505050";
              };
            };

            window-rules = [
              {
                matches = [ { app-id = "Alacritty"; } ];
                opacity = 0.95;
                draw-border-with-background = false;
              }
            ];

            binds = shortcuts.bindsFor config.lib.niri.actions;
          };
        };
      };

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
