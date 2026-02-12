---
name: git-conventions
description: Git command rules, commit message conventions, and safe usage patterns
---
# Git Conventions

## Overview

Rules for safe and consistent git usage.

## Command rules

1. Never use the command `push`.
2. Never use the option `force` `--force`.
3. Never amend commit to modify files, prefer adding more commits (fix commit) and explain the error/reason.
4. Before running a new git command, ask to add it in the allow list.
5. Do not hesitate to use git when checking differences with the previous version.
6. A task should be committed when tests pass (with assertions) and code coverage is verified.

## Commit message

A git commit message must start with:

- `feat(agt):` for feature
- `fix(agt):` when fixing the codebase
- `refac(agt):` for refactoring, mostly to prepare or finish a feat
- `chore(agt):` to cleanup the codebase, removing dead code
- `doc(agt):` when touching to .md files or documentation
- `test(agt):` when touching test only

## TODO markers

When adding todo in the code base, use the prefix `//TODO(agt)`.
