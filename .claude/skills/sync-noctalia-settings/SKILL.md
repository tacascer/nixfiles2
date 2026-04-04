---
name: sync-noctalia-settings
description: Use when the user wants to sync, export, or update noctalia shell settings from the running instance into the repo JSON configuration
---

# Sync Noctalia Settings

## Overview

Exports live noctalia-shell settings via IPC and writes them to `modules/features/noctalia.json`, which the Nix wrapper reads at build time.

## Steps

1. Dump current settings via IPC and write only the `settings` key (not `state`) to the repo JSON:
```bash
nix run nixpkgs#noctalia-shell ipc call state all | \
  node -e "
    const chunks = [];
    process.stdin.on('data', c => chunks.push(c));
    process.stdin.on('end', () => {
      const data = JSON.parse(Buffer.concat(chunks).toString());
      process.stdout.write(JSON.stringify({ settings: data.settings }, null, 2) + '\n');
    });
  " > modules/features/noctalia.json
```

2. Verify the flake still evaluates:
```bash
nix flake check
```

## Important

- **Only keep `settings`, never `state`** — state contains runtime data (wallpaper paths, display info, performance mode) that changes per session.
- The `noctalia.nix` module reads this JSON via `builtins.fromJSON (builtins.readFile ./noctalia.json)` and passes `.settings` to the wrapper.
- `node` is available on the system; `python3` and `jq` are not.
