---
name: plan
description: "Planning skill for complex, multi-session work. Use when the user enters plan mode, asks to plan a feature, design a system, create a workspace, write a design doc, or when the problem requires structured analysis before implementation."
---
# Plan

## When to use
- User enters plan mode or asks to plan before implementing
- Problem is complex, spans multiple sessions, or requires design decisions
- User asks to create a workspace, design doc, ADR, or task breakdown
- User asks to integrate workspace artifacts into durable storage
- User asks to review or amend an existing design or workspace

## Overview

Structured planning workflow using a workspace for drafting and type-scoped durable storage for validated knowledge. Tool-agnostic, markdown-only.

## Structure

the root is `./docs`

```
docs/workspace/<NAME>/               <- temporary draft space (one folder = full context)
  adrs/                         <- draft Architecture Decision Records
  DESIGN.md                     <- draft Design Doc
  TASKS.md                      <- Work Breakdown (lives and dies with workspace)

docs/adrs/                           <- durable ADRs (numbered, cross-cutting)
  0001-short-title.md

docs/designs/                        <- durable Design Docs
  <NAME>.md
```

## Document Order

Strict order — each document depends on the previous:

1. **DESIGN.md** — always first (context, FR, NFR, non-goals, design)
2. **adrs/*.md** — emerge during design (one per hard-to-reverse decision)
3. **TASKS.md** — derived from DESIGN.md (one task per FR/NFR, with acceptance criteria)

## Rules

### Phase 1 — New need

Create the workspace:
```bash
mkdir -p docs/workspace/<NAME>/adrs
```

### Phase 2 — Write DESIGN.md

DESIGN.md is the entry point. It must be written before anything else.

Each FR and NFR gets an anchor for cross-referencing:

```markdown
# <NAME> — Design Doc

## Context
Why this work exists.

## Functional Requirements

### <a id="fr1"></a>FR1 — Short title
Description of what the system must do.

### <a id="fr2"></a>FR2 — Short title
Description.

## Non-Functional Requirements

### <a id="nfr1"></a>NFR1 — Short title
Constraint: performance, security, availability, compliance.

## Non-goals
What this design explicitly does not address.

## Rabbit holes
Areas of known uncertainty where unbounded time could be lost.
For each: state what to avoid and the constraint that caps exploration.

## Design
Architecture, C4 diagrams (levels 1-2 via Mermaid), data model, interfaces.

Decisions:
- [Decision title](./adrs/decision-name.md)

## Cross-cutting Concerns
Observability, migration, rollback.
```

### Phase 3 — Write ADRs

An ADR records any decision worth explaining. ADRs emerge during design and continue to emerge during implementation as new knowledge surfaces.

**What warrants an ADR:**
- Hard-to-reverse decisions (database choice, API style, protocol)
- Trade-offs where both options have merit (consistency vs availability, simplicity vs performance)
- Constraints inherited from external systems or business rules
- Rejected alternatives that someone might propose again later
- Conventions chosen among valid options (naming, error handling strategy, logging format)

ADRs link back to the requirements they address:

```markdown
---
status: draft
---
# Decision title

Addresses: [FR2](../DESIGN.md#fr2), [NFR1](../DESIGN.md#nfr1)

## Problem
What needs to be decided and why.

## Options
| Option | Pros | Cons |
|---|---|---|
| Option A | ... | ... |
| Option B | ... | ... |

## Decision
Which option and why.

## Consequences
What becomes easier or harder.
```

ADR status lifecycle: `draft` -> `accepted` -> `superseded-by <ref>`

### Phase 4 — Write TASKS.md

Each task is derived from a FR or NFR. Each task has a goal and acceptance criteria (XP acceptance tests: written before implementation, pass/fail, define "done").

Task references are clickable links to DESIGN.md anchors and relevant ADRs:

```markdown
# <NAME> — Tasks

Design: [DESIGN.md](./DESIGN.md)

## Tasks

### 1. Task title ([FR1](./DESIGN.md#fr1), [NFR2](./DESIGN.md#nfr2))
**Goal**: Why this task exists (one sentence).
**Uncertainty**: `uphill` | `downhill`
**Acceptance criteria**:
- [ ] Criterion 1
- [ ] Criterion 2
**Decisions**: [Relevant ADR](./adrs/decision-name.md)

## Quality gates
- [ ] Acceptance criteria: all green above
- [ ] Code review: implementation matches [DESIGN.md](./DESIGN.md) intent
- [ ] Code quality: no new complexity, clean types, no duplication
- [ ] Security review: OWASP check, dependency audit, no secrets exposed
- [ ] Observability: relevant metrics identified, dashboards/alerts in place, logging covers key paths
- [ ] Performance: NFR targets met, no regressions on critical paths, load tested if applicable
```

**Uncertainty tracking** (inspired by Shape Up's hill chart):
- `uphill` = figuring it out — the problem or approach is not yet understood. May trigger new ADRs or design changes.
- `downhill` = making it happen — the approach is clear, only execution remains.
- A task stuck `uphill` is a signal: either the task needs splitting, a rabbit hole was hit (update DESIGN.md), or a decision needs an ADR.
- Update uncertainty as work progresses. All tasks must be `downhill` before quality gates.

Task granularity: each task should be independently completable and testable (INVEST: Independent, Negotiable, Valuable, Estimable, Small, Testable). Prefer vertical slicing — cut through all layers for a thin but complete feature.

### Phase 5 — Implement

Work through TASKS.md. Check acceptance criteria after each task.

**Discovery feedback loop**: implementation reveals things that design could not anticipate. When this happens:

1. **New decision needed** — create a new ADR in the workspace (`adrs/`), link it from DESIGN.md and the relevant task
2. **Requirement change** — update FR/NFR in DESIGN.md, adjust affected tasks and acceptance criteria in TASKS.md
3. **New requirement discovered** — add it to DESIGN.md with a new anchor, derive a new task in TASKS.md
4. **Design assumption invalidated** — update DESIGN.md, supersede affected ADRs with new ones
5. **New trade-off identified** — record as ADR even if the choice seems obvious now (it won't be obvious in 6 months)
6. **New knowledge about the codebase or situation** — update DESIGN.md Context section with what was learned (existing behavior, hidden constraints, undocumented dependencies, data shape, performance characteristics). This knowledge informs current and future decisions.
7. **Rabbit hole encountered** — update DESIGN.md Rabbit holes section, cap the exploration with a constraint, split or simplify the affected task

The workspace is a living draft space. Documents are never frozen during implementation — they reflect current understanding at all times.

### Phase 6 — Quality gates

Before integration, all quality gates must pass:
1. All acceptance criteria are green
2. Code review completed
3. Code quality verified
4. Security review passed
5. Observability verified — relevant metrics identified, dashboards/alerts in place
6. Performance verified — NFR targets met, no regressions on critical paths

### Phase 7 — Integrate

Move validated artifacts to durable storage:
1. Move ADRs to `docs/adrs/` — assign numbers (next available `NNNN`), set status to `accepted`
2. Move DESIGN.md to `docs/designs/<NAME>.md`
3. Delete `docs/workspace/<NAME>/` — TASKS.md dies with it, git history preserves it

## Cross-referencing

**Every identifier, acronym, or reference used in any document must be a clickable link to its definition.** This applies to:
- Requirement identifiers (FR1, NFR1)
- ADR references
- Design doc references
- Technology names when an ADR justifies the choice
- External references (specs, standards, APIs)
- Task references when mentioned from another document
- Any acronym or term defined elsewhere in the workspace

Traceability is only real if a reviewer can follow any reference without searching. If an identifier appears and is not a link, it is a defect.

**How to link**:
- Define anchors at the source: `<a id="identifier"></a>` or use markdown headings (auto-anchored)
- Link at the usage site: `[FR1](./DESIGN.md#fr1)`, `[ECB provider](./adrs/ecb-exchange-rates.md)`
- ADRs link back: `Addresses: [FR2](../DESIGN.md#fr2)`
- External references: inline link `[ISO 4217](https://en.wikipedia.org/wiki/ISO_4217)`

Link directions:
```
TASKS.md --> DESIGN.md --> ADRs
                ^            |
                +------------+
              (Addresses: FRx, NFRx)
```

## Amending existing work

To amend or extend work that was already integrated:
1. Create a new `docs/workspace/<NAME-v2>/`
2. Reference the existing design: `Amends: [designs/<NAME>.md](../../designs/<NAME>.md)`
3. Follow the same workflow (DESIGN.md -> ADRs -> TASKS.md -> quality gates -> integrate)
4. Superseded ADRs get status `superseded-by docs/adrs/NNNN-new-decision.md`
