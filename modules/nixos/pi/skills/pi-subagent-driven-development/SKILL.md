---
name: pi-subagent-driven-development
description: Execute a /tmp/pi-plans implementation plan with Pi subagents, enforcing isolated prompts, explicit child final reports, review gates, parent inspection, and final validation.
---

# Pi Subagent-Driven Development

Use this skill to execute an approved implementation plan from `/tmp/pi-plans/...` with Pi subagents and parent orchestration.

## Purpose

Run planned implementation work safely by decomposing it into isolated child Pi prompts, enforcing explicit final statuses, inspecting resulting files and diffs in the parent session, and validating the integrated result.

## Preconditions

Before execution, verify:

- The plan path is exact and exists under `/tmp/pi-plans/` unless the user explicitly provided another location.
- The plan references an approved design path, usually under `/tmp/pi-designs/`.
- The user has explicitly requested implementation.
- A dedicated worktree branch exists or has been created when repository rules require it.
- Local repository instructions and the plan's ownership boundaries have been read.
- The parent has created or updated todo items for implementation tasks, review gates, validation, and handoff.

If the plan is missing exact file paths, ownership, dependencies, acceptance criteria, validation, or safe parallelism rationale, stop and repair the plan or request context before spawning implementation children.

## Child Prompt Requirements

Every child prompt must be self-contained and include:

- Role and matching skill to load, when available.
- Working directory.
- Approved design path.
- Plan path.
- Full task text, dependencies, and acceptance criteria.
- Exact files/directories the child may edit.
- Exact read-only files/directories the child may inspect.
- Explicit files/directories that must not be edited when relevant.
- Validation commands or a clear read-only validation method.
- Commit policy; default is no commits.
- Escalation rules for `NEEDS_CONTEXT` or `BLOCKED`.
- Required final report format with an explicit status.
- Parent/orchestrator spawning context: the parent spawns the child Pi instance in visual mode when supported by current tooling and user preference; if visual mode is unavailable, continue without blocking and the prompt or parent report may note the fallback.

Never rely on hidden parent context or ask a child to infer requirements from the larger conversation.

## Status Vocabulary

Use these exact status sets for child final reports.

### Implementers

- `DONE`: implementation completed and task validation passed or was not applicable.
- `DONE_WITH_CONCERNS`: implementation completed, but there are risks, skipped validation, or follow-up items.
- `NEEDS_CONTEXT`: the child cannot proceed safely without more information.
- `BLOCKED`: the child attempted or inspected enough to determine progress is blocked.

### Spec Reviewers

- `SPEC_COMPLIANT`: implementation matches the approved design, plan, and assigned task.
- `SPEC_ISSUES_FOUND`: implementation diverges from requirements or misses acceptance criteria.
- `NEEDS_CONTEXT`: review cannot determine compliance without more information.
- `BLOCKED`: review cannot proceed due to tooling, file access, or inconsistent state.

### Quality Reviewers

- `QUALITY_APPROVED`: implementation is maintainable, simple, idiomatic, and appropriately validated.
- `QUALITY_ISSUES_FOUND`: quality, maintainability, test, or convention issues require fixes.
- `NEEDS_CONTEXT`: review cannot judge quality safely without more information.
- `BLOCKED`: review cannot proceed due to tooling, file access, or inconsistent state.

### Validation Analysts

- `ROOT_CAUSE_IDENTIFIED`: likely validation failure cause and focused fix recommendation are provided.
- `NEEDS_MORE_DATA`: more logs, commands, or context are required.
- `BLOCKED`: analysis cannot proceed safely.

## Execution Flow

1. **Read and Model the Plan**
   - Read the full plan once in the parent session.
   - Map task dependencies and ownership.
   - Create parent todo items for each implementation task, review gate, validation step, and handoff.

2. **Choose a Wave**
   - Run parallel waves only for tasks explicitly marked `parallel-safe` with non-overlapping edit scopes and satisfied dependencies.
   - Otherwise serialize tasks in dependency order.
   - If safety is ambiguous, serialize.

