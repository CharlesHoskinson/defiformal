# THE FIDELITY CRITERION

> ## AMENDED 2026-08-05 after plan review (`P2-REVIEW.md`)
>
> **Two repairs are applied below and override the original text wherever they
> conflict.**
>
> **R1 — F3 Parsimony no longer authorises deletion.** As originally written, F3
> instructed the worker to collapse any distinction the mutant suite did not
> need and *iterate to a fixed point*. The worker also authors the mutant suite,
> so a thin suite licenses deleting almost anything — and the generation
> measurement becomes circular, since the corpus would then be a function of the
> ten contrast sets. This is the same failure shape as the three known traps
> (the check passes because the stressing states were removed), except mandated.
> F3 is now a **reporting** obligation. Deletion additionally requires the
> contract-facing droppability test of section 2, which dominates.
>
> **R4 — the contrast set has three mandatory members.** Distant rivals are free
> to kill; Curve's own blend beats a contrast set of constant-sum plus
> constant-product. Every contrast set must contain, in addition to whatever the
> author chooses:
>   1. **the v1 shortcut body itself** — the exact abstraction this re-spec
>      exists to remove, as a live rival;
>   2. **a chaos relaxation** — the maximally permissive version in the same
>      relaxation direction, uniform across all ten;
>   3. **a near neighbour** agreeing with the target on at least 90% of the
>      declared domain, sourced from a sibling protocol already in the corpus.
>
> Three repairs (T0 conformance vectors, the extended nondet convention, and the
> i64 domain fixes) are specified separately in the repaired execution contract.


## 0. Verdict on the proposed criterion

> *"faithful iff there is a simulation relation to the contract's transition system that is
> surjective on mechanism-distinguishing traces"*

**Reject as stated, on two independent grounds. The core idea — mechanism-distinguishing
traces — is right and is kept.**

**(a) It points the wrong way, and so it does not reject `liquity`.** A simulation from the
spec into the contract that is *surjective on contract traces* says every contract behaviour
is matched by the spec: `B(C) ⊆ B(Q)`. Liquity's `redeem(u, boldAmt)` **satisfies** that. The
contract redeems the lowest-interest-rate trove; the spec can redeem *any* trove, so in
particular it can redeem that one. Surjectivity holds. What fails is the *opposite*
inclusion: the spec has behaviours the contract has none of — redeeming trove 3 while trove 1
carries a lower rate. Liquity's spec is a sound over-approximation, and over-approximation is
invisible to every one-sided criterion. This is the general trap: refinement theory was built
to certify that implementations do not exceed their specs, and the failure here is the spec
exceeding its implementation. `chaos` refines nothing but is refined by everything.

**(b) No refinement relation of any direction can reject the too-concrete failure.** A
line-by-line Solidity transliteration is *bisimilar* to the contract — the best possible score
under any simulation-based criterion. So the Goldilocks problem cannot be solved by one
relation. It needs a relation **plus a minimality condition**, and the minimality condition
does not come from refinement theory at all: it comes from what the spec is *for*. We are
proving "the basis generates the spec". That claim quantifies over the spec's definitions.
So the spec's definitions must be exactly the mechanism-carrying ones — no fewer (or
generation measures nothing) and no more (or generation is a claim about Solidity).

The corrected shape: **a spec is faithful iff it is a *quotient* of the contract — the
coarsest system still equivalent to it on the declared observables.** Too abstract = not
equivalent. Too concrete = equivalent but not coarsest. One equality, two failure modes.

---

## 1. The criterion

**Setup.** A contract is a labelled transition system `C = (S_C, s⁰_C, →_C)`. An
**observation interface** `O = (Λ, α, obs)` fixes an abstract action alphabet `Λ` with typed
arguments, a map `α` sending each external call of `C` either into `Λ` or to `τ`, and an
observation map `obs : S → D` into the **value-flow domain**: for each named party, what is
owed, by whom, in what asset, under what condition; plus phase and authority. `B_O(X)` is the
set of **failures** — pairs `(t, R)` with `t ∈ Λ*` annotated by `obs` at each point and
`R ⊆ Λ` the actions refused after `t`. Failures, not traces, because most of a DeFi mechanism
is a *prohibition*: "you may not redeem that trove" is a refusal, and refusals are what a
trace model throws away.

A **contrast set** `𝔐(P) = {M₀, M₁, …, M_k}` is a written list of rival mechanisms for the
protocol's characteristic operation, `M₀` the real one, each `M_i` a syntactic substitution
into the spec at the same definition site. Admissibility: each `M_i` must be either (i) the
mechanism of a really deployed protocol, or (ii) the obvious lazy alternative a modeller would
reach for. `Q[M_i]` is the spec with `M_i` substituted.

