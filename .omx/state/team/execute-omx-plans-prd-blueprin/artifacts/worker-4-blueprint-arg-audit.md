# Blueprint argument mismatch audit (worker-4 support artifact)

## Scope
Read-only audit of package/module entrypoints for Blueprint argument mismatches or fragile assumptions, with emphasis on the current `nix flake show` failure and the earlier reported concern around `packages/claude-code/default.nix`.

- Repo HEAD inspected: `b06e4f8d0b16aa1d21a1769055ddecd006bf9002`
- Task: support-only; no shared source files edited

## Executive summary

### 1) Current `nix flake show` failure is **not** a `packages/claude-code/default.nix` bare-`lib` issue
Current `nix flake show --show-trace` fails while evaluating `checks.aarch64-linux`, and the concrete failure shown is an unsupported-package leak:
- `spotify` is being evaluated on `aarch64-linux`
- trace terminates in `wrapper-modules` / `niri` config generation, not in `packages/claude-code/default.nix`

Relevant evidence:
- `packages/niri/shortcuts.nix:30` — `"Mod+Shift+M".spawn = [ (lib.getExe unfreePkgs.spotify) ];`
- `nix flake show --show-trace` reports:
  - `hostPlatform.system = "aarch64-linux"`
  - `package.meta.platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ]`
  - `error: Refusing to evaluate package 'spotify-...' ... because it is not available on the requested hostPlatform`

### 2) `packages/claude-code/default.nix` does **not** currently require a bare `lib` argument
- `packages/claude-code/default.nix:1-6` accepts `{ pkgs, inputs, system, ... }`
- `packages/claude-code/default.nix:8` defines `lib = pkgs.lib;`
- `packages/claude-code/default.nix:43` uses that local `lib`

So if there was an earlier bare-`lib` failure, it appears already fixed on the current HEAD.

### 3) The main remaining risks are Blueprint-coupling / fragility patterns, not an active missing-`lib` signature
The most fragile current patterns are:
- explicit dependence on `perSystem` inside package entrypoints
- explicit dependence on separate `system` argument when `pkgs` already implies the host platform
- platform-unsafe references inside helper files that are shared across systems

## Exact file/line findings

### A. Current active failure: unsupported package leak through `niri` shortcut generation

#### `packages/niri/shortcuts.nix`
- `packages/niri/shortcuts.nix:30`
  - `"Mod+Shift+M".spawn = [ (lib.getExe unfreePkgs.spotify) ];`
  - Problem: this eagerly references `spotify` for all non-Darwin builds, including `aarch64-linux`, where spotify is unsupported.
- `packages/niri/shortcuts.nix:28`
  - `perSystem.self.noctalia`
- `packages/niri/shortcuts.nix:36`
  - `perSystem.self."hotkey-cheatsheet"`
  - These couple the helper to Blueprint's injected `perSystem` shape.

#### `packages/niri/default.nix`
- `packages/niri/default.nix:22-29`
  - imports `./shortcuts.nix` with `pkgs`, `lib`, `perSystem`, `unfreePkgs`
- `packages/niri/default.nix:37`
  - uses `perSystem.self.noctalia`
- `packages/niri/default.nix:77`
  - `binds = shortcuts.binds;`
  - This means the unsupported spotify reference propagates into the generated wrapped package config.

#### `packages/hotkey-cheatsheet/default.nix`
- `packages/hotkey-cheatsheet/default.nix:22-29`
  - imports the same `../niri/shortcuts.nix` helper with `perSystem`
  - So the same helper is a second likely follow-on failure surface.

### B. Claimed issue that does **not** reproduce on current HEAD

#### `packages/claude-code/default.nix`
- `packages/claude-code/default.nix:1-6`
  - signature is `{ pkgs, inputs, system, ... }`
- `packages/claude-code/default.nix:8`
  - `lib = pkgs.lib;`
- `packages/claude-code/default.nix:43`
  - `command = "${lib.getExe pkgs.nodejs} ..."`

