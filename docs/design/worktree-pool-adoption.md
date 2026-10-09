# Worktree-pool adoption through myNixOS

Status: accepted by the user (Lgtm). Shared guidance is implemented and activated on pc. Claude behavioral verification is pending reauthentication; completed checks and limitations appear in the verification record below.

## Scope and delivery

Adopt worktree-pool by default for editing tasks across every repository we work on. Start validation with bazel-repo. Read-only tasks do not acquire, and callers resume an existing valid assignment rather than acquiring another.

Deliver one shared policy through each client's native Home Manager context: Codex AGENTS.md, Claude Code CLAUDE.md, and OpenCode AGENTS.md. Repository-specific instructions remain applicable, including required task branches. Resolve configuration-directory overrides during verification. Required assignment and recovery guidance must be loaded before tool use, rather than relying on lazy skill discovery.

Use the existing upstream binary and commands. Concurrent capacity-change coordination, a native grow API, its upstream tests, and a package-pin update for that feature are deferred and are not adoption prerequisites.

## Repository enrollment and capacity

Automatically register a repository for its first editing task using the existing catalog authority. Registration identifies the canonical Git common directory: linked checkouts share one repository pool; separate clones do not. Registration does not enroll other existing worktrees.

New repositories start with capacity four. Worktrees are created on demand, with eligible retained worktrees preferred. Four is a capacity setting, not an instruction to eagerly create four directories.

On a confirmed capacity rejection, inspect the repository's current maximum and raise it by four using the existing command:

```sh
worktree-pool --json pool configure --repo <repository-id> --max-worktrees <current-maximum-plus-4>
```

The normal sequence is 4 → 8 → 12 → 16, continuing as needed with no fixed policy ceiling. Configuration itself creates no worktree; the next acquisition creates a worktree on demand if no eligible retained worktree is available.

Inspect the configuration result before a fresh acquisition attempt. If that attempt again returns a confirmed capacity rejection, repeat the inspected four-slot increase as needed. Only a confirmed capacity rejection is a growth trigger. Pending/unknown outcomes require inspection and do not authorize blind retries or further growth. Capacity expansion never releases assignments or bypasses recovery.

Use checked arithmetic and surface tool/configuration failures rather than wrapping values. An explicit disabled or exceptional existing policy is not silently overwritten. Do not reset an existing limit to four each session or intentionally lower a larger inspected maximum. General coordination of concurrent capacity changes remains deferred; no native grow command or new upstream feature is planned.

The existing bazel-repo pilot maximum of one receives its approved one-time migration to four during rollout. New registration already defaults to four, and repeat registration preserves the existing record and limit.

## Assignment lifecycle and recovery

Before interpreting command results, retain raw JSON and exit status in durable caller-owned runtime state outside reusable checkouts. The runtime record location is `$XDG_STATE_HOME/worktree-pool/agent-receipts`, with the normal XDG fallback. Use unique per-invocation records and retain partial/error output. A missing or damaged receipt does not authorize guessing the newest handle.

Acquire returns the exact assignment handle, operation ID, repository/worktree IDs, lossless absolute path, fixed resolved commit, and nullable branch. Use the authoritative path bytes when routing execution. Handoffs carry these identities, the task ref, receipt location, and current assignment/recovery status. A path alone does not establish ownership.

Continuation uses the exact active assignment and confirms the previous caller has stopped. Independently editing concurrent callers use separate assignments. Time elapsed and process death do not transfer or release ownership.

Use an explicit task ref when continuing existing work, otherwise refreshed origin/main. Acquisition stays detached; branch creation remains a separate caller decision following repository rules or the requested deliverable. Do not move existing unfinished work implicitly.

Release after completed work is preserved and task-owned active writers stop, using the retained assignment handle. Rejected release retains ownership. Do not stash/reset/clean to defeat unfinished-work protection. Ignored artifacts remain retained and detached tips receive verified preservation references. Paused or unfinished tasks stay assigned and receive an explicit handoff.

