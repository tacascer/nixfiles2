# Home Instructions

These instructions apply to all projects for user tacascer.

## Git Workflow

- Use git worktrees instead of switching branches — create a worktree for each feature/fix (`git worktree add .worktrees/<branch> -b <branch>`), work there, then clean up after merging (`git worktree remove .worktrees/<branch>`)