Assessment:
- No bare `lib` parameter is required here.
- Current file is consistent with Blueprint-style `pkgs` injection.
- If worker-2 saw a previous failure mentioning missing `lib`, it likely came from an earlier revision or from another file that used `{ lib, ... }` directly.

### C. Other entrypoints with fragile Blueprint assumptions

#### Explicit `system` dependency where `pkgs` may be sufficient
These are probably valid today, but are more brittle than necessary because they rely on `system` being threaded into the package entrypoint:
- `packages/claude-code/default.nix:4,9-11`
- `packages/git/default.nix:4,8-10`
- `packages/niri/default.nix:4,17-19`
- `packages/hotkey-cheatsheet/default.nix:4,17-19`

Pattern:
- `unfreePkgs = import inputs.nixpkgs { inherit system; ... }`

Safer pattern for Blueprint/callPackage compatibility:
- derive from `pkgs.stdenv.hostPlatform.system` (or `pkgs.system` if appropriate)
- this removes one injected-arg dependency from the entrypoint signature

#### Explicit `perSystem` dependency inside packages
These are more strongly coupled to Blueprint internals:
- `packages/niri/default.nix:5,22-29,37`
- `packages/hotkey-cheatsheet/default.nix:5,22-29`
- `packages/niri/shortcuts.nix:4,28,36`

Assessment:
- These may work if Blueprint passes `perSystem` into package entrypoints, but they are a likely future failure point.
- They also make the helper harder to reuse/test in isolation.

## Suggested fix patterns for worker-2

### Priority 1: fix the actual `flake show` blocker
1. Gate the spotify bind in `packages/niri/shortcuts.nix`.
   - Example pattern: only define `Mod+Shift+M` when `unfreePkgs.spotify.meta.platforms` supports the current system, or when `pkgs.stdenv.hostPlatform.system` is supported.
2. Ensure any helper shared by `niri` and `hotkey-cheatsheet` does not eagerly reference unsupported packages for systems that are still in the declared matrix.

### Priority 2: reduce Blueprint argument fragility
1. Prefer deriving `lib` from `pkgs.lib` inside package files instead of accepting bare `lib`.
   - `packages/claude-code/default.nix` already follows this pattern.
2. Prefer deriving `system` from `pkgs.stdenv.hostPlatform.system` when importing a second nixpkgs instance for unfree packages.
   - This would simplify:
     - `packages/claude-code/default.nix`
     - `packages/git/default.nix`
     - `packages/niri/default.nix`
     - `packages/hotkey-cheatsheet/default.nix`
3. Reduce or remove `perSystem` from package helper signatures where possible.
   - Better pattern: pass concrete package dependencies (for example `noctaliaPkg`, `hotkeyCheatsheetPkg`) into helpers rather than the full `perSystem` object.
   - That would make `packages/niri/shortcuts.nix` less Blueprint-specific.

### Priority 3: keep the audit result aligned with current HEAD reality
- Do **not** spend time fixing a nonexistent bare-`lib` problem in `packages/claude-code/default.nix` unless a fresh trace proves it on the current revision.
- The current repro points at platform gating in `niri`/`spotify`, not at `claude-code`.

## Minimal rerun commands
```bash
nix flake show --show-trace

nl -ba packages/claude-code/default.nix | sed -n '1,80p'
nl -ba packages/niri/default.nix | sed -n '1,120p'
nl -ba packages/niri/shortcuts.nix | sed -n '1,120p'
nl -ba packages/hotkey-cheatsheet/default.nix | sed -n '1,80p'
```

## Recommended handoff note
Tell worker-2:
- current HEAD does not reproduce a bare-`lib` mismatch in `packages/claude-code/default.nix`
- current `flake show` blocker is `packages/niri/shortcuts.nix:30` referencing unsupported `spotify` on `aarch64-linux`
- after fixing that, the next cleanup target should be reducing `system` / `perSystem` coupling in package entrypoints
