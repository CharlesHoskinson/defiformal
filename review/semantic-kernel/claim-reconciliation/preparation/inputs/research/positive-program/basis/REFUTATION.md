# REFUTATION — adversarial attack on the completeness of `P = {F1..F8}`

The attack that works is not "here is an exotic protocol." It is: **every family in `P`
is an operation on scalars held per account, and the eight of them are closed under
composition of such operations. A large, deployed, structurally coherent half of DeFi
consists of operations whose argument is the *ledger as an ordered set* — argmin,
sort, match, clear — and no composite of scalar operations produces one.**

Four survivors, ranked. Then the candidates I killed, including several the brief
nominated. Then the minimal repair.

---

## R1 — Endogenous price formation by matching (STRONGEST)

**The mechanism.** `GPv2Settlement.settle(tokens, clearingPrices, trades, interactions)`
(`/root/DefiElements/protocol-repos/intent/cowprotocol_contracts/src/contracts/GPv2Settlement.sol:115-132`,
`computeTradeExecutions` at :286-313). A solver submits a *uniform clearing price vector*
`p` over the batch's token set. Every order `i` in the batch is a signed limit
`(sell_i, buy_i, limitSell_i, limitBuy_i)`; the settlement is valid iff each order's
limit inequality holds *at the common `p`* and the batch nets to zero across all
tokens. Same shape: 1inch LOP's remaining-invalidator fills
(`/root/DefiElements/protocol-repos/intent/1inch_limit-order-protocol`), Polymarket's
CTF Exchange (`/root/DefiElements/protocol-repos/pred/Polymarket_ctf-exchange-v2`),
Lighter's proven price-time book, Kalshi's CCP match-and-novate (L6 §7,
"Novation / clearing house … no symbol").

**Why `P` does not generate it.** `P` has exactly two ways a price can exist. `F6` is
`() → (P)`: an *exogenous* source, read. `F4` lets a price be recovered from scalar
reserve state — the AMM route, `p = ∂Φ/∂x` for a pool invariant `Φ(x,y)`. Both are
functions of **bounded arity over protocol-held state**. A clearing price is neither.
It is the solution of a *feasibility problem over an unbounded multiset of private
declarations that are not protocol state at all* — the orders are off-chain signatures,
the batch composition is chosen by the solver, and `p` must simultaneously satisfy `n`
inequalities where `n` is unbounded. No finite composite of `F1..F8` has a signature
that can even *accept* that argument, let alone produce `p`. The distinguishing
property: **the output is jointly determined by the declared preferences of an
unbounded set of parties, and existence of an output is a constraint-satisfaction
question, not an evaluation.** An AMM always has an answer; a batch may have none.

`F4` cannot be stretched to cover it without conceding the non-degeneracy failure
below: "conservation" would have to mean "any solver-supplied witness satisfying any
predicate", at which point `F4` alone generates everything and `P` says nothing.

**Verdict: genuine refuter.** And it is not a corner case. `P` is a basis for
*pool-shaped* DeFi. Order-driven DeFi — CLOBs, batch auctions, RFQ, intent solvers,
clearing houses — is roughly the other half of the field by volume and is absent from
the basis entirely. The lanes saw this and it was dropped: L4 §5 records
`BATCH_CLEARING` and `SIGNED_ORDER_REMAINING` as candidate primitives, L3 §6 splits
`Ob` four ways (`Ob-AMM` / `Ob-CLOB-proven` / `Ob-CLOB-consensus` / `Ob-none-pool`),
and none of it survived into `F1..F8`.

---

## R2 — Extremal selection over the ledger (Liquity V2 redemption priority)

