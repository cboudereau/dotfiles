# Study: Planning Methodologies — State of the Art vs Proposed Approach

## Purpose

Compare established software planning methodologies against the approach defined in [SKILL_PLAN.md](../../../SKILL_PLAN.md) to identify overlap, gaps, and whether we are reinventing the wheel.

## Methodologies Surveyed

### 1. Architecture Decision Records (ADRs)

**Origin**: Michael Nygard, 2011. Lightweight, immutable records for architecturally significant decisions.

**Structure**: Title, Status (Proposed/Accepted/Deprecated/Superseded), Context, Decision, Consequences.

**Conventions**: `doc/adr/NNNN-short-title.md`. Tooling: adr-tools (Nat Pryce), log4brains, MADR (extended template with alternatives/pros/cons).

**When to use**: Hard-to-reverse decisions — database choice, API style, auth protocol, deployment platform.

**Strengths**: Low ceremony, lives with the code, builds institutional memory.
**Weaknesses**: Can go stale; limited for decisions requiring deep design exploration.

### 2. RFCs (Request for Comments)

**Origin**: IETF tradition, adapted by Rust (rust-lang/rfcs), Oxide (RFDs), Uber, Google.

**Structure**: Summary, Motivation, Detailed Design, Drawbacks, Alternatives, Unresolved Questions. Lifecycle: Draft → Under Review → Accepted/Rejected → Implemented → Superseded.

**When to use**: Broad design changes that affect multiple teams or have org-wide impact.

**Strengths**: Forces rigorous upfront thinking, collects cross-team feedback.
**Weaknesses**: Higher overhead, can slow velocity, risk of "design by committee."

### 3. Google-style Design Docs

**Structure**: Context/Background, Goals/Non-goals, Design, Alternatives Considered, Cross-cutting Concerns (security, privacy, observability, migration, rollback).

**Adaptations**: Stripe adds "Operational Readiness"; Figma adds "User Impact" as first-class section.

**Strengths**: Forces clarity before code, captures rationale, scales across large orgs.
**Weaknesses**: Can become bureaucratic, docs rot without maintenance discipline.

### 4. C4 Model (Simon Brown)

**Four levels**:
1. **System Context** — system as a box with users and external systems
2. **Container** — deployable units (apps, databases, queues)
3. **Component** — structural blocks within a container (services, repos, controllers)
4. **Code** — class-level (recommended only when auto-generated)

**Tooling**: Structurizr DSL, C4-PlantUML, Mermaid extensions. Diagrams-as-code in version control.

**Strengths**: Consistent vocabulary, hierarchical zoom avoids "one diagram to rule them all."
**Weaknesses**: Purely structural (no behavioral views), Level 3-4 require maintenance.

### 5. Shape Up (Basecamp/37signals)

**Key concepts**: Shaping (pitch at right abstraction), Betting Table (no backlog), Hill Charts (uncertainty tracking), Appetite vs Estimate ("how much time is this worth?").

**Pitch structure**: Problem, Appetite (2 or 6 weeks), Solution sketch, Rabbit holes, No-gos.

**Strengths**: Reduces spec bloat, surfaces risk via hill charts, gives teams autonomy.
**Weaknesses**: Requires strong shaping skills, less suited to compliance-heavy contexts.

### 6. System Design Primer (donnemartin)

**Four-step framework**:
1. Use cases, constraints, assumptions
2. High-level design (block diagram)
3. Component design (APIs, data model, interfaces)
4. Scale the design (bottlenecks, caching, sharding, async)

**Relevance**: Provides a structured top-down decomposition that maps well to planning artifacts.

### 7. DIATAXIS Framework (Daniele Procida)

**Four documentation types** (2 axes: study/work × practical/theoretical):

|  | Study | Work |
|---|---|---|
| **Practical** | Tutorial | How-to Guide |
| **Theoretical** | Explanation | Reference |

**Key insight**: Mixing types in one document serves no audience well. Planning artifacts should cleanly separate explanation (ADRs, rationale) from reference (API specs, schemas) from how-to (tasks, procedures).

### 8. Acceptance Criteria and Quality Gates

Acceptance criteria define **when work is done**. Quality gates define **when work is ready to promote**.

