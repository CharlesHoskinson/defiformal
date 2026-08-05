# PHASE 2 BRIEF — re-spec the ten ungenerated protocols honestly

You are planning the critical path of the programme. Read `GOAL.md` and
`ROADMAP.md` in `/root/DefiElements/research/positive-program/` first.

## The problem in one paragraph

Six lanes modelled 60 DeFi protocols in Quint from source. All 57 specs
typecheck. But when we tested whether a candidate basis generates them, we found
that **the specs had already deleted the hard parts**. Generation was therefore
measured against a corpus with the difficulty pre-removed, so the measured
incompleteness (743 of 820 definitions generated; 10 specs ungenerated) is a
lower bound on the true figure.

## The three exhibited deletions

**1. Ordering removed.** `quint-models/L2/liquity.qnt:130` declares
`action redeem(u: int, boldAmt: int)` — the trove is a *parameter*, supplied by
`nondet u = USERS.oneOf()` in the driver. The real contract
(`protocol-repos/cdp/liquity_bold/contracts/src/TroveManager.sol:770,785`) calls
`sortedTroves.getLast()` and then walks `getPrev()` — extremal selection over a
global order, consuming the minimal prefix, cut off endogenously by redemption
size. The spec redeems from *whichever trove it is told*, which is a different
mechanism.

**2. Exact arithmetic removed.** `quint-models/L1/common.qnt:76–92` —
`geometricMint` returns `if (a0 == a1) a0 else min(a0, a1)` where Uniswap V2
computes `√(a₀·a₁)`. Self-documented: *"Unrolled for quint purity without
loops."*

**3. Convergent arithmetic removed.** `quint-models/L1/curve.qnt:22–30` —
`approxD` substitutes a "weighted blend" for Curve's Newton iteration on
`(Ann·S + D_P·n)·D / ((Ann−1)·D + (n+1)·D_P)`.

Corpus-wide corroboration: **every** `fold` in all 57 specs has the form
`fold(0, (acc, x) => acc + …)` — a commutative sum. There is not one extremal
selection anywhere in the corpus.

## The ten to re-spec

`uniswap_v2`, `curve`, `compound_v3`, `morpho_blue`, `liquity`, `apex`, `gmx`,
`huma`, `derive`, `polymarket`.

Source is cloned under `/root/DefiElements/protocol-repos/<category>/<org>_<repo>/`.
Existing specs are in `/root/DefiElements/quint-models/L*/`. Quint 0.32.0 is on
PATH; the `quint-lang` / `quint-modeling` skills are installed.

## The Goldilocks problem — this is the heart of the planning task

There are two failure modes and they are opposite.

**Too abstract** is what happened: the spec deletes the mechanism, and a
generation test over it measures nothing. Every shortcut above is this failure.

**Too concrete** is the danger in overcorrecting: if the re-spec transliterates
Solidity, then "the basis generates the spec" becomes a claim about Solidity
rather than about mechanisms, and the theorem is worthless in the other
direction. A spec that inlines the whole contract is generated only by a basis
containing that contract.

So the plan must supply a **fidelity criterion**: a statement of what a re-spec
MUST preserve and what it MAY abstract, sharp enough that a reviewer can hold a
spec against it and say yes or no. Without that criterion, the re-spec effort
will fail the same way twice.

## What is genuinely at issue technically

Quint is a finite-state, pure specification language. The lanes claimed the hard
parts were inexpressible ("unrolled for quint purity without loops"). Determine
whether that is true. Specifically:

- **Integer square root** — expressible by bounded search or a fixed unrolling
  over the bounded integer domains the specs already use?
- **Newton iteration** — Curve's own implementation caps at 255 iterations and
  converges in about 4. Is a fixed unrolling faithful?
- **Extremal selection over a ledger** — Quint has `List` with `head`/`tail`
  (Lighter's spec already uses a priority queue this way) and `Set` with `fold`.
  Can a sorted-by-key structure and a prefix walk be expressed, and at what cost
  in state-space size?
- **State-space blowup** — the re-specs must still `quint typecheck` and ideally
  `quint run` an invariant. A faithful spec nobody can execute is a regression.

If some part is genuinely inexpressible in Quint, say so and name what would
replace it — that is a finding, not a failure.

## Your deliverable

A plan an executor can follow without asking questions:

1. **The fidelity criterion.** What must be preserved; what may be abstracted;
   how a reviewer decides. Make it operational.
2. **Technique per hard part** — sqrt, Newton, extremal selection — with a worked
   Quint fragment for each, that you have actually typechecked.
3. **Per-protocol scope**, for all ten: which mechanism is the one that must
   survive, and what may be dropped.
4. **The execution split** — how to divide ten protocols across parallel workers
   without them diverging on convention.
5. **The acceptance test.** How we know a re-spec is done: typecheck, an
   invariant that runs, and a check that the previously-deleted mechanism is now
   present and exercised.
6. **The regression guard.** A mechanical check that no re-spec has reintroduced
   an abstraction shortcut — the corpus-wide `fold(0, …, acc + …)` pattern is one
   such signal; name others.

Constraints: no methodology or statistics. No enrichment of the basis — that is
Phase 1 and not yours. Stay on the ten protocols. Target 1200–1800 words.
