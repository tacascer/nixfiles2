{ self, inputs, ... }:
{

  flake.nixosModules.niri =
    {
      config,
      pkgs,
      lib,
      ...
    }:
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
          package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
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
    };

  perSystem =
    {
      pkgs,
      lib,
      self',
      system,
      ...
    }:
    {
      packages.myNiri =
        let
          unfreePkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        inputs.wrapper-modules.wrappers.niri.wrap {
          inherit pkgs;
          settings = {
            outputs."DP-2".mode = "2560x1440@164.835";

            spawn-at-startup = [
              (lib.getExe self'.packages.myNoctalia)
              "${unfreePkgs._1password-gui}/bin/1password"
            ];

            input.keyboard = {
              xkb.layout = "us";
            };
            input.focus-follows-mouse = _: { };
            input.warp-mouse-to-focus = _: {
              props.mode = "center-xy";
            };
            input.touchpad = {
              tap = _: { };
              natural-scroll = _: { };
            };

            layout.gaps = 10;
            layout.preset-column-widths = [
              { proportion = 0.5; }
            ];
            layout.focus-ring = {
              width = 4;
              active-color = "#7fc8ff";
              inactive-color = "#505050";
            };

            window-rules = [
              {
                matches = [ { app-id = "Alacritty"; } ];
                opacity = 0.85;
                draw-border-with-background = false;
              }
            ];

            binds = {
              "Mod+Space".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
              "Mod+Return".spawn-sh = "alacritty";
              "Mod+Shift+M".spawn = [ (lib.getExe unfreePkgs.spotify) ];
              "Mod+Shift+B".spawn = [ (lib.getExe pkgs.firefox) ];
              "Mod+W".close-window = _: { };

              # Window management
              "Mod+F".maximize-column = _: { };
              "Mod+Shift+Slash".spawn-sh = lib.getExe self'.packages.myHotkeyCheatsheet;
              "Mod+Left".focus-column-left = _: { };
              "Mod+Right".focus-column-right = _: { };
              "Mod+Shift+Left".move-column-left = _: { };
              "Mod+Shift+Right".move-column-right = _: { };
              "Mod+Up".focus-window-or-workspace-up = _: { };
              "Mod+Down".focus-window-or-workspace-down = _: { };
              "Mod+Shift+Up".move-window-up-or-to-workspace-up = _: { };
              "Mod+Shift+Down".move-window-down-or-to-workspace-down = _: { };
              "Mod+C".center-column = _: { };
              "Mod+O".toggle-overview = _: { };

              # Monitor focus
              "Mod+Ctrl+Left".focus-monitor-left = _: { };
              "Mod+Ctrl+Right".focus-monitor-right = _: { };

              # Move window to monitor
              "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = _: { };
              "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = _: { };
            };
          };
        };
    };
}
