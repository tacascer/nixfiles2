{
  pkgs,
  lib,
  inputs,
  system,
  perSystem,
  ...
}:
if pkgs.stdenv.hostPlatform.isDarwin then
  pkgs.runCommandLocal "hotkey-cheatsheet-unsupported-on-darwin" {
    meta.platforms = lib.platforms.linux;
  } "mkdir -p $out"
else
  let
    unfreePkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    shortcuts = import ../niri/shortcuts.nix {
      inherit
        pkgs
        lib
        perSystem
        unfreePkgs
        ;
    };
  in
  shortcuts.hotkeyCheatsheet.overrideAttrs (old: {
    meta = (old.meta or { }) // {
      platforms = lib.platforms.linux;
    };
  })
