<!-- Parent: ../../AGENTS.md -->

# modules/nixos

## Purpose
Reusable Blueprint-native NixOS modules. Files in this tree back `flake.nixosModules.<name>` and are imported by host configs under `hosts/`.

## Working In This Directory
- Keep each file focused on one reusable module or module family.
- Module files may be wrapped in a top-level function that accepts Blueprint wrapper args such as `flake` or `inputs`.
- When a module needs same-flake packages, consume them via `flake.packages.${pkgs.stdenv.hostPlatform.system}.<pname>`.
- Keep package builders and shared package helpers out of this tree; they belong under `packages/`.
- Preserve host behavior while moving code; avoid feature changes during structural migrations.

## Common Patterns
- Simple module: `{ pkgs, ... }: { environment.systemPackages = [ pkgs.<name> ]; }`
- Module with options: define `options.custom.<name>` and read them from `config.custom.<name>`
- Wrapped package consumer: import from `flake.packages.<system>` rather than rebuilding locally unless host-specific configuration requires it
- Wrapper-sensitive modules may accept `inputs` for external flakes such as `wrapper-modules`, `nvf`, or `nix-colors`

## Dependencies
### Internal
- Hosts import modules from this tree via `flake.nixosModules.<name>`
- Package-producing families are expected under `packages/`
- `niri/` depends on package outputs such as `niri`, `noctalia`, and `hotkey-cheatsheet`

### External
- `wrapper-modules` for wrapped CLI/desktop tools
- `nvf` for Neovim packaging/configuration
- `nix-colors` for theme data
- `nixos-hardware` only from host configs, not reusable modules

## Testing Requirements
- Parse-check modified files with `nix-instantiate --parse`
- Run `nix flake check` after integrated flake changes land
- Rebuild the affected host(s) when behavior changes touch runtime configuration
