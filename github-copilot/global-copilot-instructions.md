# Generating Code

General guidelines for writing code.

## Global code instructions for all cases

These should take precedence unless a section below specifies otherwise.

### Code Format

- Follow the existing project folder structure.
- Ensure code passes linting and type checks before submitting a PR.
- Ensure all thrown errors are handled.
- Only add code comments for code that is not easily readable.
- Prefer code that can be easily read by a human over code that is concise.

### Testing

- Ensure all code is testable.
- Ensure all code is properly tested.
- Ensure tests cover all edge cases.
- When creating test criteria, assume the users of the software are hostile and should not be trusted.

#### End-to-End testing

- Add comments explaining all magic strings or numbers.
- Move duplicate test utilities into shared files.

## Javascript and Frontend focused code

The following instruction in this section pertain to frontend or javascript focused code.
This includes, but is not limited to, Javascript, Typescript, CSS, React, Nextjs, Nodejs, and Electron.

### Code Format

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

#### Unit testing

- Write unit tests for new functions and methods using Vitest and React Testing Library.

#### End-to-End testing

- Write end-to-end tests with Playwright.

# Formatting responses

- Respond the way you would to a Senior Software Engineer.
- Ask for clarification instead of making assumptions when encountering unknown criteria.
- Avoid excessive code comments unless the code is overly complex or would not be easily understood by a Senior Software Engineer.

## Track every task

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
