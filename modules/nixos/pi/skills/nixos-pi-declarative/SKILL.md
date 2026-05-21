---
name: nixos-pi-declarative
description: Use when installing, updating, or configuring Pi itself, Pi packages, Pi extensions, Pi skills, prompts, or themes in this myNixOS NixOS flake. Ensures changes are made declaratively through the NixOS/Home Manager module instead of mutable pi install commands.
---

# NixOS Declarative Pi Setup

This repository manages Pi declaratively through `modules/nixos/pi/default.nix` using Home Manager.

## Rules

- Do not make persistent Pi changes with `pi install`, `pi remove`, `/settings`, or by manually editing `~/.pi/agent/settings.json`.
- Make persistent changes in `modules/nixos/pi/default.nix` under `custom.pi` options/defaults or the generated Home Manager files.
- Keep Pi itself installed from `inputs.llm-agents.packages.${system}.pi`.
- Use Nix-provided `nodejs`/`npm` for Pi package installation via the declarative `npmCommand` setting.
- Pin Pi packages when possible, e.g. `npm:pi-subagents@0.25.0`, to make rebuilds reproducible.

## Common tasks

### Add or update a Pi package

1. Inspect the package metadata if needed:
   ```bash
   npm view <package> version pi --json
   ```
2. Edit `modules/nixos/pi/default.nix` and update `custom.pi.packages` defaults or host-specific `custom.pi.packages` overrides.
3. Prefer pinned package specs:
   ```nix
   packages = [
     "npm:pi-subagents@0.25.0"
   ];
   ```
4. Validate:
   ```bash
   nix-instantiate --parse modules/nixos/pi/default.nix
   nix flake check
   ```

### Add a local declarative Pi skill

1. Put the skill in this repository under `modules/nixos/pi/skills/<skill-name>/SKILL.md`.
2. Add a Home Manager file mapping in `modules/nixos/pi/default.nix` if the whole skills directory is not already linked.
3. Ensure `settings.enableSkillCommands = true` or leave the module default enabled.
4. Validate with `nix flake check`.

### Update Pi itself

Pi comes from the `llm-agents` flake input. To update it declaratively:

```bash
nix flake update llm-agents
nix flake check
```

Then rebuild the host, for example:

```bash
sudo nixos-rebuild switch --flake ~/myNixOS#framework
```

## Current important files

- `modules/nixos/pi/default.nix` — declarative Pi package, settings, and skill installation.
- `modules/nixos/pi/skills/` — repository-owned declarative Pi skills.
- `flake.nix` / `flake.lock` — `llm-agents` input pin for Pi itself.
