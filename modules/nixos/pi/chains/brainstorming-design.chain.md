---
name: brainstorming-design
description: Read-only pre-approval brainstorming design assistance that explores context, compares approaches, and preserves the written-spec approval gate.
---

## scout
phase: Pre-approval design
label: Read-only context scan
as: context

Read-only task: explore context for this rough request without changing files or running mutating commands:

{task}

Report relevant existing conventions, likely files or modules to inspect later, constraints, risks, unknowns, and success criteria. Do not edit, scaffold, install, format, apply, or otherwise mutate repository or Pi configuration files. This chain is only design assistance before written-spec approval.

## oracle
phase: Pre-approval design
label: Gate and risk review
as: gate_review

Review the request and the scout context for design risks and gate compliance.

Original request:
{task}

Scout context:
{outputs.context}

Stay read-only. Identify assumptions, missing user decisions, likely clarification questions, and any wording that might accidentally bypass the brainstorming approval gate. Explicitly remind the parent agent that no implementation planning or repository edits may begin until a written spec/design has been reviewed and explicitly approved by the user.

## planner
phase: Pre-approval design
label: Design options and approval handoff

Using the original request, scout context, and oracle review, propose 2-3 high-level design approaches with trade-offs and a recommendation.

Original request:
{task}

Scout context:
{outputs.context}

Gate review:
{outputs.gate_review}

Do not create an implementation plan, do not instruct any child to mutate repository files, and do not authorize implementation. End with a concise handoff for the parent agent to continue the normal brainstorming workflow: ask clarifying questions as needed, write the spec/design under /tmp/pi-designs/, self-review it, and obtain explicit written-spec approval before invoking post-brainstorming-implementation.
