# DeFi Atlas Formal-Model Findings

Status: work in progress.

## Intake Findings: Source and Engine Defects

These findings come directly from the current source files.
They predate the Quint model.

### The element count mixes mechanisms with a declared non-element

`ELEMENTS` contains 59 rows.
Only 58 rows are mechanisms.
The `CSM` row has status `limit` and states that it is not an element.

### The hazard count has two valid interpretations

`HAZARDS` contains 20 rows.
The identifiers represent 19 numbered families because `X11` has `X11a` and `X11b` variants.

### The protocol death count is three

`PROTOCOLS` contains 12 protocols.
Only Terra, Mango, and Euler have `dead: true`.
The source does not identify a fourth dead protocol.

### The TypeScript parser activates only 25 of 29 laws

The parser cannot derive element subjects for `L14`, `L23`, `L25`, or `L26`.

- `L14` uses the prose subject `illiquid backing`.
- `L23` uses `Sq`, which is contested and absent from `ELEMENTS`.
- `L25` uses the prose subject `wrapped cross-domain collateral`.
- `L26` uses a conjunction, `Aw + Xf`, where the parser accepts only `|` alternatives.

These four laws never fire in the current TypeScript engine.

### The hazard projection has a polarity defect

The TypeScript engine extracts recognized element symbols from hazard prose.
It requires at least two symbols and treats all extracted symbols as present.

Only `X2`, `X11a`, and `X19` pass the two-symbol threshold.
The projection reverses the meaning of `X11a` and `X19`.

- `X11a` describes `Uc` with no `Aw` and no `At`.
  The engine arms it only when `Uc`, `Aw`, and `At` are all present.
- `X19` describes `Xf` with no destination-side `Aw`.
  The engine arms it only when both `Xf` and `Aw` are present.

The current `armedHazards` result is therefore not a sound hazard predicate.
The Quint report keeps the requested membership projection but labels this limitation.

## Model Scope

Pending implementation and verification.

## Commands and Bounds

Pending implementation and verification.

## Protocol Closure Results

Pending Quint confirmation.

## Question 10: Stratum as Graph Rank

Pending analysis.

## Question 11: Composition as a State Machine

Pending verification.

## Question 12: Unwritten Hazard Combinations

Pending bounded search.

## Question 13: Reflexive Loop as a Temporal Property

Pending temporal checks.

## Question 14: Alternatives and the Legal-Protocol Order

Pending bounded analysis.

## Visualization Implications

Pending verified findings.

## Most Surprising Finding

Pending verified findings.
