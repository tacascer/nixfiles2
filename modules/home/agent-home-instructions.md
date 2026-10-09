# Pooled coding workspaces

Use worktree-pool for editing tasks in every Git repository. Read-only tasks and work outside Git repositories need no assignment. Follow repository-specific instructions, including required task branches, within the pooled checkout. Preserve existing checkouts and unfinished work until an explicit handoff; repository enrollment does not enroll other worktrees.

## Acquire or continue

1. Inspect the existing catalog authority with `worktree-pool --json catalog info`. Use that authority. A missing/conflicting catalog or pending operation is a blocker to report; a replacement catalog is not a recovery mechanism.
2. Register a new task repository with `worktree-pool --json repo register <repository-path>`. Linked checkouts share their canonical Git common-directory identity; separate clones have separate pools. New repositories default to capacity four. Keep existing registrations and capacity rather than resetting them each session.
3. For continuation, inspect the exact retained assignment handle with `worktree-pool --json assignment inspect <assignment-handle>` and confirm the previous caller has stopped before writing. A path, elapsed time, process death, or the latest listed assignment does not prove ownership. Independently editing callers need separate assignments.
4. For a new assignment, run `worktree-pool --json acquire --repo <repository-id-or-path> [task-ref]`. Use the task's explicit ref when continuing existing work; otherwise use the default refreshed origin/main. Every acquisition refreshes origin/main, even for an explicit ref. Missing origin/main or a failed refresh is a blocker to report.
5. Retain `data.assignment.assignment_handle`, `operation_id`, repository/worktree IDs, path, resolved commit, and branch. Use the returned lossless `path.bytes` as the checkout path; `path.display` is informational. Editing starts only after successful acquisition and receipt preservation. Acquisition creates a detached checkout; create a branch separately when repository rules or the deliverable require one.

## Durable receipts and handoffs

Before interpreting pool command results, capture raw stdout JSON, stderr, and exit status in a unique invocation directory under `${XDG_STATE_HOME:-$HOME/.local/state}/worktree-pool/agent-receipts`. Create private runtime directories/files with umask 077. Keep invocation/task/repository details and partial/error output too. These are runtime records outside reusable checkouts, not mutable configuration.

Carry the exact assignment handle, operation ID, repository/worktree IDs, path, task ref/resolved commit, receipt location, and assignment/recovery status into every handoff and context-compaction summary. If output is missing or ownership cannot be attributed, stop effects, inspect known identities, and request human resolution; guessing the newest handle or blindly reacquiring is unsafe.

## Capacity

Prefer eligible retained worktrees; acquire creates a worktree on demand when capacity remains. On a confirmed capacity rejection (`capacity_all_assigned` or `capacity_no_safe_worktree`), inspect the current repository maximum and increase it by four with `worktree-pool --json pool configure --repo <repository-id> --max-worktrees <current-maximum-plus-4>`. Inspect the result, then attempt acquisition again. Repeat only after another confirmed capacity rejection.

Start at the default four and grow 4 → 8 → 12 → 16 as needed, with no fixed policy ceiling. Configuration creates no worktrees itself. Preserve explicit disabled/exceptional policies and use checked arithmetic. Concurrent capacity-change coordination is deferred. Expansion does not release ownership, clear pending operations, or authorize a disposable-worktree fallback.

## Finish or recover

Stop task-owned active writers and preserve completed work before releasing with `worktree-pool --json release <assignment-handle>`. Release uses the exact current handle, never a path; stale/repeated handles cannot release a newer assignment. Keep paused or unfinished work assigned and provide a handoff.

An unfinished-work rejection retains ownership. Preserve the checkout; do not force/reset/stash/clean away protected work to make release succeed. Ignored files stay, and detached tips require verified preservation references. A successful release still does not guarantee reuse eligibility; inspect ownership and availability separately.

JSON outcomes are completed/0, rejected/2, pending/3, and unknown/4. Pending/unknown results require inspection of the recorded assignment/operation, not blind retries, repeated fetches, or further capacity changes. `worktree-pool --json operation inspect <operation-id>` and `worktree-pool --json recover preview --operation <operation-id>` support diagnosis.

Recovery application requires explicit human approval of the exact identity and action. After an approved `recover apply`, inspect ownership and availability: successful recovery may leave ownership active/preparing or the worktree withheld. Timeouts and process death never authorize automatic reclamation. Retain unfinished files, ignored artifacts, and Git/build state throughout recovery.
