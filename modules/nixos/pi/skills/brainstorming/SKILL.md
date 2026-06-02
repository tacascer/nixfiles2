---
name: brainstorming
description: "Mandatory before any creative, design-sensitive, behavioral, refactoring, configuration, Pi workflow, or NixOS change. Produces an approved written spec/design before planning or implementation; even simple work needs this design gate."
---

# Brainstorming

Use this skill to turn a rough request into an approved written spec/design before implementation planning. This is a Pi-native adaptation of the Superpowers brainstorming workflow.

## Mandatory Trigger

Use this skill before any work that adds features, changes behavior, refactors structure, changes configuration semantics, builds Pi/NixOS workflows, or otherwise requires design judgment.

Anti-pattern: **"This is too simple to need a design."** Even small or obvious changes need at least a lightweight written spec/design before planning or implementation. The design may be short, but the gate still applies.

## Non-Negotiable Gate

Do not write implementation code, scaffold implementation files, edit existing behavior, or run mutating implementation commands while using this skill. Reading files and inspecting project state are allowed.

A spec/design must be explored, discussed, written, self-reviewed, presented for written-spec review, and explicitly approved by the user before implementation planning. After written spec approval, invoke or hand off to `pi-writing-plans`; do not start implementation code.

For changes in a git repository, remember the repository worktree safety rule for the later planning/implementation phase: before repository edits for planning or implementation, create and work from a dedicated `git worktree` branch when required by repository instructions. Brainstorming may inspect the current checkout; implementation must happen in the dedicated worktree.

Do not run mutable Pi install commands. Pi skills and Pi configuration are managed declaratively by the NixOS/Home Manager configuration.

## Spec Versus Implementation Plan

Brainstorming produces a **spec/design document**. It explains what should be built, why, constraints, behavior, boundaries, risks, and validation expectations.

Planning produces a separate **implementation plan**. It converts the approved spec into ordered engineering tasks, exact file boundaries, dependencies, validation commands, review gates, and Pi subagent execution guidance.

Do not blur these artifacts. Brainstorming stops at an approved written spec and hands off to planning; planning must happen before implementation code.

## Required Checklist

Create and maintain `todo` items for the brainstorming stages. Keep exactly one stage in progress at a time when the todo tool is available, and update each item as soon as its stage starts or completes.

Complete these stages in order:

1. **Explore project context** — inspect relevant context and use at least one read-only `Explore` child Pi subagent when subagents are available.
2. **Offer visual companion if visual questions are likely** — make the offer in its own message before clarifying questions; use a safe text-only fallback when unavailable.
3. **Ask clarifying questions** — ask one question at a time until purpose, constraints, scope, and success criteria are clear.
4. **Propose 2-3 approaches** — compare viable approaches with trade-offs and a recommendation.
5. **Present design sections** — present the proposed design in digestible sections, asking for validation after each section when the design is substantial.
6. **Write `/tmp` spec/design doc** — save the selected design under `/tmp/pi-designs/` outside the tracked worktree by default.
7. **Self-review spec/design** — reread the written file and fix placeholders, contradictions, ambiguity, scope creep, missing validation expectations, and premature implementation details.
8. **User reviews written spec/design** — present the path and concise summary; ask whether the user approves the written spec or wants changes.
9. **Transition to implementation planning** — after written spec approval, invoke or hand off to `pi-writing-plans`; do not start implementation code.

## Context Exploration with Child Pi Subagents

During **Explore project context**, use pi-subagents when the current tooling supports them:

- Start at least one read-only `Explore` child Pi subagent with a self-contained prompt.
- Spawn child Pi instances in visual mode when supported by the current tooling and user preference. If visual mode is unavailable, continue with the available subagent mode and note the limitation.
- The explorer prompt must include the working directory, the user's request, the focused exploration goal, relevant files or directories if known, read-only constraints, no-user-interaction constraints, and the required final report format.
- Start multiple focused explorers when independent context tracks can be investigated in parallel, such as implementation files, project instructions, upstream/API behavior, or recent git history.
- Use background mode for independent long-running exploration when available.
- Wait for and read an explicit final status/report from every child before relying on, summarizing, or incorporating that child's findings. Do not infer completion from quiet logs, file diffs, parent-side validation, or elapsed time.
- If a child lacks an explicit final report, treat it as incomplete: wait, replace it with a narrower child, fall back to bounded parent-side read-only inspection, or report the limitation before proceeding.
- If a child reports `NEEDS_CONTEXT`, `BLOCKED`, times out, or fails, report that outcome and either ask a clarifying question or continue only with clearly bounded parent-side read-only inspection.
- Keep all pre-approval child work read-only. Do not delegate implementation before written spec approval and planning.

If subagents are unavailable, explicitly note that limitation and perform bounded parent-side read-only exploration instead.

## Optional Visual Companion

When upcoming brainstorming likely benefits from visuals, offer visual companion support before asking clarifying questions. The offer must be its own assistant message.

