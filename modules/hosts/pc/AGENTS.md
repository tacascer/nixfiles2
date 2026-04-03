<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-03 | Updated: 2026-04-03 -->

# pc

## Purpose
NixOS configuration for a desktop PC. Imports all shared feature modules. Uses latest kernel package and does NOT use nixos-hardware (no special hardware module needed).

## Key Files

| File | Description |
|------|-------------|
| `default.nix` | Creates `flake.nixosConfigurations.pc` |
| `configuration.nix` | Main config — imports all feature modules, system services (KDE Plasma 6, SDDM, PipeWire, CUPS), user account, locale (en_GB), latest kernel |
| `hardware-configuration.nix` | Auto-generated hardware scan — do NOT edit manually |

## For AI Agents

### Working In This Directory
- Rebuild with: `sudo nixos-rebuild switch --flake ~/myNixOS#pc`
- Unlike `framework`, this host uses `boot.kernelPackages = pkgs.linuxPackages_latest` for the latest kernel
- When adding a new feature module, add `self.nixosModules.<name>` to the `imports` list in `configuration.nix`
- Custom options set here: `custom.bash.host = "pc"`, `custom.niri.wallpaper`, `custom.sudo.username`

### Testing Requirements
- Must be rebuilt on the actual desktop PC or evaluated with `nix flake check`

### Common Patterns
- Feature modules imported as `self.nixosModules.<name>`
- System services enabled via `services.<name>.enable = true`

## Dependencies

### Internal
- All feature modules from `../../features/`

<!-- MANUAL: -->
