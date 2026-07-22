<!-- Generated: 2026-04-03 | Updated: 2026-07-22 -->

# myNixOS

## Purpose
A Blueprint-native NixOS flake configuration managing two hosts (`framework` laptop, `pc` desktop) for user `tacascer`. Uses Home Manager for declarative user programs and Stylix for centralized themes, fonts, and wallpapers.

## Key Files

| File | Description |
|------|-------------|
| `flake.nix` | Flake entry point — defines all inputs and delegates to `modules/` via import-tree |
| `flake.lock` | Pinned versions of all flake inputs |
| `CLAUDE.md` | AI assistant instructions for working in this repository |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `modules/nixos/` | Reusable NixOS modules exported by Blueprint |
| `modules/home/` | Reusable Home Manager modules exported by Blueprint |
| `packages/` | Same-flake package builders exported by Blueprint |

## For AI Agents

### Working In This Directory
- Before making any code changes, create and work from a dedicated `git worktree` branch instead of editing the main checkout directly
- This is a **Nix flake** — all configuration is declarative Nix expressions
- Do NOT create unmanaged dotfiles or mutable config files; use declarative NixOS or Home Manager modules
- Blueprint automatically exports files in its standard module and package trees; no manual registration in `flake.nix` is needed
- New feature modules must be added to each host's `configuration.nix` imports list

### Testing Requirements
- Run `nix flake check` to validate syntax and evaluate the flake
- Run `sudo nixos-rebuild switch --flake ~/myNixOS#framework` (or `#pc`) to build and apply
- Use `nix flake show` to verify outputs are correctly defined

### Common Patterns
- **Home Manager bridge pattern**: `flake.nixosModules.<name>` imports `flake.homeModules.<name>` for `config.custom.homeManager.username`
- **Unfree packages**: modules needing unfree create their own `unfreePkgs` import of nixpkgs with `config.allowUnfree = true`
- **Centralized theming**: select `custom.theme` in `modules/nixos/theme.nix`; application modules must not choose themes or hardcode color schemes
- **Starship exception**: `modules/nixos/bash.nix` maps `custom.theme` to matching native Starship presets instead of applying Stylix colors

## Dependencies

### External
- `nixpkgs` (unstable) — package repository
- `blueprint` (numtide/blueprint) — flake organization and automatic output discovery
- `home-manager` (nix-community/home-manager) — declarative user environment and program configuration
- `nvf` (notashelf/nvf) — declarative neovim configuration
- `nixos-hardware` — hardware-specific optimizations for Framework laptop
- `stylix` (nix-community/stylix) — centralized color schemes, fonts, wallpapers, and application styling
- `wallpkgs` (NotAShelf/wallpkgs) — wallpaper sources selected by `custom.theme`

<!-- MANUAL: -->
