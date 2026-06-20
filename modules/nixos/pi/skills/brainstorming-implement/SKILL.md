---
name: brainstorming-implement
description: Slash-command wrapper around the saved brainstorming-implement chain for approved-spec implementation fanout and review.
---

# Brainstorming Implement Chain Wrapper

Use this skill as a thin wrapper for the saved `brainstorming-implement` chain only after a written brainstorming design/spec has been explicitly approved. The saved chain gates approval, creates a concrete plan, reviews the plan for placeholders, fans out multiple isolated implementers, then runs separate final reviews for spec compliance and code quality.

When chain slash commands are available in the current Pi harness, run or request:

```text
/run-chain brainstorming-implement -- <user args>
```

Pass through the user's arguments unchanged, and ensure they include the approved design/spec path or enough context to identify it.

## Safe Fallback

If `/run-chain` execution is unavailable in the current Pi harness, do not install Pi packages or mutate Pi settings. Instead, preserve the same sequence manually with parent orchestration:

1. Verify the request includes an explicit approved spec/design path and clear approval. If either is missing, stop and ask the parent for clarification.
2. Spawn a planner to read the approved spec completely and create a concrete implementation plan with no placeholders.
3. Spawn a reviewer to review that plan for placeholders, vague instructions, missing scope, and unresolved decisions. Stop if the reviewer does not pass the plan.
4. Spawn several implementers in parallel, each in an isolated git worktree/branch, to implement only the approved plan.
5. Spawn two final reviewers: one for approved-spec compliance and one for code quality/maintainability.

## Gate Preservation

Despite the name, this wrapper does not authorize work without an approved written spec. Do not edit implementation files, scaffold code, run mutating implementation commands, or bypass approval, concrete planning, placeholder review, worktree isolation, validation, final spec-compliance review, code-quality review, or final parent handoff gates.
