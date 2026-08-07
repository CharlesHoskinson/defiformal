# The Positive Program

Rebuilding the DeFi mechanism algebra to yield **positive** results, replacing the
preservation question ("is admissibility preserved under composition?" — answers
negatively over a flat carrier) with the **generation** question ("is every
deployed application in the closure of the primitives?").

## The iron rule

We are solving three problems, and no deliverable here may conclude that they
cannot be solved:

1. **Completeness** — a finite primitive set `P` from which all 60 corpus
   applications are constructible; argued as *functional completeness*.
2. **Composition** — composites of constructions are constructions, closed **by
   construction of the carrier**, not by measurement over sampled pairs.
3. **Construction** — synthesis of a construction from a specification, with a
   checkable certificate.

An obstruction is an **input to a requirement**, never an output. If a school's
machinery throws one, its job is to say what must change about the carrier, the
signature, or the notion of composition so it does not arise.

## Why this is not wishful thinking

The prior negative results were measured against a constraint table that is
mostly unwritten. From the knowledge graph over the paper:

- Only **3 of 29** requirement rows (`L1`, `L4`, `L5`) are fully formalized.
  **15 rows are entirely empty** — every term `[ext] ()`, naming no element.
  4 rows have a blank subject and therefore fire on nothing.
- **9 of 20** prohibition rows are English prose naming no element symbol.
  Exactly **one** row (`X2`) is a positive element set.
- **`X21` — credited with 147 of 185 composition failures (79%) — appears
  nowhere in the published table of 20 rows.**

So "the positive theory excludes nothing" is arithmetic on empty clauses, not a
fact about DeFi. The obstructions have never been tested against a finished
constraint system.

## Layout

```
research/positive-program/
├── README.md                    this file
├── POSITIVE-PROGRAM-BRIEF.md    the brief every mathematician received
├── QUINT-FLEET-BRIEF.md         the brief every Quint modelling lane received
├── requirements/                seven schools' structural requirements
│   ├── REQ-clone-theory.md      universal algebra / Post / Pol–Inv
│   ├── REQ-category-theory.md   operads, PROPs, coloured wiring
│   ├── REQ-type-theory.md       linear logic, session types, conservation
│   ├── REQ-order-theory.md      closure systems, convex geometry, bases
│   ├── REQ-model-theory.md      definability, Beth, Craig, institutions
│   ├── REQ-synthesis.md         decidability, FPT, certificates
│   └── REQ-sheaf-theory.md      local-to-global, obstruction classes
├── insights/                    empirical ledgers from Quint modelling
│   └── INSIGHT-L*.md            one per lane, six lanes, 12 categories
├── lane-logs/                   raw grok transcripts per lane
└── consolidated/                cross-cutting synthesis + its knowledge graph
```

Quint specifications live in `/root/DefiElements/quint-models/<LANE>/`.
Protocol source clones live in `/root/DefiElements/protocol-repos/<category>/`.

## The two fleets

**Theory fleet (7 mathematicians).** Each specifies, from their own school's
first principles, what the mathematical structure must satisfy: carrier and
signature, composition operator, the completeness theorem as a formal statement,
the synthesis problem, the disposition of every prior obstruction, a ranked
minimal enrichment, and a falsifiable test runnable on the existing corpus in
days. Each ends with named proof obligations (`PO-CLONE-n`, `PO-CAT-n`,
`PO-TYPE-n`, `PO-ORD-n`, `PO-MOD-n`, `PO-SYN-n`, `PO-SHF-n`).

**Empirical fleet (6 Quint lanes).** Each models the real protocols of two
categories in Quint **from their actual source code**, typechecks and runs every
spec, and records a structured insight ledger: state shapes, actions, invariants,
recurrences that are candidate primitives, distinctions the 58-symbol vocabulary
collapses, mechanisms with no symbol, and the real composition surface between
protocols.

The theory fleet says what structure we need. The empirical fleet says what the
code actually does. Consolidation is where they meet.

## Next steps

1. Consolidate the seven requirement documents — cross-cut the proof obligations,
   find where the schools independently converge, and resolve where they conflict.
2. Consolidate the six insight ledgers into one primitive inventory.
3. Graphify `requirements/` + `insights/` + `consolidated/` so the whole
   programme is queryable as one knowledge graph.
4. Pick the minimal enrichment the schools agree on and run the days-scale
   falsifiable tests against the corpus.
