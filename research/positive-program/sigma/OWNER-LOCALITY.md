# Owner-locality across all 52 families — and a correction to my own framing

**Verdict: the test proposed in `REFUTER-DELEGATED-ALLOCATION.md` §5 item 1 was
the wrong test. Running it showed why. Item 1 is reformulated, not closed, and
the reformulated version is blocked on convention 6h like everything else.**

Script: `sigma/owner_locality.py`.

---

## What was measured

Every identifier the section-5 ledgers commit each candidate primitive to,
classified by how the corpus introduces it:

| introduced as | count |
|---|---|
| `pure def` | 83 |
| `type` | 16 |
| **`action`** | **6** |
| `var` | 4 |
| unresolved (reported, not assumed) | 4 |

**46 of 52 rows resolve entirely to functions and carriers. Six identifiers
across four rows are `action`s** — `requestRedeem`, `processRedeem`
(`WITHDRAWAL_QUEUE`), `triggerDefault` (`FIRST_LOSS_COVER`), `lockCrv`
(permanent lock), `activateDesert`, `desertExit` (escape hatch).

So the premise as I stated it — *every family is a `pure def`, hence a function*
— **is false.**

## All six were then read by hand

| action | determined by its arguments? |
|---|---|
| `requestRedeem(u, sh)` | yes — moves `u`'s own shares |
| `processRedeem(u)` | yes — one post-state per `u` |
| `triggerDefault` | yes — no arguments at all |
| `lockCrv(u, amount)` | yes — `u`'s own funds |
| `activateDesert` | yes — guarded on `time` and the queue head |
| `desertExit(u)` | yes — `u`'s own L2 balance |

None has a chooser over post-states: fix the arguments and the post-state is
unique.

## Why that does not rescue the argument

**`reallocate` is also deterministic given its arguments.** In
`quint-models-v2/metamorpho.qnt` it is `reallocate(caller, mFrom, mTo, amt)`, and
fixing those fixes the result. The discretion lives in *which arguments the
allocator supplies* — and that is equally true of `requestRedeem(u, sh)`, where
the user picks `sh`.

**So determinism-given-arguments does not separate the mandate from the basis,
and neither does `pure def` versus `action`.** Both tests are about the shape of
the definition. The mandate differs in something the definition's shape cannot
express:

> **Owner-locality.** A transition changes only positions attributable to *its
> caller*. `requestRedeem(u, sh)` is owner-local when the caller is `u`.
> `reallocate` is not, because the allocator moves the depositors' assets.

The distinguishing quantity is **who called**, and it appears in neither the
type of a `pure def` nor the arity of an `action`.

## The consequence, which is now the session's recurring shape

Owner-locality cannot be checked on the v1 corpus, because **no spec models the
caller**. `processRedeem(u)` is owner-local if a depositor calls it for
themselves and non-local if a pool delegate calls it for someone else, and the
spec does not say which — it has no caller at all. That is deletion class 11
again, arriving from a fourth direction.

And `triggerDefault` is the sharpest instance. Its comment reads *"**Delegate**
triggers default — cover absorbs first loss"*. A named party chooses **when** to
realise a loss borne by depositors. `corpus50/VERDICT.md` §1 names Maple pool
delegates as an instance of the delegated allocation mandate, alongside Morpho
curators. **So `triggerDefault` is plausibly a second witness to the refuter
rather than a counterexample to it** — and the spec deleted the delegate, so any
caller may fire it.

## Correction to `REFUTER-DELEGATED-ALLOCATION.md` §5

Item 1 read: *"Owner-locality must be verified for every family, not the seven
read here."* It should read:

> 1. **Owner-locality is not checkable on the v1 corpus at all.** The `pure def`
>    / `action` split is not a proxy for it — 46 of 52 rows are functions, the
>    other 6 are deterministic actions, and `reallocate` is deterministic given
>    its arguments too. What separates them is who may supply those arguments,
>    which no v1 spec records. Verifying owner-locality requires convention 6h
>    first, and then a per-family check against re-specs that carry callers.

## What still stands, and what does not

**Stands.** The exhibit itself: `reallocate` at `MetaMorpho.sol:366` is
role-gated, moves depositors' assets, satisfies conservation exactly (`:414`),
and is machine-checked in `metamorpho.qnt` to be invisible to every invariant the
corpus writes.

**Does not stand.** Any claim that the basis is *provably* function-only, or that
owner-locality has been verified. It has been verified for one mechanism — the
one written under 6h — and is unverifiable for the other 52.

**Unchanged.** Completeness is not recorded as refuted.

## Reproduce

    python3 sigma/owner_locality.py
    grep -n -A14 "action processRedeem" quint-models/L1/maple.qnt
    grep -n -B3 -A14 "action triggerDefault" quint-models/L1/maple.qnt
