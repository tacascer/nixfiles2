# myNixOS

## Agent workspace adoption

This language describes the adoption of reusable workspaces by coding agents.

**Assignment handle**:
The explicit identifier of one particular assignment of a pooled worktree to a caller. It identifies the assignment, not just the worktree.
_Avoid_: Worktree path, slot identifier

**Recovery obligation**:
The caller’s responsibility to preserve unfinished work and disclose unresolved ownership or workspace state when normal completion is impossible.
_Avoid_: Automatic cleanup

**Assignment**:
A particular caller's claim to use a pooled worktree, continuing until that claim is explicitly ended.
_Avoid_: Worktree, branch

**Reuse eligibility**:
A worktree's suitability for another assignment, independently of whether its previous assignment has ended.
_Avoid_: Unassigned

**Pool capacity**:
The maximum number of registered worktrees belonging to one repository's pool, including worktrees that are assigned or unavailable for reuse.
_Avoid_: Number of idle worktrees, number of active agents

**Capacity expansion**:
An increase in one repository pool's allowed number of registered worktrees, permitting additional assignments without displacing existing ones.
_Avoid_: Reclamation, recovery

**Assignment receipt**:
The retained result identifying a particular workspace assignment and its reported outcome, used to support continuation and handoff.
_Avoid_: Worktree path, latest assignment
