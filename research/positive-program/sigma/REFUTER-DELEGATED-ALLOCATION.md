# The delegated allocation mandate, exhibited

**Status: a candidate refuter is now EXHIBITED against contract source, where
before it was asserted. It is not yet a theorem, and section 5 says exactly what
is missing.**

Source: `protocol-repos/lend/morpho-org_metamorpho`, rev `58e758b` (2026-07-31),
`src/MetaMorpho.sol`.

---

## 1. Why this object, and why now

`corpus50/VERDICT.md` §1 calls the delegated allocation mandate **the
most-confirmed gap in the project** — reached independently by all three lanes
(Morpho curators, Maple pool delegates, Liquity V2 batch managers; Steakhouse at
$3.08B). `GOAL.md` requires refutability: *"There must be a statable object whose
exhibition refutes completeness."*

`TODO.md`:16 records that Steakhouse Financial "is a known refuter (delegated
allocation authority) and **needs no further work to count against
completeness**."

**That is a refutation asserted rather than exhibited.** An unformalised protocol
is not a statable object. Worse, the reason it was never formalised is now known:
stating this mechanism requires modelling *who called*, and **0 of 17
gate-opening actions in the corpus model caller authority** (`GATE-1.1B-PAIR4.md`).
The programme has been carrying its refutation as an assumption, for the same
reason it could not test the autonomy law.

MetaMorpho is the formalisable instance of the same mechanism — lane 1's own
example — and its source is on disk.

## 2. The mechanism, from source

Four roles, each gating a distinct discretion:

| line | function | gate |
|---|---|---|
| `:186` | `setCurator` | `onlyOwner` |
| `:195` | `setIsAllocator` | `onlyOwner` |
| `:273` | `submitCap` | `onlyCuratorRole` |
| `:308` | `setSupplyQueue` | `onlyAllocatorRole` |
| `:323` | `updateWithdrawQueue` | `onlyAllocatorRole` |
| `:366` | **`reallocate`** | `onlyAllocatorRole` |

`onlyAllocatorRole` (`:147-155`) admits `isAllocator[sender]`, the curator, or
the owner.

`reallocate(MarketAllocation[] calldata allocations)` moves depositors' assets
between Morpho Blue markets. Its constraints are exactly three:

- `:400` the target market must have a non-zero cap — `UnauthorizedMarket`;
- `:402` `supplyAssets + suppliedAssets > supplyCap` reverts — `SupplyCapExceeded`;
- `:414` `totalWithdrawn != totalSupplied` reverts — `InconsistentReallocation`.

## 3. The property that fails — SUPERSEDED, see `CHARACTERISATION.md`

> **This section is wrong and is kept for the record.** Owner-locality fails for
> `liquidate` too (`aave_v3.qnt:156` seizes the *borrower's* collateral and is
> called by someone else), and liquidation is a basis family. Non-locality is not
> the separating property. The corrected characterisation is
> **permission-dependence** — whether the guard reads the role coordinate — and
> it is in `sigma/CHARACTERISATION.md`, machine-checked.

## 3. The property that fails — owner-locality (superseded)

Every family in the basis is a `pure def`: a **function** of the state and of
amounts supplied by the caller, and it moves only balances attributable to **that
caller**. `sharesFromAssets`, `assetsFromShares`, `presentFromScaled`,
`accrueIndex`, `isHealthy`, `currentLimit`, `cpAmountOut` are all of this shape —
verified by reading `L1/common.qnt:14-127`, `L3/common.qnt:92-196`,
`L6/common.qnt:112-140`.

Call this **owner-locality**: *a transition changes only positions attributable
to its caller.*

`reallocate` violates it. The allocator supplies an arbitrary `allocations`
vector from calldata and thereby redistributes **other people's** deposits. The
depositors are not parties to the transaction.

This is the distinction `VERDICT.md` §1 records the lanes rejecting `Sv` over, in
the same words: *"it names discretion over a loan, not over an allocation. A
curator never touches a loan; the discretion is exercised before anything goes
wrong."*

## 4. Why no invariant in the corpus can see it

**`reallocate` satisfies conservation exactly** — that is what `:414` enforces.
It also respects non-negativity and every cap bound. So the entire invariant
vocabulary the corpus actually ships (`inv_conservation`, `inv_bounds`,
`shareConservation`, `supplyConserved`) holds across it.

This is the programme's own recurring finding, arriving from the other side.
Phase 2 established that *"conservation never once detected a deleted
mechanism"*. Here conservation holds **because the mechanism is genuinely
conservative** — and it is still the wrong observable. What distinguishes the
mandate is not what moves, nor how much, but **who chose**, and no conservation
law has a term for that.

## 5. What is exhibited, and what is not

**Exhibited.** A concrete, on-disk, line-cited mechanism; the precise property it
violates (owner-locality); a demonstration that the corpus's invariant vocabulary
cannot separate it; and the reason it was never formalised.

**Not yet a theorem.** Three things are missing, and none should be glossed:

1. **Owner-locality is not checkable on the v1 corpus at all** — reformulated
   after measurement; see `sigma/OWNER-LOCALITY.md`. The original wording said
   the property must be "verified for every family, not the seven read here",
   which presumed a `pure def` / `action` split would serve as a proxy. It does
   not. 46 of 52 rows resolve to functions, the other 6 are deterministic
   actions, and **`reallocate` is deterministic given its arguments too**. What
   separates them is *who may supply those arguments*, which no v1 spec records.
   Verifying owner-locality needs convention 6h adopted first, then a per-family
   check against re-specs that carry callers.
2. **The closure argument must be written.** The intuition is that owner-locality
   is preserved by composition — if each generator touches only its caller's
   positions, so does any composite — hence no composite reaches `reallocate`.
   Preservation under `⋈` has to be proved, not asserted; `⋈`'s definition is in
   `BASIS.md` and has not been checked against this property.
3. **A Quint witness should exist.** The mechanism can only be written down once
   convention 6h (`phase2/CONVENTION-6H-AUTHORITY.md`) is adopted, since it needs
   caller identity. Until then the refuter remains prose plus Solidity.

**Do not record this as "completeness refuted".** Record it as: *the refuter is
identified, cited and stated; the generation argument that would close it is
listed above.* The programme has already lost seven passes to a claim that was
believed rather than run.

## 6. Consequence for the roadmap

`GOAL.md`'s decision point — *"Step 2.1 decides what the paper is"* — now has
supporting evidence for the second branch:

> *A basis for pool-shaped DeFi, plus a proof that extremal allocation is
> irreducible to it.*

with the delegated allocation mandate as a second, independently-confirmed
irreducible object, and one with far more TVL behind it than extremal selection.

## Reproduce

    sed -n '139,160p;366,415p' \
      protocol-repos/lend/morpho-org_metamorpho/src/MetaMorpho.sol
    grep -n "onlyCuratorRole\|onlyAllocatorRole\|onlyOwner" \
      protocol-repos/lend/morpho-org_metamorpho/src/MetaMorpho.sol
