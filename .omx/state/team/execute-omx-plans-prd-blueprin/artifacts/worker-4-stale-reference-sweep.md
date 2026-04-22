# Post-integration stale-reference sweep (worker-4 support artifact)

## Scope
Read-only sweep for stale Blueprint-migration references on the current worker-4 HEAD.

- Repo HEAD inspected: `61f47b330696325d3e173227b36291c3fea76c90`
- Sweep command:

```bash
rg -n --glob '!**/.omx/**' --glob '!**/.git/**' \
  '(flake-parts|import-tree|myClaudeCode|myCodex|myCodexYolo|myFastFetch|myGit|myHotkeyCheatsheet|myNiri|myNoctalia|myNvim|myOmx|frameworkConfiguration|frameworkHardware|pcConfiguration|pcHardware|modules/parts.nix|modules/features/niri/hotkey-cheatsheet.nix|modules/features|modules/hosts)' .
```

## Summary
The current tree still contains substantial stale references.

- Code hits: **22**
- Docs hits: **18**
- Lockfile hits: **12**

### Key conclusion
This is **not only a docs cleanup problem**. The current HEAD still has live source references to `flake-parts`, `import-tree`, `packages.my*`, and the legacy `modules/features/**` layout, even though new `hosts/` and `packages/` directories now exist.

## Remaining live-source hits

### Root flake wiring
- `flake.nix:5` — `flake-parts.url = ...`
- `flake.nix:6` — `import-tree.url = ...`
- `flake.nix:35` — `outputs = inputs: inputs.flake-parts.lib.mkFlake ... (inputs.import-tree ./modules);`

### Legacy package names under `modules/features/**`
- `modules/features/claude-code.nix:15`
- `modules/features/claude-code.nix:38`
- `modules/features/codex.nix:95`
- `modules/features/codex.nix:96`
- `modules/features/fastfetch.nix:11`
- `modules/features/fastfetch.nix:18`
- `modules/features/git.nix:15`
- `modules/features/git.nix:33`
- `modules/features/noctalia.nix:6`
- `modules/features/nvim.nix:16`
- `modules/features/nvim.nix:28`
- `modules/features/omx.nix:47`
- `modules/features/niri/niri.nix:26`
- `modules/features/niri/niri.nix:76`
- `modules/features/niri/niri.nix:84`
- `modules/features/niri/niri.nix:143`
- `modules/features/niri/niri.nix:151`
- `modules/features/niri/niri.nix:157`

### Legacy compatibility file still present
- `modules/features/niri/hotkey-cheatsheet.nix:2` — comment says it exists for `import-tree` compatibility.

## Remaining docs hits

### `CLAUDE.md`
- `CLAUDE.md:32-37` — still describes `flake-parts` + `import-tree`
- `CLAUDE.md:44-53` — still uses `packages.my<Name>` module pattern
- `CLAUDE.md:57-66` — still points to `modules/hosts/*`, `modules/features/*`, and `modules/parts.nix`
- `CLAUDE.md:72` — still says all modules are auto-discovered by `import-tree`

### AGENTS docs
- `modules/AGENTS.md:7,26,35,42` — still frames the tree as `import-tree` + `flake-parts`
- `modules/features/AGENTS.md:7,42,61` — still mixes NixOS modules with `packages.my*` guidance
- `modules/features/niri/AGENTS.md:13-14,37-38` — still refers to old hotkey module and `myNoctalia` / `myHotkeyCheatsheet`

### Host AGENTS docs still scoped to the old tree
- `modules/hosts/AGENTS.md:19,28-29`
- `modules/hosts/framework/AGENTS.md:13,35`
- `modules/hosts/pc/AGENTS.md:13,35`

## Lockfile hits
`flake.lock` still contains `flake-parts` and `import-tree` entries. That is expected while `flake.nix` still references them. These lockfile hits should disappear only after the flake cutover is actually wired and the lockfile is refreshed.

## Suggested follow-ups

### A. Code-lane follow-up (required before the final stale-reference sweep can pass)
1. Rewrite `flake.nix` to the Blueprint entrypoint and drop `flake-parts` / `import-tree`.
2. Remove or replace active `modules/features/**` consumers that still expose `packages.my*` outputs.
3. Finish moving active package-producing logic to `packages/**` and active reusable modules to the final tree used by the flake.
4. Remove `modules/features/niri/hotkey-cheatsheet.nix` once import-tree compatibility is no longer needed.
5. Refresh `flake.lock` after the flake inputs change.

### B. Docs-lane follow-up
1. Apply the checklist from `worker-4-docs-migration-checklist.md`.
2. Rewrite `CLAUDE.md` for the Blueprint-native structure.
3. Move AGENTS scopes to the new tree:
   - `modules/nixos/AGENTS.md`
   - `modules/nixos/niri/AGENTS.md`
   - `packages/AGENTS.md`
   - `hosts/AGENTS.md`
   - `hosts/framework/AGENTS.md`
   - `hosts/pc/AGENTS.md`
4. Replace `my*` package names with canonical names in docs.
5. Document the `aarch64-darwin` omission rule for `niri` and `hotkey-cheatsheet`.

## Verification commands for a future rerun
```bash
rg -n --glob '!**/.omx/**' --glob '!**/.git/**' \
  '(flake-parts|import-tree|myClaudeCode|myCodex|myCodexYolo|myFastFetch|myGit|myHotkeyCheatsheet|myNiri|myNoctalia|myNvim|myOmx|frameworkConfiguration|frameworkHardware|pcConfiguration|pcHardware|modules/parts.nix|modules/features/niri/hotkey-cheatsheet.nix)' .

find hosts modules packages -name AGENTS.md -print | sort
```

## Notes
- This artifact is intentionally read-only and does not change shared source files.
- The presence of both new `hosts/` / `packages/` directories and old `modules/features/**` references suggests the cutover is only partially integrated on this HEAD.
