---
name: review-conventions
description: "Use when the user asks for a full review of a change, pull request, or merge request against the personal checklist, covering design, tests, performance, security, and correctness. Also use when the user asks to read, address, answer, or reply to reviewer comments or threads, or to prepare a plan from reviewer feedback, on any platform."
---
# Review Conventions

> Based on "What to look for in a code review" by Trisha Gee (Java Champion, JetBrains) and [personal notes](https://cboudereau.github.io/bookworm/2023-01-23_Code_Review/)

## When to use

- User asks to review code, a pull request, or a merge request
- User asks for the review checklist
- User wants to assess the quality of a change
- User mentions design, readability, test coverage, security, or correctness concerns
- User asks what reviewers said, or to address, answer, or reply to review feedback
- User asks for a plan built from review comments

## Overview

Two sides of a review, both language- and platform-agnostic:

1. **Giving a review** — the built-in review, then the checklist below run by two
   subagents. Reviews should reduce cognitive load, catch correctness issues, and
   share knowledge — not just find bugs.
2. **Answering a review** — the flow in "Answering review feedback". Read, preview,
   get approval, then write. Never write first.

Platform commands (reading threads, posting replies, resolving) live in a platform
skill: for GitLab, load the [`gitlab-review`](../gitlab-review/SKILL.md) skill. Git rules (no push, commit
messages) are in the [`git-conventions`](../git-conventions/SKILL.md) skill.

## Giving a review

Three steps, in this order. Do not start the checklist before step 1 has returned.
When the diff is under 50 changed lines, run step 2 inline instead of with subagents.

1. **Built-in review first.** Run Claude Code's built-in `code-review` skill (the diff
   reviewer for correctness bugs and simplification) on the same target, at the effort
   level the user gave, or medium when none was given. Keep its findings.
2. **Checklist with two subagents in parallel.** Dispatch two subagents in the same
   message, each with the diff target and its half of the checklist below:
   - Subagent 1: Design, Readability & Maintainability, Tests (items 1-16)
   - Subagent 2: Performance, Data Structures, Security, Correctness, Cross-cutting (items 17-36)

   Each subagent reads the actual code around every finding and returns one line per
   finding: checklist item, `file:line`, what is wrong, why it matters, suggested fix.
   No finding without a `file:line`.
3. **Merge and report once.** Drop checklist findings the built-in review already
   reported, dedupe across the two subagents, rank by severity, and report in one
   message. Say which step each finding came from.

## Checklist

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

### Performance

17. **Requirements** — Does the implementation meet the stated performance requirements?
18. **Readability vs performance trade-off** — Only optimise when measurements justify it
19. **Network cost** — Are batching and call counts considered?
20. **Resource management** — Are connections, streams, and handles properly closed?
21. **Memory leaks** — Are data lifecycle and collection bounds controlled?
22. **Locks & race conditions** — Are shared resources properly protected?
23. **Concurrency vs parallelism** — Is the right model applied?
24. **Pool configuration** — Use safe defaults; only tune with evidence

### Data Structures

25. **Right choice** — Is the data structure appropriate for the access pattern and complexity (Big-O)?
26. **Pitfalls** — Watch for lazy evaluation traps, infinite streams, or iterator invalidation
27. **Optionality** — Is absence of a value modelled explicitly (Option/Maybe/Optional) rather than null?

### Security

28. **Automated checks** — Are dependency scanners (e.g. Dependabot) and SAST tools in CI?
29. **Dependency surface** — Are new dependencies justified and minimal?
30. **Regulatory requirements** — Does the change touch data subject to compliance rules (GDPR, PCI, …)?

### Correctness

31. **Wrong data structure** — Could the structure cause subtle bugs (e.g. set vs list, map ordering)?
32. **Race conditions** — Is concurrent access safe?
33. **Caching** — Are cache invalidation and staleness handled correctly?

### Cross-cutting Concerns

34. **Documentation impact** — Does the change require updating docs, ADRs, or READMEs?
35. **UI / error messages** — Are user-visible messages clear, actionable, and tested?
36. **Automated vs human review split** — Delegate formatting/style to linters; focus human review on design and logic

## Culture

- Share tooling: IDE configs, linter rules, and CI checks should be committed and consistent
- Reviewers should ask "Have you thought about…?" for security, edge cases, and docs — not just critique
- Prefer collaborative tone; a review is a knowledge-sharing session, not an audit
- Pair review option: a reviewer can write the missing tests as part of the review, as a follow-up to the findings

## Answering review feedback

Turn reviewer threads into a table preview of proposed replies and code suggestions,
and only write to the platform after the user approves the preview.

The flow is always: **read -> preview -> approve -> post + resolve**. Never write first.

