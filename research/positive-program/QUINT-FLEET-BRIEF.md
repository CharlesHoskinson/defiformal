# BRIEF: Quint formal-modelling fleet — building the Insight Ledger

You are a formal methods engineer. Your job is to **model real deployed DeFi
protocols in Quint**, from their actual source code, and to record what you find
in a structured **insight ledger**.

The purpose is not verification. The purpose is **discovery of shared structure**:
we are building a mathematical model of DeFi composition, and we need to know —
empirically, from executable specifications rather than from prose — which state
shapes, actions and invariants actually recur across protocols, and which are
genuinely distinct. Your ledger is the input to that model.

---

## 0. USE THE QUINT SKILLS

The `quint-lang`, `quint-modeling` and `quint-execute-spec` skills are installed
and available to you. **Load and follow them.** In particular:

- `quint-modeling/guidelines/from-code.md` — modelling an existing codebase. This
  is your primary workflow; you are modelling from Solidity/Rust source.
- `quint-lang/guidelines/operators.md`, `patterns.md`, `constraints.md` — the
  language reference. Consult it rather than guessing syntax.
- `quint-lang/guidelines/cli.md` and `simulations.md` — for `typecheck`, `run`,
  `test` and invariant checking.
- `quint-modeling/guidelines/review.md` — self-review your specs before finishing.

Reminder of the two syntax facts most often got wrong: **state update is primed
assignment** (`n' = n + 1`, not `n = n + 1`), and actions are combined with
`all { ... }` / `any { ... }`, not with `&&`/`||`.

`quint` is on PATH (version 0.32.0). **Every spec you write must typecheck.**
Run `quint typecheck <file>.qnt` on each, and fix errors until clean. Then run
`quint run <file>.qnt --invariant=<inv> --max-steps=20 --max-samples=200` for at
least one invariant per protocol. A spec that does not typecheck is not a
deliverable — delete it or fix it, never ship it.

---

## 1. THE FRAME YOU ARE FEEDING

A prior effort modelled a DeFi protocol as a **flat subset of a 58-symbol
vocabulary** of mechanisms, with requirement/prohibition/warrant constraints over
those symbols. It produced a negative result — composition does not preserve
admissibility — and the negative result turned out to rest on a constraint table
that is mostly unwritten (only 3 of 29 requirement rows are fully formalized;
9 of 20 prohibitions are English prose; the clause credited with 79% of all
composition failures does not appear in the published table at all).

We are now rebuilding the model **positively**, and the target is:

1. **Completeness** — a finite set of primitives from which all 60 corpus
   applications are constructible.
2. **Composition** — composing constructions yields a construction, by
   construction of the carrier.
3. **Construction** — synthesis of a construction from a specification.

Seven mathematicians are specifying the abstract structure in parallel. **Your
job is the empirical half**: what does the code actually do, and what actually
repeats? Where they say "there should be a primitive for X", you say "here are
the eleven protocols whose state machines share exactly this shape, and here is
the Quint module that captures it."

**You are not bound by the 58-symbol vocabulary.** If the code shows a mechanism
the vocabulary has no name for, that is a finding — record it. If one symbol
covers two protocols whose state machines are genuinely different, that is a
finding — record it. The vocabulary is a hypothesis you are testing, not a
schema you are filling in.

---

## 2. YOUR SOURCES

**Protocol source code** — shallow clones, by category:
`/root/DefiElements/protocol-repos/<category>/<org>_<repo>/`
Read the core contracts. Ignore tests, deployment scripts, node_modules, and
audit directories. You are after the state variables and the state transitions.

**Protocol profiles from the prior study** — per-category supplement sections:
`/root/DefiElements/paper/kg-corpus/supp-*.md`
These give, per protocol, a prose description of what the system does, an
exhibited element-set construction, an admissibility verdict, and a list of
obligations no element could discharge. Use them for orientation and to know
what the prior model claimed. **Do not trust them over the code.** Where the
code and the profile disagree, the code wins, and the disagreement is a finding.

**The vocabulary tables** — the 58 elements with their group `G01–G16` and
stratum `0–4`, the 29 requirement rows, 27 warrant entries, 20 prohibition rows:
`/root/DefiElements/paper/formal-data.tex`

---

## 3. WHAT TO BUILD

Work in `/root/DefiElements/quint-models/<LANE>/`.

### 3.1 One spec per protocol

For each protocol in your lane, write `<protocol>.qnt` capturing its **core
economic state machine**. Keep it small — 60–150 lines. You are modelling the
essential mechanism, not reimplementing the protocol. Include:

- **State variables** — the accounting state that actually matters (balances,
  shares, indices, debt, collateral, queue, epoch, oracle price).
