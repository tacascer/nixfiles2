<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-03 | Updated: 2026-04-03 -->

# modules

## Purpose
Contains all NixOS modules for the flake. Every `.nix` file in this tree is auto-discovered and imported by `import-tree` — no manual registration needed. Organized into feature modules (user-space programs) and host modules (machine-specific configurations).

## Key Files

| File | Description |
|------|-------------|
| `parts.nix` | Defines supported systems: `x86_64-linux`, `aarch64-linux`, `aarch64-darwin` |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `features/` | User-space feature modules — each wraps or enables a program (see `features/AGENTS.md`) |
| `hosts/` | Per-machine configurations — hardware, imports, and host-specific settings (see `hosts/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- All `.nix` files are auto-imported — adding a file here automatically makes it part of the flake
- Each file receives `{ self, inputs, ... }` as top-level arguments (flake-parts module args)
- Feature modules export via `flake.nixosModules.<name>` and optionally `perSystem.packages.my<Name>`
- Host modules export via `flake.nixosConfigurations.<name>`

### Testing Requirements
- After adding/modifying any module: `nix flake check` to validate
- New feature modules must be imported in `hosts/*/configuration.nix`

### Common Patterns
- Top-level function signature: `{ self, inputs, ... }:` for flake-parts module args
- Inner module signature: `{ pkgs, config, lib, ... }:` for NixOS module args
- Custom options use `config.custom.<module>` namespace

## Dependencies

### Internal
- `parts.nix` is required by flake-parts for system enumeration
- Feature modules are consumed by host configurations via `self.nixosModules.<name>`

<!-- MANUAL: -->
