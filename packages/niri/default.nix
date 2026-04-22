{
  pkgs,
  inputs,
  system,
  perSystem,
  ...
}:
let
  lib = pkgs.lib;
in
if pkgs.stdenv.hostPlatform.isDarwin then
  pkgs.runCommandLocal "niri-unsupported-on-darwin" {
    meta.platforms = lib.platforms.linux;
  } "mkdir -p $out"
else
  let
    unfreePkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    shortcuts = import ./shortcuts.nix {
      inherit
        pkgs
        lib
        perSystem
        unfreePkgs
        ;
    };

    wrapped = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {
        outputs."DP-2".mode = "2560x1440@164.835";

        spawn-at-startup = [
          (lib.getExe perSystem.self.noctalia)
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

        cursor.hide-when-typing = _: { };
        cursor.hide-after-inactive-ms = 3000;

        layout.gaps = 10;
        layout.preset-column-widths = [
          { proportion = 0.33; }
          { proportion = 0.5; }
          { proportion = 0.67; }
          { proportion = 1.0; }
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

        binds = shortcuts.binds;
      };
    };
  in
  wrapped.overrideAttrs (old: {
    meta = (old.meta or { }) // {
      platforms = lib.platforms.linux;
    };
  })
