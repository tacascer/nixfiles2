<!-- Parent: ../AGENTS.md -->

# packages

## Purpose
Package builders and package-local helpers for Blueprint outputs under `flake.packages.<system>.<pname>`.

## Working In This Directory
- One package family per directory or file.
- Keep shared package helpers local to the package tree, for example:
  - `packages/codex/common.nix`
  - `packages/niri/lib.nix`
  - `packages/niri/shortcuts.nix`
- Canonical package names must be used for all public outputs.
- Unsupported package families must be omitted from a system's attrset entirely.
- Codex full-auto mode is invoked as `codex --yolo`; do not reintroduce a separate `codex-yolo` package output.

## Canonical Package Names
- `claude-code`
- `codex`
- `fastfetch`
- `git`
- `hotkey-cheatsheet`
- `niri`
- `noctalia`
- `nvim`
- `omx`

## Platform Gating
- Keep the systems matrix explicit: `x86_64-linux`, `aarch64-linux`, `aarch64-darwin`.
- Omit Linux-only families from unsupported Darwin outputs.
- In particular, `niri` and `hotkey-cheatsheet` must be absent from `packages.aarch64-darwin`.

## Testing Requirements
- Parse-check modified package files.
- Use `nix flake show --all-systems` to confirm unsupported packages are omitted, not broken.
- Build affected package outputs on supported systems after integration.