**Definition (faithful).** `Q` is faithful for `C` w.r.t. `(O, 𝔐, 𝒟)` — `𝒟` the declared
finite domain — iff:

- **F0 Declaration.** `O`, `𝔐`, `𝒟`, and every deliberate relaxation are written in the spec
  file, with contract line citations.
- **F1 Adequacy.** `B_O(Q) = B_O(C)` on the machine. *Both* inclusions. `⊆` forbids invented
  behaviour (liquity); `⊇` forbids lost behaviour (geometricMint).
- **F2 Discrimination.** For every `i ≥ 1`, `Q ≢ Q[M_i]`, witnessed by an exhibited separating
  behaviour.
- **F3 Parsimony (AMENDED R1 — reporting only).** Any strict collapse `Q′ ≺ Q`
  (quotient of a state variable, deletion of a field, coarsening of a definition)
  that still satisfies F1 and F2 is **recorded as a parsimony candidate**. It is
  NOT deleted on that basis alone: the mutant suite is author-supplied, so
  surviving it proves only that the author's rivals were weak. Deletion requires
  the contract-facing droppability test of section 2 to pass as well.
- **F4 Witness-hosting.** Every F2 witness lies inside `𝒟` and is producible by
  `quint run`/`quint verify` against the spec as shipped. A separating trace that needs
  balances outside `𝒟` does not count.
- **F5 Environment frontier.** Split `C` into machine (on-chain code) and environment
  (callers, oracles, prices, governance). For the environment, F1 is replaced by a two-sided
  *permissiveness* condition: **(E≥)** every environment input the machine cannot reject is
  enabled in `Q`; **(E≤)** every input the machine does reject is disabled in `Q`. No more
  permissive, no less.

**How the parts earn their place.** F1 is not checkable — `C` is an unbounded Solidity
program. F2 is its *finite falsifier*: if `Q ≡ C` then `Q ≢ Q[M_i]` for every `M_i` the
contract does not implement, because `Q[M_i] ≡ C[M_i] ≢ C`. So a surviving mutant **refutes**
F1 mechanically. That is the whole trick — it converts an unverifiable equivalence into a
finite refutation procedure, which is also what the programme's own refutability requirement
asks for. F3 is independent of F1 and comes from the generation theorem; it is what makes
"the basis generates `Q`" mean "the basis generates the mechanism". F4 stops the fraud of a
faithful formula on a domain too small for its faithfulness to matter — a real defect in
`curve` (§5.3).

**Lemma (why this licenses the theorem).** If `Q` satisfies F2 and F3, every definition in `Q`
is load-bearing for at least one mutant-separating witness. Hence a basis that generates `Q`
must generate every mechanism-carrying distinction in `P`, and — by F3 — nothing that is
merely Solidity. Both directions of the Goldilocks worry are discharged by the same pair.

---

## 2. The abstraction budget, derived

One rule, not a list. Everything below is a consequence.

> **Droppability rule.** A contract feature `f` may be dropped iff **(a)** no transition guard
> on any state-changing path reads `f`'s state, *or* every such guard is vacuous at the spec's
> step granularity; **and (b)** no `M_i ∈ 𝔐` is distinguished from `M₀` by `f`.

Test (a) is a static, citable grep over Solidity: does any `require`/`if`/early-return on a
state-changing path read this variable? Test (b) is the mutation harness of §3.

