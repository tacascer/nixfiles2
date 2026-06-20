---
name: brainstorming-implement
description: Read-only approved-spec handoff assistance that verifies approval and routes to retained Pi-native planning and execution gates.
---

## oracle
phase: Approval verification
label: Check approved spec gate
as: approval_check

Read-only task: verify whether this request clearly provides an explicitly approved brainstorming spec/design path and a post-approval implementation or handoff request:

{task}

Required gate: the request must include an approved written spec/design path, normally under `/tmp/pi-designs/`, and must state or imply that the spec has been approved. If approval or the spec path is missing, report that the parent must stop and ask for clarification. Do not edit files, create plans, run mutating commands, or begin implementation.

Explicit non-bypass rule: this chain cannot approve its own spec, cannot replace user written-spec approval, and cannot authorize direct repository edits.

Your output must include:

- `Spec path`: the explicit approved spec/design path, or `Missing`.
- `Approval status`: whether explicit approval is present, missing, or ambiguous.
- `Blocking issues`: any missing context that prevents safe handoff.
- `Gate result`: `PASS` only when both the path and approval are clear; otherwise `STOP`.

## planner
phase: Post-approval handoff
label: Route to retained Pi-native workflow
as: handoff

Using the approval check, prepare a read-only handoff for the parent agent.

Original request:
{task}

Approval check:
{outputs.approval_check}

If the approved spec path or approval is missing or ambiguous, recommend stopping for clarification instead of proceeding.

If the approved spec path and approval are present, route the parent through these retained Pi-native skills by name:

1. `pi-writing-plans`: read the approved spec completely, inspect project instructions, verify worktree requirements, and create a concrete implementation plan under `/tmp/pi-plans/`.
2. `pi-subagent-driven-development`: use only after the parent has reviewed the plan and explicitly authorized execution.
3. `pi-finishing-development-branch`: use after implementation, review, and validation are complete to finish the branch handoff.

Preserve these gates in the handoff: approved spec path verification, explicit approval, plan creation before execution, worktree safety before any later repository mutation, execution authorization before `pi-subagent-driven-development`, review, validation, and final parent handoff.

Do not draft repository changes, do not modify files, do not tell any child to mutate repository files, and do not bypass planning, review, validation, or final handoff gates.

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

Confirm whether the handoff verifies an explicit approved spec path and approval before routing onward. Confirm whether it routes to `pi-writing-plans`, then to `pi-subagent-driven-development` only after execution authorization, then to `pi-finishing-development-branch` after implementation/review/validation.

Flag any language that could be read as permission for this chain to edit repository files, skip plan creation, skip execution authorization, replace parent/user approval, or bypass review, validation, or final handoff gates.
