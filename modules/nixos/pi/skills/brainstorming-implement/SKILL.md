---
name: brainstorming-implement
description: Slash-command wrapper around the saved brainstorming-implement chain for approved-spec implementation handoff.
---

# Brainstorming Implement Chain Wrapper

Use this skill as a thin wrapper for the saved `brainstorming-implement` chain only after a written brainstorming design/spec has been explicitly approved.

When chain slash commands are available in the current Pi harness, run or request:

```text
/run-chain brainstorming-implement -- <user args>
```

Pass through the user's arguments unchanged, and ensure they include the approved design/spec path or enough context to identify it.

## Safe Fallback

If `/run-chain` execution is unavailable in the current harness, do not install Pi packages or mutate Pi settings. Instead, verify the request includes an explicit approved spec/design path and clear approval. If either is missing, stop and ask the parent for clarification. If both are present, route the parent through the retained Pi-native sequence by name:

1. `pi-writing-plans` to read the approved spec and create the implementation plan under `/tmp/pi-plans/`.
2. `pi-subagent-driven-development` only after the parent has granted execution authorization for that plan.
3. `pi-finishing-development-branch` after implementation and review are complete.

## Gate Preservation

Despite the name, this wrapper does not authorize direct implementation. Do not edit implementation files, scaffold code, run mutating implementation commands, or bypass approval, planning, worktree-safety, review, validation, or final handoff gates. The parent remains responsible for confirming the approved spec path, authorizing each phase, and deciding when later Pi-native skills may be invoked.
