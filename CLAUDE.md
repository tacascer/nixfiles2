# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A NixOS flake configuration for a Framework laptop (AMD Ryzen, x86_64). Single host (`framework`), single user (`tacascer`).

## Common Commands

```bash
# Rebuild and switch to new configuration
sudo nixos-rebuild switch --flake ~/myNixOS#framework

# Update flake inputs then rebuild
sudo nix flake update --flake ~/myNixOS && sudo nixos-rebuild switch --flake ~/myNixOS#framework

# Shell aliases defined in bash.nix: sysup (rebuild), sysup-update (update + rebuild)

# Evaluate without building (useful for checking syntax)
nix flake check

# Show flake outputs
nix flake show
```

## Architecture

**Flake entry point**: `flake.nix` uses `flake-parts` + `import-tree` to automatically discover and import all `.nix` files under `modules/`.

**Key inputs**:
- `nixpkgs` (unstable)
- `flake-parts` - flake organization framework
- `import-tree` - auto-imports all modules from the `modules/` directory tree
- `wrapper-modules` (`BirdeeHub/nix-wrapper-modules`) - declarative tool wrapping for git, niri, noctalia, claude-code
- `nvf` (`notashelf/nvf`) - declarative neovim configuration framework

### Module Pattern

Every feature module in `modules/features/` follows this structure:

```nix
{self, inputs, ...}: {
  flake.nixosModules.<name> = { pkgs, ... }: { /* NixOS module config */ };
  perSystem = { pkgs, ... }: { packages.<name> = ...; };
}
```

Modules export a `nixosModule` (imported by the host) and optionally a `perSystem` package.

### Host Composition

`modules/hosts/framework/default.nix` creates the NixOS system configuration. `configuration.nix` imports feature modules by referencing `self.nixosModules.<name>`. New features must be both defined in `modules/features/` and imported in `configuration.nix`.

### Directory Layout

- `modules/parts.nix` - defines supported systems (x86_64-linux, aarch64-linux, etc.)
- `modules/features/` - user-space feature modules (bash, git, niri, nvim, noctalia, claude-code)
- `modules/hosts/framework/` - host-specific config (system settings, hardware)

## Key Conventions

- Tool configuration uses `wrapper-modules` wrappers (`inputs.wrapper-modules.wrappers.<tool>.wrap`) instead of dotfiles
- Neovim config uses `nvf` framework, not raw lua/vimscript
- All modules are auto-discovered by `import-tree` -- no manual registration in `flake.nix` needed, but new feature modules must be imported in the host's `configuration.nix`
