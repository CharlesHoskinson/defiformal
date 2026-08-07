# `Perm` confirmed against a second witness — and why gate 0.1 failed

**Two results. The factorisation survives a genuine falsification test on an
independent protocol, with `Perm` as the invariant factor. And `BASIS.md`'s
`Q`/`Σ` split turns out to be a permission statement written as an arithmetic
one, which is why gate 0.1 could never be operationalised.**

---

## 1. The falsification test

`CHARACTERISATION.md` derived `mandate = Perm ⋈ Led.move` from **one** witness.
A factorisation fitted to one instance is a description, not a characterisation,
so it was tested against a second: Liquity V2's batch managers, contracts on disk
at `protocol-repos/cdp/liquity_bold`.

`BorrowerOperations.sol:905 setBatchManagerAnnualInterestRate`:

| line | element | maps to |
|---|---|---|
| `_requireValidInterestBatchManager(msg.sender)` | **the gate** | `Perm` |
| `_requireInterestRateInBatchManagerRange(msg.sender, …)` | bounded discretion | law 3 |
| `_requireBatchInterestRateChangePeriodPassed(…)` | cooldown | rate-limit family |
| `_requireNewTCRisAboveCCR(newTCR)` | system health | `Cmp` |
| **effect: sets `annualInterestRate` on the batch** | **not `Led.move`** | `Post(Σ)` |

**The effect is different.** Morpho's allocator *moves balances*; Liquity's batch
manager *sets a rate* that governs future accrual on other people's debt. Nothing
is transferred.

So:

    mandate_morpho   =  Perm ⋈ Led.move
    mandate_liquity  =  Perm ⋈ Post(rate)

**`Perm` is the invariant factor; what it gates varies.** That is the outcome you
want from a test like this — had the second witness needed a *different* gate, or
no gate, the characterisation would have been fitted to Morpho. It is the gated
part that is common, and the gated-over part that is protocol-specific.

The laws survive too: bounded discretion appears as an explicit rate *range* per
manager rather than a supply cap per market, and revocability appears as the
cooldown plus the borrower's right to leave the batch. Different instruments,
same five laws.

---

## 2. Why gate 0.1 failed — the same missing coordinate

`BASIS.md`:29-31 defines the load-bearing sort split:

> "They are nevertheless distinct sorts because **different operations are legal
> on them**: a `Σ` may be **overwritten by an external writer**
> (`applyPostPrice`, L5/common.qnt:109; `shockPrice` in L1/morpho_blue.qnt), a
> `Q` never is."

**That is a permission predicate.** "May be overwritten by an external writer" is
a statement about *who is allowed to write*, not about arithmetic.

And the corpus models no writer. Verified:

    L5/common.qnt:109   applyPostPrice(old: PostedPrice, p: int, t: int)
    L1/morpho_blue.qnt:178   action shockPrice(p: int)

Neither takes a caller. The "external writer" that defines the sort is absent
from both cited witnesses.

**So `Q`/`Σ` is a distinction in `R`, stated as a distinction in `P`.** That is
exactly why it could not be operationalised. Every attempt looked for it in the
arithmetic:

| attempt | looked for |
|---|---|
| `qsigma.py` | RHS mentions a formal parameter |
| `qsigma2`/`qsigma3` | replacement vs update |
| `qsigma4` | same, minus `init` |
| `qsigma5` | same, plus binding resolution |

All four are predicates on `P`. **The property is not in `P`.** `qsigma5` got the
sharpest result available — 95.5% of balances never replaced — and still scored
only 36.5% of prices as `Σ`, because accrual indices evolve from their own prior
value. Exogenous in *provenance*, endogenous in *update form*: provenance is `R`,
update form is `P`, and only the second was measurable.

`QSIGMA-VERDICT.md` §3 said "no syntactic test on assignment form will separate
provenance" and stopped there. This is why: provenance **is** the permission
coordinate.

## 3. And `Post` is a decapitated `Perm`

`BASIS.md` merges F1/F6 into `Prop` + `Post`, with `Post(Σ)` "supplying the ratio
exogenously". Strip the euphemism: `Post` is *a principal writes a value*. With
the principal modelled it is `Perm ⋈ assignment`.

**So the basis does not merely lack `Perm`. It contains a family — `Post`, i.e.
F6 — that is a `Perm`-gated assignment with the gate deleted.** Deletion class 11,
occurring in the basis itself rather than in a spec.

This also explains why F6 merged so easily into `Prop`: with the gate removed,
"supply a ratio exogenously" and "read a ratio off two totals" differ only in
where the number came from — and provenance was the unmodelled coordinate.

---

## 4. What this unifies

Five findings that looked independent are one missing coordinate:

| finding | what it turned out to be |
|---|---|
| gate 0.1 — `Q`/`Σ` untestable, `\|P\|=4` withdrawn | a permission split stated arithmetically |
| deletion class 11 — 4 confirmed, 0 of 17 gates modelled | `R` deleted from the specs |
| pair 4 — the autonomy law untestable | needs `R` to evaluate |
| the refuter — delegated allocation | a `Perm`-gated transition |
| F1/F6 merging into `Prop`+`Post` | `Post` is `Perm` with the gate removed |

**The programme has been circling one absence for its whole life.**

## 5. Limits

- Two witnesses is two, not four. Steakhouse operates MetaMorpho so it is not
  independent of witness 1; Grove has no contracts on disk. The claim is
  confirmed on the two that could be tested.
- `Post`-is-decapitated-`Perm` is an argument from `BASIS.md`'s own wording plus
  two unmodelled call sites. It is not a proof that F6 is non-primitive; it is a
  strong reason to re-derive F6 once `R` exists.
- None of this touches the generation theorem for `P ∪ {Perm}`.

## Reproduce

    sed -n '905,960p' protocol-repos/cdp/liquity_bold/contracts/src/BorrowerOperations.sol
    grep -n -A6 "def applyPostPrice" quint-models/L5/common.qnt
    grep -n -A6 "action shockPrice"  quint-models/L1/morpho_blue.qnt
    sed -n '25,35p' research/positive-program/basis/BASIS.md
