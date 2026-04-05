<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-03 | Updated: 2026-04-03 -->

# features

## Purpose
User-space feature modules — each file wraps, configures, or enables a program or system feature. Most follow a two-part pattern: a `nixosModule` that installs the package and a `perSystem` block that builds it via `wrapper-modules`.

## Key Files

| File | Description |
|------|-------------|
| `colors.nix` | Central color scheme — exposes `custom.colorScheme` option using nix-colors (Tokyo Night Storm) |
| `claude-code.nix` | Claude Code CLI with OMC plugins, settings, and HUD — uses unfree nixpkgs |
| `nvim.nix` | Neovim via nvf framework — Tokyo Night theme, LSP, Telescope, DAP, extensive keymaps |
| `bash.nix` | Bash config with starship prompt, host-parameterized aliases (`nrbs`, `nrbsu`, `claude-yolo`) |
| `git.nix` | Git with 1Password SSH signing, user config — uses unfree nixpkgs for `op-ssh-sign` |
| `noctalia.nix` | Noctalia shell launcher — reads settings from `noctalia.json`, no nixosModule (spawned by niri) |
| `alacritty.nix` | Alacritty terminal — themed via `custom.colorScheme.palette`, JetBrainsMono Nerd Font |
| `fuzzle.nix` | Fuzzel launcher — themed via `custom.colorScheme.palette`, used by hotkey cheatsheet |
| `firefox.nix` | Firefox browser — system dark theme, XDG portal file picker, no wrapped package |
| `1password.nix` | 1Password CLI + GUI — polkit, SSH agent socket for `tacascer` |
| `node.nix` | Node.js and Bun runtimes |
| `discord.nix` | Discord via Vesktop |
| `spotify.nix` | Spotify desktop client (unfree) |
| `obsidian.nix` | Obsidian note-taking app (unfree) |
| `fastfetch.nix` | Fastfetch system info — neofetch-style output via wrapper-modules |
| `sudo.nix` | Passwordless sudo for `nixos-rebuild` and `nix` — parameterized by username |
| `nix-maintenance.nix` | Automatic GC (weekly, 30d) and system auto-upgrade |
| `nix-formatter.nix` | Sets `nixfmt-tree` as the flake formatter |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `niri/` | Niri window manager and related utilities (see `niri/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- Each file defines exactly one feature — name the file after the program/feature
- Follow the two-part pattern: `flake.nixosModules.<name>` + `perSystem.packages.my<Name>`
- Modules using unfree packages must create their own `unfreePkgs` import
- For theming, access colors via `config.custom.colorScheme.palette` (requires importing `colors` module)
- After creating a new module, add `self.nixosModules.<name>` to **both** host `configuration.nix` files

### Testing Requirements
- `nix flake check` after any change
- Rebuild on target host to verify the program works correctly

### Common Patterns
- Simple package module: `flake.nixosModules.<name> = { pkgs, ... }: { environment.systemPackages = [ pkgs.<name> ]; };`
- Wrapped package module: `perSystem` builds via `inputs.wrapper-modules.wrappers.<tool>.wrap { ... }`
- Custom options: `options.custom.<module> = { ... }` with `lib.mkOption`
- Color access: `config.custom.colorScheme.palette.base00` through `base0F` (Base16)

## Dependencies

### Internal
- `colors.nix` — consumed by `alacritty.nix`, `fuzzle.nix` for theming
- `niri/niri.nix` — references `myNoctalia` and `myHotkeyCheatsheet` packages
- `1password.nix` — provides SSH agent used by `git.nix` signing

### External
- `wrapper-modules` — used by git, nvim, niri, noctalia, alacritty, fuzzel, fastfetch, claude-code
- `nvf` — used exclusively by `nvim.nix`
- `nix-colors` — used by `colors.nix`

<!-- MANUAL: -->
