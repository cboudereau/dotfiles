# Study: Workflow Simulation — "Billing V2"

## Purpose

Walk through a concrete planning session to evaluate the workflow against these criteria:
1. How is it driven? (order of documents, who fills what)
2. Does it bring value vs letting AI work alone?
3. Is it simple but exhaustive?
4. Does it solve known problems? (cross-cutting decisions, knowing when to stop, quality)

## Scenario

A team needs to redesign the billing system to support multi-currency payments.

---

## Step-by-step Simulation

### Step 1 — Create the workspace

```bash
mkdir -p workspace/billing-v2/adrs
```

**What exists now:**
```
workspace/billing-v2/
  (empty)
```

**Who drives this**: the person (human or AI) who identifies the need.

---

### Step 2 — Write DESIGN.md (first document, always)

DESIGN.md is the **entry point**. It must be written before anything else because:
- ADRs can't exist without a problem context
- Tasks can't exist without requirements to derive from
- It forces you to think before acting

```markdown
# billing-v2 — Design Doc

## Context
Current billing supports EUR only. Sales has closed deals in GBP and USD.
Invoices must be generated in the customer's currency by Q3.

## Functional Requirements

### <a id="fr1"></a>FR1 — Multi-currency invoice generation
Support EUR, GBP, USD for invoice generation.

### <a id="fr2"></a>FR2 — Daily exchange rates
Exchange rates fetched daily from ECB.

### <a id="fr3"></a>FR3 — Currency at contract level
Customer currency stored at contract level.

### <a id="fr4"></a>FR4 — Historical currency preservation
Historical invoices remain in original currency.

## Non-Functional Requirements

### <a id="nfr1"></a>NFR1 — Exchange rate latency
Exchange rate fetch must not block invoice generation (< 200ms).

### <a id="nfr2"></a>NFR2 — Currency precision
Currency amounts stored with 4 decimal precision (ISO 4217).

### <a id="nfr3"></a>NFR3 — Conversion audit trail
Audit trail for every currency conversion.

## Non-goals
- Real-time exchange rates (daily is enough)
- Customer-facing currency selector (backoffice only for now)
- Crypto currencies

## Design
[C4 Level 1 — System Context diagram here]
[C4 Level 2 — Container diagram here]

Invoice Service fetches rates from ECB API daily via a cron job, stores
them in a rates table. At invoice generation, the rate for the invoice
date is looked up. If missing, generation fails loudly (no silent fallback).

Decisions:
- [ECB as exchange rate provider](./adrs/ecb-exchange-rates.md)
- [4 decimal precision](./adrs/currency-precision.md)

## Cross-cutting Concerns
- **Observability**: alert if ECB fetch fails 2 days in a row
- **Migration**: backfill existing contracts with EUR as default currency
- **Rollback**: feature flag on multi-currency; EUR-only fallback
```

**Key observation**: this document is ~40 lines. It answers "what and why" without prescribing "how" at the code level. An AI reading this has full context. A human reading this can challenge scope.

---

### Step 3 — Write ADRs (as decisions emerge from design)

While writing DESIGN.md, decisions surface. Each one that is hard to reverse gets an ADR.

**workspace/billing-v2/adrs/ecb-exchange-rates.md:**
```markdown
---
status: draft
---
# Use ECB as exchange rate provider

Addresses: [FR2](../DESIGN.md#fr2), [NFR1](../DESIGN.md#nfr1)

## Problem
We need daily exchange rates for EUR/GBP/USD. Options: ECB (free, EUR-based),
Open Exchange Rates (paid, USD-based), hardcoded rates.

## Options
| Option | Pros | Cons |
|---|---|---|
| ECB | Free, official, EUR-based (our base) | XML format, EUR pairs only |
| Open Exchange Rates | JSON, all pairs | Paid, USD-based requires double conversion |
| Hardcoded | Simple | Stale, liability |

## Decision
ECB. Free, EUR-based matches our base currency. XML parsing is a one-time cost.

## Consequences
- Must handle ECB downtime (cache last known rates)
- Limited to EUR-based pairs (acceptable for EUR/GBP/USD)
```

**workspace/billing-v2/adrs/currency-precision.md:**
```markdown
---
status: draft
---
# Store currency amounts with 4 decimal precision

Addresses: [NFR2](../DESIGN.md#nfr2)

## Problem
How many decimal places for currency storage? 2 (display), 4 (ISO 4217), arbitrary (bigdecimal).

## Options
| Option | Pros | Cons |
|---|---|---|
| 2 decimals | Simple, matches display | Rounding errors in conversion |
| 4 decimals | ISO 4217 compliant, handles subdivision | Slightly more storage |
| Arbitrary | No precision loss | Complex, overkill |

## Decision
4 decimals (ISO 4217). Balances correctness with simplicity.

## Consequences
- Migration needed: alter column precision on amounts table
- Display layer must round to 2 for presentation
```

**Key observation**: ADRs are short (< 30 lines each). They capture the **why** behind a decision, not the implementation. They are written **during** design, not after.

---

### Step 4 — Write TASKS.md (derived from FR/NFR)