Agents may inspect and preview recovery. Applying recovery requires explicit human approval of the exact identity and action. Successful recovery does not necessarily release ownership or make the worktree reusable; inspect both ownership and availability afterward. Never initialize another catalog to escape missing/conflicting authority or pending work.

Repositories without origin/main, failed refreshes, and pending/unknown operations remain blockers. The existing binary always refreshes origin/main, even with an explicit task ref. These failures do not trigger capacity growth or a disposable-worktree fallback.

Accepted existing-worktree policy: preserve existing checkouts and caches rather than automatically enrolling or migrating them. New editing tasks use pooled assignments; unfinished existing work requires an explicit handoff before migration.

## Verification and rollout

Fresh CLI verification is accepted for Codex, Claude Code, and OpenCode. Codex desktop loading is tracked separately and not inferred from CLI success.

Accepted rollout: implement shared declarative guidance using the installed upstream capabilities, evaluate/build both hosts, activate pc, perform the one-time bazel-repo capacity migration, and verify all three clients live on pc. Framework runtime verification remains pending until an actual access route exists. Preserve current sandbox and approval settings; inspect pooled-path trust rather than broadly trusting home/the pool root or assuming linked-checkout trust inheritance.

Run nix flake check and nix flake show; apply the verified pc configuration with the repository-native nixos-rebuild workflow. Record outputs and material limitations. No upstream feature implementation or package pin update is required by this plan.

Deployment evidence compares resolved native instruction paths and policy content hashes, including CODEX_HOME, CLAUDE_CONFIG_DIR, and XDG overrides. Runtime evidence uses genuinely fresh sessions with normal client configuration and a neutral prompt that supplies no expected policy and attaches no guidance file. Capture version, working directory, invocation, loaded-source evidence, response/transcript, and any limitations.

Probe the canonical bazel-repo checkout, a pooled checkout, a second repository, and a non-repository directory. Loading probes are read-only and do not acquire/release worktrees. Do not use client-native worktree-creation flags, bare/pure modes, or resumed sessions for discovery checks.

Corroborate actual discovery with Codex session evidence, Claude's fresh interactive /context, and OpenCode prompt-source diagnostics or constrained file-read tracing. Model repetition and file hashes alone do not prove full loading. OpenCode debug config/agent output is not an assembled-prompt dump. Verify no workspace-mutating tool execution occurred.

Use isolated application/Git fixtures for meaningful sequential checks of enrollment, sequential four-slot increases (4 → 8 → 12), successful on-demand acquisition after exhaustion, receipt/handle retention, stale release, rejected unfinished-work release, and recovery preview. Do not saturate the real bazel-repo pool artificially or apply recovery without its required explicit approval. Existing core ownership coordination remains in force; concurrent capacity-change implementation/tests are deferred.

## Verified baseline, 2026-10-09

myNixOS baseline commit a50c932 installs worktree-pool 0.1.0 through Home Manager, with both hosts importing the bridge. The package pins bazel-repo commit 44063c8865be48acab7d844330d0a9687787e187. The [packaging record](../../packages/worktree-pool/README.md) documents prior installation/pilot checks. The installed upstream README is `/nix/store/w5vq2ikjpvps91249nbh1d8lfmpavxkm-worktree-pool-0.1.0/share/doc/worktree-pool/README.md`.

Fresh semantic read-only inspections found catalog revision 26 active and validated, one registered bazel-repo pool with maximum one, and one unassigned worktree with unverified availability and no pending work. Coordination-lock access required elevated filesystem permissions. Unassigned does not guarantee reuse eligibility; acquisition validates safety.

Codex 0.160.0 has no configured Home Manager context and an empty global AGENTS.md. Claude Code 2.1.288 and OpenCode's pinned 1.18.34 package share the effectively empty modules/home/claude-home-instructions.md. All three pinned Home Manager modules expose native context options. Default paths are ~/.codex/AGENTS.md, ~/.claude/CLAUDE.md, and ~/.config/opencode/AGENTS.md.

