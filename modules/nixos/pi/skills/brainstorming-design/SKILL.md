---
name: brainstorming-design
description: Slash-command wrapper around the saved brainstorming-design chain for pre-approval design exploration.
---

# Brainstorming Design Chain Wrapper

Use this skill as a thin wrapper for the saved `brainstorming-design` chain.

When chain slash commands are available in the current Pi harness, run or request:

```text
/run-chain brainstorming-design -- <user args>
```

Pass through the user's arguments unchanged unless a brief clarification is required to form the chain request.

## Safe Fallback

If `/run-chain` execution is unavailable in the current harness, do not install Pi packages or mutate Pi settings. Instead, follow the same safe behavior manually: perform read-only design exploration, identify scope, constraints, risks, success criteria, and clarifying questions, then guide the parent toward the normal `brainstorming` written-spec workflow.

## Gate Preservation

This wrapper and its fallback do not authorize implementation. Do not edit implementation files, scaffold code, run mutating implementation commands, or bypass the written-spec approval gate. Final planning or implementation may begin only through the existing post-brainstorming workflow after the written design/spec has been explicitly approved.
