<!-- Parent: ../AGENTS.md -->

# hosts

## Purpose
Per-machine NixOS configurations in the Blueprint layout. Each host keeps its own `configuration.nix` and `hardware-configuration.nix` under `hosts/<name>/`.

## Subdirectories
| Directory | Purpose |
|-----------|---------|
| `framework/` | Framework 13 laptop configuration |
| `pc/` | Desktop PC configuration |

## Working In This Directory
- Import reusable modules from `flake.nixosModules.<name>`.
- Keep hardware scan data host-local; do not move it back into reusable module exports.
- Preserve host-specific `custom.*` settings while sharing reusable modules across both hosts.
- When adding a new reusable module, wire it into each host that should consume it.

## Testing Requirements
- Rebuild the specific host with `sudo nixos-rebuild switch --flake ~/myNixOS#<hostname>`.
- Use `nix flake check` after integrated host/module/package changes land.
