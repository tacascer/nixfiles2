---
name: post-brainstorming-implementation
description: Use after an approved brainstorming design and explicit user request to implement. Orchestrates git worktree setup, pi-subagents delegation, role/status handling, review gates, validation, and handoff.
---

# Post-Brainstorming Implementation

Use this skill after a brainstorming design has been approved and the user explicitly asks to implement it.

## Hard Gates

- Do not implement without an approved design and explicit implementation request.
- In a git repository, create and work from a dedicated `git worktree` branch before code changes.
- Use pi-subagents `Agent` for every safely separable exploration, implementation, review, or validation task before the parent performs substantive implementation edits.
- Prefer delegation over parent-handled implementation. Parent direct edits should be limited to orchestration glue, final integration, conflict resolution, tiny inseparable edits, or cases where delegation is unsafe.
- Parent Pi owns orchestration, final correctness, integration, validation, and user-facing decisions.
- Child Pi outputs are advisory until the parent reads an explicit final report/status from each child and verifies relevant files or diffs.

## Required Flow

1. Read the approved design file.
2. Inspect local instructions such as `AGENTS.md`, `CLAUDE.md`, and relevant nested guidance.
3. Check repository status and preserve user changes.
4. Create a dedicated worktree branch and continue from that worktree.
5. Create `todo` items for implementation, child delegation, review, validation, and handoff.
6. Build a dependency graph from the approved design:
   - identify implementation tasks, impacted files, validation needs, and review scopes;
   - mark dependencies between tasks and review gates;
   - mark each task as parallel-safe, serialized, or parent-handled with a short rationale.
7. If boundaries, ownership, or affected files are unclear, start a parallel explorer wave before implementation planning is finalized.
8. Start parallel child implementer waves with `Agent` for independent, non-overlapping implementation tasks. Serialize only tasks that depend on unfinished work, have overlapping edit ownership, require parent-only judgment, or are too small/inseparable to delegate safely.
9. After each implementation wave, use `get_subagent_result` as needed and read every child's explicit final report, inspect relevant files or diffs, and perform parent integration or conflict resolution.
10. For implementation tasks, run review gates in order:
    - start spec reviewer children with `Agent` after implementation is complete for their assigned scope;
    - start code-quality reviewer children with `Agent` only after spec compliance passes for that scope.
11. Repeat fix/review waves as needed, using implementer children for bounded fixes whenever safe.
12. Run final validation in the parent session.
13. If validation fails and the cause is not trivial and inseparable, start one or more validation analyst children with `Agent`, exact commands, logs, and relevant context; use `get_subagent_result` as needed and read their explicit final reports before choosing fixes.
14. Review final diff and summarize handoff.

## Role Selection

Use role skills for child prompts:

- `child-pi-explorer` for unclear work, context research, decomposition, or ownership discovery.
- `child-pi-implementer` for bounded implementation and bounded fixes.
- `child-pi-spec-reviewer` after implementation is complete for the assigned scope.
- `child-pi-code-quality-reviewer` only after spec review passes for the assigned scope.
- `child-pi-validation-analyst` for validation failures.

Child agents should not infer requirements from the parent conversation.

## Parallelization Discipline

- Prefer breadth-first parallel waves of children over one-at-a-time delegation whenever tasks do not depend on each other.
- A task is parallel-safe when it has clear acceptance criteria, clear file/ownership boundaries, no dependency on an unfinished task, and no expected overlap with another active edit.
- Do not parallelize dependent review gates: spec review happens after implementation; code-quality review happens only after spec compliance passes.
- Do not assign overlapping edits in the same worktree to multiple children unless ownership is explicitly partitioned and conflicts are acceptable.
- For large independent work with expected conflicts, consider separate child worktrees or branches, but do not make that the default.
- Keep parent implementation limited. If a substantial task is parent-handled or serialized instead of delegated/parallelized, record the safety, dependency, or scope rationale for the handoff.
- When a child reports `NEEDS_CONTEXT` or `BLOCKED`, clarify the task, split it, change role, or ask the user if needed; never retry a blocked prompt unchanged.

## Subagent Tooling

- Use `Agent` to start each child/subagent with the selected role prompt and required instructions.
- Use background mode for independent long-running work that can proceed while the parent continues orchestration.
- Use `get_subagent_result` with waiting enabled to retrieve background results before relying on them.
- Use `steer_subagent` only when a running child must be redirected with clarified scope, constraints, or stop instructions.

## Child Prompt Rules

Every child prompt must be self-contained and include:

- Role.
- Working directory.
- Approved design path.
- Full task text.
- Relevant context and files.
- Before you begin criteria for reporting `NEEDS_CONTEXT` before work starts.
- Permissions for edits, commands, and commits.
- Escalation rules for `NEEDS_CONTEXT` and `BLOCKED`.
- Self-review requirements, required for implementers and encouraged for other roles.
- Required report format.

## Child Output Discipline

- Wait for and read an explicit final status/report from every delegated child before relying on or summarizing that child.
- Do not infer child completion from quiet event logs, file diffs, parent-side validation, or tool silence.
- If a child output lacks an explicit final status/report, treat that child as incomplete or failed; wait, start a replacement with a clarified prompt, or report the failure.
- Verify relevant files or diffs after child implementation before review or integration decisions.

## Status Handling

General child statuses:

- `DONE`: read output, inspect relevant files/diff, then proceed.
- `DONE_WITH_CONCERNS`: resolve correctness or scope concerns before review; record minor concerns.
- `NEEDS_CONTEXT`: provide missing context and start a replacement or continue with a clarified prompt.
- `BLOCKED`: change something before retrying; provide context, split the task, change role, or ask the user.

Reviewer statuses:

- `SPEC_COMPLIANT`: proceed to code quality review.
- `SPEC_ISSUES_FOUND`: send issues to an implementer/fix child, then repeat spec review.
- `QUALITY_APPROVED`: proceed to integration or next task.
- `QUALITY_ISSUES_FOUND`: send issues to an implementer/fix child, then repeat quality review after fixes.

Never retry the same blocked prompt unchanged.

## Validation

Parent runs final validation. For this NixOS flake, typical commands are:

```bash
nix-instantiate --parse modules/nixos/pi/default.nix
nix flake check
nix flake show
```

Host rebuilds are only run when requested or appropriate.

## Handoff

Final response includes:

- Worktree path and branch.
- Summary of changes.
- Subagent batches started, roles, tasks, final statuses, and which work was parallelized.
- Tasks intentionally serialized or parent-handled, with safety/dependency rationale.
- Validation commands and outcomes.
- Known issues or follow-ups.
- Manual user actions, if any.
