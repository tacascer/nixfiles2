{ self, inputs, ... }: {

  flake.nixosModules.niri = { pkgs, lib, ... } : {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };
    services.displayManager.defaultSession = "niri";
  };

  perSystem = { pkgs, lib, self', ... }: {
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {
        spawn-at-startup = [
          (lib.getExe self'.packages.myNoctalia)
        ];

        input.keyboard = {
          xkb.layout = "us";
        };
        input.touchpad = {
          tap = _: {};
          natural-scroll = _: {};
        };
        
        layout.gaps = 10;
        layout.preset-column-widths = [
          { proportion = 0.5; }
        ];

        window-rules = [
          {
            matches = [{ app-id = "Alacritty"; }];
            opacity = 0.85;
          }
        ];

        binds = {
          "Mod+Space".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
          "Mod+Return".spawn-sh = lib.getExe self'.packages.myAlacritty;
          "Mod+W".close-window = _: {};

          # Workspace focus
          "Mod+1".focus-workspace = "w0";
          "Mod+2".focus-workspace = "w1";
          "Mod+3".focus-workspace = "w2";
          "Mod+4".focus-workspace = "w3";
          "Mod+5".focus-workspace = "w4";
          "Mod+6".focus-workspace = "w5";
          "Mod+7".focus-workspace = "w6";
          "Mod+8".focus-workspace = "w7";
          "Mod+9".focus-workspace = "w8";

          # Move window to workspace
          "Mod+Shift+1".move-column-to-workspace = "w0";
          "Mod+Shift+2".move-column-to-workspace = "w1";
          "Mod+Shift+3".move-column-to-workspace = "w2";
          "Mod+Shift+4".move-column-to-workspace = "w3";
          "Mod+Shift+5".move-column-to-workspace = "w4";
          "Mod+Shift+6".move-column-to-workspace = "w5";
          "Mod+Shift+7".move-column-to-workspace = "w6";
          "Mod+Shift+8".move-column-to-workspace = "w7";
          "Mod+Shift+9".move-column-to-workspace = "w8";

          # Window management
          "Mod+F".maximize-column = _: {};
          "Mod+R".switch-preset-column-width = _: {};
          "Mod+Left".focus-column-left = _: {};
          "Mod+Right".focus-column-right = _: {};
          "Mod+Shift+Left".move-column-left = _: {};
          "Mod+Shift+Right".move-column-right = _: {};
          "Mod+Up".focus-window-or-workspace-up = _: {};
          "Mod+Down".focus-window-or-workspace-down = _: {};
          "Mod+Shift+Up".move-window-up-or-to-workspace-up = _: {};
          "Mod+Shift+Down".move-window-down-or-to-workspace-down = _: {};
          "Mod+C".center-column = _: {};

          # Monitor focus
          "Mod+Ctrl+Left".focus-monitor-left = _: {};
          "Mod+Ctrl+Right".focus-monitor-right = _: {};

          # Move window to monitor
          "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = _: {};
          "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = _: {};
        };
      };
    };
  };
}
