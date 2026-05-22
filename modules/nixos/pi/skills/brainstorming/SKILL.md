---
name: brainstorming
description: "Use before creative or design-sensitive work: adding features, modifying behavior, refactoring, changing configuration semantics, or building new Pi/NixOS workflows. Guides a Pi-native design discussion before implementation."
---

# Brainstorming

Use this skill to turn a rough request into an approved design before implementation. This is a Pi-native adaptation of the Superpowers brainstorming workflow for this NixOS flake and other local projects.

## Hard Gate

Do not write implementation code, scaffold files, edit existing behavior, or run mutating implementation commands until the user has approved a design. Reading files and inspecting project state are allowed as part of this skill.

For changes in a git repository, remember the repository worktree safety rule: before code changes, create and work from a dedicated `git worktree` branch. Brainstorming itself may inspect the current checkout; implementation must happen in the dedicated worktree.

## Required Flow

Create and maintain `todo` items for these stages, completing each stage before starting the next:

1. **Explore context** — inspect relevant files, docs, existing patterns, and recent commits.
2. **Clarify intent** — ask one question at a time until purpose, constraints, scope, and success criteria are clear.
3. **Compare approaches** — propose 2-3 viable approaches with trade-offs and a recommendation.
4. **Present design** — describe the selected design in reviewable sections sized to the complexity of the work.
5. **Get approval** — ask explicitly whether the design is approved or needs changes.
6. **Write design file** — after approval, save the design under `/tmp/pi-designs/` so it is outside the git worktree.
7. **Self-review design file** — fix placeholders, contradictions, scope creep, and ambiguous requirements inline in the `/tmp` design file.
8. **Stop** — do not proceed to implementation planning or code unless the user asks for the next step.

## Clarifying Questions

Ask exactly one clarifying question per assistant message. Prefer `ask_user_question` with concrete choices when a structured answer would help. Use open-ended questions when the user needs to explain goals or constraints in their own words.

Good question topics:

- What problem are we solving?
- Who or what uses this?
- What should be out of scope?
- What does success look like?
- Are there compatibility, security, performance, or deployment constraints?
- Which existing conventions should this follow?

If the request is too large for one design, stop early and help the user decompose it into smaller specs. Then brainstorm only the first agreed sub-project.

## Approach Comparison

Before presenting the final design, offer 2-3 approaches. For each approach, include:

- What it is.
- Why it might be good.
- Main trade-offs or risks.

End with your recommendation and the reason. Favor simple, reversible, idiomatic changes over broad rewrites.

## Design Presentation

Present the design in sections. Scale detail to complexity: a few bullets for simple changes, more structure for nuanced ones.

Cover the relevant subset of:

- scope and non-goals
- user-facing behavior
- architecture or module boundaries
- data/configuration flow
- error handling and failure modes
- migration or compatibility concerns
- validation/testing strategy
- implementation sequence at a high level

Ask whether the design looks right. If the user requests changes, revise the design and ask again.

## Design Records

Always write the approved brainstorming design to a file under `/tmp/pi-designs/`, using a path like `/tmp/pi-designs/YYYY-MM-DD-<topic>-design.md`. Create the directory if needed.

Never create, stage, commit, or check in design spec files from brainstorming. Do not add brainstorming design specs under `docs/specs/` or any other tracked project path. Tell the user the `/tmp` design path and note that it is intentionally outside the git worktree.

## Design Self-Review

Before telling the user the design is ready, review and fix the `/tmp` design file for:

1. Placeholder text such as `TBD`, `TODO`, or incomplete bullets.
2. Internal contradictions.
3. Scope that is too broad for one implementation pass.
4. Ambiguous requirements that could be interpreted more than one way.
5. Missing validation or testing notes.

Then tell the user the `/tmp` design path and ask whether they want changes before any implementation work begins.

## Pi-Specific Practices

- Use `read` and `bash` for context inspection.
- Use `todo` to make the workflow visible.
- Use `ask_user_question` for structured one-question prompts.
- Do not use `write`/`edit` for implementation before design approval.
- Do not use `spawn_pi_instance_pane` for implementation before design approval.
- If implementation later benefits from delegation and tmux is available, prefer visible Pi instance panes as described by the system prompt.
