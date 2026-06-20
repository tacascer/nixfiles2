---
name: brainstorming-design
description: Slash-command wrapper around the saved brainstorming-design chain for read-only pre-approval design exploration.
---

# Brainstorming Design Chain Wrapper

Use this skill as a thin wrapper for the saved `brainstorming-design` chain before implementation planning or execution has been approved.

When chain slash commands are available in the current Pi harness, run or request:

```text
/run-chain brainstorming-design -- <user args>
```

Pass through the user's arguments unchanged unless a brief clarification is required to form the chain request.

## Safe Fallback

If `/run-chain` execution is unavailable in the current harness, do not install Pi packages or mutate Pi settings. Instead, manually follow the chain's read-only behavior:

- inspect context without changing repository or runtime configuration files;
- identify scope, constraints, risks, unknowns, missing decisions, and success criteria;
- produce prioritized clarifying questions;
- when more user input is needed, recommend exactly one next user-facing question for the parent to ask;
- prepare digestible design sections with validation prompts that the parent can present to the user before writing the final design/spec.

## Gate Preservation

This wrapper and its fallback do not authorize implementation planning or execution. Do not edit implementation files, scaffold code, run mutating implementation commands, or bypass the written-spec approval gate. Subagents may recommend questions and sectioned presentation material, but the parent remains responsible for asking the user, presenting design sections, recording decisions, writing the final `/tmp/pi-designs/` spec, and obtaining explicit approval before any later handoff.
