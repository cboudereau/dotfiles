---
name: code-quality
description: "Code quality principles for writing clean, maintainable software. Use when reviewing code, refactoring, discussing best practices, improving readability, reducing complexity, or when the user mentions code quality, clean code, SOLID, DRY, or maintainability."
---
# Code Quality

## When to use
- User asks to review, refactor, or improve existing code
- User asks about best practices, readability, or reducing complexity
- User mentions "clean code", "SOLID", "DRY", "maintainability", or "code quality"
- User asks to extract functions, reduce duplication, or improve consistency
- User asks why code fails silently or uses suspicious default values

## Overview

Principles to maintain high code quality across any codebase.

## Rules

1. **Avoid bad trade-offs with default values** - Fail fast, don't mask missing data
2. **Maintain consistency across similar code paths** - Same problem = same solution
3. **Extract reusable functions to modules** - Organize for reuse

## Comments

When adding todo in the code base, use the prefix `//TODO(agt)`.
