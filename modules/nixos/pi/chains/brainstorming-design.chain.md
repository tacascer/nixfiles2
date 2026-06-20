---
name: brainstorming-design
description: Read-only pre-approval design assistance that scouts context, researches the user's request, and plans clarifying questions while preserving the parent-led written-spec approval gate.
---

## scout
phase: Pre-approval design
label: Read-only request and context scan
as: context

Read-only task: explore the immediate context for this rough user request without changing files or running mutating commands:

{task}

Focus on understanding what the user is asking for and what local context may matter. Report:

- `Request summary`: concise restatement of the user's request.
- `Relevant local context`: existing conventions, likely files/modules/docs to inspect, and any repo-specific constraints.
- `Initial constraints and risks`: constraints, risks, unknowns, and success criteria apparent from the request or repository context.
- `Research directions`: concrete topics, files, commands, or documentation areas the researcher should examine next.
- `Initial question candidates`: possible clarifying questions, ordered by expected impact on the eventual design direction.

Do not edit, scaffold, install, format, apply, or otherwise mutate repository or Pi configuration files. This chain is only design assistance before written-spec approval. Subagents cannot replace the parent/user interaction or approve the design themselves.

## researcher
phase: Pre-approval design
label: Read-only request research
as: research

Read-only task: research the user's request using the scout findings. Do not change files or run mutating commands.

Original request:
{task}

Scout context:
{outputs.context}

Investigate the request enough to help the parent ask high-value questions before any design/spec is written. Prefer repository files, project documentation, existing chain/skill conventions, and other authoritative local sources. Use external research only when the request requires it.

Your output must include:

- `Research summary`: what you learned that materially affects the request.
- `Evidence and references`: relevant files, modules, docs, conventions, or external references consulted.
- `Decision points`: choices the user or parent must make before a design can be finalized.
- `Assumptions to verify`: assumptions that should not be silently baked into the design.
- `Question inputs for planner`: candidate clarifying questions, grouped by topic and ordered by likely impact.
- `Risks and constraints`: items the parent should keep visible while questioning the user.

Stay read-only. Do not edit, modify, write, delete, create, patch, apply, or otherwise change files. Explicitly avoid creating an implementation plan or authorizing implementation.

## planner
phase: Pre-approval design
label: Clarifying question plan and parent handoff

Using the original request, scout context, and researcher findings, plan the questions the parent should ask the user about the request.

Original request:
{task}

Scout context:
{outputs.context}

Research findings:
{outputs.research}

Stay read-only. Do not edit, modify, write, delete, create, patch, apply, or otherwise change files. Do not create an implementation plan, do not instruct any child to mutate repository files, and do not authorize implementation.

Your final handoff must be parent-facing and include these sections:

1. `Question strategy`: the overall approach for resolving ambiguity with the user.
2. `Prioritized user questions`: ordered list of concrete questions, highest-impact first, with a short reason for each.
3. `Recommended next user-facing question`: exactly one concise question for the parent to ask first; if no more input is needed, state `None` and explain why.
4. `Question grouping`: digestible groups of related questions the parent can ask in separate turns if needed.
5. `Expected answer impact`: how likely answers would affect the eventual written design/spec.
6. `Known constraints and assumptions`: concise list of constraints and assumptions to confirm or preserve.
7. `Approval gate reminder`: state that subagents cannot obtain approval or replace parent/user interaction; the parent must ask the user any needed questions, present any later design sections, write the `/tmp/pi-designs/` spec, self-review it, and obtain explicit approval before any planning or implementation handoff.
