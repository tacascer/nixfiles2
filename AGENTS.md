<!-- Generated: 2026-04-03 | Updated: 2026-04-03 -->

# myNixOS

## Purpose
A NixOS flake configuration managing two hosts (`framework` laptop, `pc` desktop) for user `tacascer`. Uses flake-parts with import-tree for automatic module discovery, wrapper-modules for declarative tool configuration, and nix-colors for centralized theming.

## Key Files

| File | Description |
|------|-------------|
| `flake.nix` | Flake entry point — defines all inputs and delegates to `modules/` via import-tree |
| `flake.lock` | Pinned versions of all flake inputs |
| `CLAUDE.md` | AI assistant instructions for working in this repository |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `modules/` | All NixOS modules — auto-discovered by import-tree (see `modules/AGENTS.md`) |
| `wallpapers/` | Desktop wallpaper images used by niri via swaybg |

## For AI Agents

### Working In This Directory
- This is a **Nix flake** — all configuration is declarative Nix expressions
- Do NOT create dotfiles or config files; use `wrapper-modules` wrappers instead
- All `.nix` files under `modules/` are auto-imported by `import-tree` — no manual registration in `flake.nix` needed
- New feature modules must be added to each host's `configuration.nix` imports list

### Testing Requirements
- Run `nix flake check` to validate syntax and evaluate the flake
- Run `sudo nixos-rebuild switch --flake ~/myNixOS#framework` (or `#pc`) to build and apply
- Use `nix flake show` to verify outputs are correctly defined

### Common Patterns
- **Two-part module pattern**: `flake.nixosModules.<name>` (NixOS config) + `perSystem.packages.my<Name>` (wrapped package)
- **Unfree packages**: modules needing unfree create their own `unfreePkgs` import of nixpkgs with `config.allowUnfree = true`
- **Centralized theming**: modules access `config.custom.colorScheme.palette` (Base16 colors from nix-colors)
- **Wrapper-modules**: `inputs.wrapper-modules.wrappers.<tool>.wrap { settings = { ... }; }` for tool configuration

## Dependencies

### External
- `nixpkgs` (unstable) — package repository
- `flake-parts` — flake organization framework
- `import-tree` — automatic module discovery from directory tree
- `wrapper-modules` (BirdeeHub/nix-wrapper-modules) — declarative tool wrapping
- `nvf` (notashelf/nvf) — declarative neovim configuration
- `nixos-hardware` — hardware-specific optimizations for Framework laptop
- `nix-colors` (misterio77/nix-colors) — Base16 color scheme management

<!-- MANUAL: -->
