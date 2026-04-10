import { Database } from "bun:sqlite"
import { existsSync, mkdirSync, writeFileSync } from "fs"
import path from "path"
import { homedir } from "os"

const SCHEMA = `
CREATE TABLE IF NOT EXISTS memories (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  updated_at  TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')),
  scopes      TEXT    NOT NULL,
  content     TEXT    NOT NULL,
  category    TEXT    NOT NULL CHECK(category IN (
                'user-requirement',
                'architecture',
                'design-pattern',
                'reference'
              )),
  archived    INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_memories_category ON memories(category);
CREATE INDEX IF NOT EXISTS idx_memories_archived ON memories(archived);
`

const AGENTS_MD = `# Memory Database

This directory contains a SQLite memory database used by AI agents to store and retrieve reusable information.

## Purpose

- Cache information so agents can get up to speed quickly without re-gathering it
- Store user requirements, architectural decisions, design patterns, and reference material
- Avoid redundant external documentation lookups

## Schema

| Column       | Type    | Description                                                            |
| ------------ | ------- | ---------------------------------------------------------------------- |
| \`id\`         | INTEGER | Auto-incrementing primary key                                          |
| \`updated_at\` | TEXT    | ISO timestamp of last update                                           |
| \`scopes\`     | TEXT    | JSON array of scope strings (e.g. \`["auth", "api"]\`)                   |
| \`content\`    | TEXT    | Markdown-formatted content                                             |
| \`category\`   | TEXT    | One of: user-requirement, architecture, design-pattern, reference      |
| \`archived\`   | INTEGER | 0 = active, 1 = archived                                              |

## Categories

- **user-requirement** -- Explicitly requested by the user. Must always be included in context when working on matching scopes.
- **architecture** -- Architectural decisions. Not a hard requirement but worth checking when working in a similar area.
- **design-pattern** -- Reusable patterns for codebase consistency.
- **reference** -- Cached external documentation. Check this before searching externally for similar information. Store once confirmed correct.

## Available Tools

### \`memory_store\`

Store a new memory entry.

| Arg        | Type    | Required | Description                                                       |
| ---------- | ------- | -------- | ----------------------------------------------------------------- |
| \`scopes\`   | string  | Yes      | Comma-separated scope names (e.g. "auth,api")                     |
| \`category\` | enum    | Yes      | user-requirement, architecture, design-pattern, or reference      |
| \`content\`  | string  | Yes      | Markdown content to store                                         |
| \`global\`   | boolean | No       | Store in global DB instead of project DB (default: false)         |

### \`memory_find\`

Query the memory database with raw SQL.

| Arg      | Type    | Required | Description                                            |
| -------- | ------- | -------- | ------------------------------------------------------ |
| \`query\`  | string  | Yes      | Valid SQLite SELECT query against the \`memories\` table  |
| \`global\` | boolean | No       | Query global DB instead of project DB (default: false) |

### \`memory_archive\`

Mark memories as archived.

| Arg            | Type    | Required | Description                                                      |
| -------------- | ------- | -------- | ---------------------------------------------------------------- |
| \`id\`           | number  | No       | Specific memory ID to archive                                    |
| \`scope\`        | string  | No       | Archive entries that include this scope                          |
| \`category\`     | enum    | No       | Archive entries matching this category                           |
| \`contentMatch\` | string  | No       | Archive entries whose content contains this substring            |
| \`global\`       | boolean | No       | Target global DB (default: false)                                |

At least one of \`id\`, \`scope\`, \`category\`, or \`contentMatch\` is required.

### \`memory_list_scopes\`

List all unique scopes across active (non-archived) memory entries with counts.

| Arg      | Type    | Required | Description                                            |
| -------- | ------- | -------- | ------------------------------------------------------ |
| \`global\` | boolean | No       | Query global DB instead of project DB (default: false) |

### \`memory_list_categories\`

List all categories that have active (non-archived) memory entries with counts.

| Arg      | Type    | Required | Description                                            |
| -------- | ------- | -------- | ------------------------------------------------------ |
| \`global\` | boolean | No       | Query global DB instead of project DB (default: false) |

## When to Use

### Check memory BEFORE:
- Reading code to understand patterns or architecture
- Fetching external documentation
- Starting work on a new area (check for user-requirements in matching scopes)

### Store memory AFTER:
- Confirming external documentation is correct
- Discovering a codebase pattern worth reusing
- A user explicitly asks you to remember something
- Identifying an architectural decision

### Archive memory WHEN:
- Information becomes outdated due to code changes
- A pattern is replaced by a new one
- A reference is no longer applicable

## Example Queries

\`\`\`sql
-- All active memories for a scope
SELECT * FROM memories
WHERE archived = 0
  AND EXISTS (SELECT 1 FROM json_each(scopes) WHERE value = 'auth');

-- All user requirements (always check these)
SELECT * FROM memories
WHERE category = 'user-requirement' AND archived = 0;

-- Search content by keyword
SELECT * FROM memories
WHERE archived = 0 AND content LIKE '%authentication%';

-- Cached references for a specific version
SELECT * FROM memories
WHERE category = 'reference' AND archived = 0
  AND EXISTS (SELECT 1 FROM json_each(scopes) WHERE value = 'react@19');

-- Recently updated memories
SELECT * FROM memories
WHERE archived = 0
ORDER BY updated_at DESC LIMIT 10;
\`\`\`
`

function getProjectDbDir(worktree: string): string {
  return path.join(worktree, ".opencode", "memory-db")
}

function getGlobalDbDir(): string {
  return path.join(homedir(), ".config", "opencode", "memory-db")
}

export function getDbPath(worktree: string, global: boolean): string {
  const dir = global ? getGlobalDbDir() : getProjectDbDir(worktree)
  return path.join(dir, "database.sqlite")
}

function ensureAgentsMd(dir: string): void {
  const agentsMdPath = path.join(dir, "AGENTS.md")
  if (!existsSync(agentsMdPath)) {
    writeFileSync(agentsMdPath, AGENTS_MD.trim() + "\n")
  }
}

export function openDatabase(worktree: string, global: boolean): Database {
  const dir = global ? getGlobalDbDir() : getProjectDbDir(worktree)

  if (!existsSync(dir)) {
    mkdirSync(dir, { recursive: true })
  }

  const dbPath = path.join(dir, "database.sqlite")
  const db = new Database(dbPath)

  db.exec("PRAGMA journal_mode = WAL;")
  db.exec(SCHEMA)

  ensureAgentsMd(dir)

  return db
}

export function parseScopes(scopes: string): string {
  const parsed = scopes
    .split(",")
    .map((s) => s.trim())
    .filter((s) => s.length > 0)
  return JSON.stringify(parsed)
}