The current host is pc. No framework SSH/Tailscale target is configured; this is not evidence that the laptop is offline. Framework evaluation/build is available independently of runtime access.

At the initial baseline, guidance and fresh-session verification were absent. The verification record below captures the subsequent deployment and observed loading. Existing benchmark acceptance concerns the pinned upstream's measured scope; this change makes no additional performance claim.

## Source evidence

Pinned upstream README documents registration, on-demand acquisition/creation, absolute capacity configuration, exact-handle release, and explicit recovery. Fresh upstream README retrieval confirmed on-demand creation and existing capacity increases. Native implementation references: git.rs:87-129, acquisition_workflow.rs:58-85, cli.rs:25-35 and 174-190 and 864-900, acquisition.rs:13-28, workflows.rs:76-98 and 265-291, management.rs:394-413, creation_workflow.rs:147-165.

[Upstream capacity and on-demand creation](https://github.com/LowkeyLab/bazel-repo/blob/main/worktree_pool/README.md#capacity-and-on-demand-creation), [official Codex guidance](https://learn.chatgpt.com/docs/agent-configuration/agents-md), [Claude memory guidance](https://code.claude.com/docs/en/memory), [OpenCode rules](https://opencode.ai/docs/rules/), and [OpenCode CLI](https://opencode.ai/docs/cli/).

## Implementation verification

The shared policy is modules/home/agent-home-instructions.md. Codex's native context, Claude's context bridge, and OpenCode's native context consume that same source. The effectively empty Claude-named source was replaced. No upstream package/version/pin or concurrency feature changed.

Nix flake check passed, including both host builds; flake show --all-systems passed. Modified Nix files parsed and Git diff checks passed. Non-blocking warnings reported the dirty development tree, Blueprint output names, and incompatible aarch64 systems omitted by the local check. Only pc was activated.

The first pc activation was blocked by an existing .codex/AGENTS.md.backup. The current unmanaged AGENTS.md was verified empty and preserved in private evidence state; the older backup was retained. Retried nixos-rebuild switch succeeded, with Home Manager ActiveState=active and Result=success.

All three native instruction files resolve to the same Nix store source and have identical SHA-256 dc9b3407620f249a967a97d2144b2d001e818295050e782ba7a8a4a82ee4f30b. Default config roots were used, and Codex retains read-only sandbox, on-request approvals, and auto_review. No broad trust grant was added.

Fresh normal-configuration Codex and OpenCode sessions passed all four loading probes: canonical bazel-repo, its retained pooled checkout, ai-plugins as a second repository, and a non-repository directory. Constrained strace logs prove the native global instruction source was opened and its policy contents read. The responses preserve exact assignment handles, durable receipts/handoffs, four-slot growth, interrupted-result inspection, human-approved recovery, and read-only applicability. Transcripts contain no tool executions, and workspace status/HEAD remained unchanged. OpenCode's probe permissions explicitly denied tools without changing user configuration.

Claude's fresh bazel-repo session likewise opened and read the shared policy. Its response failed with an expired OAuth session that could not refresh. Reauthentication was requested; Claude behavioral and remaining directory probes are pending rather than reported successful. Framework runtime and Codex desktop loading remain separately unverified.

The installed CLI passed a private real Git/catalog pilot: new capacity four; on-demand acquisition until exhaustion; sequential limits 4 → 8 → 12 without eager allocation; nine simultaneously assigned fixture worktrees; unfinished-work release rejected while retaining ownership; a synthetic fixture commit preserved the work; stale/repeated release left the new assignment active; recovery preview required no apply. All fixture assignments were released and final catalog check passed. The raw receipts remain private runtime evidence. The harness initially used an incorrect capacity-field name; it was corrected to the actual repository.capacity schema before the behavioral pilot proceeded.

The real bazel-repo repository received its approved one-time maximum change from one to four with full raw receipts. Existing source checkouts and caches were preserved. The remaining myNixOS edits were explicitly handed off from the original design worktree into an assigned pooled checkout when this session received the new policy; no original source work was discarded.
