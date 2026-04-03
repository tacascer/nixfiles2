<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-03 | Updated: 2026-04-03 -->

# hosts

## Purpose
Per-machine NixOS configurations. Each subdirectory defines a `nixosConfiguration` for a specific host, composing feature modules with hardware-specific settings.

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `framework/` | Framework 13 (7040 AMD) laptop configuration (see `framework/AGENTS.md`) |
| `pc/` | Desktop PC configuration (see `pc/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- Each host has `default.nix` (creates `nixosConfigurations.<name>`) and `configuration.nix` (imports feature modules)
- Both hosts share all feature modules — differences are in hardware config and `custom.bash` settings
- When adding a new feature module, add its import to **both** host `configuration.nix` files
- Hardware configurations (`hardware-configuration.nix`) are auto-generated — do not manually edit

### Testing Requirements
- Rebuild the specific host: `sudo nixos-rebuild switch --flake ~/myNixOS#<hostname>`

### Common Patterns
- `default.nix`: creates `flake.nixosConfigurations.<name>` pointing to the configuration module
- `configuration.nix`: defines `flake.nixosModules.<name>Configuration` with imports list and system settings

<!-- MANUAL: -->
