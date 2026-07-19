<!-- Parent: ../AGENTS.md -->

# modules/nixos/niri

## Purpose
Niri window-manager module surface for the Blueprint layout. DankMaterialShell integration lives in the sibling `dms.nix` module.

## Related Files
- `default.nix` — reusable Niri NixOS module and Home Manager settings
- `modules/nixos/dms.nix` — declarative DankMaterialShell configuration and user service

## Working In This Directory
- Use nixpkgs's NixOS `programs.niri` module with `pkgs.niri` for installation and session integration.
- Import only `inputs.niri.homeModules.config` for declarative settings; do not import niri-flake's NixOS or full Home Manager modules.
- Keep Niri settings under Home Manager's `programs.niri.settings`; do not write raw KDL.
- Keep keybindings declarative in `default.nix` using `config.lib.niri.actions`.
- Start DMS through its `niri.service`-scoped user service, not `spawn-at-startup` and not DMS's Niri Home Manager module.
- Preserve `custom.niri.wallpaper` and the repository-managed `swaybg` user service.

## Common Patterns
- Build keybind actions with `config.lib.niri.actions` from niri-flake.
- Represent startup commands as `{ argv = [ "binary" "arg" ]; }` entries.
- Invoke DMS features through `dms ipc call <target> <function>` keybind commands.

## Testing Requirements
- Parse-check modified files.
- Validate the generated KDL with `niri validate`.
- Rebuild on a Linux host and verify Niri and DMS start cleanly.
- Verify the DMS launcher, lock screen, and the `swaybg` wallpaper.
