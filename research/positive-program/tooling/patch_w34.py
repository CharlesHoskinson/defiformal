import pathlib

r = pathlib.Path("/root/DefiElements/research/positive-program/ROADMAP.md")
t = r.read_text(encoding="utf-8")

section = """

---

## Gate 2.1b — W3 (`liquity`, `polymarket`) and W4 (`derive`, `huma`) delivered

All four typecheck. W3: 8 + 8 invariants hold, **18 + 14** witnesses violated,
21 + 13 T0 groups. W4: 9 + 7 invariants hold, **22 + 24** witnesses violated,
42 + 38 T0 vectors.

### The structural result of the whole phase

**Value signatures cannot kill a selection-shaped deletion, and neither can the
mechanism invariant.**

W3 asserted a value signature (`debtsOf(troves) == List(4000,0,0)`) unreachable
under its mutant, then *built and ran* the mutant: it reached that exact state at
depth 3, by touching trove 3, then 2, then 1 across separate transitions. Quint's
`--invariant` is a single-state predicate (trap K6), so no predicate can say "in
one transition". For a mechanism whose content is *which elements were selected
together*, the discriminating observable is the **arity of the selection**.

Measured on `liquity_M1`: `inv_T0`, `inv_conservation`, `inv_bounds`,
`inv_listCanonical`, **`inv_redeemPrefix`** and `inv_all` all `[ok]`. It dies to a
single ghost-counter witness. `inv_redeemPrefix` is the *mechanism* invariant and
it does not discriminate either, because it quantifies over a hypothetical
application at the current state rather than over the transition taken.

W4 confirmed this independently with a purpose-built mutant,
`huma_M6_oneTranche`, which keeps the cap and every arithmetic definition and
only refuses to serve both tranches in one epoch: all six invariants and all four
value-level witnesses behave exactly as on the target; only
`wit_arity_bothTranches` dies.

Ghosts were justified against on-chain observables in both cases — liquity's
one `TroveUpdated` event per touched trove; huma's one
`executeRedemptionSummary` per served tranche; derive's `scenarios.length`
(which `PMRMLib.sol:97` reverts on) and `worstScenario` (which `DutchAuction`
stores as `auctions[].scenarioId`).

### The predicted cheat was built, run, and passes the prescribed checks

`mutants/derive_M1prime.qnt` is the plan review's decoration cheat, one
substitution at the definition site:

| obligation | result |
|---|---|
| `inv_marginIsMin` | **[ok]** — the cheat passes the P2-SCOPE prescribed check |
| `inv_worstIsFirst` | **[ok]** |
| `inv_conservation` | **[ok]** |
| `inv_T0` | [violation] |
| `wit_splitSensitiveArgmin` | T0-LIVE state unreachable — the kill |
| `wit_arity_fullScan` | the arity half also kills it |

**A re-spec shipping only the three named acceptance criteria would have signed
the deletion off.** T0 vectors and the arity witness are what separate them.

### The transferable rule (W4)

- An **under-approximating** deletion (uniswap) is caught by a *reachability
  witness* and not by an invariant.
- A **relaxing** deletion (huma) is caught by an *invariant* and not by a
  reachability witness — the mutant's reachable set strictly contains the
  target's.

W4's first `wit_juniorCapped` was violated by the mutant too, measured; pinning
it to the instant with `lastOp == OP_EPOCH` fixed it.

### Contract errors found by running rather than reading

1. **`inv_seniorRatio` is not a contract invariant.** Junior is first-loss, so
   `lossToTranches(700,200,300) = (600, 0)` leaves senior 600 against junior 0 —
   `Pool.sol:235-238` says so. v1 was right that it breaks and wrong about why.
2. **`inv_marginIsMin` is a shape property** that passes under the deleted
   mechanism — measured, not argued.
3. **`P2-CONTRACT` §A.10's polymarket batch row is not economically
   realisable**: it implies a taker contribution of **-30**.
4. **`sorted.qnt`'s 3 D1 findings were TRUE positives**, not the false positives
   `PILOT-NOTES` §2 guessed — a payout nothing constrained, a counter nothing
   read, a price nothing asserted unchanged. Now 3 -> 0.
5. **Quint's `/` truncates toward zero** (`(-7)/2 == -3`), matching Solidity
   `int` division, so `mulDivDown` is a floor only on non-negative operands.
   derive is signed throughout and pins the direction locally.
6. **R4's agreement percentage must be reported per returned component.** M4
   (correct magnitude, index discarded) agrees **100% on the value** and 68.1%
   on the index. A contrast set scored on the value column alone reports "no
   rival separates" and is wrong.
7. **6g's decisive demonstration is inside liquity.** `batchLiquidateTroves`
   takes ids from calldata (footprint empty — legitimate `nondet`);
   `redeemCollateral` derives them from `getLast()`/`getPrev()` (footprint
   non-empty — rejected). One protocol, two identity-valued inputs, and 6g
   separates them where convention 6 alone cannot.

### Three linter bugs found by the workers, all fixed

- `keyed` was computed and discarded into message text, so the linter scored a
  **repaired** `redeemCollateral(boldAmt)` exactly as loudly as the defective
  `redeem(u, boldAmt)` — it could not tell a defect from its own repair. Split
  into **D4a** (keys state: told WHICH element) and **D4b** (exogenous quantity).
- `keyed` was always false anyway: the body regex terminated on the first nested
  `val`, and `val t = troves.get(u)` is typically the first line of the body.
  Replaced with a bounded character window.
- `keyed` was then computed once per *action* but attributed per *argument*, so
  in `startAuction(u, sid)` the integer `sid` was reported as D4a because `u`
  keys. Now decided per argument by positional binding.

Verified after all three: v1 `liquity` reports **2 x D4a**, v2 `liquity` reports
**1 x D4b**, the pilot stays clean, and `startAuction` splits `u` -> D4a,
`sid` -> D4b."""

if "## Gate 2.1b — W3" not in t:
    t = t + section
r.write_text(t, encoding="utf-8")
print("ROADMAP updated with W3 + W4")
