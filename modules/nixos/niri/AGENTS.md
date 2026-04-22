<!-- Parent: ../AGENTS.md -->

# modules/nixos/niri

## Purpose
Niri window-manager module surface for the Blueprint layout. This scope documents the reusable module while package builders live elsewhere.

## Related Files
- `default.nix` — reusable Niri NixOS module
- `packages/niri/default.nix` — Niri package wrapper
- `packages/noctalia/default.nix` — launcher package used by Niri binds/startup
- `packages/hotkey-cheatsheet/default.nix` — generated cheatsheet package

## Working In This Directory
- Keep Niri settings as Nix attrsets for `wrapper-modules`; do not rewrite them as raw config syntax.
- Preserve keybind generation semantics: the hotkey cheatsheet is generated from the `binds` attrset.
- Preserve `custom.niri.wallpaper` behavior and the swaybg user service.
- Use canonical package names (`niri`, `noctalia`, `hotkey-cheatsheet`) in docs and code.

## Common Patterns
- Parameterless action bind: `"Mod+Key".<action> = _: { };`
- Shell command bind: `"Mod+Key".spawn-sh = "command string";`
- Arg-vector bind: `"Mod+Key".spawn = [ "binary" "arg" ];`
- Same-flake package access from the module should go through `flake.packages.${pkgs.stdenv.hostPlatform.system}.<pname>`.

## Platform Notes
- `niri` and `hotkey-cheatsheet` are Linux-only package families.
- They must be omitted entirely from `packages.aarch64-darwin` rather than exposed and allowed to fail.

## Testing Requirements
- Parse-check modified files.
- Rebuild on a Linux host and verify Niri starts cleanly.
- Verify `Mod+Shift+/` still opens the generated hotkey cheatsheet.
