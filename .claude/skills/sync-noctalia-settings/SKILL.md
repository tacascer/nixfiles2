---
name: sync-noctalia-settings
description: Use when the user wants to sync, export, or update noctalia shell settings from the running instance into the repo JSON configuration
---

# Sync Noctalia Settings

## Overview

Exports live noctalia-shell settings via IPC and writes them to `modules/features/noctalia.json`, which the Nix wrapper reads at build time.

## Steps

1. Find the running noctalia binary path:
```bash
pgrep -a quickshell
```
Noctalia runs as `quickshell` at runtime, not `noctalia-shell`. The output shows the nix store path like `/nix/store/...-noctalia-shell-X.Y.Z/share/noctalia-shell`. The binary is at the corresponding `/bin/noctalia-shell` path in the **wrapper** package — extract it with:
```bash
nix build ~/myNixOS#myNoctalia --no-link --print-out-paths
```

2. Dump current settings via IPC and write only the `settings` key (not `state`) to the repo JSON:
```bash
/nix/store/...-noctalia-shell-X.Y.Z/bin/noctalia-shell ipc call state all | \
  node -e "
    const chunks = [];
    process.stdin.on('data', c => chunks.push(c));
    process.stdin.on('end', () => {
      const data = JSON.parse(Buffer.concat(chunks).toString());
      process.stdout.write(JSON.stringify({ settings: data.settings }, null, 2) + '\n');
    });
  " > modules/features/noctalia.json
```

3. Verify the flake still evaluates:
```bash
nix flake check
```

## Important

- **Only keep `settings`, never `state`** — state contains runtime data (wallpaper paths, display info, performance mode) that changes per session.
- The `noctalia.nix` module reads this JSON via `builtins.fromJSON (builtins.readFile ./noctalia.json)` and passes `.settings` to the wrapper.
- `node` is available on the system; `python3` and `jq` are not.
