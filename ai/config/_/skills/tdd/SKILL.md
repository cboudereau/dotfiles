---
name: tdd
description: "Test Driven Development methodology with acceptance tests and unit tests. Use when the user asks to write tests, add test coverage, implement a feature using TDD, create a failing test first, or when discussing red-green-refactor, test-first development, or test strategy."
---
# Test Driven Development

## When to use
- User asks to write tests, add test coverage, or create a failing test first
- User asks to implement a feature using TDD or test-first development
- User mentions "red-green-refactor", "acceptance test", or "unit test"
- User asks to verify that tests pass before committing
- User asks about test strategy or test structure

## Overview

This project follows Test Driven Development with acceptance tests and unit tests.

## Rules

1. Preserve file encoding
2. Create a failing acceptance test if it does not exist. Add unit tests to test small cases or technical parts.
3. Implement the feature. Always double check before implementing if the function does not exist.
4. Run tests and get feedback
5. Refactor

## Run tests and get feedback

**CRITICAL: Before modifying the code:**

Before committing, always run **ALL** tests in the solution file. If the repo contains multiple .sln files, confirm which sln to use before.

1. **Tests pass with assertions** - Verify tests have meaningful assertions that check expected behavior
2. **Code coverage verified** - Check coverage report for new/modified code
