# Niri Workspace Keybinds Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Super+1-9 workspace focus and Super+Shift+1-9 move-to-workspace keybindings to niri.

**Architecture:** Add 18 keybind entries to the existing `binds` attrset in the niri wrapper-modules configuration.

**Tech Stack:** Nix, niri, wrapper-modules

---

### Task 1: Add workspace keybinds to niri.nix

**Files:**
- Modify: `modules/features/niri.nix:25-29` (inside `binds` attrset)

- [ ] **Step 1: Add focus-workspace and move-column-to-workspace binds**

Add the following entries inside the `binds` attrset in `modules/features/niri.nix`, after the existing `"Mod+Q"` line:

```nix
          # Workspace focus
          "Mod+1".focus-workspace = "w0";
          "Mod+2".focus-workspace = "w1";
          "Mod+3".focus-workspace = "w2";
          "Mod+4".focus-workspace = "w3";
          "Mod+5".focus-workspace = "w4";
          "Mod+6".focus-workspace = "w5";
          "Mod+7".focus-workspace = "w6";
          "Mod+8".focus-workspace = "w7";
          "Mod+9".focus-workspace = "w8";

          # Move window to workspace
          "Mod+Shift+1".move-column-to-workspace = "w0";
          "Mod+Shift+2".move-column-to-workspace = "w1";
          "Mod+Shift+3".move-column-to-workspace = "w2";
          "Mod+Shift+4".move-column-to-workspace = "w3";
          "Mod+Shift+5".move-column-to-workspace = "w4";
          "Mod+Shift+6".move-column-to-workspace = "w5";
          "Mod+Shift+7".move-column-to-workspace = "w6";
          "Mod+Shift+8".move-column-to-workspace = "w7";
          "Mod+Shift+9".move-column-to-workspace = "w8";
```

- [ ] **Step 2: Verify the configuration evaluates**

Run: `nix flake check /home/tacascer/myNixOS 2>&1`
Expected: No errors (warnings are OK)

- [ ] **Step 3: Build and switch**

Run: `sudo nixos-rebuild switch --flake /home/tacascer/myNixOS#framework`
Expected: Build succeeds, niri picks up the new keybinds on next restart/reload.

- [ ] **Step 4: Commit**

```bash
git add modules/features/niri.nix
git commit -m "feat: add workspace switching keybinds to niri (Super+1-9)"
```
