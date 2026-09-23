---
name: git-conventions
description: "Use when the user asks to commit, stage, branch, diff, write a commit message, or perform any git operation, and when the user asks to describe or summarise a change for review, such as a merge request or pull request description (MR, PR). Also use when discussing version control workflows or git safety."
---
# Git Conventions

## When to use
- User asks to commit, stage, diff, or perform any git operation
- User asks to create a branch or write a commit message
- User asks to check differences with a previous version
- User asks to describe or summarise a change for review (merge request, pull request)
- User mentions "git", "commit", "branch", "diff", "MR", "PR", or "version control"
- User is ready to commit after completing a task

## Overview

Rules for safe and consistent git usage, from the commit to the change description.

Platform-specific tooling lives in its own skill: for GitLab (`glab`), see the
[`gitlab-review`](../gitlab-review/SKILL.md) skill. Reviewing code or answering review feedback is the
[`review-conventions`](../review-conventions/SKILL.md) skill.

## Rules
Before committing, the code must compile and tests must be successful without failing / ignored tests.

## Command rules

1. Never use the command `push`.
2. Never use the option `force` `--force`.
3. Never amend commit to modify files, prefer adding more commits (fix commit) and explain the error/reason.
4. Do not hesitate to use git when checking differences with the previous version.
5. A task should be committed when tests pass (with assertions) and code coverage is verified.

## Commit message

Terse and exact. Why over what: the diff already says what changed.

### Subject

`<type>(<scope>): <imperative summary>`, scope optional.

Types:

- `feat:` for feature
- `fix:` when fixing the codebase
- `refac:` for refactoring, mostly to prepare or finish a feat
- `chore:` to cleanup the codebase, removing dead code
- `doc:` when touching to .md files or documentation
- `test:` when touching test only
- `perf:` for a measured performance change
- `build:` or `ci:` for build tooling or pipeline changes
- `revert:` when reverting a prior commit

Rules: imperative mood ("add", "fix", "remove", never "added" or "adds"), 50 characters
when possible and 72 at most, no trailing period, no restating the file name when the
scope already says it. Match the project convention for capitalisation after the colon.

### Body

Skip it when the subject is self-explanatory. Add one only for a non-obvious why, a
breaking change, migration notes, or linked issues. Wrap at 72 characters, bullets with
`-`, issue references last (`Closes #42`, `Refs #17`).

Always add a body for: breaking changes, security fixes, data migrations, and reverts.
Future debuggers need the context.

Never in a commit message: "this commit does", "I", "we", "now", "currently", "as
requested by" (use a `Co-authored-by` trailer), AI attribution, emoji unless the project
convention requires it.

Examples:

- Not: `feat: add a new endpoint to get user profile information from the database`
- Yes:
  ```
  feat(api): add GET /users/:id/profile

  Mobile client needs profile data without the full user payload
  to reduce LTE bandwidth on cold-launch screens.

  Closes #128
  ```
- Breaking change:
  ```
  feat(api)!: rename /v1/orders to /v1/checkout

  BREAKING CHANGE: clients on /v1/orders must migrate to /v1/checkout
  before 2026-06-01. Old route returns 410 after that date.
  ```

Adapted from the MIT-licensed caveman-commit skill by Julius Brussee.

## Change description

When asked to describe a change for review, whatever the platform calls it (merge
request, pull request):

1. Prepare a concise markdown description of the work done.
2. Copy the description content by using clip.exe (windows tool) without introducing complex symbols.
