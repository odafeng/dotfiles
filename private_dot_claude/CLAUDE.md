# Global Instructions

## Language
- Always respond in Traditional Chinese (繁體中文)
- Keep technical terms in English (e.g. API, middleware, hook, component)
- Commit messages in English, follow Conventional Commits (feat:, fix:, chore:, test:)

## Testing
- App projects (web app, CLI tool, API server): must write tests when adding/modifying features
- Test levels: unit test (function/module logic), smoke test (app starts, main paths don't crash), E2E test (full user flow)
- Library/utility projects: at least unit tests
- Use the project's existing test framework; suggest mainstream frameworks if none exists

## Behavioral Boundaries
- Never auto-run git push — let me confirm first
- When uncertain, ask — don't guess
- When you don't know, say so — no inference or hallucination

## CI/CD
- Every new project must include a CI/CD workflow with linting, type checking, and pre-commit hooks
- Python projects: Ruff (linting/formatting) + Pyright (type checking) + pre-commit
- JavaScript/TypeScript projects: ESLint + Prettier + pre-commit (or equivalent)
- Set up on project creation, not as an afterthought

## Architecture Decision Records (ADR)
- Every project must have ADRs for significant architectural decisions
- Format: Michael Nygard's original (Title, Status, Context, Decision, Consequences)
- Store in `docs/adr/` or project-appropriate location
- Number sequentially: 0001-title.md, 0002-title.md
- Create ADRs when: choosing a framework, changing data flow, adding infrastructure, changing a fundamental pattern
- "Consequences" must include negatives/trade-offs — not just benefits

## Coding Principles (Karpathy Guidelines)

### 1. Think Before Coding
- State assumptions explicitly before implementing. If uncertain, ask — don't silently pick an interpretation
- When multiple interpretations exist, list options for me to choose
- If a simpler approach exists, propose it. Push back when warranted
- If confused, stop, name what's unclear, and ask

### 2. Simplicity First
- Minimum code to solve the current problem. No speculative features
- No unrequested features, abstractions, or configurability
- No error handling for impossible scenarios
- If 200 lines can be 50, rewrite it. Test: would a senior engineer say it's overcomplicated?

### 3. Surgical Changes
- Only change lines directly related to the request. Don't "improve" adjacent code, comments, or formatting
- Don't refactor what isn't broken. Match existing style even if you'd write it differently
- Clean up orphans (unused imports/variables/functions) caused by YOUR changes, but don't touch pre-existing dead code unless asked
- You may mention unrelated dead code, but don't delete it

### 4. Goal-Driven Execution
- Transform vague tasks into verifiable goals:
  - "Add validation" → write tests for invalid inputs, then make them pass
  - "Fix bug" → write a test that reproduces it, then make it pass
  - "Refactor X" → ensure tests pass before and after
- For multi-step tasks, state a plan with verification per step:
  ```
  1. [Step] → verify: [check]
  2. [Step] → verify: [check]
  ```
- Clear success criteria enable independent looping; vague criteria ("make it work") require constant clarification
