# Blueprint docs migration checklist (worker-4 support artifact)

## Purpose
Provide a concrete migration checklist and file map for the AGENTS/CLAUDE docs lane while task 4 remains blocked. This is a support artifact for worker-1 to apply later.

## Source references
- `.omx/plans/prd-blueprint-migration.md`
- `.omx/plans/test-spec-blueprint-migration.md`
- current tracked docs: `CLAUDE.md`, `modules/AGENTS.md`, `modules/features/AGENTS.md`, `modules/features/niri/AGENTS.md`, `modules/hosts/AGENTS.md`, `modules/hosts/framework/AGENTS.md`, `modules/hosts/pc/AGENTS.md`

## Deliverables to produce in the docs lane
- Rewrite `CLAUDE.md` for the Blueprint-native layout.
- Move AGENTS scopes so they match the new tree.
- Remove stale `flake-parts` / `import-tree` / `my*` naming guidance.
- Document canonical package names and Darwin gating rules.

## Checklist

### 1. `CLAUDE.md`
- Replace flake architecture text that still describes `flake-parts` + `import-tree`.
- Describe the Blueprint-native layout:
  - `hosts/`
  - `modules/nixos/`
  - `packages/`
  - thin `flake.nix`
- Replace old feature-module examples using `packages.my<Name>` with canonical package names.
- Update host composition docs to use `hosts/<name>/configuration.nix` plus `hosts/<name>/hardware-configuration.nix`.
- Remove references to `modules/parts.nix`, `modules/features/`, and `modules/hosts/` as the active layout.
- Add the canonical package rename map:
  - `myClaudeCode` -> `claude-code`
  - `myCodex` -> `codex`
  - `myCodexYolo` -> `codex-yolo`
  - `myFastFetch` -> `fastfetch`
  - `myGit` -> `git`
  - `myHotkeyCheatsheet` -> `hotkey-cheatsheet`
  - `myNiri` -> `niri`
  - `myNoctalia` -> `noctalia`
  - `myNvim` -> `nvim`
  - `myOmx` -> `omx`
- Add same-flake consumption guidance:
  - inside hosts: use `perSystem.self.<pname>`
  - inside reusable modules: use `flake.packages.${pkgs.stdenv.hostPlatform.system}.<pname>`
- Add Darwin gating note: `niri` and `hotkey-cheatsheet` must be omitted entirely from `packages.aarch64-darwin`.

### 2. AGENTS scope migration
- Do **not** overwrite the root `AGENTS.md` inside this worker worktree; it is the team runtime overlay.
- Replace `modules/AGENTS.md` with scope-appropriate docs in the migrated tree:
  - `modules/nixos/AGENTS.md`
  - `packages/AGENTS.md`
- Move/update host guidance:
  - `modules/hosts/AGENTS.md` -> `hosts/AGENTS.md`
  - `modules/hosts/framework/AGENTS.md` -> `hosts/framework/AGENTS.md`
  - `modules/hosts/pc/AGENTS.md` -> `hosts/pc/AGENTS.md`
- Move/update niri guidance:
  - `modules/features/niri/AGENTS.md` -> `modules/nixos/niri/AGENTS.md`

### 3. `modules/nixos/AGENTS.md` content targets
- Describe reusable NixOS modules only.
- Remove claims that every file is auto-imported by `import-tree`.
- Remove `flake-parts`-specific argument guidance and `parts.nix` references.
- Explain that Blueprint provides the structure and that reusable modules are consumed from `flake.nixosModules.<name>`.
- Mention that package-producing families now live under `packages/`.

### 4. `packages/AGENTS.md` content targets
- Describe package builders under `packages/**`.
- Mention package-local helpers such as:
  - `packages/codex/common.nix`
  - `packages/niri/lib.nix` or `packages/niri/shortcuts.nix`
- Explain canonical package names and the rule to omit unsupported packages from a system's attrset entirely.
- Call out the intentional absence of `niri` and `hotkey-cheatsheet` on `aarch64-darwin`.

### 5. `modules/nixos/niri/AGENTS.md` content targets
- Reference `packages/niri/default.nix`, `packages/noctalia/default.nix`, and `packages/hotkey-cheatsheet/default.nix`.
- Replace `myNoctalia` / `myHotkeyCheatsheet` references with `noctalia` / `hotkey-cheatsheet`.
- Preserve notes about wrapper-modules settings, keybind patterns, wallpaper option, and hotkey-cheatsheet generation from binds.
- Add the Darwin omission rule for `niri` and `hotkey-cheatsheet`.

### 6. `hosts/AGENTS.md` and host-specific AGENTS content targets
- Drop `default.nix` references; PRD says hosts end at `configuration.nix` + `hardware-configuration.nix`.
- Preserve the note that both hosts share reusable modules but differ in hardware and `custom.*` settings.
- Preserve framework-specific note about `inputs.nixos-hardware.nixosModules.framework-13-7040-amd`.
- Preserve PC-specific note about `boot.kernelPackages = pkgs.linuxPackages_latest`.
- Update internal path references from `../../features/` to the new `modules/nixos/` layout.

## File map

| Current file | Planned destination / action | Notes |
|---|---|---|
| `CLAUDE.md` | rewrite in place | Replace flake-parts/import-tree language with Blueprint-native structure |
| `modules/AGENTS.md` | split into `modules/nixos/AGENTS.md` and `packages/AGENTS.md` | Current doc is stale for both scopes |
| `modules/features/AGENTS.md` | fold into `modules/nixos/AGENTS.md` plus package docs | Mixed module/package guidance no longer matches target tree |
| `modules/features/niri/AGENTS.md` | `modules/nixos/niri/AGENTS.md` | Update canonical package names and Darwin gating |
| `modules/hosts/AGENTS.md` | `hosts/AGENTS.md` | Remove `default.nix` wording |
| `modules/hosts/framework/AGENTS.md` | `hosts/framework/AGENTS.md` | Keep Framework hardware guidance |
| `modules/hosts/pc/AGENTS.md` | `hosts/pc/AGENTS.md` | Keep latest-kernel guidance |

## Exact stale ranges from current review
- `CLAUDE.md`: lines 32-37, 44-53, 57-66, 72
- `modules/AGENTS.md`: lines 7, 13, 19-20, 25-28, 35, 42
- `modules/features/AGENTS.md`: lines 7, 18, 42, 61
- `modules/features/niri/AGENTS.md`: lines 13-14, 37-38
- `modules/hosts/AGENTS.md`: lines 19, 28-29
- host-specific AGENTS: stale `default.nix` and old internal path references

## Suggested verification for the eventual docs lane
- `find hosts modules packages -name AGENTS.md -print | sort`
- `rg -n --glob '!**/.omx/**' --glob '!**/.git/**' '(flake-parts|import-tree|myClaudeCode|myCodex|myCodexYolo|myFastFetch|myGit|myHotkeyCheatsheet|myNiri|myNoctalia|myNvim|myOmx|frameworkConfiguration|frameworkHardware|pcConfiguration|pcHardware|modules/parts.nix)' .`
- review moved docs for scope accuracy against `.omx/plans/prd-blueprint-migration.md`

## Notes
- This artifact intentionally avoids editing the shared source files because task 4 remains blocked.
- The root `AGENTS.md` in this worker worktree is runtime-generated team guidance, not the final repo doc surface.
