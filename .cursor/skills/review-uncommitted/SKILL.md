---
name: review-uncommitted
description: Review uncommitted (unstaged, staged, and untracked) changes in the working tree and apply sensible improvements - run linters, extract reusable/generic modules, relocate shared types and interfaces, hunt for potential bugs, and ensure meaningful test coverage. Use only when explicitly invoked, e.g. /review-uncommitted.
disable-model-invocation: true
metadata:
  author: flex-hiring-and-adjacencies
---

# Review Uncommitted Changes

Review the code that is not yet committed and apply changes that make sense. This skill operates on the current working tree only - do not touch already-committed history.

## Scope

- In scope: unstaged changes, staged changes, and untracked files (the full `git status` working tree).
- Out of scope: committed code, unrelated files, broad refactors of code the diff does not touch. Only refactor committed/untouched code when it is directly required to land a change in the diff (e.g. moving a shared type), and call it out.
- This skill may modify files. It must not commit, push, stage for commit on the user's behalf, or run destructive git commands.

## Workflow

Copy this checklist and track progress as you go:

```
Review Progress:
- [ ] Step 1: Establish the change set
- [ ] Step 2: Run format / linters / type checks (baseline)
- [ ] Step 3: Extract reusable & generic modules
- [ ] Step 4: Relocate shared types, interfaces, and modules
- [ ] Step 5: Hunt for potential bugs
- [ ] Step 6: Verify meaningful test coverage
- [ ] Step 7: Re-run format, lint & tests, then summarize
```

### Step 1: Establish the change set

Identify every repo with uncommitted work (this workspace can contain several). For each, gather the working-tree state:

```bash
git status --short
git diff            # unstaged
git diff --staged   # staged
```

Read the changed and untracked files in full before judging them. Build a mental model of what the change is trying to achieve - improvements must serve that intent.

### Step 2: Run linters / type checks (baseline)

Run the project's linter and type checker to capture the starting state. Discover the right command from `package.json` / repo conventions rather than assuming. Common forms in these repos:

```bash
pnpm format && pnpm lint          # or: pnpm run format && pnpm run lint
pnpm graphql:codegen && pnpm format && pnpm lint   # hirer-graphql-api requires codegen first
```

Record any pre-existing failures separately - your job is to not introduce new ones, and to fix breakages in the changed code. Prefer fixing root causes over `// eslint-disable` suppressions.

### Step 3: Extract reusable & generic modules (priority)

This is the highest-value step - prioritize it.

- Look for logic that is duplicated, or that is general-purpose but currently buried inside a component, route handler, or resolver.
- If a piece of logic could be generic/reusable, extract it into its own well-named module in the appropriate shared location, and update call sites.
- Prefer composing or reusing an existing utility over creating a near-duplicate. Search the repo first.
- Keep extractions tightly scoped to the change set. Do not start a repo-wide refactor.

### Step 4: Relocate shared types, interfaces, and modules

- Move types and interfaces that are shared across files out of feature files into the conventional shared/types location for that repo.
- Co-locate single-use types with their consumer; only promote them when genuinely shared.
- Use `import type` for type-only imports and follow the repo's import ordering conventions.

### Step 5: Hunt for potential bugs

Inspect the changed code for real defects, not style nits:

- Unhandled error / rejection paths and missing `await`.
- Null/undefined and boundary cases (empty arrays, missing optional fields).
- Incorrect or missing input validation (e.g. Zod schemas in these repos).
- Race conditions, incorrect state updates, and stale closures in React hooks.
- Off-by-one, inverted conditions, and wrong comparison operators.
- Leaked secrets or logging of sensitive data.

For each suspected bug, either fix it directly when the correct behavior is clear, or flag it explicitly in the summary when intent is ambiguous.

### Step 6: Verify meaningful test coverage

- Confirm the changed behavior is covered by tests that assert real outcomes - not tests that only assert mocks were called or that re-implement the code under test.
- Add or strengthen tests for new logic, extracted modules, and the bugs found in Step 5 (a failing-then-passing test is ideal for a bug fix).
- Co-locate test files per repo convention (`*.test.ts(x)` next to source).
- Remove redundant or vacuous assertions rather than padding coverage numbers.

### Step 7: Re-run linters & tests, then summarize

Re-run the linter/type checker and the relevant test suite to confirm nothing is broken:

```bash
pnpm format && pnpm lint
pnpm test          # or the scoped test command for the changed files
```

Then report back with:

- **Changes applied** - what you refactored/extracted/relocated/fixed, grouped by repo.
- **Bugs found** - fixed vs. flagged (with file:line references).
- **Tests** - added/updated, and final lint + test status.
- **Suggestions not applied** - anything out of scope or needing the user's decision.

## Guardrails

- Make changes that clearly improve the code; when a change is risky or subjective, flag it instead of applying it.
- Never commit, push, or run destructive git commands. Leave staging decisions to the user.
- Keep every change traceable to the uncommitted work being reviewed.
