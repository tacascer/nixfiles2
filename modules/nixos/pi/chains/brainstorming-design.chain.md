---
name: brainstorming-design
description: Read-only pre-approval design assistance that explores context, frames decisions, and preserves the parent-led written-spec approval gate.
---

## scout
phase: Pre-approval design
label: Read-only context scan
as: context

Read-only task: explore context for this rough request without changing files or running mutating commands:

{task}

Report relevant existing conventions, likely files or modules to inspect later, constraints, risks, unknowns, missing decisions, and success criteria.

Also include:

- `Prioritized clarifying questions`: ordered by the decisions most likely to affect design direction.
- `Recommended next user-facing question`: exactly one concise question for the parent to ask if more user input is needed; otherwise state `None`.
- `Candidate design sections`: digestible sections or section groups the parent could later present to the user for validation.

Do not edit, scaffold, install, format, apply, or otherwise mutate repository or Pi configuration files. This chain is only design assistance before written-spec approval. Subagents cannot replace the parent/user interaction or approve the design themselves.

## oracle
phase: Pre-approval design
label: Gate, unknowns, and presentation review
as: gate_review

Review the request and the scout context for design risks, missing decisions, and gate compliance.

Original request:
{task}

Scout context:
{outputs.context}

Stay read-only. Identify assumptions, missing user decisions, and wording that might accidentally bypass the written-spec approval gate.

Your output must include:

- `Missing decisions / unknowns`: specific items that need parent or user resolution.
- `Prioritized clarifying questions`: ordered list, highest-impact first.
- `Recommended next user-facing question`: exactly one concise question for the parent to ask when more user input is needed; otherwise state `None`.
- `Section presentation guidance`: digestible design sections and a validation prompt for each section, written for the parent to present to the user.

Explicitly remind the parent agent that child/subagent output is advisory only: the parent must ask the user any needed questions, present sections for validation, write the final `/tmp/pi-designs/` design/spec, and obtain explicit user approval before implementation planning or repository changes begin.

## planner
phase: Pre-approval design
label: Design options and parent handoff

Using the original request, scout context, and oracle review, propose 2-3 high-level design approaches with trade-offs and one recommendation.

Original request:
{task}

Scout context:
{outputs.context}

Gate review:
{outputs.gate_review}

Stay read-only. Do not create an implementation plan, do not instruct any child to mutate repository files, and do not authorize implementation.

Your final handoff must be parent-facing and include these sections:

1. `Unknowns and missing decisions`: concise list.
2. `Prioritized clarifying questions`: ordered list.
3. `Recommended next user-facing question`: exactly one question when more user input is needed; otherwise `None`.
4. `Digestible design sections`: proposed sections or section groups the parent can present one at a time.
5. `Validation prompts`: one prompt per design section for the parent to use when asking the user to confirm or correct the section.
6. `Recommended approach`: the single recommended high-level direction and why.
7. `Approval gate reminder`: state that subagents cannot obtain approval or replace parent/user interaction; the parent must present questions/sections, write the `/tmp/pi-designs/` spec, self-review it, and obtain explicit approval before any planning or implementation handoff.