**The mechanism.** Liquity V2 (`/root/DefiElements/protocol-repos/cdp/liquity_bold`).
Each borrower *sets their own* `annualInterestRate` on their trove. `SortedTroves.sol`
maintains the troves in a doubly-linked list ordered by that rate. `TroveManager.
redeemCollateral` (:747-841) begins at `sortedTrovesCached.getLast()` and walks
upward, consuming troves **lowest-rate-first** until the redemption amount is filled
(:770, :783, :807). The borrower's rate choice is therefore not a credit price — it is
a *bid for position in a queue of systemic liability* (L2 §7, "Borrower-chosen
interest = redemption priority").

**Why `P` does not generate it.** This is an exact invariance argument, and it is the
cleanest refutation in this document. `F1`, the pro-rata share ledger, is **symmetric
under permutation of equal claimants**: two holders of equal shares are affected
identically by every `F1` action, because the allocation rule is proportional.
Composition preserves that symmetry pointwise. `F5` can *break* symmetry, but only
by a **pointwise predicate**: "every position with health < 1 is liquidable" is a test
each position passes or fails independently of the others.

Liquity's rule is neither. The set of troves redeemed is the minimal prefix of the
*global rate order* whose total debt covers the redemption size. Whether your trove is
touched depends on **how many other troves are cheaper and how large they are** — the
cut-off is `argmin` over an unbounded set, determined endogenously by the size of the
incoming redemption. That is a sort, not a predicate. No composite of pointwise
predicates and permutation-symmetric allocations computes a prefix of a total order.

Same structure, independently recorded: Huma's senior-first redemption waterfall
(L3 §7, "`Tr` names waterfall, not leverage bound"), Sky's descending `clip` auction
(L2 §6, `Li-descending-auction`), Lighter's priority queue, Maple's FIFO withdrawal
queue. `F2` (deferred claim) supplies the *delay* but carries no *discipline* — FIFO,
pro-rata rationing and price-priority are three different machines under one signature
`(K) → (K@later)`.

**Verdict: genuine refuter.** Structurally the same missing primitive as R1 — see the
repair — but worth stating separately, because it shows the gap is not confined to
exchanges. It sits in the middle of a CDP.

---

## R3 — Commitment-carrier ledgers (Lighter desert mode; shielded pools)

**The mechanism.** `/root/DefiElements/protocol-repos/perp/elliottech_lighter-contracts`,
`IZkLighterDesertMode` + `IDesertVerifier`. The L1 contract holds `totalDeposited` and
a state *root*. It does not hold anyone's balance. When the operator misses a priority
request deadline, anyone may set an irreversible mode bit; thereafter users exit by
submitting a Merkle proof of their leaf against the last committed root. Sharper and
outside the corpus: Railgun / Aztec / Privacy Pools, where the claim carrier is a
commitment tree plus a nullifier set — there is no account map at all, and "who owns
what" is not a question the contract can answer.

**Why `P` does not generate it.** Every family in `P` presupposes that the construction
can *read* the ledger. `F1` maps assets to a claim held at an index. `F4`'s conservation
law is a boundary condition on `A` and `K` — to state it you must be able to sum `K`.
Under a commitment carrier the construction cannot read a single balance and cannot
compute the sum; **its own solvency invariant is not expressible in its own state.**
What replaces it is: an accumulator, a one-time-spend set, and a verification relation
that *accepts a proof about state it does not have*. That is a different kind of object
— possession of a witness, not possession of a quantity.

The honest counterweight: the *observable balance behaviour* of the composite (deposit
in, prove, withdraw) is `F1`-shaped, so an extensional reading may say it is generated.
The refutation bites on the intensional claim the paper actually needs — that the
construction's invariants are theorems of `P`. Here they are theorems of the circuit,
which is not in `P`.

**Verdict: genuine refuter of the invariant claim; contested on pure behaviour.**

---

## R4 — Babylon: enforcement authority created by the fault

**The mechanism.** `/root/DefiElements/protocol-repos/lsd/babylonlabs-io_babylon`,
`CreateBTCDelegation`. The protocol holds nothing. The stake is a Bitcoin UTXO under a
Taproot script tree with a timelock path, a covenant unbonding path, and a slashing
path. Slashing is a **pre-signed transaction** whose completion requires the finality
provider's key — and that key is *extracted* from an EOTS double-signature. The fault
manufactures the secret that authorises the penalty (L2 §7: "enforcement is adaptor-
signature completion, not an on-protocol state write").

**Why `P` does not generate it.** `F5` is `(K, K*, P) → (V)`: an evaluator produces a
verdict, and a seizure action is gated on it. Babylon has no evaluator and no gate.
There is no state variable whose value is "slashable"; there is a *capability* that
either exists in someone's hands or does not, and it comes into existence as a
by-product of misbehaviour. `P` has no primitive whose output is a permission, and no
carrier in which authority is a first-class, pre-committable, transferable object.

**Verdict: genuine refuter of `F5`'s account of enforcement; the balance arithmetic
around it is generated.** Ranked below R1–R3 because it can be argued down to "`F5`
with the fault as the valuation source" by anyone willing to make `F6` accept
arbitrary witnesses.

---

## Candidates I killed

- **EigenLayer slashability magnitude budget** (the brief's headline nominee).
  Dissolves. `maxMagnitude` is a **quota** — `F3` with slope zero (no refill); the
  deallocation delay is `F3` composed with `F2`; slashing's proportional burn of
  deposit shares is `F1`. That a single action updates two ledgers at once is
  composition, not a new primitive. "Conserved liability orthogonal to shares" is a
  second application of `F3`+`F4`, not a ninth family.
- **Convex permanent one-way lock.** Dissolves immediately. `F1`'s signature includes
  both directions; a construction is free to expose `(A)→(K)` and omit `(K)→(A)`.
  Omission is not a mechanism.
- **Polymarket complementary outcome split.** Dissolves. `1 collateral → 1 YES + 1 NO`
  is `F4` over two claim ledgers; redemption is `F8` on a discrete-valued `F6`
  (the UMA resolution). The dispute-reset is just a non-monotone `F6`; nothing in
  `F6` promised monotonicity. The *exchange* around it is R1 — that is where
  Polymarket actually escapes.
- **Uniswap v4 deferred net settlement.** Mostly dissolves. "Signed deltas sum to zero
  at scope close" is `F4` on a transaction-scoped carrier; adding a carrier is free.
  The residue — that the invariant is *bracketed* rather than holding in every state,
  so temporary insolvency is legal — is real but is a statement about when `F4` is
  checked, expressible as a mode.
- **crvUSD soft-liquidation bands (LLAMMA).** Dissolves, conditionally. In the
  arbitraged limit the collateral fraction is a function of the current oracle price:
  `F8`, `(P) → (A)`. The hysteresis on round trips is a loss term, not a new family.
- **Lighter desert as such / register-of-record duality (BUIDL, USYC).** The duality
  dissolves behaviourally: transfer-agent supremacy is an admin write on `F1`. Its real
  consequence is that the composite has *no* invariants — degenerate, not ungenerated.
  Lighter survives only through R3's commitment carrier.
- **Superfluid-style continuous streaming** (outside corpus). Dissolves. `balance(t) =
  b₀ ± r·Δt` is `F3`'s envelope arithmetic with the cap removed and the sign flipped.
  A quota and a balance differ in role, not in behaviour.

**One meta-observation the adversary is obliged to record.** The kills above lean hard
on `F4`. If `F4` means "any invariant `Φ` you like, and the action is whatever saturates
it", then `F4` alone generates `F1` (`Φ` = shares/assets), `F5` (`Φ` = health), `F7`
(`Φ` monotone) and every AMM curve — and `P` has Post's `⊤` problem. Note also that
`CONSTANT_PRODUCT_SWAP` is L1's most-instantiated candidate primitive (6 protocols) and
appears nowhere in `F1..F8`; it is currently being absorbed by exactly this unrestricted
reading of `F4`. The generation theorem must fix a restricted grammar for `Φ` *before*
it can claim any of my kills.

---

## The minimal addition to `P`

R1 and R2 are one missing primitive. Add:

> **`F9` — Allocation rule.** `Multiset(D) × ≼ → (Fill, P)`. Takes a finite multiset of
> declarations `D = {(party, size, limit)}` and a total preorder `≼` on `D`, and returns
> a fill vector plus a settlement price, such that (i) each filled declaration satisfies
> its own limit inequality at `P`, (ii) the fill is aggregate-conserving, and (iii) the
> filled set is **`≼`-extremal** among feasible fills.

Instances: `≼` trivial and the fill proportional gives pro-rata rationing; `≼` by price
gives uniform-price batch clearing (CoW) and CLOB matching; `≼` by borrower-set rate
gives Liquity redemption; `≼` by arrival gives FIFO queues; `≼` by descending price over
time gives Sky's `clip` auction; `≼` by tranche seniority gives Huma's waterfall.

The constructive payoff is larger than a ninth family. **`F1` is the `≼`-trivial,
permutation-symmetric instance of `F9`.** Pro-rata is not primitive; it is the
*anonymous* allocation rule. If the paper adopts `F9` it loses a primitive as well as
gaining one, which is exactly what an independence argument is supposed to do — and it
brings the order-driven half of DeFi inside the basis instead of leaving it outside,
unnamed, in six separate lane ledgers.
