{ inputs, ... }:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  has1Password = system == "x86_64-linux";

  unfreePkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  config = {
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };
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

            spawn-at-startup = lib.optional has1Password {
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

            binds = with config.lib.niri.actions; {
              "Mod+Space".action = spawn "dms" "ipc" "call" "spotlight" "toggle";
              "Mod+L".action = spawn "dms" "ipc" "call" "lock" "lock";
              "Mod+Return".action = spawn "alacritty";
              "Mod+Shift+B".action = spawn (lib.getExe pkgs.firefox);
              "Mod+W".action = close-window;

              "Mod+F".action = switch-preset-column-width;
              "Mod+Left".action = focus-column-left;
              "Mod+Right".action = focus-column-right;
              "Mod+Shift+Left".action = move-column-left;
              "Mod+Shift+Right".action = move-column-right;
              "Mod+Up".action = focus-window-or-workspace-up;
              "Mod+Down".action = focus-window-or-workspace-down;
              "Mod+Shift+Up".action = move-window-up-or-to-workspace-up;
              "Mod+Shift+Down".action = move-window-down-or-to-workspace-down;
              "Mod+C".action = center-column;
              "Mod+O".action = toggle-overview;

              "Mod+Ctrl+Left".action = focus-monitor-left;
              "Mod+Ctrl+Right".action = focus-monitor-right;
              "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
              "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
            };
          };
        };
      };
  };
}
