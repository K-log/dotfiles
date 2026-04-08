import { tool } from "@opencode-ai/plugin"
import { existsSync } from "fs"
import path from "path"

const LOCKFILE_COMMANDS: Record<string, string[]> = {
  "bun.lock": ["bun", "install"],
  "bun.lockb": ["bun", "install"],
  "pnpm-lock.yaml": ["pnpm", "install"],
  "yarn.lock": ["yarn", "install"],
  "package-lock.json": ["npm", "install"],
}

const DESCRIPTION_PATTERN = /^[a-z0-9]+(-[a-z0-9]+)*$/
// Matches "PROJ-123-my-description" and splits into ticket ID + description
const BRANCH_PATTERN = /^([A-Za-z][A-Za-z0-9]*-\d+)-(.+)$/

function parseBranchInput(input: string): {
  ticketId: string
  description: string
} | null {
  const match = BRANCH_PATTERN.exec(input)
  if (!match) return null
  return { ticketId: match[1], description: match[2] }
}

async function detectDefaultBranch(cwd: string): Promise<string> {
  try {
    const ref =
      await Bun.$`git symbolic-ref refs/remotes/origin/HEAD --short`
        .cwd(cwd)
        .text()
    return ref.trim().replace(/^origin\//, "") || "main"
  } catch {
    return "main"
  }
}

async function findExistingBranches(
  ticketId: string,
  cwd: string,
): Promise<string[]> {
  try {
    const result =
      await Bun.$`git branch --list "${ticketId}_*" --format="%(refname:short)"`
        .cwd(cwd)
        .text()
    return result
      .trim()
      .split("\n")
      .filter((b) => b.length > 0)
  } catch {
    return []
  }
}

interface WorktreeEntry {
  path: string
  branch: string
}

async function findExistingWorktrees(
  ticketId: string,
  cwd: string,
): Promise<WorktreeEntry[]> {
  try {
    const result = await Bun.$`git worktree list --porcelain`.cwd(cwd).text()
    const entries: WorktreeEntry[] = []
    let currentPath = ""
    let currentBranch = ""

    for (const line of result.split("\n")) {
      if (line.startsWith("worktree ")) {
        currentPath = line.replace("worktree ", "")
      } else if (line.startsWith("branch ")) {
        currentBranch = line.replace("branch refs/heads/", "")
      } else if (line === "") {
        if (currentBranch.startsWith(`${ticketId}_`)) {
          entries.push({ path: currentPath, branch: currentBranch })
        }
        currentPath = ""
        currentBranch = ""
      }
    }

    // Handle last entry if output doesn't end with a trailing newline
    if (currentBranch.startsWith(`${ticketId}_`)) {
      entries.push({ path: currentPath, branch: currentBranch })
    }

    return entries
  } catch {
    return []
  }
}

function detectLockfile(worktreePath: string): {
  file: string
  command: string[]
} | null {
  for (const [file, command] of Object.entries(LOCKFILE_COMMANDS)) {
    if (existsSync(path.join(worktreePath, file))) {
      return { file, command }
    }
  }
  return null
}

async function runInstallCommand(
  lockfile: { file: string; command: string[] },
  cwd: string,
): Promise<string> {
  try {
    const [bin, ...args] = lockfile.command
    return await Bun.$`${bin} ${args}`.cwd(cwd).text()
  } catch (e: unknown) {
    const message = e instanceof Error ? e.message : String(e)
    return `Install failed: ${message}`
  }
}

export default tool({
  description: `Create or reuse a git worktree for a ticket.

Takes a single branch string in the format "PROJ-123-my-feature" which is
parsed into a ticket ID (PROJ-123) and description (my-feature) automatically.

Call with action "check" (default) first. If existing branches/worktrees are
found for the ticket, the result will indicate a conflict -- ask the user
whether to reuse the existing worktree or create a new one, then call again
with action "reuse" or "create".

After the worktree is ready, the result includes lockfile detection info.
If runInstall is false and a lockfile was found:
- If the current plan already mentions installing packages, call again with runInstall: true.
- Otherwise, ask the user if they want to run the install command.`,

  args: {
    branch: tool.schema
      .string()
      .describe(
        'Combined ticket-description string, e.g. "PROJ-123-add-login-page". The ticket ID is parsed automatically.',
      ),
    baseBranch: tool.schema
      .string()
      .optional()
      .describe(
        "Base branch to create from. Auto-detected from origin/HEAD if omitted.",
      ),
    action: tool.schema
      .enum(["check", "create", "reuse"])
      .optional()
      .describe(
        'Action to perform. "check" (default) looks for existing branches/worktrees. "create" forces creation. "reuse" switches to existing worktree.',
      ),
    runInstall: tool.schema
      .boolean()
      .optional()
      .describe("Run the detected package manager install in the worktree."),
  },

  async execute(args, context): Promise<string> {
    const {
      branch,
      baseBranch,
      action = "check",
      runInstall = false,
    } = args
    const repoRoot = context.worktree || context.directory

    const parsed = parseBranchInput(branch)
    if (!parsed) {
      return JSON.stringify({
        status: "error",
        message: `Invalid branch format: "${branch}". Expected "TICKET-123-description" (e.g. "PROJ-123-add-login-page").`,
      })
    }

    const { ticketId, description } = parsed

    if (!DESCRIPTION_PATTERN.test(description)) {
      return JSON.stringify({
        status: "error",
        message: `Invalid description format: "${description}". Must be kebab-case (e.g. add-login-page).`,
      })
    }

    const worktreePath = path.join(repoRoot, ".worktrees", ticketId)
    const branchName = `${ticketId}_${description}`

    if (action === "check") {
      const [branches, worktrees] = await Promise.all([
        findExistingBranches(ticketId, repoRoot),
        findExistingWorktrees(ticketId, repoRoot),
      ])

      if (branches.length > 0 || worktrees.length > 0) {
        return JSON.stringify({
          status: "conflict",
          ticketId,
          existingBranches: branches,
          existingWorktrees: worktrees,
          message: `Found existing branch(es) or worktree(s) for ${ticketId}. Ask the user whether to reuse an existing worktree or create a new one.`,
        })
      }
    }

    if (action === "check" || action === "create") {
      const base = baseBranch || (await detectDefaultBranch(repoRoot))

      try {
        await Bun.$`git worktree add -b ${branchName} ${worktreePath} ${base}`
          .cwd(repoRoot)
          .text()
      } catch (e: unknown) {
        const message = e instanceof Error ? e.message : String(e)
        return JSON.stringify({
          status: "error",
          message: `Failed to create worktree: ${message}`,
        })
      }

      const lockfile = detectLockfile(worktreePath)
      const installResult =
        lockfile && runInstall
          ? await runInstallCommand(lockfile, worktreePath)
          : null

      return JSON.stringify({
        status: "created",
        branch: branchName,
        baseBranch: base,
        worktreePath,
        worktreeRelativePath: path.join(".worktrees", ticketId),
        lockfile: lockfile
          ? { file: lockfile.file, command: lockfile.command.join(" ") }
          : null,
        installResult,
      })
    }

    if (action === "reuse") {
      const worktrees = await findExistingWorktrees(ticketId, repoRoot)

      if (worktrees.length === 0) {
        return JSON.stringify({
          status: "error",
          message: `No existing worktree found for ${ticketId}.`,
        })
      }

      if (worktrees.length > 1) {
        return JSON.stringify({
          status: "ambiguous",
          ticketId,
          existingWorktrees: worktrees,
          message: `Multiple worktrees found for ${ticketId}. Ask the user which one to reuse.`,
        })
      }

      const target = worktrees[0]
      const lockfile = detectLockfile(target.path)
      const installResult =
        lockfile && runInstall
          ? await runInstallCommand(lockfile, target.path)
          : null

      return JSON.stringify({
        status: "reused",
        branch: target.branch,
        worktreePath: target.path,
        worktreeRelativePath: path.join(".worktrees", ticketId),
        lockfile: lockfile
          ? { file: lockfile.file, command: lockfile.command.join(" ") }
          : null,
        installResult,
      })
    }

    return JSON.stringify({
      status: "error",
      message: `Unknown action: ${action}`,
    })
  },
})
