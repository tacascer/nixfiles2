<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-03 | Updated: 2026-04-03 -->

# niri

## Purpose
Niri scrollable tiling Wayland compositor configuration and related utilities. Defines the window manager, keybindings, window rules, wallpaper service, and a hotkey cheatsheet overlay.

## Key Files

| File | Description |
|------|-------------|
| `niri.nix` | Main niri config — display output, keybindings, layout, window rules, wallpaper via swaybg, spawns noctalia + 1password at startup |
| `hotkey-cheatsheet.nix` | Empty module — cheatsheet logic is now auto-generated from binds in `niri.nix` |

## For AI Agents

### Working In This Directory
- Niri config uses `wrapper-modules` — settings are Nix attrsets, NOT kdl/config file syntax
- Keybindings use the pattern `"Mod+Key".<action> = _: { };` for parameterless actions or `"Mod+Key".spawn-sh = "command"` for spawning
- The `custom.niri.wallpaper` option controls swaybg — set to `null` to disable
- Window rules match on `app-id` (Wayland app identifier)
- The hotkey cheatsheet is auto-generated from the `binds` attrset in `niri.nix` — no manual sync needed

### Testing Requirements
- Rebuild and verify niri loads correctly — keybinding errors prevent compositor start
- Test hotkey cheatsheet via `Mod+Shift+/`

### Common Patterns
- Keybind with no args: `"Mod+Key".<action> = _: { };`
- Keybind spawning a command: `"Mod+Key".spawn-sh = "command string";`
- Keybind spawning with args: `"Mod+Key".spawn = [ "binary" "arg1" ];`

## Dependencies

### Internal
- References `myNoctalia` package from `../noctalia.nix` (launcher at startup and via `Mod+Space`)
- References `myHotkeyCheatsheet` package from `hotkey-cheatsheet.nix`
- Uses unfree `_1password-gui` and `spotify` packages

### External
- `wrapper-modules` — wraps niri binary with configuration
- `swaybg` — wallpaper daemon (managed via systemd user service)
- `fuzzel` — used by hotkey cheatsheet for dmenu-style selection

<!-- MANUAL: -->
