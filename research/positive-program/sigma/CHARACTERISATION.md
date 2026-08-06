# The delegated allocation mandate, characterised

**Result: the basis is incomplete by exactly one coordinate. The mandate factors
as `Perm ⋈ Led.move`, where `Led.move` is already primitive `P1` and `Perm` — a
permission gate — is not in the basis and cannot be composed from it.**

Machine-checked in `quint-models-v2/metamorpho.qnt` (`inv_separation` `[ok]`).

---

## 0. A correction that reshaped the argument

`REFUTER-DELEGATED-ALLOCATION.md` §3 characterised the object by **owner-locality**
— *a transition changes only positions attributable to its caller*. That is
wrong, and the counterexample is inside the basis:

    aave_v3.qnt:156   action liquidate(borrower: str, repayAmt: int)

Liquidation seizes the **borrower's** collateral and is called by somebody else.
It is non-local and it is a basis family. **Non-locality is not the separating
property**, and any characterisation resting on it collapses.

What survives is sharper, and the rest of this note is the corrected version.

---

## 1. Setup

Factor the state into two coordinates:

    S  ≅  P × R

- **P — positions.** Balances, supplies, debts, reserves: the quantities that
  conserve and that principals own.
- **R — the role assignment.** A map `N → 2^Roles`. It is state, it is mutable,
  and it is *not* a position: it does not conserve, it cannot be transferred, and
  no arithmetic law relates it to `P`.

