<!-- Parent: ../AGENTS.md -->

# packages

## Purpose
Package builders and package-local helpers for Blueprint outputs under `flake.packages.<system>.<pname>`.

## Working In This Directory
- One package family per directory or file.
- Keep shared package helpers local to the package tree, for example `packages/qmd/common.nix`.
- Canonical package names must be used for all public outputs.
- Unsupported package families must be omitted from a system's attrset entirely.
- AI coding agents and companion tools owned by the pinned `llm-agents` input do not belong in this tree. Do not recreate Codex or OMX package outputs here.

## Canonical Package Names
- `nvim`
- `qmd`

## Platform Gating
- Keep the systems matrix explicit: `x86_64-linux`, `aarch64-linux`, `aarch64-darwin`.
- Omit Linux-only families from unsupported Darwin outputs.

## Testing Requirements
- Parse-check modified package files.
- Use `nix flake show --all-systems` to confirm unsupported packages are omitted, not broken.
- Build affected package outputs on supported systems after integration.
