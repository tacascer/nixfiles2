---
name: post-brainstorming-implementation
description: Use after an approved brainstorming design plus either an explicit user implementation request or a direct approved-spec handoff from brainstorming. Direct handoff authorizes planning only; implementation execution still needs the normal execution gate.
---

# Post-Brainstorming Implementation

Use this skill after the user has approved a brainstorming design and either explicitly asked to implement it or the brainstorming workflow directly hands off an approved written spec.

A direct brainstorming handoff authorizes implementation planning only. It does not by itself authorize implementation execution. Continue from planning into `pi-subagent-driven-development` only when the user explicitly requested implementation/execution or the planning workflow's own approval/execution gate has been satisfied.

This is the coordinator and safety gate for post-brainstorming work. It should route the work through the focused skills `pi-writing-plans`, `pi-subagent-driven-development`, and `pi-finishing-development-branch` instead of duplicating their full workflows here.

## Required Preconditions

Before any implementation work:

- Confirm there is an approved design artifact, normally under `/tmp/pi-designs/`.
- Confirm either the user explicitly requested implementation after approving that design, or the brainstorming workflow directly handed off the approved written spec after user approval.
- If entry is a direct brainstorming handoff without an explicit implementation/execution request, treat it as authorization for planning only until the appropriate plan approval/execution gate is satisfied.
- Read the approved design completely.
- Inspect applicable local instructions, including repository `AGENTS.md`, `CLAUDE.md` when present, and nested guidance for touched paths.
- Check repository status and identify user changes before modifying files.
- Preserve user changes. Do not overwrite, move, stash, or rebase ambiguous existing work without explicit user direction.
- In a git repository, create or verify a dedicated `git worktree` branch before repository edits for planning or implementation when repository rules require it. Continue implementation from that worktree.
- Do not write implementation code before the planning gates complete.
- Do not use mutable Pi install commands; manage Pi configuration and skills declaratively through the repository.

If any precondition is missing or ambiguous, stop and ask for clarification instead of implementing.

## Coordination Flow

After the gates pass:

1. Establish the worktree path and branch when repository edits will be needed, then operate from that worktree.
2. Create parent todo items for planning, review, and any later execution/validation/handoff stages that are authorized.
3. Invoke `pi-writing-plans` to convert the approved design into a temporary implementation plan under `/tmp/pi-plans/`.
4. Read and sanity-check the plan for scoped tasks, file ownership, dependencies, validation commands, and review gates.
5. If implementation execution is authorized by explicit user request or the plan workflow's execution gate, invoke `pi-subagent-driven-development` to execute the plan with child Pi agents where useful.
6. After authorized execution completes, invoke `pi-finishing-development-branch` for final validation, diff review, branch/worktree summary, known issues, and next actions.

If only direct brainstorming handoff is authorized, stop after the planning workflow produces the plan and requests whatever approval or execution instruction that workflow requires.

Keep parent work focused on orchestration, safety decisions, integration, and user-facing judgment.

## Simplified Path for Tiny or Inseparable Work

You may use a simplified path only when the work is genuinely too small or too tightly coupled to benefit from separate planning and subagent waves.

Before using the simplified path, record a short rationale covering:

- why the change is tiny or inseparable;
- why child delegation or a full `/tmp/pi-plans/` plan would add more risk or overhead than value;
- which files are in scope;
- what validation will still run.

Even on the simplified path:

- the approved design and either an explicit implementation request or direct approved-spec handoff from brainstorming are still required;
- direct approved-spec handoff alone authorizes only the planning portion of the simplified path, not implementation execution;
- repository instructions and local status must still be checked;
- a dedicated git worktree branch is still required before repository edits in a git repository when repository rules require it;
- user changes must still be preserved;
- final diff review, validation, and handoff are still required.

If any subagent is used on the simplified path, all child output rules below still apply.

## Subagent Requirements

Prefer Pi subagents for separable exploration, implementation, review, and validation work. Spawn visual-mode child Pi instances when supported by the current tooling and user preference, but do not block solely because visual mode is unavailable.

For every child Pi agent:

- provide a self-contained prompt with role, working directory, approved design path, plan path when relevant, exact task, file permissions, validation commands, escalation rules, and required final report format;
- do not allow the child to infer requirements from hidden parent context;
- wait for and read an explicit final status/report before relying on that child;
- do not infer completion from file diffs, quiet logs, validation success, or tool silence;
- treat missing or unclear final status as incomplete until resolved.

If a child reports `NEEDS_CONTEXT` or `BLOCKED`, clarify, split, reroute, or ask the user as appropriate. Never retry the same blocked prompt unchanged.

## Delegated Skill Responsibilities

- `pi-writing-plans` owns plan creation, task boundaries, dependencies, validation commands, review gates, parallel-safety rationale, and plan self-review.
- `pi-subagent-driven-development` owns plan execution with child implementers, spec reviewers, code-quality reviewers, validation analysts, explicit status handling, and parent inspection between gates.
- `pi-finishing-development-branch` owns final validation, diff review, handoff summary, and next-action reporting.

Do not copy those detailed workflows here. If their instructions conflict with the safety gates in this coordinator, the stricter safety gate applies. In all cases, planning may follow written-spec approval, but implementation code may not begin before the plan and execution gates allow it.

## Final Handoff

The final response should include:

- worktree path and branch;
- approved design path and plan path, if a plan was created;
- whether the full or simplified path was used, with rationale for simplified work;
- summary of changes;
- child Pi roles/tasks and explicit final statuses that were read;
- validation commands and outcomes;
- known issues, follow-ups, or manual user actions.