| Feature | Verdict | Derivation |
|---|---|---|
| Events / logs | **always drop** | Never read by any guard. Fails (a) trivially. |
| ERC20/1155 contract internals | **drop the contract, keep the map** | This is a change of *representation* of an observable, not loss of one. `obs` still reports the balance. |
| Gas, OOG padding | **always drop** | Not state. |
| Reentrancy guards | **drop** | Read by a guard, but constant across an atomic Quint action, so vacuous — (a)'s second clause. **This is conditional**: any re-spec that models callback interleaving must reinstate them. |
| Upgrade proxies, initializers | **drop** | Meta-mechanism over a fixed implementation. Exception: if the mechanism *is* governed parameter change, keep the timelock (it is F2/phase). |
| WAD/RAY scaling | **drop the 1e18** | Scale is representation. |
| Rounding direction (`mulDivDown`/`Up`) | **never drop** | Decides who absorbs the residual — protocol or user. That is a value-flow observable and the site of real exploits. |
| Caller-supplied resource caps (`_maxIterations`) | **drop** | Caller-side restriction of the same mechanism; `_maxIterations = 0` (unbounded) is a legal call, so the uncapped walk is a real behaviour. |
| Protocol-enforced caps | **never drop** | Endogenous; changes the reachable set. |
| Access-control modifiers | **default keep**; drop only via (b) | They *are* read on state-changing paths, so (a) does not clear them. `onlyOwner setFee` clears (b) if no mutant is "permissionless fee". `onlyAdmin resolveManually` does not clear (b) — it changes *who determines the payout*. |
| Multi-asset arity (N→2) | **drop to the smallest arity that hosts every F2 witness** | Derived by F4, not chosen. |
| **Selection rule** (argmin/argmax, sorted order, queue discipline, prefix consumption) | **never drop** | Parameterising replaces `min S` with `∈ S`; these agree only on singletons. This is the canonical failure. |
| **Trading function / invariant shape** | **never drop** | Need not be exact — must agree with the real function on a set that separates it from every rival in `𝔐`. |
| **Endogenous termination** (`while remaining > 0`) | **never drop** | It is what couples request size to extent of effect. |
| **Phase / delay / liveness windows** | **never drop** | Deleting the delay collapses two-phase claim into one-phase. |
| **Cross-user coupling** (redistribution, socialised loss, index accrual) | **never drop** | Without it the protocol is a disjoint union of single-user protocols. |

---

## 3. The decision procedure

**Mechanical core — bidirectional mutation.**

1. **Build the mutant suite.** Each `M_i` is a Quint module that re-exports `Q` with one
   definition overridden. `k` between 3 and 6 per protocol.
2. **Discrimination run (F2).** For each `i`, model-check `Q` and `Q[M_i]` against the same
   invariant/witness set, or run a product driver asserting the two agree. Require an
   **explicit separating witness** — a state or trace, printed, inside `𝒟`. *No witness ⇒
   fail.* Green means: every mutant killed, each with a named trace.
3. **Parsimony run (F3) — AMENDED R1.** For each spec-side distinction `d`, form
   `Q/d` and re-run step 2. If `Q/d` still kills all mutants and preserves all
   declared invariants, **record `d` in a parsimony report**. Do NOT delete it,
   and do NOT iterate to a fixed point. Deletion is permitted only when the
   section 2 contract-facing test also says `d` is droppable — i.e. no
   state-changing guard in the contract reads it and no rival mechanism turns
   on it. A distinction the contract uses stays, however weak the rivals are.
4. **Frontier check (F5).** For each environment input, enumerate the on-chain `require`s at
   the boundary; assert reachability of *every* input value they permit, and unreachability of
   every value they forbid.

**Checklist — objective questions, all yes/no.**

1. Is `O` (observables), `𝔐` (rivals), `𝒟` (domain) written in the file header?
2. Does every action carry a `contract:line` citation, and does every state-reading `require`
   at that line appear as a guard or a recorded relaxation?
3. Does the spec take as a *parameter* any quantity the contract *computes*? (Any `action
   f(x)` where `x` is chosen by `oneOf` in the driver but derived from state in Solidity is an
   automatic fail.)
4. Is there any **write-only state** — a field assigned and never read in any guard?
5. Does every mutant have a printed separating witness inside `𝒟`?
6. Does every state variable and record field appear in at least one witness or invariant?
7. Are all `fold`s commutative sums? (See §6.)
8. Does any comment contain "abstract", "approx", "simplified", "stand-in", "conservative",
   "for quint purity"? Each is a confession; each requires a discharged mutant.
9. Do the declared bounds `𝒟` admit the regime where the mechanism differs from its rivals?
10. `quint typecheck` and at least one `quint run` of an invariant, both green.

---

## 4. Application to the three exhibited deletions

### 4.1 `redeem(u, boldAmt)` — REJECTED, four times over

Contrast set: `M₀` lowest-annual-interest-rate-first with prefix consumption
(`TroveManager.sol:770,785` — `getLast()` then `getPrev()`); `M₁` lowest-ICR-first (Liquity
v1); `M₂` redeemer's choice; `M₃` pro-rata across all active troves.

- **F1 (`⊆`) fails.** The spec admits a behaviour with two active troves at rates 5 and 12 in
  which the rate-12 trove is redeemed. `C` has no such behaviour. This is the inclusion the
  proposed criterion omits.
