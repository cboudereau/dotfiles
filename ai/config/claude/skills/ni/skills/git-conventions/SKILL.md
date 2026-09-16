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

A git commit message must start with:

- `feat:` for feature
- `fix:` when fixing the codebase
- `refac:` for refactoring, mostly to prepare or finish a feat
- `chore:` to cleanup the codebase, removing dead code
- `doc:` when touching to .md files or documentation
- `test:` when touching test only

## Change description

When asked to describe a change for review, whatever the platform calls it (merge
request, pull request):

1. Prepare a concise markdown description of the work done.
2. Copy the description content by using clip.exe (windows tool) without introducing complex symbols.
