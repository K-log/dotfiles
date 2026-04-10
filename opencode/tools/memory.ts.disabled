import { tool } from "@opencode-ai/plugin"
import { openDatabase, parseScopes } from "./memory-db"

export const store = tool({
  description: `Store a new memory entry in the memory database.

Use this to persist reusable information so it can be retrieved later without re-gathering it. Categories:
- "user-requirement": user explicitly asked to remember this. Must always be checked when working on matching scopes.
- "architecture": architectural decisions. Worth checking when working in a similar area.
- "design-pattern": reusable pattern for codebase consistency.
- "reference": cached external documentation. Check this before searching externally.

Duplicates (same content, scopes, and category) are detected and updated rather than re-inserted.`,

  args: {
    scopes: tool.schema
      .string()
      .describe(
        'Comma-separated scope names this memory pertains to (e.g. "auth,api", "react@19", "database").',
      ),
    category: tool.schema
      .enum([
        "user-requirement",
        "architecture",
        "design-pattern",
        "reference",
      ])
      .describe("The category of this memory entry."),
    content: tool.schema
      .string()
      .describe("The memory content in markdown format."),
    global: tool.schema
      .boolean()
      .optional()
      .describe(
        "Store in the global cross-project database instead of the project-local database. Default: false.",
      ),
  },

  async execute(args, context): Promise<string> {
    const { scopes, category, content, global: isGlobal = false } = args
    const worktree = context.worktree || context.directory

    const db = openDatabase(worktree, isGlobal)
    try {
      const scopesJson = parseScopes(scopes)

      if (scopesJson === "[]") {
        return JSON.stringify({
          status: "error",
          message: "At least one scope is required.",
        })
      }

      const existing = db
        .query(
          `SELECT id FROM memories
           WHERE content = ? AND scopes = ? AND category = ? AND archived = 0`,
        )
        .get(content, scopesJson, category) as { id: number } | null

      if (existing) {
        db.query(
          `UPDATE memories SET updated_at = strftime('%Y-%m-%dT%H:%M:%SZ', 'now') WHERE id = ?`,
        ).run(existing.id)

        return JSON.stringify({
          status: "updated",
          id: existing.id,
          message: `Duplicate found. Updated timestamp for existing memory #${existing.id}.`,
        })
      }

      const result = db
        .query(
          `INSERT INTO memories (scopes, content, category)
           VALUES (?, ?, ?)`,
        )
        .run(scopesJson, content, category)

      return JSON.stringify({
        status: "created",
        id: result.lastInsertRowid,
        message: `Stored new ${category} memory with scopes ${scopesJson}.`,
      })
    } catch (e: unknown) {
      const message = e instanceof Error ? e.message : String(e)
      return JSON.stringify({
        status: "error",
        message: `Store failed: ${message}`,
      })
    } finally {
      db.close()
    }
  },
})

export const find = tool({
  description: `Query the memory database using a raw SQLite SELECT query.

Use this to retrieve previously stored memories before reading code, fetching external documentation, or starting work in a new area. The table is called "memories" with columns: id, updated_at, scopes (JSON array), content (markdown), category, archived (0 or 1).

Common queries:
- All active memories for a scope: SELECT * FROM memories WHERE archived = 0 AND EXISTS (SELECT 1 FROM json_each(scopes) WHERE value = 'auth');
- All user requirements: SELECT * FROM memories WHERE category = 'user-requirement' AND archived = 0;
- Search by keyword: SELECT * FROM memories WHERE archived = 0 AND content LIKE '%keyword%';
- Recent memories: SELECT * FROM memories WHERE archived = 0 ORDER BY updated_at DESC LIMIT 10;`,

  args: {
    query: tool.schema
      .string()
      .describe(
        'A valid SQLite SELECT query against the "memories" table. Only SELECT queries are allowed.',
      ),
    global: tool.schema
      .boolean()
      .optional()
      .describe(
        "Query the global cross-project database instead of the project-local database. Default: false.",
      ),
  },

  async execute(args, context): Promise<string> {
    const { query, global: isGlobal = false } = args
    const worktree = context.worktree || context.directory

    const trimmed = query.trim()
    if (!/^SELECT\b/i.test(trimmed)) {
      return JSON.stringify({
        status: "error",
        message:
          "Only SELECT queries are allowed. Use memory_store or memory_archive for mutations.",
      })
    }

    const db = openDatabase(worktree, isGlobal)
    try {
      const results = db.query(trimmed).all()

      return JSON.stringify({
        status: "ok",
        count: results.length,
        results,
      })
    } catch (e: unknown) {
      const message = e instanceof Error ? e.message : String(e)
      return JSON.stringify({
        status: "error",
        message: `Query failed: ${message}`,
      })
    } finally {
      db.close()
    }
  },
})

