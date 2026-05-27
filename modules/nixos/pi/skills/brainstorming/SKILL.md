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

1. **Explore context** — use child Pi explorer subagents for read-only context gathering when available, with parent-side read-only inspection as fallback.
2. **Clarify intent** — ask one question at a time until purpose, constraints, scope, and success criteria are clear.
3. **Compare approaches** — propose 2-3 viable approaches with trade-offs and a recommendation.
4. **Write design draft** — save the full selected design under `/tmp/pi-designs/` so it is outside the git worktree.
5. **Self-review design file** — fix placeholders, contradictions, scope creep, ambiguous requirements, and missing validation notes inline in the `/tmp` design file before asking for approval.
6. **Present concise review prompt** — show only a short summary, the design file path, and an approval-or-changes question in the Pi window; do not dump the full design document into the conversation.
7. **Get approval** — ask explicitly whether the design is approved or needs changes. If changes are requested, update and self-review the same `/tmp` design file, then ask again.
8. **Stop** — do not proceed to implementation planning or code unless the user asks for the next step.

## Child Pi Exploration

During **Explore context**, prefer pi-subagents `Agent` when available:

- Start at least one `Explore` subagent with `Agent` and a self-contained prompt covering the working directory, user request, focused exploration goal, relevant files or directories if known, read-only/no-user-interaction constraints, and explicit final report format.
- Start multiple focused explorers when independent context tracks can be investigated in parallel, such as implementation files, project docs, upstream/API behavior, or recent git history. Use background mode for independent long-running exploration.
- Use `get_subagent_result` with waiting enabled for background agents, and read an explicit final status/report from every delegated child before relying on or summarizing that child's findings. Do not infer completion from quiet logs, diffs, or parent-side validation.
- Use `steer_subagent` only when a running explorer needs redirected scope or constraints.
- If delegation is unavailable, fails, or a child reports `NEEDS_CONTEXT`, `BLOCKED`, times out, or lacks an explicit final report, report that outcome and either fall back to bounded parent-side read-only inspection, start a narrower follow-up child, or ask a clarifying question.
- Keep child exploration read-only; implementation edits remain forbidden until after the design is approved and the user asks for implementation.

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

## Design File and Concise Presentation

Write the full design document to `/tmp/pi-designs/` before requesting approval. The design file should use sections sized to the complexity of the work: a few bullets for simple changes, more structure for nuanced ones.

Cover the relevant subset of:

- scope and non-goals
- user-facing behavior
- architecture or module boundaries
- data/configuration flow
- error handling and failure modes
- migration or compatibility concerns
- validation/testing strategy
- implementation sequence at a high level

In the Pi window, do not display the full design document. Present only a concise summary, the `/tmp` design file path, and a clear question asking whether the design is approved or needs changes. If the user requests changes, update the same `/tmp` design file, self-review it again, and ask for approval again.

## Design Records

Always write the brainstorming design to a file under `/tmp/pi-designs/` before asking for approval, using a path like `/tmp/pi-designs/YYYY-MM-DD-<topic>-design.md`. Create the directory if needed.

Use the `/tmp` file as the review artifact. If the user requests revisions, update the same `/tmp` design file rather than creating tracked project files.

Never create, stage, commit, or check in design spec files from brainstorming. Do not add brainstorming design specs under `docs/specs/` or any other tracked project path. Tell the user the `/tmp` design path and note that it is intentionally outside the git worktree.

## Design Self-Review

Before asking the user to approve the design, review and fix the `/tmp` design file for:

1. Placeholder text such as `TBD`, `TODO`, or incomplete bullets.
2. Internal contradictions.
3. Scope that is too broad for one implementation pass.
4. Ambiguous requirements that could be interpreted more than one way.
5. Missing validation or testing notes.

Then tell the user the `/tmp` design path, provide a concise summary, and ask whether they approve the design or want changes before any implementation work begins.

## Pi-Specific Practices

- Use `read` and `bash` for parent-side context inspection.
- Use `todo` to make the workflow visible.
- Use `ask_user_question` for structured one-question prompts.
- During Explore context, prefer pi-subagents `Agent` for read-only child Pi exploration when available, use `get_subagent_result` for background results, and read explicit final reports before relying on child findings.
- Do not use `write`/`edit` for implementation before design approval.
- Do not use `Agent` for implementation work before design approval; pre-approval child use is limited to read-only exploration.
- If implementation later benefits from delegation, prefer pi-subagents `Agent`, `get_subagent_result`, and `steer_subagent` as described by the system prompt.
