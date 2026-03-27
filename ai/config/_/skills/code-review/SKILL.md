---
name: code-review
description: "Code review principles and checklist for reviewing any codebase regardless of language. Use when the user asks to review code, perform a code review, assess a pull request, or evaluate code quality across design, tests, performance, security, and correctness."
---
# Code Review

> Based on "What to look for in a code review" by Trisha Gee (Java Champion, JetBrains).

## When to use

- User asks to review code or a pull request
- User asks for a code review checklist
- User wants to assess the quality of a change
- User mentions design, readability, test coverage, security, or correctness concerns

## Overview

A structured, language-agnostic checklist to guide thorough code reviews. Reviews should reduce cognitive load, catch correctness issues, and share knowledge — not just find bugs.

## Rules

### Design

1. **Architecture fit** — Does the change align with the overall architecture and existing conventions?
2. **SOLID** — Are Single Responsibility, Open/Closed, Liskov, Interface Segregation, and Dependency Inversion respected?
3. **DDD** — Are domain concepts clearly named and properly modelled?
4. **YAGNI / KISS** — No speculative generality; prefer the simplest solution that works
5. **Code reuse** — Is there a refactoring or extraction opportunity to avoid duplication?

### Readability & Maintainability

6. **Understandability** — Can a new reader understand the intent without context?
7. **Naming** — Are names precise, consistent, and self-documenting?
8. **Happy path vs exceptional cases** — Are both paths handled explicitly and clearly?
9. **Configuration vs hard-coded values** — No magic constants; prefer named config

### Tests

10. **Coverage of new code** — Are all new branches and edge cases covered?
11. **Test intent** — Does each test name and assertion communicate *why*, not just *what*?
12. **Tests are code** — Apply the same quality rules (naming, readability, no duplication)
13. **Granularity** — Right level: unit > integration > end-to-end; avoid testing implementation details
14. **Edge cases** — Cardinality (empty, single, many), nullability, boundary values, error paths
15. **Limitations** — Are test limitations intentional and documented, or accidental gaps?
16. **Performance & security tests** — Are they needed? Are they present?
17. **Pair review option** — Reviewers can write missing tests as part of the review

### Performance

18. **Requirements** — Does the implementation meet the stated performance requirements?
19. **Readability vs performance trade-off** — Only optimise when measurements justify it
20. **Network cost** — Are batching and call counts considered?
21. **Resource management** — Are connections, streams, and handles properly closed?
22. **Memory leaks** — Are data lifecycle and collection bounds controlled?
23. **Locks & race conditions** — Are shared resources properly protected?
24. **Concurrency vs parallelism** — Is the right model applied?
25. **Pool configuration** — Use safe defaults; only tune with evidence

### Data Structures

26. **Right choice** — Is the data structure appropriate for the access pattern and complexity (Big-O)?
27. **Pitfalls** — Watch for lazy evaluation traps, infinite streams, or iterator invalidation
28. **Optionality** — Is absence of a value modelled explicitly (Option/Maybe/Optional) rather than null?

### Security

29. **Automated checks** — Are dependency scanners (e.g. Dependabot) and SAST tools in CI?
30. **Dependency surface** — Are new dependencies justified and minimal?
31. **Regulatory requirements** — Does the change touch data subject to compliance rules (GDPR, PCI, …)?

### Correctness

32. **Wrong data structure** — Could the structure cause subtle bugs (e.g. set vs list, map ordering)?
33. **Race conditions** — Is concurrent access safe?
34. **Caching** — Are cache invalidation and staleness handled correctly?

### Cross-cutting Concerns

35. **Documentation impact** — Does the change require updating docs, ADRs, or READMEs?
36. **UI / error messages** — Are user-visible messages clear, actionable, and tested?
37. **Automated vs human review split** — Delegate formatting/style to linters; focus human review on design and logic

## Culture

- Share tooling: IDE configs, linter rules, and CI checks should be committed and consistent
- Reviewers should ask "Have you thought about…?" for security, edge cases, and docs — not just critique
- Prefer collaborative tone; a review is a knowledge-sharing session, not an audit
