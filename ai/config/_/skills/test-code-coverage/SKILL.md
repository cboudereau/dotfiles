---
name: test-code-coverage
description: "Verify and improve code coverage using Cobertura reports. Use when the user asks about code coverage, uncovered code, coverage reports, or when checking if new or modified code is properly tested. Also use after writing tests to verify coverage targets are met."
---
# Verify code coverage for test after

## When to use
- User asks about code coverage, uncovered code, or coverage reports
- User asks to check if new or modified code is properly tested
- User wants to verify coverage targets after writing tests
- User mentions "cobertura", "coverage", or "uncovered lines"
- User asks to improve test coverage on a specific area of code

## Overview

Unit tests can be created either before (TDD) or after (Test after). The first one is easy to check due to the correlation between a small change and the fact that the test pass (was normally failing before) as opposed to test after where it is non obvious which part of the code is really covered.

## Code coverage
Use cobertura code coverage which has a good support.
1. Build and run test with cobertura with the appropriate skill
2. Spot non covered code through cobertura code coverage
3. Write test to cover it
4. Rerun the test and inspect the cobertura by analyzing if the goal is met.