export const archive = tool({
  description: `Mark one or more memory entries as archived.

Archived entries are kept for historical reference but are excluded from active use. Use this when information becomes outdated, a pattern is replaced, or a reference is no longer applicable.

Provide a specific memory ID, or use the optional scope/category/content filters to match entries. At least one filter criterion is required.`,

  args: {
    id: tool.schema
      .number()
      .optional()
      .describe("The specific memory ID to archive."),
    scope: tool.schema
      .string()
      .optional()
      .describe(
        "Archive entries that include this scope (exact match within the JSON scopes array).",
      ),
    category: tool.schema
      .enum([
        "user-requirement",
        "architecture",
        "design-pattern",
        "reference",
      ])
      .optional()
      .describe("Archive entries matching this category."),
    contentMatch: tool.schema
      .string()
      .optional()
      .describe(
        "Archive entries whose content contains this substring (case-insensitive LIKE match).",
      ),
    global: tool.schema
      .boolean()
      .optional()
      .describe(
        "Target the global cross-project database instead of the project-local database. Default: false.",
      ),
  },

  async execute(args, context): Promise<string> {
    const {
      id,
      scope,
      category,
      contentMatch,
      global: isGlobal = false,
    } = args
    const worktree = context.worktree || context.directory

    if (
      id === undefined &&
      !scope &&
      !category &&
      !contentMatch
    ) {
      return JSON.stringify({
        status: "error",
        message:
          "At least one of 'id', 'scope', 'category', or 'contentMatch' is required to identify entries to archive.",
      })
    }

    const db = openDatabase(worktree, isGlobal)
    try {
      const conditions: string[] = ["archived = 0"]
      const params: (string | number)[] = []

      if (id !== undefined) {
        conditions.push("id = ?")
        params.push(id)
      }

      if (scope) {
        conditions.push(
          "EXISTS (SELECT 1 FROM json_each(scopes) WHERE value = ?)",
        )
        params.push(scope)
      }

      if (category) {
        conditions.push("category = ?")
        params.push(category)
      }

      if (contentMatch) {
        conditions.push("content LIKE ?")
        params.push(`%${contentMatch}%`)
      }

      const sql = `UPDATE memories SET archived = 1, updated_at = strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
                    WHERE ${conditions.join(" AND ")}`

      const result = db.query(sql).run(...params)
      const count = result.changes ?? 0

      return JSON.stringify({
        status: "ok",
        archived_count: count,
        message:
          count > 0
            ? `Archived ${count} memor${count === 1 ? "y" : "ies"}.`
            : "No matching active memories found to archive.",
      })
    } catch (e: unknown) {
      const message = e instanceof Error ? e.message : String(e)
      return JSON.stringify({
        status: "error",
        message: `Archive failed: ${message}`,
      })
    } finally {
      db.close()
    }
  },
})

export const list_scopes = tool({
  description: `List all unique scopes across active (non-archived) memory entries, with a count of how many entries each scope appears in.

Use this to discover what scopes exist in the memory database before querying for specific ones.`,

  args: {
    global: tool.schema
      .boolean()
      .optional()
      .describe(
        "Query the global cross-project database instead of the project-local database. Default: false.",
      ),
  },

  async execute(args, context): Promise<string> {
    const { global: isGlobal = false } = args
    const worktree = context.worktree || context.directory

    const db = openDatabase(worktree, isGlobal)
    try {
      const results = db
        .query(
          `SELECT DISTINCT je.value AS scope, COUNT(*) AS count
           FROM memories, json_each(memories.scopes) AS je
           WHERE memories.archived = 0
           GROUP BY je.value
           ORDER BY count DESC`,
        )
        .all()

      return JSON.stringify({
        status: "ok",
        count: results.length,
        results,
      })
    } catch (e: unknown) {
      const message = e instanceof Error ? e.message : String(e)
      return JSON.stringify({
        status: "error",
        message: `List scopes failed: ${message}`,
      })
    } finally {
      db.close()
    }
  },
})

export const list_categories = tool({
  description: `List all categories that have active (non-archived) memory entries, with a count of how many entries each category has.

Use this to discover what categories of memories are stored before querying for specific ones.`,

  args: {
    global: tool.schema
      .boolean()
      .optional()
      .describe(
        "Query the global cross-project database instead of the project-local database. Default: false.",
      ),
  },

  async execute(args, context): Promise<string> {
    const { global: isGlobal = false } = args
    const worktree = context.worktree || context.directory

    const db = openDatabase(worktree, isGlobal)
    try {
      const results = db
        .query(
          `SELECT category, COUNT(*) AS count
           FROM memories
           WHERE archived = 0
           GROUP BY category
           ORDER BY count DESC`,
        )
        .all()

      return JSON.stringify({
        status: "ok",
        count: results.length,
        results,
      })
    } catch (e: unknown) {
      const message = e instanceof Error ? e.message : String(e)
      return JSON.stringify({
        status: "error",
        message: `List categories failed: ${message}`,
      })
    } finally {
      db.close()
    }
  },
})