Use visual support only for genuinely visual questions, such as mockups, diagrams, layouts, architecture maps, side-by-side visual comparisons, or spatial relationships. Continue using terminal questions for textual requirements, scope, trade-offs, and conceptual decisions.

If Pi-compatible visual companion tooling is unavailable, say so briefly and continue text-only. Do not run mutable Pi install commands to add visual tooling. If visual artifacts are produced, keep them under `/tmp` or another ignored scratch area unless the user explicitly requests tracked artifacts.

## Clarifying Questions

Ask exactly one clarifying question per assistant message. Prefer a structured question with concrete choices when that helps the user decide. Use an open-ended question when the user needs to explain goals or constraints in their own words.

Good question topics:

- What problem are we solving?
- Who or what uses this?
- What should be out of scope?
- What does success look like?
- Are there compatibility, security, performance, or deployment constraints?
- Which existing conventions should this follow?

If the request is too large for one design, stop early and help the user decompose it into smaller designs. Then brainstorm only the first agreed sub-project.

## Approach Comparison

Before writing the final spec/design, offer 2-3 approaches. For each approach, include:

- What it is.
- Why it might be good.
- Main trade-offs or risks.

End with a recommendation and the reason. Favor simple, reversible, idiomatic changes over broad rewrites.

## Design Presentation

Before writing the final `/tmp` spec/design, present the proposed design in digestible sections scaled to the complexity of the work. Use sections such as scope, behavior, boundaries, data/configuration flow, failure modes, validation, and rollout when relevant.

For substantial designs, ask the user to validate each section or small group of sections before moving on. For lightweight designs, one concise design presentation may be enough, but it must still be validated before writing the spec/design file.

## Design File Rules

Always write the brainstorming spec/design to a file under `/tmp/pi-designs/` before asking for written-spec approval. Use a path like `/tmp/pi-designs/YYYY-MM-DD-<topic>-design.md`, and create the directory if needed.

Use the `/tmp` file as the review artifact. This Pi adaptation intentionally overrides upstream Superpowers' tracked `docs/superpowers/specs/` default for artifact location and commit behavior only: keep brainstorming specs/designs outside tracked project documentation by default. Do not create, stage, commit, or check in brainstorming specs under `docs/`, `docs/specs/`, `docs/superpowers/specs/`, or any other tracked project path unless the user explicitly asks for a tracked document as a separate deliverable.

If the user requests revisions, update the same `/tmp/pi-designs/...-design.md` file rather than creating a new tracked project file.

## Design Content

Size the spec/design to the complexity of the work. Cover the relevant subset of:

- scope and non-goals
- user-facing behavior
- architecture or module boundaries
- data/configuration flow
- error handling and failure modes
- migration or compatibility concerns
- validation/testing strategy
- high-level implementation sequence
- explicit next-step trigger for implementation planning

The spec/design must be specific enough that a later implementation plan can derive file boundaries, acceptance criteria, and validation commands from it.

## Self-Review Before Written-Spec Approval

Parent self-review is mandatory. Before asking the user to approve the written spec/design, reread the `/tmp` design file and fix:

1. Placeholder text, incomplete bullets, or vague sections.
2. Internal contradictions.
3. Scope that is too broad for one implementation pass.
4. Requirements that could be interpreted more than one way.
5. Missing validation or testing notes.
6. Language that implies implementation code can begin before written spec approval and planning.
7. Premature implementation details that belong in the implementation plan rather than the spec/design.

Optionally, when child subagents are available and the design is substantial, start a read-only child design-reviewer or spec-reviewer before user approval. The child review is advisory, but its explicit final status/report must be read before relying on it. Incorporate valid findings into the same `/tmp` design file, then repeat the mandatory parent self-review.

## Written-Spec Approval Prompt

In the Pi conversation, do not dump the full spec/design document. Present only:

- a concise summary of the spec/design
- the `/tmp/pi-designs/...-design.md` path
- notable risks or open decisions, if any
- a clear question asking whether the user approves the written spec/design or wants changes

If the user approves, acknowledge approval and invoke or hand off to `pi-writing-plans`. Do not start implementation code.

If the user requests changes, update the same `/tmp` design file, rerun self-review, and ask for written-spec approval again.

## Pi-Specific Practices

- Use parent-side read-only file inspection for context as needed.
- Use `todo` to make the brainstorming stages visible.
- Use structured one-question prompts when a concrete user decision is needed.
- Prefer pi-subagents for read-only exploration and optional design/spec review when available.
- Spawn child Pi instances in visual mode when supported by the current tooling and user preference.
- Read an explicit final report/status from every child before relying on child findings.
- Do not use implementation children, edit implementation files, or run mutating implementation commands before written spec approval, planning, and a later implementation execution gate.
- Keep design artifacts under `/tmp/pi-designs/`, not tracked project docs, unless the user explicitly asks otherwise.
