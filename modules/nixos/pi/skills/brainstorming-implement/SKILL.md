---
name: brainstorming-implement
description: Slash-command wrapper around the saved brainstorming-implement chain for post-approval implementation handoff.
---

# Brainstorming Implement Chain Wrapper

Use this skill as a thin wrapper for the saved `brainstorming-implement` chain after a written brainstorming design/spec has been explicitly approved.

When chain slash commands are available in the current Pi harness, run or request:

```text
/run-chain brainstorming-implement -- <user args>
```

Pass through the user's arguments unchanged, and ensure they include the approved design/spec path or enough context to identify it.

## Safe Fallback

If `/run-chain` execution is unavailable in the current harness, do not install Pi packages or mutate Pi settings. Instead, verify that a written spec/design has been approved, then invoke or route to the normal `post-brainstorming-implementation` workflow for planning and any later execution gates.

## Gate Preservation

Despite the name, this wrapper does not authorize direct implementation. Do not edit implementation files, scaffold code, run mutating implementation commands, or bypass planning, worktree-safety, review, or validation gates. Implementation may proceed only after the existing post-brainstorming planning and execution gates allow it.