**Acceptance criteria** (inline in tasks):

**Goal + Acceptance criteria** — directly from XP (Kent Beck, 1999). In XP, acceptance tests are customer-written tests that verify a story is done: written before implementation, pass/fail, owned by the person who defines the need. No prescribed syntax — just "prove it works."

Format at the planning level: **Goal** (why this task exists) + **Acceptance criteria** (pass/fail checklist).

Note: Given/When/Then (BDD, Dan North) was built on top of XP's acceptance tests, adding a specific syntax. That syntax is useful at the test-code level but adds ceremony at the planning level without proportional clarity.

Example:
```markdown
### 1. Add currency column to contracts table (FR3, NFR2)
**Goal**: Contracts carry a currency code.
**Acceptance criteria**:
- Currency column exists with ISO 4217 codes (EUR, GBP, USD)
- Existing contracts default to EUR after migration
- 4 decimal precision on amounts (NFR2)
```

**Quality gates** (applied after acceptance, before promotion):
1. **Code review** — Peer review of the implementation against design intent. Ensures the code matches what was decided in the Design Doc and ADRs.
2. **Code quality** — Static analysis, complexity metrics, maintainability. Can be automated (linters, sonar) or manual.
3. **Security review** — OWASP Top 10 check, dependency audit, threat modeling against the design. Should reference the Design Doc's cross-cutting concerns section.

**Key principles**:
- Acceptance criteria are written at design time (in TASKS), not after implementation. They are the contract between the design and the implementation.
- Quality gates are the toll before promotion — no artifact moves from workspace to durable storage without passing them.

### 9. Cross-referencing

Every identifier (FR1, NFR2, ADR name) used in any document must be a clickable link to its definition. Traceability is only real if a reviewer can follow references without searching.

**Rules**:
- Each FR/NFR in DESIGN.md gets an anchor: `<a id="fr1"></a>`
- TASKS.md links requirement references to DESIGN.md: `[FR1](./DESIGN.md#fr1)`
- TASKS.md links relevant ADRs: `[ECB as provider](./adrs/ecb-exchange-rates.md)`
- DESIGN.md links to ADRs in the Design section
- ADRs link back to the requirements they address: `Addresses: [FR2](../DESIGN.md#fr2)`

**Link directions**:
```
TASKS.md ──→ DESIGN.md ──→ ADRs
                ↑               │
                └───────────────┘
                (Addresses: FRx, NFRx)
```

### 10. Task Decomposition

- **Vertical slicing** — Cut through all layers for thin but complete features (Jeff Patton, "User Story Mapping")
- **Story mapping** — Activities left-to-right, priority top-to-bottom; top row = walking skeleton
- **Work Breakdown Structure** — Epic > Feature > Story > Task; leaf ≤ 4 hours

---

## Comparison: Proposed Approach vs State of the Art

### Proposed Structure — Revised with Industry Vocabulary

Original (SKILL_PLAN.md) → Revised:

| Original | Revised | Industry Term |
|---|---|---|
| `specs/<NAME>/` | `workspace/<NAME>/` | Draft space (no industry equivalent — see RFC vs RFD analysis below) |
| `studies/<NAME>.md` | `adrs/<NAME>.md` | Architecture Decision Record (Nygard, MADR) |
| `SYSTEM_DESIGN.md` | `DESIGN.md` | Design Doc (Google) — contains FR, NFR, non-goals |
| `TASKS.md` | `TASKS.md` | Work Breakdown — workspace-only, not promoted |

### Why Not RFC or RFD?

| | RFC (Request for Comments) | RFD (Request for Discussion) | Workspace (chosen) |
|---|---|---|---|
| Origin | IETF, Rust, Google | Oxide, Joyent | — |
| Format | Single document = one proposal | Single document = one topic | Folder with decomposed artifacts |
| Tone | "Approve or reject my proposal" | "Let's discuss this together" | "Draft space, iterate freely" |
| Lifecycle | Draft → Review → Accepted/Rejected | Prediscussion → Discussion → Published | Draft → Quality gates → Integrate → Delete |
| Decision tracking | Embedded in the document | Embedded in the document | Separated into ADRs |
| Design | Embedded in the document | Embedded in the document | Separated into DESIGN.md |

