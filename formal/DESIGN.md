# DeFi Atlas Quint Model Design

## Objective

Model the DeFi mechanism taxonomy as executable Quint data and state machines.
Use the source data as the vocabulary authority.
Keep source defects visible instead of silently repairing them.

## Scope

The model covers these source files:

- `viz/src/data.ts` supplies elements, attributes, laws, and hazards.
- `viz/src/protocols.ts` supplies the 12 protocol element sets.
- `viz/src/laws.ts` supplies the current operational closure semantics.
- `research/QUESTIONS.md` supplies questions 10 through 14.

The model does not change those files.
All generated files stay in `formal/`.

## Architecture

`atlas.qnt` contains several modules in one file.

The vocabulary module defines element identifiers and attributes.
It also defines law records, hazard records, and protocol sets.

The raw assembly module starts with an empty element set.
Its `addOne` action adds one nondeterministically selected element.
Its predicates expose closure violations and hazard projections.

The legal assembly module uses the same state shape.
Its `addLegal` action permits only results that satisfy closure and `hazardFree`.
This module exposes the legal-configuration order.

The reflexive module adds economic state that element membership cannot express.
It models peg health, endogenous backing, supply expansion, and recovery capital.
Its target liveness property is `always(depegged implies eventually(recovered))`.

`atlas_test.qnt` contains executable checks and protocol assertions.
`analyze.mjs` independently computes protocol closure, graph ranks, and bounded configuration results.
It does not import `viz/src/laws.ts`.

## Semantic Layers

The faithful layer models the current element-set semantics.
External law clauses become recorded residue and do not fail closure.

The projection layer implements the requested membership-based `hazardFree` predicate.
This projection is not a faithful interpretation of many prose hazards.

The hypothesis layer defines candidate properties from existing notes and attributes.
Each candidate result remains separate from confirmed hazards.

## Verification

Run `quint typecheck` after each model increment.
Run `quint run` after each executable state-machine increment.
Run `quint test` for fixed protocol cases.
Run `quint verify` only because the user explicitly requested model checking.

Attempt full vocabulary checking first.
If the full state space is intractable, use an explicit reduced universe.
Record every universe, depth, timeout, and result in `FINDINGS.md`.

## Interpretation Rules

Do not call a candidate property a confirmed financial hazard.
Do not claim that model checking can infer unspecified economic facts.
Treat the TypeScript engine result as a comparison target, not as proof.
Treat Quint output and the independent analyzer as separate evidence.

