---
name: brainstorming-implement
description: Post-approval brainstorming handoff assistance that verifies an approved spec path and routes to planning without directly editing files.
---

## oracle
phase: Approval verification
label: Check approved spec gate
as: approval_check

Read-only task: verify whether this request clearly provides an explicitly approved brainstorming spec/design path and a post-approval implementation or handoff request:

{task}

Required gate: the request must include an approved written spec/design path, normally under /tmp/pi-designs/, and must state or imply that the spec has been approved. If approval or the spec path is missing, report that the parent must stop and ask for clarification. Do not edit files, create plans, run mutating commands, or begin implementation.

Explicit non-bypass rule: this chain cannot approve its own spec, cannot replace user written-spec approval, and cannot authorize direct repository edits.

## planner
phase: Post-approval handoff
label: Route to post-brainstorming workflow
as: handoff

Using the approval check, prepare a read-only handoff for the parent agent.

Original request:
{task}

Approval check:
{outputs.approval_check}

If the approved spec path and approval are present, instruct the parent to invoke the existing post-brainstorming-implementation workflow. The handoff must preserve these gates: read the approved spec completely, inspect project instructions, verify or create the dedicated worktree before repository edits, create a /tmp/pi-plans implementation plan through the planning workflow, and only execute implementation after the normal execution gate allows it.

Do not draft repository changes, do not modify files, do not tell any child to mutate repository files, and do not bypass planning, review, validation, or final handoff gates. If the approval check found missing context, recommend stopping for clarification instead of proceeding.

## oracle
phase: Safety review
label: Non-bypass review

Review the handoff for unsafe shortcuts.

Original request:
{task}

Approval check:
{outputs.approval_check}

Handoff:
{outputs.handoff}

Confirm whether the handoff preserves the approved-spec requirement and routes to post-brainstorming-implementation rather than direct editing. Flag any language that could be read as permission for a child to mutate repository files or skip planning, review, validation, or implementation gates.
