---
name: tdd
description: "Use when writing tests, adding test coverage, implementing a feature or fix test-first, creating a failing test before code, or discussing red-green-refactor, acceptance tests, unit tests, or test strategy."
---
# Test Driven Development

## When to use
- **Any code change** - every fix, feature, or refactor must have a corresponding test
- User asks to write tests, add test coverage, or create a failing test first
- User asks to implement a feature using TDD or test-first development
- User mentions "red-green-refactor", "acceptance test", or "unit test"
- User asks to verify that tests pass before committing

## Overview

Test Driven Development with acceptance tests and unit tests. The test comes first
and must fail before the implementation exists. That failure is the proof the test
is worth anything.

## Rules

1. Preserve file encoding
2. Analyse the test setup: which framework is actually used, how to build, how to run tests, how to read coverage (see the build skill for the stack in [`software-engineer`](../software-engineer/SKILL.md))
3. Create a failing acceptance test if it does not exist. Add unit tests for small cases or technical parts.
4. Watch the test fail for the expected reason before writing any implementation
5. Implement the feature. Check first that the function does not already exist.
6. Run tests and get feedback
7. Refactor

## Discipline

Implementation written before its test is deleted and restarted from the test. Not
kept as reference, not adapted while the test is written. Deleted.

A test that passes on first run proves nothing. Make it fail first, or find out why it
cannot fail and fix the test.

## Run tests and get feedback

Before committing, always run **all** tests in the solution or workspace. If the repo
contains several solution files, confirm which one to use before.

1. **Tests pass with assertions** - every test asserts expected behaviour, not just "no exception"
2. **Code coverage verified** - check the report for new or modified code (see `software-engineer` testing strategy)