- **F2 fails.** `Q` *is* `M₂`, so mutant `M₂` is unkillable — there is no separating trace by
  construction. `M₃` also survives on the singleton-trove traces the driver mostly explores.
- **Checklist Q3 fails** by inspection: `u` is a parameter supplied by
  `nondet u = USERS.oneOf()` (`liquity.qnt:177`) and is computed in Solidity.
- **Checklist Q4 fails**: `Trove.rate` (line 22) is written at `openTrove` (line 69), copied
  through `redeem` (line 153), and **read by no guard anywhere**. The spec carries the sort key
  and never sorts by it. That is the deletion, visible statically.
- Second lost observable: the contract consumes a *prefix* sized by `remainingBold`, so the
  number of troves touched is a function of the redemption amount. The spec's
  `boldAmt <= t.debt` makes that function constant at 1.

### 4.2 `geometricMint → min(a₀,a₁)` — REJECTED

Contrast set: `M₀` `√(a₀·a₁)`; `M₁` `min`; `M₂` `(a₀+a₁)/2`; `M₃` `a₀`.

Computed: `(1,4) → √=2, min=1, mean=2`; `(2,8) → 4, 2, 5`; `(9,16) → 12, 9, 12`;
`(5,5) → 5, 5, 5`. **The spec equals `M₀` exactly on the diagonal `a₀=a₁`, which is precisely
the set where every member of the contrast set coincides.** The spec is correct only where
correctness carries no information. F2 fails maximally: zero mutants killed. F1 fails both
ways (`C` mints 2 on `(1,4)`; `Q` mints 1 and `C` never does).

The mechanism lost is not "an arithmetic detail": the geometric mean is the unique symmetric
degree-1-homogeneous function whose level sets *are* the constant-product curve, so
"shares = the invariant" is the mechanism, and `min` is not any AMM invariant.

### 4.3 `approxD → weighted blend` — REJECTED, and worse than it looks

Contrast set: `M₀` Newton on `(Ann·S + D_P·n)·D / ((Ann−1)·D + (n+1)·D_P)`; `M₁` `S`
(constant-sum); `M₂` `2√(xy)` (constant-product); `M₃` the blend.

Computed at `A=100, n=2` (Curve `get_D` vs `blend` vs `2√(xy)`):

| `x, y` | Curve D | blend | `2√(xy)` |
|---|---|---|---|
| 100, 100 | 200 | 200 | 200 |
| 100, 25 | 124 | 124 | 100 |
| 150, 50 | 199 | 199 | 172 |
| 190, 10 | **196** | 199 | 86 |
| 199, 1 | **170** | 199 | 28 |

The blend tracks Curve in the near-peg regime and collapses to `S` in the tail — it is a
constant-sum AMM with a kink at `x=y`, exactly the geometry Curve exists to *not* have. `M₁`
survives everywhere the spec's own driver goes. **F4 is the sharper failure**: the spec
initialises at `bal0 = bal1 = 100` and the separating region begins around 190/10, so the
witness that would kill `M₁` is not hostable in `𝒟`. Even a corrected `approxD` would fail
F4 until the domain is widened to reach depeg. That defect is invisible to any criterion that
does not make the domain part of the spec.

---

## 5. The hardest case: `polymarket`

The mechanism is off-chain, so state what fidelity *cannot* mean: it cannot mean modelling
UMA's proposers, bonds, or DVM vote. F5 gives the right answer — **fidelity is fidelity of the
trust boundary, not of the oracle.**

Two mechanisms must survive, on opposite sides of the frontier.

**(a) Complementary split (machine side).** `YES + NO ≡ collateral`: `split`/`merge` are
mutually inverse, payouts sum to one unit, locked collateral ≡ outstanding complete sets. The
non-obvious content is that a holder of a complete set can recover collateral **without the
oracle**, at par, at any time before resolution — a *possibility* property, which is why the
criterion uses failures and not traces: `merge` must be shown never to be refused when a
complete set is held. Contrast set: `M₁` independent YES and NO each backed 1:1 (no merge);
`M₂` parimutuel — payout is a pro-rata share of the losing pool, no fixed unit. `M₂` is the
serious rival: same user interface, different mechanism. The existing spec **passes** here:
`split`/`merge`, `redeemPayout = y·payout.yes + n·payout.no`, and `inv_complementary_lock`
kill both.

**(b) Optimistic resolution with dispute (frontier).** The existing spec **fails completely**.
`resolve(1,0)` (`polymarket.qnt`) is atomic, unconditional and gated only on `phase == Open` —
it is a trusted single-oracle write, i.e. it *is* the rival mutant `M₁ = trusted oracle`, so
`M₁` is unkillable. F2 fails.

