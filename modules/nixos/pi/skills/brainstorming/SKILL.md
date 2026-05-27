---
name: brainstorming
description: "Use before creative or design-sensitive work: adding features, modifying behavior, refactoring, changing configuration semantics, or building new Pi/NixOS workflows. Requires a Pi-native design discussion and user approval before implementation."
---

# Brainstorming

Use this skill to turn a rough request into an approved design before implementation. This is a Pi-native adaptation of the Superpowers brainstorming workflow for this NixOS flake and other local projects.

## Non-Negotiable Gate

Do not write implementation code, scaffold implementation files, edit existing behavior, or run mutating implementation commands while using this skill. Reading files and inspecting project state are allowed.

A design must be written, self-reviewed, presented, and explicitly approved by the user before implementation planning or code changes begin. After the user approves the design, stop. Do not continue into implementation unless the user separately asks for the next step.

For changes in a git repository, remember the repository worktree safety rule for the later implementation phase: before code changes, create and work from a dedicated `git worktree` branch. Brainstorming may inspect the current checkout; implementation must happen in the dedicated worktree.

Do not run mutable Pi install commands. Pi skills and Pi configuration are managed declaratively by the NixOS/Home Manager configuration.

## Required Todos

Create and maintain `todo` items for the brainstorming stages. Keep exactly one stage in progress at a time when the todo tool is available, and update each item as soon as its stage starts or completes.

Required stages:

1. **Explore context** — inspect relevant project context and use at least one read-only `Explore` child Pi subagent when subagents are available.
2. **Clarify intent** — ask one clarifying question at a time until purpose, constraints, scope, and success criteria are clear.
3. **Compare approaches** — present 2-3 viable approaches with trade-offs and a recommendation.
4. **Write design draft** — save the selected design under `/tmp/pi-designs/` outside the git worktree.
5. **Review design** — perform mandatory parent self-review and, when useful and available, request an optional read-only child design/spec review.
6. **Revise design** — fix review findings, placeholders, contradictions, excessive scope, ambiguous requirements, and missing validation notes in the same `/tmp` design file.
7. **Ask for approval** — present only a concise summary, the design path, and an approval-or-changes question.
8. **Stop after approval** — if approved, stop and wait for an explicit implementation request; if changes are requested, revise the same design file and ask again.

## Context Exploration with Child Pi Subagents

During **Explore context**, use pi-subagents when the current tooling supports them:

- Start at least one read-only `Explore` child Pi subagent with a self-contained prompt.
- Spawn child Pi instances in visual mode when supported by the current tooling and user preference. If visual mode is unavailable, continue with the available subagent mode and note the limitation.
- The explorer prompt must include the working directory, the user's request, the focused exploration goal, relevant files or directories if known, read-only constraints, no-user-interaction constraints, and the required final report format.
- Start multiple focused explorers when independent context tracks can be investigated in parallel, such as implementation files, project instructions, upstream/API behavior, or recent git history.
- Use background mode for independent long-running exploration when available.
- Wait for and read an explicit final status/report from every child before relying on, summarizing, or incorporating that child's findings. Do not infer completion from quiet logs, file diffs, parent-side validation, or elapsed time.
- If a child lacks an explicit final report, treat it as incomplete: wait, replace it with a narrower child, fall back to bounded parent-side read-only inspection, or report the limitation before proceeding.
- If a child reports `NEEDS_CONTEXT`, `BLOCKED`, times out, or fails, report that outcome and either ask a clarifying question or continue only with clearly bounded parent-side read-only inspection.
- Keep all pre-approval child work read-only. Do not delegate implementation before design approval and a separate implementation request.

If subagents are unavailable, explicitly note that limitation and perform bounded parent-side read-only exploration instead.

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

Before writing the final design, offer 2-3 approaches. For each approach, include:

- What it is.
- Why it might be good.
- Main trade-offs or risks.

End with a recommendation and the reason. Favor simple, reversible, idiomatic changes over broad rewrites.

## Design File Rules

Always write the brainstorming design to a file under `/tmp/pi-designs/` before asking for approval. Use a path like `/tmp/pi-designs/YYYY-MM-DD-<topic>-design.md`, and create the directory if needed.

Use the `/tmp` file as the review artifact. Keep brainstorming design files outside tracked project documentation by default. Do not create, stage, commit, or check in brainstorming design specs under `docs/`, `docs/specs/`, or any other tracked project path unless the user explicitly asks for a tracked document as a separate deliverable.

If the user requests revisions, update the same `/tmp/pi-designs/...-design.md` file rather than creating a new tracked project file.

## Design Content

Size the design to the complexity of the work. Cover the relevant subset of:

- scope and non-goals
- user-facing behavior
- architecture or module boundaries
- data/configuration flow
- error handling and failure modes
- migration or compatibility concerns
- validation/testing strategy
- high-level implementation sequence
- explicit next-step trigger for implementation

The design must be specific enough that a later implementation plan can derive file boundaries, acceptance criteria, and validation commands from it.

## Review Before Approval

Parent self-review is mandatory. Before asking the user to approve the design, reread the `/tmp` design file and fix:

1. Placeholder text, incomplete bullets, or vague sections.
2. Internal contradictions.
3. Scope that is too broad for one implementation pass.
4. Requirements that could be interpreted more than one way.
5. Missing validation or testing notes.
6. Any language that implies implementation can begin before user approval.

Optionally, when child subagents are available and the design is substantial, start a read-only child design-reviewer or spec-reviewer before user approval. The child review is advisory, but its explicit final status/report must be read before relying on it. Incorporate valid findings into the same `/tmp` design file, then repeat the mandatory parent self-review.

## Approval Prompt

In the Pi conversation, do not dump the full design document. Present only:

- a concise summary of the design
- the `/tmp/pi-designs/...-design.md` path
- notable risks or open decisions, if any
- a clear question asking whether the user approves the design or wants changes

If the user approves, acknowledge approval and stop. State that implementation will require a separate explicit request and, for git repositories, a dedicated worktree branch.

If the user requests changes, update the same `/tmp` design file, rerun review, and ask for approval again.

## Pi-Specific Practices

- Use parent-side read-only file inspection for context as needed.
- Use `todo` to make the brainstorming stages visible.
- Use structured one-question prompts when a concrete user decision is needed.
- Prefer pi-subagents for read-only exploration and optional design/spec review when available.
- Spawn child Pi instances in visual mode when supported by the current tooling and user preference.
- Read an explicit final report/status from every child before relying on child findings.
- Do not use implementation children, edit implementation files, or run mutating implementation commands before design approval and a later explicit implementation request.
- Keep design artifacts under `/tmp/pi-designs/`, not tracked project docs, unless the user explicitly asks otherwise.
