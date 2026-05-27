---
name: pi-finishing-development-branch
description: Finish a dedicated Pi development worktree by validating the result, reviewing the final diff, and producing a concise handoff summary with branch, subagent, validation, issue, and next-action details.
---

# Pi Finishing Development Branch

Use this skill after implementation and review work has completed in a dedicated git worktree branch. The goal is to verify what changed, record what was validated, and give the user a clear handoff without making unrelated edits.

## Preconditions

Proceed only when:

- The work is in a dedicated git worktree or otherwise clearly isolated development branch.
- The approved design and implementation plan, if they exist, have been read or their paths are known.
- All spawned child Pi instances that matter to the result have explicit final reports/statuses, or missing reports are called out as incomplete.
- Implementation tasks and review gates have either passed or their unresolved issues are known.

If a prerequisite is missing and you cannot safely reconstruct it, stop and report the missing context instead of guessing.

## Final Inspection

1. Confirm the current worktree path and branch with git.
2. Check repository status and distinguish intentional changes from untracked or unrelated files.
3. Review the final diff before summarizing. Use focused file reads for important changed files, not only a high-level diffstat.
4. Verify that changes are limited to the approved design, plan, and task scopes. If scope drift is found, report it clearly.
5. Preserve user changes. Do not stash, reset, clean, amend, commit, or switch branches unless the user explicitly asks.

## Final Validation

Run validation appropriate to the repository and the changed files. Prefer the strongest practical checks, but do not hide skipped checks.

For this myNixOS flake, expected validation includes:

- Parse-check changed Nix files when practical, for example `nix-instantiate --parse <file>`.
- Run `nix flake check` when feasible for integrated flake validation.
- Run `nix flake show` when useful to confirm exposed outputs or output shape.
- Run host rebuilds such as `sudo nixos-rebuild switch --flake ...` only when the user requested it or when it is clearly appropriate and safe for the task.

For skill or Markdown changes, also validate:

- Skill files are readable Markdown.
- Frontmatter includes `name` and a clear `description`.
- No unintended placeholders, contradictory instructions, or mutable Pi installation steps were introduced.

When validation fails:

- Capture the command, exit status, and most relevant error lines.
- If the cause is unclear and subagents are available, dispatch a bounded validation analyst child with the failure log and required final status/report.
- Do not claim the branch is ready without either fixing failures or listing them as known issues.

## Subagent Accounting

Summarize every subagent batch that contributed to the work:

- Batch purpose and whether it was parallel or serialized.
- Child role or skill used.
- Task scope.
- Explicit final status/report received.
- Review outcome, fix loop, or validation analysis result.

Never rely on a child result unless its explicit final status/report has been read. If a child timed out, failed, or did not provide a final report, state that plainly and treat its work as incomplete until independently verified.

## Handoff Summary

Produce a concise final handoff that includes:

- Worktree path and branch name.
- Design path and plan path, when applicable.
- Files changed and a short explanation of each group of changes.
- Subagent batches and final statuses.
- Validation commands run and outcomes.
- Known issues, skipped checks, or residual risks.
- Recommended next actions, such as user review, running a rebuild, committing, or merging.

Do not run mutable Pi install commands. Pi configuration, packages, skills, prompts, and themes must remain declaratively managed through the NixOS/Home Manager configuration.
