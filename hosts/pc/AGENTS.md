<!-- Parent: ../AGENTS.md -->

# hosts/pc

## Purpose
Blueprint-native NixOS configuration for the desktop PC host.

## Key Files
| File | Description |
|------|-------------|
| `configuration.nix` | Main host config importing shared modules and PC-specific settings |
| `hardware-configuration.nix` | Auto-generated hardware scan; do not edit manually |

## Working In This Directory
- Preserve the PC host's latest-kernel boot choice as implemented by the shared boot stack.
- This host does not use `nixos-hardware`.
- Preserve current `custom.*` values such as wallpaper, flake dir, sudo username, and Limine Windows entry.

## Testing Requirements
- Rebuild with `sudo nixos-rebuild switch --flake ~/myNixOS#pc`.
- Use `nix flake check` for integrated verification.
