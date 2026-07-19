{
  pkgs,
  perSystem,
  ...
}:
let
  lib = pkgs.lib;
in
if pkgs.stdenv.hostPlatform.isDarwin then
  pkgs.runCommandLocal "hotkey-cheatsheet-unsupported-on-darwin" {
    meta.platforms = lib.platforms.linux;
  } "mkdir -p $out"
else
  let
    shortcuts = import ./shortcuts.nix {
      inherit pkgs lib;
      packages = perSystem.self;
    };
  in
  shortcuts.hotkeyCheatsheet.overrideAttrs (old: {
    meta = (old.meta or { }) // {
      platforms = lib.platforms.linux;
    };
  })
