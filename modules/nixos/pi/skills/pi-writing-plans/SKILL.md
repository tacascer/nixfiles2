---
name: pi-writing-plans
description: Convert an approved Pi design from /tmp/pi-designs into a temporary, reviewable implementation plan under /tmp/pi-plans with explicit task boundaries, validation, dependencies, and subagent execution guidance.
---

# Pi Writing Plans

Use this skill after a user has approved a design artifact under `/tmp/pi-designs/...` and has explicitly asked for implementation planning or implementation. The output is a plan file outside the tracked worktree by default, normally `/tmp/pi-plans/YYYY-MM-DD-<topic>-plan.md`.

## Purpose

Turn an approved design into a concrete implementation plan that is detailed enough for parent orchestration and child Pi subagents, while keeping planning artifacts temporary and out of repository history unless the user explicitly requests otherwise.

## Preconditions

Before writing a plan, verify:

- The approved design path is exact and exists under `/tmp/pi-designs/` unless the user explicitly provided another location.
- The user has approved the design and requested planning or implementation.
- The target repository working directory and dedicated worktree path are known.
- Relevant repository instructions have been inspected.
- The plan destination is outside the tracked worktree by default, usually under `/tmp/pi-plans/`.

If any item is missing and cannot be inferred safely from explicit user instructions, stop and ask for context rather than inventing it.

## Plan File Requirements

Create a Markdown plan at an exact `/tmp/pi-plans/...-plan.md` path. Include these sections:

1. **Design and Goal**
   - Exact approved design path.
   - Concise implementation goal.
   - Explicit non-goals or out-of-scope items from the design.

2. **Worktree and Branch**
   - Exact working directory or planned dedicated worktree path.
   - Branch name.
   - Note that implementation must not edit the main checkout directly when repository rules require a dedicated worktree.

3. **Impacted Files and Ownership Boundaries**
   - Exact file paths or directory paths for every expected change.
   - Which task owns each path.
   - Read-only paths needed for context.
   - Any files that must not be edited.

4. **Task Dependency Graph**
   - Numbered tasks with dependencies.
   - Mark each task as one of:
     - `parallel-safe`: may run in the same wave because file ownership is non-overlapping and dependencies are satisfied.
     - `serialized`: must run alone or after a dependency because ownership overlaps, order matters, or integration risk is high.
     - `parent-handled`: should be performed by the parent because it involves orchestration, user-facing decisions, final integration, or small inseparable edits.
   - Provide rationale for every parallel, serialized, or parent-handled decision.

5. **Per-Task Instructions**
   For each task include:
   - Task title.
   - Recommended role, such as `child-pi-implementer`, `child-pi-explorer`, `child-pi-spec-reviewer`, `child-pi-code-quality-reviewer`, or parent.
   - Exact files and directories in edit scope.
   - Exact read-only context files if needed.
   - Acceptance criteria.
   - Validation commands or validation method.
   - Dependencies and blockers.
   - Whether child commits are allowed; default is no commits.
   - Expected final status/report format when a child subagent will run it.

6. **Review Gates**
   - Define which implementation tasks require spec review.
   - Define that quality review happens only after spec compliance passes.
   - Identify any task-specific review focus.

7. **Final Validation**
   - Exact commands the parent should run after integration when feasible.
   - Any manual checks that cannot be automated.
   - Conditions under which heavier validation, such as host rebuilds, should be skipped or require user approval.

8. **Handoff Notes**
   - Any known risks.
   - Any user decisions still required before execution.
   - Expected final summary contents.

## Granularity Guidance

- Make tasks small enough for isolated child prompts.
- Avoid broad tasks that own unrelated files.
- Combine tiny, tightly coupled edits only when separating them would create unsafe coordination overhead.
- For high-risk changes, include expected structure or snippets. For straightforward Nix or Markdown content edits, describe precise outcomes instead of duplicating full implementation.
- Prefer explicit ownership boundaries over vague module names.

## Parallelism Rules

Only mark tasks `parallel-safe` when all are true:

- Their edit scopes do not overlap.
- Their validation can run independently or after a known integration step.
- They do not rely on each other's unmerged changes.
- The parent can inspect and integrate their results without guessing.

Mark tasks `serialized` when files overlap, behavior is order-dependent, or review of one task should inform the next. Mark tasks `parent-handled` for final validation, final diff review, worktree setup, and user-facing decisions.

## Self-Review Before Reporting the Plan

Before presenting the plan path, read the plan as if a different parent agent will execute it. Fix issues within the plan if you find any of the following:

- Placeholder text or vague ownership.
- Missing exact file paths.
- Missing task acceptance criteria.
- Missing validation commands or validation method.
- Missing dependencies.
- Parallel tasks that could write the same file or depend on each other.
- Missing review gates.
- Instructions that would edit outside the approved scope.
- Instructions that require mutable Pi install commands.

## Output to Parent/User

Report only a concise summary plus the exact plan path. Include any concerns that affect safe execution. Do not begin implementation from this skill unless another skill or the user explicitly instructs execution.