**Neither RFC nor RFD fits.** Both are single-document formats that bundle problem, design, alternatives, and decision into one file. This approach decomposes those concerns into separate artifacts (ADRs, DESIGN.md, TASKS.md). The workspace folder is not an RFC — it's a temporary container that **produces** artifacts equivalent to what an RFC would contain.

### Where FR and NFR Live

Functional and Non-Functional Requirements live in **DESIGN.md**, which maps to the Google Design Doc structure:

```markdown
# <NAME> — Design Doc

## Context
Why this work exists.

## Functional Requirements (FR)
What the system must do.

## Non-Functional Requirements (NFR)
Constraints: performance, security, availability, compliance.

## Non-goals
What this design explicitly does not address.

## Design
Architecture, C4 diagrams (levels 1-2), data model, interfaces.
References ADRs for decision rationale.

## Cross-cutting Concerns
Observability, migration, rollback.
```

FR/NFR flow through the system:
- **DESIGN.md** defines them (workspace, then promoted to `designs/`)
- **TASKS.md** derives tasks from them (with acceptance criteria that verify each FR/NFR)
- **ADRs** justify decisions made to satisfy them

```
workspace/<NAME>/               ← temporary draft space (one folder = full context)
  adrs/                         ← draft ADRs
  DESIGN.md                     ← draft Design Doc
  TASKS.md                      ← Work Breakdown (lives and dies with workspace)

adrs/                           ← durable ADRs (numbered, cross-cutting)
  0001-short-title.md

designs/                        ← durable Design Docs
  <NAME>.md
```

Tasks are not promoted. Once done, a completed task file has no durable value — decisions are in `adrs/`, design is in `designs/`, history is in `git log`. Tasks are a workspace-only artifact.

### Mapping to Established Patterns

| Revised Artifact | Closest Established Pattern | Coverage |
|---|---|---|
| `adrs/0001-*.md` | ADR (Nygard) + MADR (Kopp) | **Direct match.** Uses established ADR structure: Context, Decision, Consequences. Numbered chronologically. Cross-cutting decisions are naturally discoverable by scanning `adrs/`. |
| `designs/<NAME>.md` | Google Design Doc + C4 levels 1-2 + System Design Primer steps 1-3 | **Strong overlap.** Design doc with explicit FR/NFR and non-goals. References ADRs by number, keeping the doc focused on design rather than decision rationale. |
| `workspace/<NAME>/TASKS.md` | WBS + Goal/Acceptance criteria + Quality Gates | **Workspace-only.** Each task has a goal and pass/fail acceptance criteria. Quality gates are final tasks. Not promoted — completed tasks have no durable value beyond git history. |

### What the Proposed Approach Does Well

1. **Cross-cutting decisions are first-class** — `adrs/` is a single chronological log of all decisions across all features. Scanning it reveals patterns ("we always pick X"), recurring tradeoffs, and contradictions. A feature-scoped approach buries these inside individual folders.

2. **Traceability** — Design docs reference ADRs by number (`see ADR-0005`); task files reference design docs by name. The links go: tasks → design → ADRs, forming a traceable chain from work to rationale.

3. **Separation of concerns by artifact type** — Each folder answers one question: `adrs/` = "what did we decide and why?", `designs/` = "what are we building?", `tasks/` = "what work remains?". This mirrors the DIATAXIS principle of not mixing explanation with reference.

4. **Built-in quality gates** — Acceptance criteria are written at design time (in task files), not after implementation. Code review, code quality, and security review are explicit final tasks. This makes "done" unambiguous and tool-agnostic.

### Gaps to Consider

