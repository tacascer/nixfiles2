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
- Keep DMS startup and generated include handling in `modules/nixos/dms.nix` through DMS's Niri Home Manager module.
- Keep theme and wallpaper selection out of this module. Stylix owns both; DMS only renders the selected wallpaper and its mutable color include must remain excluded.

## Common Patterns
- Build keybind actions with `config.lib.niri.actions` from niri-flake.
- Represent startup commands as `{ argv = [ "binary" "arg" ]; }` entries.
- Invoke DMS features through `dms ipc call <target> <function>` keybind commands.

## Testing Requirements
- Parse-check modified files.
- Validate the generated KDL with `niri validate`.
- Rebuild on a Linux host and verify Niri and DMS start cleanly.
- Verify the DMS launcher, lock screen, Stylix wallpaper on every output, and Stylix-derived colors; Matugen and separate wallpaper services must not run.
