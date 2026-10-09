# worktree-pool through Nix

The package builds the standalone `worktree_pool` crate from merged bazel-repo
commit `44063c8865be48acab7d844330d0a9687787e187`. Source and Cargo vendor hashes
are pinned. The crate's own Cargo.lock supplies locked dependencies; the monorepo
root lockfile and Bazel toolchain are not used by this package.

The pinned Nixpkgs Rust compiler is 1.98.1, satisfying the manifest's 1.96 minimum.
Upstream supports x86_64-linux; Blueprint omits this package from both aarch64
outputs. License metadata is AGPL-3.0-only, and the license and public docs are
installed alongside the executable.

Home Manager installs the package through `modules/home/worktree-pool.nix`.
Both hosts import the NixOS bridge. The executable wrapper supplies Nixpkgs
Git 2.55.0, satisfying upstream's 2.36 minimum. SSH transport uses the host's
SSH executable, credentials and agent; installation does not supply credentials.
Installation does not initialize a catalog, enroll repositories, or acquire slots.

## Verification

```sh
nix build .#worktree-pool
nix flake check
nix flake show --all-systems
sudo -n nixos-rebuild switch --flake .#pc
worktree-pool --version
```

The package uses Nixpkgs [buildRustPackage](https://nixos.org/manual/nixpkgs/stable/#rust).
Its default Cargo check ran all 39 library tests with real private fixtures:
39 passed, zero failed, ignored or filtered. The installed-command pilot below
checks wrapper wiring and actual origin transport beyond those library checks.
No application interfaces or test doubles were added. Catalog files are owned
application state; Git's common directory and origin are shared external
resources, so the pilot uses explicit identities and one new slot.

On 2026-10-09, the package build, Nix formatting/parse checks, flake check and
all-system output inspection passed. Both host systems built during flake check;
only pc was activated. Home Manager reported ActiveState=active and Result=success.
The installed executable reported worktree-pool 0.1.0. Blueprint's unknown-output
warnings were non-blocking; flake check skipped incompatible aarch64 systems.
This does not establish runtime support outside x86_64-linux.

## Explicit local pilot

Inspect `worktree-pool --json catalog info` first. A missing catalog was confirmed
before initializing the default authority. Do not initialize another catalog to
work around an existing or pending authority.

The pilot explicitly initialized that catalog, enrolled `/home/tacascer/Projects/bazel-repo`,
and configured `--max-worktrees 1`. Existing worktrees were not enrolled.
Run acquisition from any working directory with an explicit repository selector:

```sh
worktree-pool --json acquire --repo /home/tacascer/Projects/bazel-repo
```

Retain the returned assignment handle and path. Finish work in that checkout,
then release by handle, never by path:

```sh
worktree-pool release <assignment-handle>
worktree-pool assignment inspect <assignment-handle>
worktree-pool operation inspect <operation-id>
worktree-pool recover preview --operation <operation-id>
worktree-pool catalog check
```

Apply recovery only for the exact inspected identity and its prescribed action.
Do not blindly retry a pending or unknown operation. The pilot exercised recovery
of a completed release, not an injected crash or pending failure.

Observed pilot outcomes:

- Actual GitHub SSH origin/main refresh and detached acquisition succeeded.
- Installed worktree inspection succeeded with PATH=/nonexistent; the wrapper supplied Git.
- A second acquisition while the single slot was assigned returned capacity_all_assigned.
- Release with an unfinished pilot note returned unfinished_work and retained ownership.
- Full repository formatting passed without modifying files. A local pilot-note
  commit was created with signing disabled only for that synthetic fixture commit.
- Explicit release preserved its detached tip in the exact operation reference.
- Operation inspection, recovery preview and completed-operation apply succeeded.
- Reacquisition with only SSH's directory in ambient PATH reused the same slot,
  returned a fresh handle, checked out refreshed origin/main and retained the earlier tip.
- Releasing the old handle left the new assignment active. The final new-handle
  release succeeded; catalog check passed at revision 26 with no active assignments.

Retained local identities:

| Item | Identity |
| --- | --- |
| Catalog | de2f76d2-3cb1-4050-838e-9618087569c6 |
| Repository | 207f1904-1165-417f-a4f0-399e8498ed22 |
| Worktree | 0f5edc87-b50a-4267-bc01-f3b78b44991f |
| First assignment (released) | 55448a7f-924a-443b-a829-cb122726733d |
| First release | 22759855-c971-4778-a767-fa20e6e87966 |
| Pilot commit | 881d961cbef8235aba7cfd0c9d65c7cc92cf0e18 |
| Preservation reference | refs/worktree-pool/22759855-c971-4778-a767-fa20e6e87966 |
| Second assignment (released) | 7002aa36-8345-432c-b8ce-a47fa08b8417 |
| Final release | 5dc71cb7-9882-4f6b-b5df-071989071b9d |

The retained slot lives at `/home/tacascer/.local/share/worktree-pool/worktrees/207f1904-1165-417f-a4f0-399e8498ed22/0f5edc87-b50a-4267-bc01-f3b78b44991f`. Final ownership is unassigned;
availability is unverified, so a later acquisition must validate safety again.
The original checkout remains clean on chore/vale. Fetch deliberately updated
origin/main; existing checkout contents and branches were not switched.

Raw private receipts and logs: `/tmp/worktree-pool-nix-pilot-20261009/`.
Nix logs: `/tmp/worktree-pool-nix-{build,check,show,switch}.log`.
Temporary logs are not durable acceptance infrastructure. The committed summary
and catalog history retain the workflow identities. This pilot does not rerun the
accepted benchmark or establish crash/power-loss behavior. Retained worktree and
Bazel formatter state remain local; no cache cleanup was performed.

Crates.io publication, wider adoption and agent-instruction updates remain
separate follow-ups. The Nix change is local until separately approved for publication.
