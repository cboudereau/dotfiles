---
name: test-code-coverage
description: "Verify and improve code coverage using Cobertura reports. Use when the user asks about code coverage, uncovered code, coverage reports, or when checking if new or modified code is properly tested. Also use after writing tests to verify coverage targets are met."
---
# Verify code coverage for test after
## Overview

Unit tests can be either before (TDD) or after (Test after). The first one is easy to check due to the corelation between a small change and the fact that the test pass (was normally failing before) as opposite to test after where it is non obvious which part of the code is really covered.

## Code coverage
Use cobertura code coverage which has a good support.
1. Build and run test with cobertura with the appropriate skill
2. Spot non covered code through cobertura code coverage
3. Write test to cover it
4. Rerun the test and inspect the cobertura and analyze if the goal is met.