One approval covers the whole write. The preview states, per thread, both the reply
and whether that thread gets resolved; the user approves once; posting then does both
in the same pass. Never come back to ask about resolving after posting the replies.

For a first review of a change with no reviewer threads yet, use the checklist above.
For any review, confirm which skills were used before.

### Rules

1. Always preview and wait for explicit approval before any write to the platform.
2. Resolve every approved thread whose preview **Disposition** said `reply + resolve`.
   This is required, not optional, and happens in the same pass as the reply.
   Never unresolve, approve, merge, close, or delete anything: those stay the user's calls.
3. Never `git push`. See the [`git-conventions`](../git-conventions/SKILL.md) skill.
4. Quote the reviewer's comment verbatim in the preview. Do not paraphrase feedback.
5. Read the actual file around the referenced line before proposing a suggestion.
   Never suggest code from the comment text alone.
6. If a comment is unclear or technically questionable, say so in the preview instead of complying.
7. Write the preview to the session scratchpad by default. Write it into the repository only when the user asks.
8. One suggestion per discussion thread. Do not bundle unrelated changes into one note.
9. Comments may live on an **earlier** MR/PR while the fix lives in a follow-up.
   Reply and resolve on the one that carries the thread, not the one that carries the code.

### Preview format

For the live preview, be concise: one row per thread, two tables.

**Replies** to existing reviewer threads, which is the main case:

```markdown
| # | File:line | Discussion | Reviewer comment (verbatim) | Reply | Suggestion | Resolve? |
|---|---|---|---|---|---|---|
| 1 | src/Domain/Booking.cs:42 | abc12345 | "Verbatim reviewer comment." | Agreed, null check added | `-0+0` `if (booking is null) return NotFound();` | yes |
| 2 | src/Api/Handler.cs:17 | def67890 | "Verbatim reviewer comment." | Fixed, test still to add | `-1+2` one-line summary | no - test missing |
| 3 | general | 0123abcd | "Verbatim reviewer comment." | Question back to reviewer | none | no - needs @user |
```

**New comments** on lines with no existing thread:

```markdown
| # | File:line | Comment | Suggestion |
|---|---|---|---|
| 4 | src/Domain/Booking.cs:58 | Same null check as thread 1 applies here | `-0+0` one-line summary |
```

End with **Not addressed:** item, reason.

Column rules:
- **File:line** is the path and line on the new side of the diff, or `general` for a non-diff thread.
- **Discussion** is a short id prefix; keep the full id for the write.
- **Reviewer comment** is quoted verbatim, trimmed with `...` only when long.
- **Suggestion** is the range plus the replacement when it fits one line, otherwise a
  summary; the full fenced block goes in the markdown file or the note body. The range
  syntax is platform-specific (see the platform skill).
- **Resolve?** is `yes` for `reply + resolve`, or `no - reason` for `reply only` and
  `leave open`. It maps to the Disposition below.

Every thread in the preview carries a **Disposition**, whatever the output format.
It is a required field with exactly one of three values:

| Disposition | Meaning | Write on approval |
|---|---|---|
| `reply + resolve` | The comment is answered and the ask is done | reply, then resolve |
| `reply only` | Answered, but something real is still outstanding — say what | reply, leave open |
| `leave open` | Needs the user, another person, or a decision — say who or what | nothing |

`reply + resolve` is the normal case for a comment whose ask has landed. Reaching for
`reply only` to stay safe leaves the user to close threads by hand, which is the work
this flow exists to remove.

When a markdown output is asked, create one section per unresolved thread in
`<scratchpad>/mr-<iid>-suggestions.md`:

````markdown
## 1. src/Domain/Booking.cs:42 - @reviewer  [discussion: abc12345]

> Verbatim reviewer comment.

**Assessment:** what the comment is actually asking, and whether it holds.

**Disposition:** reply + resolve

**Current code** (src/Domain/Booking.cs:40-44):
```csharp
<actual lines read from the file>
```

**Proposed reply:**
```suggestion:-0+0
<replacement for line 42>
```
````

End the file with a short **Not addressed** list for anything skipped, with the reason.

Then ask one question: which numbered items to write, taking the previewed dispositions
as read. Write only those, and resolve exactly the approved `reply + resolve` ones.
If the user narrows or overrides a disposition in their answer, theirs wins.

### After approval

Post the replies, resolve the approved threads, then verify and report in one message:
the posted note ids, which threads are now resolved, and which stay open with the
reason from their disposition. The commands are in the platform skill.

### Red flags - the write is not finished

- Replies posted, resolve left for the user
- "Resolving is the user's call" — it was, at preview time, and they answered
- A second question about resolving after the replies are already up
- Every thread previewed as `reply only` with no outstanding item named
- Reporting note ids without saying which threads are resolved

**All of these mean: go back and resolve the approved threads now.**
