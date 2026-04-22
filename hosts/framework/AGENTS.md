<!-- Parent: ../AGENTS.md -->

# hosts/framework

## Purpose
Blueprint-native NixOS configuration for the Framework 13 (7040 AMD) laptop.

## Key Files
| File | Description |
|------|-------------|
| `configuration.nix` | Main host config importing shared modules and host-specific settings |
| `hardware-configuration.nix` | Auto-generated hardware scan; do not edit manually |

## Working In This Directory
- Preserve `inputs.nixos-hardware.nixosModules.framework-13-7040-amd` in the host imports.
- Keep hardware-specific settings local to this host.
- Preserve current `custom.*` host values such as wallpaper, flake dir, and sudo username.

## Testing Requirements
- Rebuild with `sudo nixos-rebuild switch --flake ~/myNixOS#framework`.
- Use `nix flake check` for integrated verification.
