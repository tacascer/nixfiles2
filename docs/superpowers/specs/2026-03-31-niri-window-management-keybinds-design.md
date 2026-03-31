# Niri Window Management Keybinds

## Context

Single maximized window per workspace is the default workflow. Occasionally need to view two windows side-by-side (e.g. reference + code), then return to maximized.

## Design

### Layout Configuration

Add `preset-column-widths` with a single 50% proportion:

```nix
layout.preset-column-widths = [
  { proportion = 0.5; }
];
```

### Keybinds

| Keybind | Action | Purpose |
|---------|--------|---------|
| `Mod+F` | `maximize-column` | Snap back to full width |
| `Mod+R` | `switch-preset-column-width` | Set column to 1/2 width |
| `Mod+Left` | `focus-column-left` | Focus left column |
| `Mod+Right` | `focus-column-right` | Focus right column |
| `Mod+Shift+Left` | `move-column-left` | Move column left |
| `Mod+Shift+Right` | `move-column-right` | Move column right |
| `Mod+C` | `center-column` | Center the focused column |

### Workflow

1. Working in maximized window (default)
2. Open a second window (appears as new column, scrolled off or partially visible)
3. Press `Mod+R` on each column to set 50/50 split
4. Navigate between columns with `Mod+Left/Right`
5. When done, close the secondary window and press `Mod+F` to re-maximize

## Implementation

Modify `modules/features/niri.nix`:
- Add `layout.preset-column-widths` to the settings
- Add all 7 keybinds to the `binds` attrset
