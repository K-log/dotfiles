---
description: "Create a git worktree for a ticket. Usage: /worktree <ticket-id-description> [base-branch]"
---

Create a worktree for `$1`.

Call the `worktree` tool with branch `$1` and action `"check"`.
If `$2` is provided, pass it as baseBranch.

If the result status is `"conflict"`, present the existing branches and worktrees
to the user and ask whether to:

- **Reuse** the existing worktree (call the tool again with action `"reuse"`)
- **Create** a new worktree anyway (call the tool again with action `"create"`)

If the result status is `"ambiguous"`, multiple worktrees exist for the ticket.
Present the list to the user and ask which one to use, then call the tool again
with action `"reuse"` and the branch string corresponding to the chosen worktree.

After the worktree is created or reused, if a lockfile is detected and `installResult`
is null:

- If the current plan already mentions installing packages or dependencies, call the
  tool again with `runInstall: true`.
- Otherwise, ask the user if they want to run the detected install command.
