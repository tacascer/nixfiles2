# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Blueprint-native NixOS flake for two Linux hosts (`framework`, `pc`) owned by `tacascer`. Both hosts share reusable NixOS modules from `modules/nixos/`, consume same-flake packages from `packages/`, and preserve the existing desktop/tooling behavior.

## Common Commands

```bash
# Rebuild and switch to a host configuration
sudo nixos-rebuild switch --flake ~/myNixOS#framework
sudo nixos-rebuild switch --flake ~/myNixOS#pc

# Update inputs then rebuild
sudo nix flake update --flake ~/myNixOS
sudo nixos-rebuild switch --flake ~/myNixOS#framework

# Evaluate the flake
nix flake show
nix flake show --all-systems
nix flake check
```

## Architecture

### Flake layout

The flake is organized around Blueprint's standard folder structure:

- `hosts/` — host-local NixOS configurations
- `modules/nixos/` — reusable NixOS modules exported as `flake.nixosModules.<name>`
- `packages/` — same-flake package builders exported as `flake.packages.<system>.<pname>`
- `formatter.nix` — default formatter surface
- `flake.nix` — thin Blueprint entrypoint plus input declarations

### Host composition

Each host lives under `hosts/<name>/` and consists of:

- `configuration.nix` — imports reusable modules from `flake.nixosModules.*`
- `hardware-configuration.nix` — host-local hardware scan data

`framework` additionally imports `inputs.nixos-hardware.nixosModules.framework-13-7040-amd`.
`pc` preserves its latest-kernel boot choice through the shared boot stack and does not use `nixos-hardware`.

### Same-flake package consumption

- Inside hosts, consume same-flake packages via `perSystem.self.<pname>` when Blueprint passes `perSystem`.
- Inside reusable modules, consume same-flake packages via `flake.packages.${pkgs.stdenv.hostPlatform.system}.<pname>`.
- Do not reintroduce flake-parts-only `self` / `self'` package access patterns.

## Package Naming

Canonical package outputs are:

- `claude-code`
- `codex`
- `codex-yolo`
- `fastfetch`
- `git`
- `hotkey-cheatsheet`
- `niri`
- `noctalia`
- `nvim`
- `omx`

Legacy names removed by the migration:

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

## Key Conventions

- Tool wrappers still use `wrapper-modules` when appropriate; wrapper settings remain Nix attrsets, not raw dotfile syntax.
- Neovim is still built with `nvf`.
- Hardware configs stay host-local under `hosts/<name>/hardware-configuration.nix`; they are not reusable module exports.
- Reusable module files live in `modules/nixos/`; package builders live in `packages/`.
- Canonical package names must be used in new code and docs.

## Platform Gating

The systems matrix remains explicit:

- `x86_64-linux`
- `aarch64-linux`
- `aarch64-darwin`

Linux-only package families must be omitted entirely from unsupported systems instead of being exposed and failing during evaluation. In particular, `niri` and `hotkey-cheatsheet` must be absent from `packages.aarch64-darwin`.