What F5 demands, read off `UmaCtfAdapter.sol`:

- **(E≥) The payout must be genuinely adversarial.** Every payout vector the adapter cannot
  reject must be reachable in every pre-resolution state. Mechanically: assert that from any
  reachable `Open` state, all three of `[1,0]`, `[0,1]`, `[1,1]` are reachable. This is the
  formal content of "you may not assume the oracle is honest": no invariant may be provable
  that depends on which one arrives.
- **(E≤) …but only those.** `PayoutHelperLib` admits exactly `[1,0]`, `[0,1]`, `[1,1]`;
  `[0,0]` and `[2,0]` are rejected on-chain and must be unreachable in `Q`. `validBinaryPayout`
  already does this — keep it.
- **The adapter's own state machine is machine-side and is mandatory.** `initialize` →
  `_requestPrice` → proposal → *liveness elapses without dispute* → `resolve`; `priceDisputed`
  (line 163) resets the question **once**; a second dispute sets `refund = true` and does
  **not** reset (lines 175–182); `_resolve` (line 423) resets on the ignore-price. The
  `reset`/`refund` flags are on-chain storage read by guards, so rule (a) forbids dropping
  them: *at most one automatic re-request* is the mechanism, and one boolean carries it.
- **Time is not droppable here.** "Silence for Δ equals assent" is the whole of optimism; a
  spec without a liveness clock cannot express it.
- **Admin overrides are not droppable.** `resolveManually`, `pause`, `flag` are `onlyAdmin`
  guards on state-changing paths; they fail rule (a), and they fail (b) too because
  "authority can override the oracle" versus "cannot" is a live rival mechanism.
- **Bonds and reward tokens are droppable.** Objective test: no on-chain transition is *gated*
  on the bond amount — it is set, forwarded, never compared. It fails rule (a). The incentive
  argument for why disputes happen is off-chain and outside `O`. Reward *refunds* move value,
  so they survive as a scalar ledger effect.

So the polymarket target: `phase ∈ {Uninit, Requested, Proposed(p, expiry), Disputed,
Resolved(p), Paused}`, a clock, a one-shot `reset` flag, adversarial proposal, and admin
override — with the CTF ledger unchanged. Contrast set `{optimistic-with-single-reset,
trusted-write, committee, no-dispute-immediate-finality}`.

---

## 6. Regression signals (mechanical, corpus-wide)

Each is a grep-level *presumption of failure*, discharged only by a passing mutant witness:

1. **Commutative-fold monoculture** — every `fold` of the form `fold(0, (acc,x) => acc + …)`.
   No `fold` in the corpus computes an argmin, a running remainder, or a prefix cut.
2. **Write-only fields** — a record field assigned and never read in a guard (`Trove.rate`).
   The signature of a deleted ordering.
3. **Computed-quantity-as-parameter** — an action argument bound by `oneOf` in the driver that
   Solidity derives from state.
4. **No `List` in an ordered protocol** — `Set`-only state where the contract holds a linked
   list, heap, or queue. Only `lighter.qnt` uses `List` with `head`/`tail`.
5. **Confession comments** — "abstract", "approx", "simplified", "stand-in", "for quint
   purity", "conservative lower bound".
6. **Degenerate domains** — `init` at a symmetric point with bounds too tight to reach the
   regime where the mechanism differs from its rivals (`curve` at `100/100`).
7. **Single-user-sufficient invariants** — every invariant provable with `|USERS| = 1`,
   indicating no cross-user coupling survived.

---

## 7. Where judgment still lives — the honest residue

The criterion does not eliminate taste; it **relocates all of it into one reviewable artifact,
the contrast set `𝔐`.** Given `𝔐`, F1–F5 are objective and largely mechanical. `𝔐` itself is
chosen, and a lazy `𝔐` yields a lazy spec — the same failure one level up. Two mitigations,
both cheap: (i) admissibility — every `M_i` must be a really deployed protocol or the obvious
lazy alternative, which makes a thin contrast set visible as such; (ii) `𝔐` is reviewed
*before* the re-spec is written, by someone other than its author. A minimal discriminating
spec need not be unique, but any two agree on `𝔐`, so the residual freedom is over
presentation, not content.

One further honest limit: F1 is never verified, only left unrefuted. The programme should say
so. What it buys is precise — a spec that has survived a published, adversarial contrast set
is a spec whose mechanism is *present and exercised*, which is exactly and only what the
generation theorem needs.