- **Actions** — the user-facing and keeper-facing transitions (deposit, withdraw,
  borrow, repay, liquidate, rebase, settle, bridge, fill, resolve).
- **Invariants** — at minimum one solvency or conservation invariant, stated as
  a `val`. This is the most valuable single artifact you produce. Examples of
  the shape we are looking for: total shares times index equals total assets;
  sum of debts equals total borrowed; collateral value exceeds debt times
  threshold; minted supply equals locked backing; deltas net to zero at scope
  close.

Use `pure def` for the mathematics and keep actions thin. Parameterize with
`const` where a protocol differs from a sibling only by a constant.

### 3.2 A shared module

Write `common.qnt` for your lane holding **every definition you found yourself
wanting to write twice**. This file is the actual deliverable — it is the
empirical evidence for what a primitive is. If two protocols in your lane share
a state shape, factor it out and have both import it. Record in the ledger which
protocols instantiate each shared definition and how they differ.

### 3.3 Verify

Every `.qnt` must `quint typecheck` clean. Run at least one invariant per
protocol under `quint run`. Where an invariant **fails**, that is a first-class
finding: either your model is wrong (fix it) or the invariant does not actually
hold without an assumption the code makes implicitly (record the assumption —
this is exactly the kind of hidden precondition the mathematical model needs).

---

## 4. THE INSIGHT LEDGER — YOUR PRIMARY DELIVERABLE

Write `/root/DefiElements/research/positive-program/insights/INSIGHT-<LANE>.md`.

This must be **structured markdown**, because it will be parsed into a knowledge
graph and reasoned over. Follow this schema exactly. Use the exact heading text
and the exact table columns; add rows, never columns.

```markdown
# Insight Ledger — <LANE> (<category A>, <category B>)

## 1. Protocols modelled

| protocol | category | repo path | spec file | typechecks | invariant run | verdict |
|---|---|---|---|---|---|---|

## 2. State shapes

One row per distinct state shape you found. A "shape" is a named tuple of state
variables that recurs. Give it a name you would defend as a primitive.

| shape | fields | protocols instantiating | differs by |
|---|---|---|---|

## 3. Actions

| action | signature | protocols | preconditions | element symbol (or NONE) |
|---|---|---|---|---|

## 4. Invariants

The most important table. One row per invariant you actually stated in Quint.

| invariant | formal statement | protocols it holds for | verified how | hidden assumption |
|---|---|---|---|---|

## 5. Recurrences — candidate primitives

Things you factored into `common.qnt`, with the evidence.

| candidate primitive | quint definition | instantiated by (n) | why it is primitive |
|---|---|---|---|

## 6. Distinctions the 58-symbol vocabulary collapses

Cases where one element symbol covers protocols whose state machines differ
materially. This is evidence for splitting a symbol.

| element symbol | protocols | how their state machines differ | proposed split |
|---|---|---|---|

## 7. Mechanisms with no symbol

Code-visible mechanisms the vocabulary cannot name.

| mechanism | protocols | what it does | why no existing symbol fits |
|---|---|---|---|

## 8. Cross-protocol connections

Places where one protocol's state is another protocol's input — the real
composition surface.

| from | to | what flows | shared state | composition hazard |
|---|---|---|---|---|

## 9. Code vs prior profile disagreements

| protocol | prior profile claims | code shows | which is right |
|---|---|---|---|

## 10. Open questions for the mathematicians

Numbered list. Each one a specific question your modelling raised that the
abstract structure must answer.
```

Rules for the ledger:

- **Every claim traceable.** Cite a file and line in the protocol repo, or a
  definition name in your `.qnt`. A claim with no trace is not a finding.
- **Report failures.** If a protocol defeated you, say so in the verdict column
  and say why. A lane that reports 10 successes and no difficulties is not
  credible and will be discarded.
- **Prefer negative space.** Sections 6, 7 and 8 are worth more than section 1.
  Anyone can list protocols; only someone who modelled them can say what the
  vocabulary is missing.
- Do not pad. A short precise ledger beats a long vague one.

---

## 5. WORKING RULES

- Do not modify anything under `/root/DefiElements/protocol-repos/` — read only.
- Do not modify the paper, the Lean development, or other lanes' directories.
- Write only inside `/root/DefiElements/quint-models/<LANE>/` and your single
  ledger file.
- If a repo for one of your protocols was not cloned, note it and continue with
  the rest. Use the supplement profile for that one and mark the ledger row
  `verdict = profile-only`.
- Budget your time. Better to ship 6 solid protocols with clean typechecked specs
  and a sharp ledger than 10 broken ones.
