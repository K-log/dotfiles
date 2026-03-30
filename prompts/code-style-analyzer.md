# Code Style Analyzer

Purpose: Analyze user created code for the purpose of directly an AI agent to follow the user's coding style.

## What to Analyze

Analyze the following within the current codebase:
- Naming - How does the user name user-added values in code?
- Programming paradigms - What paradigms are used by the user and within the app?
- Styling - How does the user apply styling to user facing elements?
- Organization - How does the user sort, order, and group their code?

## What to produce

- Output a project agnostic breakdown of what has been analyzed. 
- Minimize duplicate tokens in the output.
- Keep output markdown file under 500 lines.

### Output Format:

A single markdown file:

```markdown

# Title

How to Use:

Details for an LLM, AI Agent, or other autonomous tool to use this file. 

The goal is for a consuming tool to read this output file and structure it's own output
to match what is detailed here.

A consuming Agent should be forced to use this styling while working in the application this file exists in.

## Analysis section

Simple description of analysis result for this section

- Breakdown of any notable ways the user writes code in this section's format

```TSX
Code example of one of the sections analyzed

```
### Subsection

If analysis could be broken down into subsections, do so like this
```
