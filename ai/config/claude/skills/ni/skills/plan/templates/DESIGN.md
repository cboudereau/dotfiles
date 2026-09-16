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

Before listing a non-goal, verify it is truly out of scope:
- **Already covered?** Check whether existing behavior, architecture, or a planned feature already provides the capability. If it does, it is not a non-goal — it is a fact to document (e.g., "OR composition is already provided by the first-match-wins evaluation order").
- **Deferred or excluded?** If it is genuinely not covered and not planned, state *why* it is excluded (cost, complexity, low priority) so the decision can be revisited later.
- **Misclassified FR?** If exploration reveals the capability is actually needed for the stated goals, promote it to an FR instead.

A non-goal that turns out to be already solved is a planning error — it signals incomplete analysis of the existing system.

## Rabbit holes
Areas of known uncertainty where unbounded time could be lost.
For each: state what to avoid and the constraint that caps exploration.

## Design
Architecture, C4 diagrams (levels 1-2 via Mermaid), data model, interfaces.

Decisions:
- [Decision title](./adrs/decision-name.md)

## Cross-cutting Concerns
Observability, migration, rollback.
