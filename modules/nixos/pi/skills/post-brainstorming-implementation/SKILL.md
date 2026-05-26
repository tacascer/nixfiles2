---
name: post-brainstorming-implementation
description: Use after an approved brainstorming design and explicit user request to implement. Orchestrates git worktree setup, tmux child Pi spawning, role/status handling, review gates, validation, and handoff.
---

# Post-Brainstorming Implementation

Use this skill after a brainstorming design has been approved and the user explicitly asks to implement it.

## Hard Gates

- Do not implement without an approved design and explicit implementation request.
- In a git repository, create and work from a dedicated `git worktree` branch before code changes.
- If inside tmux, spawn at least one visible child Pi instance before substantive implementation edits.
- Parent Pi owns final correctness, integration, validation, and user-facing decisions.
- Child Pi outputs are advisory until the parent reads their event/output files and verifies relevant files or diffs.

## Required Flow

1. Read the approved design file.
2. Inspect local instructions such as `AGENTS.md`, `CLAUDE.md`, and relevant nested guidance.
3. Check repository status and preserve user changes.
4. Create a dedicated worktree branch and continue from that worktree.
5. Create `todo` items for implementation, child delegation, review, validation, and handoff.
6. Spawn at least one visible child Pi instance with a self-contained role prompt.
7. Use role skills for child prompts:
   - `child-pi-explorer` for unclear work or context research.
   - `child-pi-implementer` for bounded implementation.
   - `child-pi-spec-reviewer` after implementation.
   - `child-pi-code-quality-reviewer` only after spec review passes.
   - `child-pi-validation-analyst` for validation failures.
8. Read child outputs/events before relying on findings or changes.
9. For implementation tasks, run review gates in order: spec compliance, then code quality.
10. Integrate changes and reconcile conflicts.
11. Run final validation in the parent session.
12. Review final diff and summarize handoff.

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

Child agents should not infer requirements from the parent conversation.

## Status Handling

General child statuses:

- `DONE`: read output, inspect relevant files/diff, then proceed.
- `DONE_WITH_CONCERNS`: resolve correctness or scope concerns before review; record minor concerns.
- `NEEDS_CONTEXT`: provide missing context and respawn or continue with a clarified prompt.
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
- Child agents spawned and roles/results.
- Validation commands and outcomes.
- Known issues or follow-ups.
- Manual user actions, if any.
