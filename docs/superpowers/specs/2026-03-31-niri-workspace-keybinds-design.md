# Niri Workspace Keybinds

## Summary

Add keybindings to switch between workspaces and move windows to workspaces using Super + number keys in the niri window manager configuration.

## Scope

Modify `modules/features/niri.nix` only. Add 18 new keybinds to the existing `binds` attrset.

## Keybindings

### Focus workspace (Super + number)

| Key | Action |
|-----|--------|
| `Mod+1` | `focus-workspace "w0"` |
| `Mod+2` | `focus-workspace "w1"` |
| `Mod+3` | `focus-workspace "w2"` |
| `Mod+4` | `focus-workspace "w3"` |
| `Mod+5` | `focus-workspace "w4"` |
| `Mod+6` | `focus-workspace "w5"` |
| `Mod+7` | `focus-workspace "w6"` |
| `Mod+8` | `focus-workspace "w7"` |
| `Mod+9` | `focus-workspace "w8"` |

### Move window to workspace (Super + Shift + number)

| Key | Action |
|-----|--------|
| `Mod+Shift+1` | `move-column-to-workspace "w0"` |
| `Mod+Shift+2` | `move-column-to-workspace "w1"` |
| `Mod+Shift+3` | `move-column-to-workspace "w2"` |
| `Mod+Shift+4` | `move-column-to-workspace "w3"` |
| `Mod+Shift+5` | `move-column-to-workspace "w4"` |
| `Mod+Shift+6` | `move-column-to-workspace "w5"` |
| `Mod+Shift+7` | `move-column-to-workspace "w6"` |
| `Mod+Shift+8` | `move-column-to-workspace "w7"` |
| `Mod+Shift+9` | `move-column-to-workspace "w8"` |

## Technical Details

- Workspaces are zero-indexed: Super+1 maps to `w0`, Super+9 maps to `w8`
- The niri wrapper-modules framework auto-generates workspace definitions `w0` through `w9`
- Nix syntax: `"Mod+1".focus-workspace = "w0";` (string value, not a function like `close-window`)
- The `move-column-to-workspace` action moves the entire focused column (niri's unit of window movement)

## Files Changed

- `modules/features/niri.nix` — add entries to `binds` attrset