3. **Optional Exploration**
   - If ownership or implementation approach is unclear, start read-only explorer children before implementers.
   - Wait for and read each explorer's explicit final report before relying on findings.

4. **Run Implementers**
   - Spawn child implementers with isolated prompts for the selected wave or serialized task.
   - Prefer visual-mode child Pi spawning when supported by current tooling and user preference.
   - Do not block solely because visual mode is unavailable.
   - Wait for and read an explicit final status/report from every child before considering its task complete.
   - Treat missing final reports as incomplete work, not success.

5. **Parent Inspection After Each Implementation Scope**
   - Inspect relevant files and `git diff` for the child's edit scope.
   - Confirm the child stayed within assigned files.
   - Confirm no obvious unrelated or unsafe changes were introduced.

6. **Spec Review Gate**
   - Run a spec reviewer child for each completed implementation scope, using a self-contained prompt that includes the design, plan, task, changed files, and acceptance criteria.
   - Wait for and read the explicit final spec review report.
   - If status is `SPEC_ISSUES_FOUND`, dispatch a bounded fix implementer, then repeat spec review for that scope.
   - If status is `NEEDS_CONTEXT` or `BLOCKED`, resolve or report before proceeding.

7. **Quality Review Gate**
   - Run quality review only after spec review reports `SPEC_COMPLIANT` for that scope.
   - Wait for and read the explicit final quality review report.
   - If status is `QUALITY_ISSUES_FOUND`, dispatch a bounded fix implementer, then repeat spec review before another quality review.
   - If status is `NEEDS_CONTEXT` or `BLOCKED`, resolve or report before proceeding.

8. **Continue Through Dependencies**
   - Start the next safe wave only after all dependencies and review gates for required prior tasks have passed.
   - Never retry the same blocked prompt unchanged; revise the task, gather context, or report the blocker.

9. **Parent Final Validation**
   - After all implementation and review gates pass, run the plan's final validation commands from the parent session when feasible.
   - Inspect final diffs and key files directly in the parent session.
   - If validation fails and the cause is not obvious, dispatch a validation analyst child with logs, commands, changed files, design path, and plan path.

10. **Handoff**
    - Summarize completed tasks, child statuses, review outcomes, validation results, changed files, worktree path, branch, concerns, and next actions.

## Parallelism Constraints

Parallel execution is allowed only when the plan explicitly marks tasks as safe and their file ownership is non-overlapping. Do not parallelize tasks because they appear independent if the plan lacks rationale. Do not run multiple children that may edit the same file or directory at the same time.

If parallel children produce changes that interact unexpectedly, stop new waves, inspect the diff, and serialize fixes.

## Parent Responsibilities

The parent remains responsible for:

- Reading every child final report before relying on it.
- Maintaining todos and dependency state.
- Inspecting files and diffs after child work.
- Enforcing spec review before quality review.
- Running final validation.
- Making user-facing decisions and reporting concerns.
- Preserving user changes and repository safety rules.

Child agents do not commit unless the plan explicitly grants commit permission for a task.

## Failure Handling

- `NEEDS_CONTEXT`: pause the affected path and obtain the missing context through the parent workflow.
- `BLOCKED`: do not retry unchanged; identify a different prompt, split the task, dispatch an explorer or validation analyst, or report the blocker.
- Missing child final report: wait, replace the child, or report failure; never infer success from a quiet log or file diff.
- Validation failure: inspect logs, run focused checks, and use a validation analyst for unclear root causes.
- Scope violation: stop and inspect the diff before any further child work.

## Self-Review Before Final Report

Before reporting completion of this execution phase, confirm:

- Every child used an isolated, self-contained prompt.
- Every child final status/report was read.
- Parallel work was limited to plan-marked safe, non-overlapping tasks.
- Spec review happened before quality review for every implementation scope.
- Parent diff/file inspection occurred after child implementation.
- Final validation was run or a clear reason is documented.
- No mutable Pi install commands were used.