Each task traces back to a requirement. Each task has a **goal** (why it exists) and **acceptance criteria** (pass/fail checklist to verify it's done).

```markdown
# billing-v2 — Tasks

Design: [DESIGN.md](./DESIGN.md)

## Tasks

### 1. Add currency column to contracts table ([FR3](./DESIGN.md#fr3), [NFR2](./DESIGN.md#nfr2))
**Goal**: Contracts carry a currency code.
**Acceptance criteria**:
- [ ] Currency column exists with ISO 4217 codes (EUR, GBP, USD)
- [ ] Existing contracts default to EUR after migration
- [ ] 4 decimal precision on amounts

### 2. Create exchange rate service ([FR2](./DESIGN.md#fr2), [NFR1](./DESIGN.md#nfr1))
**Goal**: Daily exchange rates available for invoice generation.
**Acceptance criteria**:
- [ ] Cron fetches EUR/GBP and EUR/USD rates daily from ECB
- [ ] ECB downtime handled: last known rates used, alert fires
- [ ] Rate lookup < 200ms
**Decisions**: [ECB as provider](./adrs/ecb-exchange-rates.md)

### 3. Multi-currency invoice generation ([FR1](./DESIGN.md#fr1), [FR4](./DESIGN.md#fr4))
**Goal**: Invoices generated in the customer's contract currency.
**Acceptance criteria**:
- [ ] GBP contract produces GBP invoice
- [ ] Historical EUR invoices remain in EUR
- [ ] Missing rate for invoice date fails with explicit error (no silent fallback)

### 4. Audit trail for conversions ([NFR3](./DESIGN.md#nfr3))
**Goal**: Every currency conversion is traceable.
**Acceptance criteria**:
- [ ] Conversion log records: source amount, target amount, rate, timestamp

### 5. Observability (Cross-cutting)
**Goal**: Operations is alerted when exchange rate data becomes stale.
**Acceptance criteria**:
- [ ] Alert fires after 2 consecutive days of ECB fetch failure

## Quality gates
- [ ] Code review: implementation matches [DESIGN.md](./DESIGN.md) intent
- [ ] Code quality: no new complexity warnings, types cover currency domain
- [ ] Security review: exchange rate API key handling, no PII in conversion logs
- [ ] All acceptance criteria above are green
```

**Key observation**: tasks are derived from FR/NFR numbers. Goal + acceptance criteria are written at design time, not after code. Quality gates are explicit final items. No BDD ceremony — just "what does success look like?" as a pass/fail checklist.

---

## Document Order

```
1. DESIGN.md     ← always first (context, FR, NFR, non-goals, design)
2. adrs/*.md     ← emerge during design (one per hard-to-reverse decision)  
3. TASKS.md      ← derived from DESIGN.md (one task per FR/NFR, with acceptance criteria)
```

This order is strict:
- You cannot write ADRs without the problem context from DESIGN.md
- You cannot write tasks without requirements to derive from
- Quality gates are always the last section of TASKS.md

---

## Evaluation

### Does it bring value vs letting AI work alone?

| Without this workflow | With this workflow |
|---|---|
| AI jumps to code immediately | AI reads DESIGN.md first — scoped, constrained |
| Decisions are implicit in code | Decisions are explicit in ADRs — challengeable, traceable |
| "Done" is undefined | "Done" = all acceptance green + quality gates passed |
| Scope creep is invisible | Non-goals section prevents it ("no crypto", "no real-time rates") |
| Cross-cutting concerns are afterthoughts | Observability, migration, rollback are designed upfront |
| Quality is checked at the end (if at all) | Quality gates are part of the plan |

**The value is constraint.** An AI without a design doc will produce working code that may solve the wrong problem, miss edge cases, or make decisions nobody reviewed. The design doc is a contract: "build this, not that, and here's how we'll verify it."

**The value is also stop condition.** Without acceptance criteria, an AI (or human) can iterate forever. acceptance criteria are binary: green or red. When all are green and quality gates pass, you're done.

### Is it simple but exhaustive?

**Simple:**
- 3 document types only (DESIGN.md, ADRs, TASKS.md)
- No special tooling needed — just markdown files in a folder
- Strict order: DESIGN → ADRs → TASKS
- One workspace folder = full context

**Exhaustive:**
- FR/NFR/non-goals cover scope completely
- Every FR/NFR has at least one task
- Every task has acceptance criteria
- Cross-cutting concerns are explicit
- Quality gates close the loop (review, quality, security)

**The exhaustiveness comes from traceability**, not from volume. You can verify completeness by checking:
- Every FR/NFR in DESIGN.md has at least one task in TASKS.md
- Every task has at least one acceptance criterion
- Quality gates are present

### How is it driven?

| Phase | Driver | Artifact | Action |
|---|---|---|---|
| 1. Frame | Human | DESIGN.md | Write context, FR, NFR, non-goals |
| 2. Decide | Human + AI | adrs/*.md | Explore options, pick, justify |
| 3. Plan | Human + AI | TASKS.md | Derive tasks from requirements, write acceptance criteria |
| 4. Build | AI (primarily) | Code | Implement tasks, check criteria |
| 5. Verify | Human + AI | TASKS.md | Run acceptance criteria, quality gates |
| 6. Integrate | Human | adrs/, designs/ | Promote durable artifacts, delete workspace |

The human drives framing (phase 1) and final verification (phases 5-6). AI assists with decisions and planning (phases 2-3) and drives implementation (phase 4). This is the right division: humans own the "what and why", AI accelerates the "how".

### Does it solve known problems?

| Problem | How this workflow addresses it |
|---|---|
| AI makes undocumented decisions | ADRs force explicit decisions with rationale |
| No way to know when to stop | Acceptance criteria (acceptance) are binary stop conditions |
| Scope creep during implementation | Non-goals section + FR/NFR scoping |
| Cross-cutting concerns forgotten | Explicit section in DESIGN.md + dedicated tasks |
| Quality checked too late | Quality gates are planned tasks, not afterthoughts |
| Context lost between sessions | Workspace folder = full context reload |
| Decisions buried in code/chat | ADRs survive in durable `adrs/` folder |
| No traceability from task to rationale | Tasks → DESIGN.md → ADRs chain |
