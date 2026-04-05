# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A NixOS flake configuration managing two hosts (`framework`, `pc`) for user `tacascer`. Both are x86_64-linux with KDE Plasma 6, niri window manager, and shared feature modules.

## Common Commands

```bash
# Rebuild and switch to new configuration
sudo nixos-rebuild switch --flake ~/myNixOS#framework  # or #pc

# Update flake inputs then rebuild
sudo nix flake update --flake ~/myNixOS && sudo nixos-rebuild switch --flake ~/myNixOS#framework

# Shell aliases (defined in bash.nix, parameterized per host):
#   nrbs         - rebuild current host
#   nrbsu        - update inputs + rebuild
#   claude-yolo  - claude --dangerously-skip-permissions

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
- `wrapper-modules` (`BirdeeHub/nix-wrapper-modules`) - declarative tool wrapping for git, niri, noctalia, alacritty, claude-code
- `nvf` (`notashelf/nvf`) - declarative neovim configuration framework
- `nixos-hardware` - hardware-specific optimizations (used by `framework` host)

### Module Pattern

Most feature modules in `modules/features/` follow this two-part structure:

```nix
{self, inputs, ...}: {
  flake.nixosModules.<name> = { pkgs, ... }: { /* NixOS module — enables program, adds system packages */ };
  perSystem = { pkgs, ... }: { packages.my<Name> = inputs.wrapper-modules.wrappers.<tool>.wrap { ... }; };
}
```

The `nixosModule` installs the wrapped package into the system. The `perSystem` block builds it via `wrapper-modules`. Not all modules need both parts — `firefox.nix` has no wrapped package, `noctalia.nix` has no nixosModule (it's spawned by niri).

### Host Composition

Each host has `modules/hosts/<name>/default.nix` (creates `nixosConfigurations.<name>`) and `configuration.nix` (imports feature modules via `self.nixosModules.<name>`). The two hosts share all feature modules but differ in hardware config and `custom.bash` settings.

**Adding a new feature**: create `modules/features/<name>.nix`, then add `self.nixosModules.<name>` to each host's `configuration.nix` imports.

### Directory Layout

- `modules/parts.nix` - defines supported systems
- `modules/features/` - user-space feature modules (bash, git, niri, nvim, noctalia, claude-code, alacritty, firefox, 1password, node)
- `modules/hosts/framework/` - Framework laptop config (uses `nixos-hardware` module)
- `modules/hosts/pc/` - Desktop PC config

## Key Conventions

- Tool configuration uses `wrapper-modules` wrappers (`inputs.wrapper-modules.wrappers.<tool>.wrap { settings = { ... }; }`) instead of dotfiles — settings are Nix attrsets, not config file syntax
- Neovim config uses `nvf` framework, not raw lua/vimscript — keymaps use `{ key, mode, action, desc, lua }` attrset format
- All modules are auto-discovered by `import-tree` — no manual registration in `flake.nix` needed, but new feature modules must be imported in each host's `configuration.nix`
- Git commits are signed via 1Password SSH agent (`op-ssh-sign`)
- Modules needing unfree packages create their own `unfreePkgs` import (see `git.nix`, `claude-code.nix`)