| Gap | Description | Recommendation |
|---|---|---|
| **Decision status tracking** | ADRs need explicit Status lifecycle. | Add status header: `Status: draft / accepted / superseded-by <ref>` |
| **Non-goals** | Google Design Docs explicitly list non-goals to prevent scope creep. | Add a "Non-goals" section to design docs |
| **ADR template** | MADR's structured template is more rigorous than free-form. | Use MADR: Problem, Options, Evaluation Criteria, Decision, Consequences |
| **Task decomposition** | Task files need granularity and slicing guidance. | INVEST criteria + vertical slicing: each task independently completable and testable |
| **Acceptance criteria** | Tasks need a clear "done" definition. | Goal + pass/fail acceptance criteria per task, written at design time |
| **Diagrams** | No explicit guidance on architectural diagrams. | C4 levels 1-2 (System Context + Container) in design docs via Mermaid |
| **Quality gates** | No explicit review step before closing. | Code review → code quality → security review as final tasks |
| **DIATAXIS separation** | Solved by type-scoped organization. | `adrs/` = explanation, `designs/` = design, `tasks/` = work tracking |

### Organization: Workspace + Type-Scoped

**Two-layer approach**: draft in a workspace folder, integrate into type-scoped durable structure when done.

| Layer | Purpose | Lifetime |
|---|---|---|
| `workspace/<NAME>/` | Draft space — one folder, full context, iterate freely | Temporary — deleted after integration |
| `adrs/`, `designs/` | Durable knowledge — cross-cutting, chronological, discoverable | Permanent |

**Why both layers:**
- **Workspace solves context loading** — one folder = everything needed for a session, no link-chasing
- **Type-scoped solves cross-cutting concerns** — `adrs/` is the single chronological decision log across all features
- **Clean separation of draft vs validated** — workspace content is unreviewed; durable content passed quality gates
- **Low friction to start** — `mkdir workspace/billing-v2` and go, no numbering or taxonomy needed yet

### Workflow

```
Phase 1 — New need
  mkdir workspace/<NAME>/
  mkdir workspace/<NAME>/adrs/
  Draft DESIGN.md, TASKS.md, and ADRs freely in the workspace

Phase 2 — Implement
  Work through workspace/<NAME>/TASKS.md
  Each task has a goal and acceptance criteria
  Iterate on DESIGN.md and ADRs as understanding grows

Phase 3 — Quality gates
  □ Acceptance criteria pass
  □ Code review completed
  □ Code quality verified
  □ Security review passed

Phase 4 — Integrate
  Move ADRs to adrs/ (assign numbers, set status: accepted)
  Move DESIGN.md to designs/<NAME>.md
  Delete workspace/<NAME>/ (TASKS.md dies with it — git history preserves it)
```

### Verdict: Not Reinventing the Wheel

The proposed approach is a **well-structured synthesis** of established patterns, not a reinvention. It combines:
- **Google Design Docs** (design structure with FR/NFR/non-goals)
- **ADRs/MADR** (decision records with alternatives and consequences)
- **Goal + Acceptance criteria** (pass/fail stop conditions per task)
- **Quality gates** (code review, code quality, security as explicit workflow steps)

The two-layer organization (workspace + type-scoped) solves the fundamental tension: **full context during active work** (workspace) and **cross-cutting discoverability for durable knowledge** (type-scoped). It remains simple, tool-agnostic, and coherent.

**Final structure:**
1. `workspace/<NAME>/` — temporary draft space with `adrs/`, `DESIGN.md`, `TASKS.md`
2. `adrs/` — durable, numbered, cross-cutting decision log
3. `designs/` — durable design docs
4. No durable `tasks/` — tasks die with the workspace, git history preserves them
5. ADR status tracking: `draft / accepted / superseded-by <ref>`
6. MADR template for ADRs: Problem, Options, Evaluation Criteria, Decision, Consequences
7. Non-goals section in design docs
8. INVEST criteria + vertical slicing for task granularity
9. Goal + acceptance criteria per task, written at design time
10. Quality gates as final tasks: acceptance tests → code review → code quality → security review

## References

- Michael Nygard, "Documenting Architecture Decisions" (cognitect.com/blog, 2011)
- npryce/adr-tools, thomvaill/log4brains, adr/madr on GitHub
- rust-lang/rfcs, oxide/rfd repositories
- Simon Brown, c4model.com
- Ryan Singer, "Shape Up" (basecamp.com/shapeup, 2019)
- donnemartin/system-design-primer on GitHub
- Daniele Procida, diataxis.fr
- Jeff Patton, "User Story Mapping" (O'Reilly, 2014)
- Bill Wake, INVEST criteria (xp123.com)
