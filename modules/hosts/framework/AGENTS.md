<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-03 | Updated: 2026-04-03 -->

# framework

## Purpose
NixOS configuration for a Framework 13 laptop (7040 AMD). Imports all shared feature modules plus `nixos-hardware` optimizations for the specific hardware revision.

## Key Files

| File | Description |
|------|-------------|
| `default.nix` | Creates `flake.nixosConfigurations.framework` |
| `configuration.nix` | Main config — imports all feature modules, system services (KDE Plasma 6, SDDM, PipeWire, CUPS), user account, locale (en_GB) |
| `hardware-configuration.nix` | Auto-generated hardware scan — do NOT edit manually |

## For AI Agents

### Working In This Directory
- Rebuild with: `sudo nixos-rebuild switch --flake ~/myNixOS#framework`
- The `nixos-hardware.nixosModules.framework-13-7040-amd` import provides hardware-specific optimizations (power, firmware)
- When adding a new feature module, add `self.nixosModules.<name>` to the `imports` list in `configuration.nix`
- Custom options set here: `custom.bash.host = "framework"`, `custom.niri.wallpaper`, `custom.sudo.username`

### Testing Requirements
- Must be rebuilt on the actual Framework laptop or evaluated with `nix flake check`

### Common Patterns
- Feature modules imported as `self.nixosModules.<name>`
- System services enabled via `services.<name>.enable = true`

## Dependencies

### Internal
- All feature modules from `../../features/`
- `nixos-hardware` input for Framework-specific optimizations

<!-- MANUAL: -->
