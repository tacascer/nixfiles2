{ pkgs, lib, inputs, system, perSystem, ... }:
let
  unfreePkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  shortcuts = import ../niri/shortcuts.nix {
    inherit pkgs lib perSystem unfreePkgs;
  };
in
shortcuts.hotkeyCheatsheet.overrideAttrs (old: {
  meta = (old.meta or { }) // {
    platforms = lib.platforms.linux;
  };
})
