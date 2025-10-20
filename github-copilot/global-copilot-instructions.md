# Copilot Instructions

These are instructions to be followed when performing actions. 
These instructions should always be followed as closely as possible unless explicitly requested by the user.


## Generating Code

General guidelines for writing code.

### Global code instructions for all cases

These should take precedence unless a section below specifies otherwise.

#### Code Format

- Follow the existing project folder structure.
- Ensure code passes linting and type checks before submitting a PR.
- Ensure all thrown errors are handled.
- Only add code comments for code that is not easily readable.
- Prefer code that can be easily read by a human over code that is concise.

#### Testing

- Ensure all code is testable.
- Ensure all code is properly tested.
- Ensure tests cover all edge cases.
- When creating test criteria, assume the users of the software are hostile and should not be trusted.

##### End-to-End testing

- Add comments explaining all magic strings or numbers.
- Move duplicate test utilities into shared files.

### Javascript and Frontend focused code

The following instruction in this section pertain to frontend or javascript focused code.
This includes, but is not limited to, Javascript, Typescript, CSS, React, Nextjs, Nodejs, and Electron.

#### Code Format

- Use TypeScript for all new React components.
- Prefer functional components and React hooks.
- Ensure all props and state are strongly typed.
- Use the correct package manager for the project by checking for a lock file or the `package.json`.
- Use ES6+ syntax and features.
- Avoid using `any` or `unknown` types unless absolutely necessary.
- Document public functions and components with JSDoc comments.
- Prefer CSS modules over inline styles.
- Prefer CSS vars from `shared-ui-styles` where possible.
-

##### Unit testing

- Write unit tests for new functions and methods using Vitest and React Testing Library.

##### End-to-End testing

- Write end-to-end tests with Playwright.


## Planning Mode (ONLY WHEN EXPLICITLY REQUESTED)

When asked, you support an interactive "Planning" mode for AI agents and engineers to collaboratively produce a complete, buildable specification for new features. Use this mode when you want a single, self-contained plan that another engineer (or automated agent) can follow to implement a feature end-to-end.

When in Planning mode, follow these rules:

- Start by collecting facts and constraints: target platform, browsers, data shapes, performance targets, security/permissions, and any hard requirements (APIs, libs, design system).
- Ask clarifying questions until you're 100% certain you have all required inputs to produce the plan. Do not proceed to produce the final plan until all clarifications are resolved.
- Produce a single Markdown file as the final artifact. Name it: `PLANS/<feature-slug>-plan.md` (create `PLANS/` if missing). The file must be self-contained and actionable.
- The plan must be detailed enough for a Senior Engineer or an autonomous agent to implement without further questions.
- Break the plan into clear sections, include concrete acceptance criteria, API contracts, data models, UI mockups (ASCII or links to assets), testing strategy, and a task-level implementation checklist with time estimates.
- Include a small runnable prototype outline or test harness where applicable (commands to run, minimal code snippets, sample requests/responses). These may be references—do not put large binaries into the plan.
- List all dependencies and required environment variables. Specify any changes to CI, scripts, or package.json required to support development or testing.
- Add a Risks & Mitigations section describing important edge cases and how to validate them.
- Provide a sample Playwright and Vitest test case (happy-path + 1 edge case) as examples the implementer should add.
- Ensure accessibility and internationalization considerations are included when the feature affects UI.

Plan template (required sections):

1. Title and short description (1-2 sentences)
2. Goals and non-goals
3. Stakeholders and roles
4. Assumptions & constraints
5. Data model / API contracts (request/response examples)
6. UX / UI spec (screens, states, interactions, mockups)
7. Accessibility requirements
8. Acceptance criteria (clear, testable)
9. Testing strategy (unit, integration, E2E with sample tests)
10. Implementation tasks (task list with owner, priority, rough estimate)
11. CI / build / deployment notes
12. Rollout plan and monitoring
13. Risks & mitigations
14. Files to create/modify (paths)
15. Appendix: sample code snippets, mock data, commands to run

Interactive behavior for the agent:

- The agent must iterate with the requestor: ask one focused question at a time, incorporate the answer, and repeat until all sections can be fully populated.
- Before finishing, print a short checklist mapping each template section to status: Done / Needs input (and what input is needed).
- After the plan file is created, open a short PR description draft with the plan link and a minimal implementation proposal.

Example usage flow (agent):

1. Ask: "What is the feature slug and a 1-line description?"
2. Ask required clarifying questions for assumptions (auth, org-level data, mobile/responsive needs, etc.)
3. When inputs are complete, generate `PLANS/<feature-slug>-plan.md` following the template.
4. Show the plan to the requestor and ask for sign-off or missing data.
5. After sign-off, optionally scaffold basic files (`src/` skeleton, tests) in a separate branch and open a PR.

Naming and deliverable standards:

- Use kebab-case for filenames and feature slugs (e.g., `inspection-measurements-plan.md`).
- Provide time estimates in whole hours (rounded up) and identify the critical path tasks.
- Keep the plan focused and avoid implementation-level minutiae unless necessary for clarity.


## Formatting responses

- Respond the way you would to a Senior Software Engineer.
- Ask for clarification instead of making assumptions when encountering unknown criteria.
- Avoid excessive code comments unless the code is overly complex or would not be easily understood by a Senior Software Engineer.

### Track every task

- Generate a log file to track the progress of my current task.
- Generate only a single log file per day.
- Append each new log into the log file for the current day.
- Print the log into the chat whenever it is saved to the file.
- The log file should include the following details for each step:
  1. Timestamp: The exact time when the step was initiated.
  2. Time Taken: The duration it took to complete the step.
  3. Estimated time saved: The estimated amount of time it would have taken to complete this task manually.
  4. Prompt: The input or instruction provided for the step.
  5. Response: The output or implementation details for the step.
- The log file should be formatted as follows:
  1. Timestamp: [YYYY-MM-DD HH:MM:SS]
  2. Time Taken: [X minutes]
  3. Estimated Time Saved: [X minutes]
  4. Prompt: [Description of the task or instruction]
  5. Response: [Details of the implementation or output]
  6. Save the log file as `~/Documents/copilot-logs/task_progress_log-{Timestamp}.txt`.
  7. Never save or create a log file outside of `~/Documents/copilot-logs/task_progress_log-{Timestamp}.txt`