**Definition (permission-free).** A transition `t` is *permission-free* if its
guard and effect factor through `P`:

    ∀ p ∈ P, ∀ r, r' ∈ R :   enabled(t, (p,r)) ⟺ enabled(t, (p,r'))
                        and  effect(t, (p,r)) =P= effect(t, (p,r'))

Equivalently: `R` is a **spectator coordinate** for `t` — never read, never
written.

---

## 2. Claim 1 — every basis family is permission-free

Checked against the definitions, not assumed:

| family | guard reads | permission-free |
|---|---|---|
| `Led` credit/debit/move | the caller's own balance | yes |
| `Prop` (pro-rata) | totals | yes |
| index accrual | index, rate, elapsed | yes |
| `Cmp` health / `isHealthy` | collateral, debt, price | yes |
| **`liquidate`** | **the victim's health — and anyone may call** | **yes** |
| trading function | reserves | yes |
| rate curve / `currentLimit` | utilisation, elapsed | yes |

Liquidation is the instructive row. It is non-local *and* permission-free: the
right to intervene is granted by a **state predicate**, not by an identity.
Anybody may liquidate an unhealthy position. That is precisely what a mandate is
not.

Machine-checked at `metamorpho.qnt`: `t0_deposit_permission_free` and
`t0_liquidate_permission_free` hand each guard the role map and show it constant
in it.

*(Caveat: the v1 corpus deleted access control everywhere — `DELETION-11.md`,
`GATE-1.1B-PAIR4.md` — so "no family reads `R`" is partly a fact about the specs
rather than about DeFi. The Solidity does gate `liquidate` in some protocols by
allowlist. Claim 1 holds for the basis **as defined**, which is what the
generation theorem quantifies over.)*

## 3. Claim 2 — permission-freedom is closed under composition

**Lemma.** Let `F` be a set of permission-free transitions and let `⋈` build
composites by sequencing members of `F`, conditioning on their guards, and
combining their effects. Then every `⋈`-composite is permission-free.

*Proof.* Induction on composite structure. **Base:** generators are
permission-free by hypothesis. **Sequencing:** if `t₁, t₂` never read or write
`R`, the intermediate state's `R`-component equals the initial one and is unread,
so `t₂ ∘ t₁` factors through `P`. **Conditioning:** a guard built from
permission-free guards is a boolean combination of `P`-functions, hence a
`P`-function. **Combination:** effects that fix `R` compose to an effect that
fixes `R`. ∎

The content is one sentence: **`R` is a spectator coordinate for the whole
closure of `F`, because nothing in `F` can see it.**

*(This is where `⋈` matters. The lemma holds for any operator that builds
composites **from the generators**. An operator that could introduce a fresh
state read would not be composing them — it would be adding a primitive, which is
the thing under test.)*

## 4. Claim 3 — the mandate is permission-dependent

`reallocate` (`MetaMorpho.sol:366`, `onlyAllocatorRole` at `:147-155`) has a
guard reading `isAllocator[caller]`. Machine-checked, one line:

    t0_mandate_permission_dependent:
        hasAllocatorRole("mallory", ROLES_YES, "curator")
      ∧ ¬hasAllocatorRole("mallory", ROLES_NO,  "curator")

Identical positions, identical caller, identical arguments; only `R` differs and
enablement flips.

## 4b. Necessary but not sufficient — see `APEX-LIQUIDATE.md`

Permission-dependence alone does **not** identify a mandate. `apex.liquidate`
reads `R` — `routerMap`, mutable by the owner — and is not a mandate: the router
relays and exercises no discretion. The additional condition is that the gate be
**non-surjective**, i.e. the permission cannot be self-acquired:

- MetaMorpho's `isAllocator` is reachable only through `setIsAllocator`
  (`onlyOwner`) — non-surjective, a mandate.
- apex's router path is reachable by any user through an open `Router.liquidate`
  — surjective, not a mandate.

**The theorem below is unaffected**, because the basis contains no `R`-reading
generator at all and so fails the first condition already. The refinement matters
for classifying `R`-reading transitions once convention 6h puts them in the
corpus.

## 5. Theorem

> **The mandate is not in the closure of the basis.**
> By Claim 1 every generator is permission-free; by Claim 2 so is every
> composite; by Claim 3 the mandate is not. ∎

Stated honestly, the content is: **the basis has no role coordinate, and the
mandate needs one.**

---

## 6. What the object *is* — the constructive half

The theorem says something is missing. This says exactly what.

**Definition (delegated allocation mandate).** A tuple

    M = (N, Roles, ⊑, A, C, act)

- `N` principals; `Roles = {owner, curator, allocator, guardian}`;
- `⊑` a **delegation order**: `owner ⊒ curator ⊒ allocator`, `guardian` holding
  revocation only;
- `A : S → (N → 2^Roles)` the assignment, **mutable only by strictly-⊒ roles**
  (`setCurator` `:186`, `setIsAllocator` `:195`, both `onlyOwner`);
- `C : S → Constraints` the caps, settable by `curator` (`submitCap` `:273`);
- `act` a **conservative non-local redistribution**, enabled iff the caller holds
  `allocator` and the result satisfies `C`, preserving `Σ pos` (`:414`).

### The factorisation

`act`'s *effect* — move `amt` from market `i` to market `j`, total preserved — is
exactly `BASIS.md`'s `P1 · Led`:

> `move : N × N × Q ⇀ Led`, with *Conservation*: `‖bal‖ = sup` preserved.

So the effect is **already primitive**. Everything the mandate does beyond
`Led.move` is the gate. Hence:

> **`mandate  =  Perm ⋈ Led.move`**

where `Perm : (N → 2^Roles) × N × Roles → Bool` is a permission gate, together
with `grant`/`revoke` which are themselves `Perm`-gated.

**This is the precise sense in which the basis is incomplete: by one primitive,
and that primitive is `Perm`.** Not by a family of missing mechanisms — the
survey's residue long tail is idiosyncrasy, not structure (`RESIDUE-LONGTAIL.md`)
— but by a single coordinate the whole corpus was written without.

### Laws `Perm` must satisfy

Read off the contract, each falsifiable:

1. **Monotone delegation.** `A` is mutable only by strictly-⊒ roles. An allocator
   cannot appoint an allocator.
2. **Revocability.** For every grant there is a `⊒`-reachable revoke
   (`guardian`, `:420-427`).
3. **Bounded discretion.** `act` ⊆ `C`, and `C` is set by a strictly-⊒ role than
   the one exercising `act`. Curator sets caps, allocator acts within them.
4. **Conservation.** `act` preserves `Σ pos` exactly.
5. **Position-blindness of the gate.** `Perm` reads `R` only — holding a role is
   independent of holding a position. (Mallory has zero shares throughout.)

Law 5 is the one that makes it irreducible; laws 1–3 are what make it *safe*, and
are the "role SPLIT that makes curated vaults safe" the corpus residue named and
could not express.

---

## 7. Why the corpus's observables are blind — as an equation

Let `O_cons(s) = Σ_n pos(s,n)` and `O_share(s,n) = pos(s,n)`.

**Conservation cannot separate two allocations.** Machine-checked:

    totalAssets({0↦100, 1↦200, 2↦0}, 0)  ==  totalAssets({0↦0, 1↦0, 2↦300}, 0)

Two distributions with nothing in common, one observable value. No predicate on
`O_cons` distinguishes them, so no conservation law can detect *which*
reallocation occurred — or that one occurred at all.

**Share accounting cannot either.** `reallocate` leaves every `O_share(·,n)`
fixed; `inv_sharesSum` is `[ok]` across it.

**The discriminating observable is the pair `(caller, n ↦ Δpos(n))`** — who
acted, and the whole distribution vector, not its sum. Neither component alone
suffices. That is a theorem about the observable, and it explains the empirical
result Phase 2 kept hitting from the other side: *conservation never once
detected a deleted mechanism*, because conservation is a function of `Σ pos` and
mechanisms live in the distribution.

---

## 8. What this establishes, and what it does not

**Establishes.** A precise definition of the object; a proof of its
irreducibility relative to the basis as defined; the exact missing primitive
(`Perm`); five falsifiable laws; and a proof that the corpus's two invariant
families cannot detect it.

**Does not establish.** That `Perm` is *atomic* — given a role-reading primitive
the mandate decomposes immediately, which is the point of §6. Nor that the basis
is complete once `Perm` is added; that is the generation theorem and it is
untouched.

**Consequence for the paper.** The result is not "completeness refuted" but the
sharper and more useful:

> A basis for permission-free DeFi, plus a proof that permission-gated
> reallocation is irreducible to it, plus the minimal extension that repairs it.

That is `GOAL.md`'s second branch, with a named repair rather than only a
delimitation — and with four independent corpus witnesses (`RESIDUE-MINED.md`:
Morpho, Liquity V2 batch managers, Steakhouse, Grove) where no basis family has
even two.

## Reproduce

    cd quint-models-v2
    quint run metamorpho.qnt --invariant=inv_separation --max-steps=20 --max-samples=3000
    grep -n -A6 "action liquidate" ../quint-models/L1/aave_v3.qnt
