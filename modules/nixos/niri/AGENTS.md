<!-- Parent: ../AGENTS.md -->

# modules/nixos/niri

## Purpose
Niri window-manager module surface for the Blueprint layout. This scope documents the reusable module while package builders live elsewhere.

## Related Files
- `default.nix` — reusable Niri NixOS module and Home Manager settings
- `packages/hotkey-cheatsheet/shortcuts.nix` — shared Niri keybind and cheatsheet definitions
- `packages/noctalia/default.nix` — launcher package used by Niri binds/startup
- `packages/hotkey-cheatsheet/default.nix` — generated cheatsheet package

## Working In This Directory
- Use nixpkgs's NixOS `programs.niri` module with `pkgs.niri` for installation and session integration.
- Import only `inputs.niri.homeModules.config` for declarative settings; do not import niri-flake's NixOS or full Home Manager modules.
- Keep Niri settings under Home Manager's `programs.niri.settings`; do not write raw KDL.
- Preserve keybind generation semantics: Niri binds and the hotkey cheatsheet share `packages/hotkey-cheatsheet/shortcuts.nix`.
- Preserve `custom.niri.wallpaper` behavior and the swaybg user service.
- Use canonical package names (`noctalia`, `hotkey-cheatsheet`) in docs and code.

## Common Patterns
- Build keybind actions with `config.lib.niri.actions` from niri-flake.
- Represent startup commands as `{ argv = [ "binary" "arg" ]; }` entries.
- Same-flake package access from the module should go through `flake.packages.${pkgs.stdenv.hostPlatform.system}.<pname>`.

## Platform Notes
- `hotkey-cheatsheet` is a Linux-only package family.
- It must be omitted entirely from `packages.aarch64-darwin` rather than exposed and allowed to fail.

## Testing Requirements
- Parse-check modified files.
- Rebuild on a Linux host and verify Niri starts cleanly.
- Verify `Mod+Shift+/` still opens the generated hotkey cheatsheet.
