# Global Rules

## Communication

- No emojis anywhere: code, comments, commit messages, documentation, responses.
- Skip preambles, pleasantries, and unnecessary validation. Get to the point.
- Assume senior-level knowledge. Don't explain basic concepts unless asked.
- Only explain decisions that are complex or non-obvious. Focus on WHY, not WHAT.
- One paragraph maximum when explaining, unless complexity demands more.
- No "I'll now...", "Great!", or play-by-play announcements.

## Code Changes

- Make the absolute minimum changes necessary. Only modify what's required for the task.
- Do not refactor unrelated code unless explicitly asked.
- Do not add "nice to have" features beyond the requirement.
- Three instances of similar code is better than a premature abstraction.
- Before implementing, research the codebase. Match existing structure, conventions, naming, and libraries.
- When in doubt, copy the existing pattern exactly.
- Prefer editing existing files over creating new ones.
- Never manually edit auto-generated files.

## Code Quality

- Never add redundant comments. Only comment complex or non-obvious logic.
- Never add documentation overhead unless creating public APIs.
- Never use debug print/log statements in production code.
- Never bypass the type system (`any`, `dynamic`, `object`, etc.) when strict types are available.
- Use explicit types for public interfaces. Make function signatures self-documenting.

## Refactoring

Only refactor proactively when:
- The same logic appears 3+ times in related files.
- Type safety gaps exist in files you are already modifying.
- There is an obvious performance bottleneck.
- There is clearly dead code in files you are already modifying.

Never refactor:
- Working code in files you are not modifying.
- Code using older patterns that works correctly.
- Code that could be "more elegant" but is readable.

## Testing

Test: business logic, complex utilities, validation/transformation logic, error handling at boundaries.

Do not test: simple presentational logic, third-party behavior, auto-generated code, trivial getters/setters.

- Test public interfaces and behavior, not internal state or implementation details.
- Mock external dependencies, not internal modules.
- Write descriptive test names that document intent.
- Assume users are hostile and should not be trusted when writing test criteria.

## TypeScript / JavaScript

- Use TypeScript for all new code. Use ES6+ syntax.
- Prefer functional React components and hooks.
- Ensure all props and state are strongly typed.
- Use the correct package manager for the project (check for a lock file or `package.json`).
- Avoid `any` or `unknown` unless absolutely necessary.
- Prefer CSS modules over inline styles.
- Write unit tests with Vitest and React Testing Library.
- Write end-to-end tests with Playwright.

## Linting and Type Checking

- Before declaring a task done, run the project's linter and type-checker.
- Respect the project's existing linter and formatter config. Do not override or ignore it.

## Git Commits

- Before writing a commit message, check `git log` to infer the project's existing commit style and follow it.
- If the current branch name contains a ticket number (e.g. `PROJ-1234`), prefix the commit message with it: `[PROJ-1234] my commit message`.
- Keep messages simple and easy to read.
- Do not prefix messages with `feat:`, `fix:`, `refactor:`, or similar conventional commit tags unless the project already uses them.

## Code Review

After completing non-trivial code changes, invoke the `code-reviewer` subagent to review the work.
Use judgment — skip this for trivial edits (single-line changes, config tweaks, typo fixes, etc.).

Once the review is complete, present the findings to the user and ask which issues (if any) they want
fixed before the task is considered done.
