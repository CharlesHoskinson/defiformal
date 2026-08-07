# PILOT-NOTES — `uniswap_v2` re-spec, gate 2.1

Files in this directory:

| file | what it is |
|---|---|
| `sqrt.qnt` | gate 2.0d artifact, unmodified. `isqrt` exact on `0 <= n < 2^62`, 31 folds |
| `sorted.qnt` | gate 2.0d artifact, unmodified. W3's machinery; unused by the pilot |
| `kernel.qnt` | **new.** shared machinery + the registry names. Two modules: `kernel` (state-free) and `kernelCheck` (its harness) |
| `uniswap_v2.qnt` | **new.** the pilot re-spec |
| `mutants/uniswap_v2_M1.qnt` | **new.** contrast-set member M1 — the v1 shortcut body substituted at the single definition site. F2 evidence, §7 |
| `PILOT-NOTES.md` | this file |

Acceptance, as run (all commands from this directory):

```
quint typecheck kernel.qnt                                            -> OK
quint typecheck uniswap_v2.qnt                                        -> OK
quint run --main=uniswap_v2 --invariant=inv_conservation \
          --max-steps=20 --max-samples=2000 uniswap_v2.qnt            -> [ok] 90ms
quint run --main=uniswap_v2 --invariant=inv_all ...                   -> [ok] 202ms
python3 ../research/positive-program/phase2/respec_lint.py uniswap_v2.qnt
                                                    -> TOTAL FINDINGS: 0
```

Thirteen `wit_*` obligations, each of which `quint run --invariant=<w>` **must**
violate, all violated. Full table in §6.

---

## 1. The kernel decision, and why nine workers should care

**`kernel.qnt` imports `sqrt.qnt`; it does not fold it.** It republishes the two
names the registry needs — `isqrtFloor` (over `isqrt`) and `isqrtExactAt` (over
`isqrtCorrect`) — plus the rounding primitives every protocol needs
(`mulDivDown`, `mulDivUp`, `ceilDiv`, `minInt`, `maxInt`) and `I64_MAX`.

Reasons, in order:

1. Folding would duplicate a definition that was verified on ~14 000 points. A
   duplicate is a second thing that can drift, and nothing would notice.
2. A blanket `export sqrt.*` **was tested and works** in Quint 0.32, but it drops
   `sqrt.qnt`'s exhaustive verification vals (`checkSmall`, `checkSquares`,
   `checkDecades`, `checkBoundary` — each an O(10^4) fold) into every consumer's
   namespace. Those are gate evidence, not spec machinery. `kernel.kernelOk`
   re-runs them on demand instead, so the alias cannot silently diverge from what
   gate 2.0d verified.
3. `sorted.qnt` is deliberately **not** wrapped. It exports a *type* (`Trove`),
   and a type cannot be republished through a wrapper module without
   re-declaring it — which is exactly the duplication being avoided. W3 writes
   `import sorted.* from "./sorted"` directly. This is a limitation of Quint's
   module system, not a choice.

`kernel` declares **no `var`, no `init`, no `step`**. See §5 trap K1.

The kernel is frozen for modification and **append-only** for extension. W1
appends `newtonD` (with the `done` flag, K = 8 — hard constraint 2); nobody
edits or deletes an existing definition, because nine specs are pinned to these
names and to `kernelOk`.

---

## 2. The second deletion, diagnosed

The brief said `kLast` is dead in v1 and asked for the diagnosis. It is:

- v1 writes `kLast` at `quint-models/L1/uniswap_v2.qnt:28` (`init`), `:48`
  (`mint`) and `:69` (`burn`), and copies it at `:88`, `:105`. **No expression
  anywhere in v1 reads it.**
- Its reader in the contract is `_mintFee` (`UniswapV2Pair.sol:89-107`), which is
  absent from v1 entirely.

So the deletion is not "a dead variable". It is three mechanisms:

1. **the protocol's own revenue** — `liquidity = totalSupply·(rootK − rootKLast)
   / (rootK·5 + rootKLast)` (`:98-100`), the only path by which value leaves LPs
   for the protocol. Restored as `mintFeeLiquidity`.
2. **the governance switch** — `feeOn = IUniswapV2Factory(factory).feeTo() !=
   address(0)` (`:90-91`), set by `UniswapV2Factory.setFeeTo` (`Factory:40-43`).
   Restored as `var feeOn` + `action setFeeTo`.
3. **the teardown branch** — `else if (_kLast != 0) kLast = 0` (`:104-106`), the
   other side of the `feeOn` conditional. Restored as
   `kLast' = if (feeOn) r0n * r1n else 0` in `mint`/`burn`, which is `_mintFee`'s
   else-branch composed with the post-update write at `:129`/`:154`.

Note that `kLast` in v1 is *not* what lint D2 catches (D2 wants ≤1 substantive
write; v1 has three) and *not* what D1 catches (D1 is record fields only). It is
a **write-only `var`**, which is convention 6e's clause and is currently checked
by a human reading the coverage table. **Recommendation to the linter owner: add
D6 — a `var` with ≥1 substantive write and zero reads outside its own
assignment.** That detector, run on v1, finds this deletion by itself; nothing in
the current four does.

`kLast` is now read in three places: `mintFeeLiquidity` (a guard, `:94`),
`inv_kLastMeaning`, and `wit_used_ammAmountOut`.

### The linter is blind to both of this protocol's deletions — measured

```
python3 respec_lint.py quint-models/L1/uniswap_v2.qnt quint-models/L1/common.qnt
  -> TOTAL FINDINGS: 0 across 2 spec(s)
```

**The v1 spec this re-spec exists to replace scores zero.** Both deletions are
invisible to all four detectors: D1 is record-fields-only and `kLast` is a `var`;
D2 wants ≤1 substantive write and `kLast` has three; D3 needs a mechanism-naming
comment over identity assignments and v1 has neither; D4 needs a selection verb
and `mint`/`burn`/`swap` are not selections. The 185-findings/57-specs baseline
therefore contains **nothing at all from this protocol**.

Two consequences, and the first one is the honest reading of this pilot's result:

1. **"0 findings" is not by itself evidence that the re-spec is better than v1**,
   because v1 also scores 0. The evidence that the mechanism is present is
   `inv_T0`, the thirteen violated `wit_*` obligations, and the M1 mutant run in
   §7 — not the lint number. A worker who treats a clean lint as the acceptance
   test has reproduced the fourth trap.
2. **D6 is worth implementing**: a `var` with ≥1 substantive write and zero reads
   outside its own assignment. That single detector finds v1's `kLast` on its
   own, and it is the mechanisable half of convention 6e ("no `var` may be
   write-only"), which is currently checked only by a human reading the coverage
   table.

Separately, `respec_lint.py --dir .` over this directory reports **3 D1 findings
in `sorted.qnt`** — `collOut`, `price`, `touched`, all "read in a guard 0x".
`sorted.qnt` is a gate-2.0d artifact and is shipped unmodified, so these are not
the pilot's findings; but W3 imports that file and should expect them. Two of the
three look like genuine D1 false positives (they are read inside `redeemOne`'s
arithmetic and inside `redeemIsExtremal`, neither of which the `guard_lines()`
heuristic classifies as a guard), and `price` is read in a real comparison inside
`icrOk`. W3 should confirm rather than assume.

---

## 3. Conventions as actually applied

| convention | how it landed here |
|---|---|
| 1 module name | `module uniswap_v2` — unchanged from v1 |
| 2 header block | all six lines present, plus `GHOST:`, `INPUTS:` (6g), `COVERAGE:` (6e), `UNITS:` (H2), and the contrast set 𝔐 |
| 3 registry `pure def` | six pinned defs, see §4. Nothing is inlined into an action |
| 4 `init` | one action, every `var` assigned, every value a named `pure val` in `UPPER_SNAKE`. No arithmetic in `init` |
| 5 ordered state | none needed — `uniswap_v2` has no ordered structure |
| 6 driver | five `nondet`s, all exogenous: caller identity, two deposit amounts, a burn amount, a swap amount, a governance boolean |
| 6b arithmetic identity | 22 T0 vectors; ≥1 off-diagonal per def; ≥1 where the v1 shortcut disagrees |
| 6c rounding | every division floors, matching `:100`, `:123`, `:144-145`. Inexact-quotient vectors: `t0_02` (15→3), `t0_07` (414), `t0_10` (28), `t0_18` (857), `t0_19` (3333) |
| 6d no-op / dead branch | no action has an all-identity frame; five `wit_fired_*`, all violated |
| 6e coverage table | in the header; every external state-changing function of `UniswapV2Pair`, `UniswapV2ERC20` and `UniswapV2Factory` is an action or an `ABSTRACTED:` line. No write-only `var` |
| 6f branch/threshold | `t0_08`/`t0_09` (both sides of `MINIMUM_LIQUIDITY`), `t0_12`/`t0_10` (both sides of `rootK > rootKLast`), `t0_13`/`t0_10` (both sides of `kLast == 0`), `t0_21`/`t0_22` (both sides of the K guard), `t0_14`/`t0_15` (fee invisible / visible) |
| 6g dependency parity | `INPUTS:` table, five rows, each with the contract expression, file:line, `foot(Q)` and the spec vars read. All five have `foot(Q) = ∅` — see §8 |
| 7 invariants | `inv_conservation`, `inv_bounds`, `inv_sqrtExact`, `inv_permanentLock`, `inv_kLastMeaning`, `inv_supplyBelowGeometric`, plus `inv_T0`; all conjoined as `inv_all` |
| 8a branching | 2 LPs; 7 / 5 / 3 / 2 enumerated values per `nondet`; no list state |
| 8b magnitude | declared peak **4.611686×10^18** — see §9, this is a correction |
| 8c constant-crossing | `MINIMUM_LIQUIDITY`, the 997/1000 fee, `FEE_MINT_SHARE`, the `kLast == 0` test and `MAX_RESERVE` are each crossed; the last verified by a throwaway probe invariant that found a state where a further 20 000 mint is refused |
| 9 prohibited words | no `abstract`/`simplified`/`stand-in`/`approx` outside the `ABSTRACTED:` list |

---

## 4. The six pinned definitions and their T0 vectors

`P2-SCOPE` convention 3 lists only `isqrtFloor` for this protocol; `P2-CONTRACT`
§A.1 names three (`isqrtFloor`, `geometricMint`, `mintFee`). Convention 6b says
*every* arithmetic mechanism is a registry-named `pure def` pinned by vectors, so
six are shipped. This is deviation D-a in §10.

| `pure def` | contract | T0 vectors (computed, all asserted as `pure val`) |
|---|---|---|
| `isqrtFloor` | `Math.sol:11-20` | `36000000→6000`, `15→3`, `8→2`, `2000000→1414` |
| `geometricMint` | `Pair.sol:120` | `(4000,9000)→5000`, `(2000,8000)→3000`, `(1000,2000)→414`, `(1000,1000)→0`, `(900,900)→−100` |
| `mintFeeLiquidity` | `Pair.sol:92-103` | `(kLast 10^6, 1200,1200, ts 1000)→28`, `(…,2000,2000,…)→90`, `(…,1000,1000,…)→0`, `(kLast 0,…)→0` |
| `ammAmountOut` | `Pair.sol:180-182` | `(1000,1000,100)→90`, `(1000,1000,1000)→499`, `(4000,9000,20000)→7496` |
| `proportionalMint` | `Pair.sol:123` | `(1000,1000,24000,1504,6000)→250`, `(1000,1000,7000,7000,6000)→857` |
| `proportionalBurn` | `Pair.sol:144-145` | `(5000,4000,6000)→3333`, `(5000,9000,6000)→7500` |
| `kGuardHolds` | `Pair.sol:180-182` | `(1000,1000,2000,501,1000,0)` true; `(…,2000,500,…)` false |

**The three headline vectors, and what the shortcut gives:**

| input | `geometricMint` (M0) | v1 `min` shortcut (M1) |
|---|---|---|
| `(4000, 9000)` | **5000** | 3000 |
| `(2000, 8000)` | **3000** | 1000 |
| `(1000, 2000)` | **414** | 0 (action refused) |

All three lie off the diagonal, which is the whole point: on the diagonal every
member of 𝔐 agrees, which is why v1 killed zero mutants.

---

## 5. T0-LIVE and the fifth trap — the general recipe

**The trap, restated concretely.** `inv_T0` is 22 `pure val` equalities. Every
one of them is true in a module where `geometricMint` is never called. The
arithmetic would be present as a library and absent as a mechanism.

**What was shipped.** Six `wit_used_<f>` obligations, five `wit_fired_<action>`
obligations, one `wit_branch_feeOff`, and the `T0-LIVE` witness. Each is a state
predicate that `quint run --invariant=<name>` must **violate**; the violation
*is* the trace.

The `T0-LIVE` trace, printed by `quint run --invariant=wit_live_geometricMint`:

```
[State 0] reserve0 0, reserve1 0, totalSupply 0, kLast 0, feeOn true,
          lpBalance {addressZero:0, alice:0, bob:0, feeTo:0}, lastOp "init"
[State 1] reserve0 4000, reserve1 9000, totalSupply 6000, kLast 36000000,
          lpBalance {addressZero:1000, alice:5000, bob:0, feeTo:0}, lastOp "mint"
[violation]
```

`geometricMint(4000, 9000) = 5000` as a **state change**, with 1000
permanently locked at `address(0)` and `totalSupply = 6000`. Depth 1 from `init`.

**The recipe the nine should follow, in priority order.**

1. **Value signature, tag-free.** Find a predicate over the protocol's own
   observables that only `f` can make true. Five of the six here are of this
   form and they are the strong ones:
   - `isqrtFloor` — `totalSupply == isqrtFloor(k)` **and** `totalSupply² < k`:
     the strict floor, so the truncation was load-bearing, not just the value.
   - `geometricMint` — same, plus `reserve0 != reserve1`: forces the witness off
     the diagonal.
   - `proportionalMint` — both LPs hold shares; only one can have bootstrapped.
     (This also discharges regression signal 7, single-user-sufficient.)
   - `proportionalBurn` — `lpBalance[address(0)] == 1000 and totalSupply == 1000
     and reserves > 0`: every redeemable share redeemed, the lock still locked.
   - `mintFeeLiquidity` — `lpBalance[feeTo] > 0`; no other writer exists.
   - `ammAmountOut` — `feeOn and kLast > 0 and reserve0·reserve1 > kLast`. Only a
     swap raises the product above its value at the last liquidity event, which
     is `kLast`'s *stated* meaning (`Pair.sol:28`).
2. **Ghost trace label, only if step 1 fails.** Quint 0.32's `--invariant` takes
   a **single-state** predicate. There is no two-state or action-level property,
   so "a burn happened" is not directly expressible. Where no value signature
   exists, declare `var lastOp: str` under a `GHOST:` header line. Justification:
   it is the trace label Λ of the observation interface (`P2-FIDELITY` §1), and
   it carries exactly the information the contract's own `Mint`/`Burn`/`Swap`/
   `Sync` events carry — which are droppable only because no guard reads them.
   It is read by `wit_fired_*` and by nothing else; no guard and no `pure def`
   may read it, and it is exempt from 6e's write-only clause on that basis.
3. **Never let a `wit_used_<f>` be tag-only** when the action has ≥2 arithmetic
   branches — a tag proves the action fired, not which branch. Here the ghost is
   used *only* for 6d enabledness (`wit_fired_*`), never for a `wit_used_*`. That
   split is the convention: **tag for enabledness, value signature for
   mechanism.**

**§D part 1's grep rule needs amending.** It says to `grep` that each registry
name occurs "at least once inside an `action` body". `isqrtFloor` does **not**
appear literally in any action here — it is reached through `geometricMint` and
`mintFeeLiquidity`. The rule must be **transitive**: `f` is used if some action
body reaches it through the call graph of `pure def`s. The value-level
`wit_used_isqrtFloor` shipped here is strictly stronger than either form of the
grep and is what should be relied on.

---

## 6. Obligation results

| obligation | required | observed |
|---|---|---|
| `inv_conservation` | no violation | `[ok]` |
| `inv_all` (T0 + 6 invariants) | no violation | `[ok]` |
| `inv_T0`, `inv_bounds`, `inv_sqrtExact`, `inv_permanentLock`, `inv_kLastMeaning`, `inv_supplyBelowGeometric` | no violation | `[ok]` each |
| `wit_live_geometricMint` (T0-LIVE) | **violation** | `[violation]`, depth 1 |
| `wit_used_isqrtFloor` | **violation** | `[violation]` |
| `wit_used_geometricMint` | **violation** | `[violation]` |
| `wit_used_proportionalMint` | **violation** | `[violation]` |
| `wit_used_proportionalBurn` | **violation** | `[violation]` |
| `wit_used_mintFeeLiquidity` | **violation** | `[violation]` |
| `wit_used_ammAmountOut` | **violation** | `[violation]` |
| `wit_fired_mint` / `burn` / `swap0for1` / `swap1for0` / `setFeeTo` | **violation** | `[violation]` each |
| `wit_branch_feeOff` | **violation** | `[violation]` |
| `respec_lint.py uniswap_v2.qnt` | few or none | **0 findings** |

All at `--max-steps=20 --max-samples=2000`, every run under 250 ms.

---

## 7. The contrast set, and a finding about R4

Declared in the header. Members, with agreement against `M0` measured
exhaustively over all 7×7 = 49 pairs of the declared mint domain:

| | mechanism | source | agreement with M0 |
|---|---|---|---|
| M0 | `isqrtFloor(a0·a1) − 1000` | `Pair.sol:120` | — |
| M1 | `(if a0 == a1 then a0 else min(a0,a1)) − 1000` | v1 `common.qnt:76-92` — **R4 member 1** | 7/49 = 14.3 % |
| M2 | any liquidity in `[1, isqrtFloor(a0·a1)]` | chaos — **R4 member 2** | 0/49 |
| M3 | `(a0+a1)/2 − 1000` | apex `apex.qnt:183-185`, sibling in corpus — **R4 member 3** | 7/49 = 14.3 % |
| M4 | ceil-sqrt | rounding-direction rival | 15/49 = 30.6 % |

**M1 was built and run** (`mutants/uniswap_v2_M1.qnt`, one `sed` substitution at
the single definition site plus a `../kernel` import path):

```
inv_T0                  [violation]   <- killed by the vectors
wit_live_geometricMint  [ok]          <- the T0-LIVE state is UNREACHABLE
inv_conservation        [ok]          <- conservation does not discriminate
```

The third line is the important one. **`inv_conservation` holds under the
deleted mechanism**, which is precisely the v1 failure mode: the headline
invariant survives because the mechanism that stresses it was removed. The kill
comes from `inv_T0` and from `wit_live_geometricMint` *failing to be violated*.

**Finding — R4's member 3 is unsatisfiable for this protocol.** R4 requires a
near neighbour agreeing with the target on ≥90 % of the declared domain. For
`geometricMint` **no such rival exists**: all four candidates were enumerated
over all 49 domain pairs and the best is M4 at 30.6 %, which is exactly the count
of perfect-square products. The geometric mean is extremal — it is the unique
symmetric degree-1-homogeneous function whose level sets are the constant-product
curve — so every rival separates from it off the diagonal, and the diagonal is
7/49 of the domain. The ≥90 % clause is satisfiable for *smooth* mechanisms
(`mintFeeLiquidity` with denominator `rootK·6` instead of `rootK·5 + rootKLast`
agrees everywhere the fee is zero, which is most liquidity events) and not for
*algebraic identity* mechanisms. **Recommendation: R4 member 3 should read
"agreeing on ≥90 % of the domain, or the closest available rival with its
measured agreement reported."** M3 is shipped with 14.3 % reported.

**Second finding — no global state invariant separates M0 from M1.** This was
attempted and failed, and the reason generalises. Every natural invariant on an
AMM bounds supply *above*: `totalSupply² ≤ reserve0·reserve1`
(`inv_supplyBelowGeometric`, which does hold, and is tight at the bootstrap).
M1 mints *less* than M0, so it satisfies every upper bound. The reverse bound
`totalSupply ≥ isqrtFloor(k)` is **false for the honest spec** — a swap raises
`k` without raising supply, which is the entire economics of the fee. So the
separation is a *reachability* fact, not an invariant fact, and it is carried by
`inv_T0` plus the T0-LIVE trace. **Expect the same shape for every deletion that
under-approximates a quantity.** This is why repair 2 and §D exist and it is
worth stating explicitly in the plan.

---

## 8. Convention 6g as applied

Five driver-supplied quantities. `foot(Q)` is empty for all five:

- `caller` — `mint(address to)` / `msg.sender`. Calldata.
- `a0`, `a1` — `balanceX.sub(_reserveX)` (`:114-115`). The storage read is
  `balanceOf[pair]`, an ERC20 staging slot the caller wrote in the immediately
  preceding transfer; its **value** is caller-chosen calldata, so `foot(Q) = ∅`
  and parity holds. The staging slot itself is dropped under `ABSTRACTED:`
  (balance ≡ reserve once `skim`/`sync` and donations are gone).
- `shares` — `balanceOf[address(this)]` (`:140`). Same argument, plus the (E≤)
  restriction `shares <= lpBalance.get(holder)`: you cannot send LP you do not
  hold.
- `amountIn` — same as `a0`/`a1`.
- `switchOn` — `IUniswapV2Factory(factory).feeTo()` (`:90-91`). A genuine
  external-call return, `foot(Q) = ∅`. This is exactly the oracle case 6g was
  written to permit, and it is worth noting that the pilot exercises that side of
  6g rather than the forbidding side.

There is no `markPrice`-shaped quantity in `uniswap_v2`: nothing the driver
supplies is computed from reserves in the contract. 6g is silent here, as
`P2-CARRYFORWARD`'s ten-way table predicted (row 1, "parity").

---

## 9. Deviations from `P2-CONTRACT.md`, each with its reason

**D-a — registry extended from 1 (or 3) names to 6.**
`P2-SCOPE` convention 3 lists `isqrtFloor`; `P2-CONTRACT` §A.1 names
`isqrtFloor`, `geometricMint`, `mintFee`. Convention 6b says every arithmetic
mechanism is a registry-named `pure def`. `uniswap_v2` has six. `mintFee` is
shipped as **`mintFeeLiquidity`**, the name §A.1's own vector rows use.

**D-b — T0 vector set enlarged from 7 to 22.**
§A.1 gives 7. Conventions 6c (an inexact quotient per `pure def`) and 6f (one
vector each side of every branch) need more. The 7 from §A.1 are all present and
all reproduce exactly.

**D-c — `isqrtBits(n, 16)` replaced by the 31-fold `isqrt`.**
§C row 1 prescribes `isqrtBits(n,16)`, `cand² ≤ 4.3×10^9`. Task directive: do not
reinvent `isqrt`. Consequence below.

**D-d — the declared peak intermediate is 4.61×10^18, not 4×10^8. This is a
correction to §C row 1, and it binds all nine.**
§C row 1 declares `a0·a1 ≤ 4×10^8` and `P2-CARRYFORWARD`'s table declares
`8.0×10^11`. Both are peaks of the *protocol* arithmetic. The spec's actual peak
is inside `kernel.isqrtFloor`: the 31-fold restoring loop tests
`cand² ≤ n` with `cand` up to `2^31 − 1`, so the peak intermediate is
`(2^31 − 1)² = 4.611686×10^18`, about **11 million times** the declared figure.
It still clears `I64_MAX = 9.22×10^18` with 2× headroom, so nothing here breaks —
but the margin is 2×, not 10^10×, and **any spec that calls `isqrtFloor`
inherits this floor on its peak.** Checked against the other declared peaks:
`curve` 5.0×10^17, `compound_v3` 2.0×10^12, `morpho_blue` 4.0×10^12 — all fine,
because 4.61×10^18 dominates them rather than adding to them. A protocol whose
own arithmetic exceeded ~4.6×10^18 could not also call `isqrtFloor` on the
default backend. **Every `BOUNDS:` 8b line in a spec that calls `isqrtFloor` must
state 4.611686e18**, not the protocol figure.

**D-e — reserves capped at 100 000, and the peak of the *protocol* arithmetic is
the K guard, not the amount-out numerator.**
§C row 1 declares `reserves ≤ 40000` and `in·997·rOut ≤ 7.98×10^11`. That is the
numerator of `getAmountOut`. The pair's own guard at `:180-182` computes
`balance0Adjusted · balance1Adjusted`, which is larger:
`(MAX_RESERVE · 1000)² = 1.0×10^16`. §C row 1 omits it because it treats the
router's formula as the mechanism; the contract's mechanism is the guard.
`MAX_RESERVE = 100000` is the descaled `require(balance <= uint112(-1))`
(`:74`) — a real contract guard, kept rather than dropped — and 100 000 was
chosen so 8c can cross it (five mints of 20 000), which was verified by probe.

**D-f — `INIT_FEE_ON = true`.**
The protocol cut needs `kLast != 0` at a liquidity event, which needs `feeOn`
true at the *first* one. Starting the switch off puts `wit_used_mintFeeLiquidity`
four steps deep behind a specific action sequence. The off side is reached by
`setFeeTo` and is witnessed by `wit_branch_feeOff`, so both sides of the branch
are exercised either way. This is a domain choice recorded per the standing
directive, and no witness moved out of `𝒟` because of it.

**D-g — the two sub-`MINIMUM_LIQUIDITY` revert paths are merged.**
`SafeMath.sub` reverts when `sqrt(a0·a1) < 1000`; `require(liquidity > 0)`
(`:125`) reverts when it `== 1000`. Both are refusals of the same action at the
same argument and are indistinguishable in the failures model, so both are the
single guard `liquidity > 0`. `t0_08` (`= 0`) and `t0_09` (`= −100`) pin both
sides of the constant even though only one is reachable in `𝒟` — `𝒟`'s minimum
mint amount is 1000, so `sqrt(a0·a1) ≥ 1000` always. Recorded under `ABSTRACTED:`.

**D-h — a `GHOST:` var was added.** See §5 step 2. Not contract state, not read
by any guard, exempt from 6e by the argument given.

**D-i — `BURN_SHARES = {500, 1000, 5000}` is not prescribed anywhere.** 5000 is
needed for `wit_used_proportionalBurn` — it is exactly the LP a bootstrap at
`(4000, 9000)` mints, so the pool can be drained to the lock.

**Zero lint findings are left, so nothing needs justifying under that heading.**

---

## 10. Traps the nine will hit that `P2-CONTRACT.md` does not cover

**K1 — a kernel with a state machine breaks every consumer.** If `module kernel`
declares `init`/`step`, `import kernel.*` fails with `QNT101: Conflicting
definitions found for name 'init'`. `kernel` is state-free; its harness is a
second module, `kernelCheck`, in the same file:
`quint run --main=kernelCheck --invariant=inv_kernel --max-steps=1 kernel.qnt`.

**K2 — `to` is a Quint built-in.** `action mint(to: str, ...)` fails with
`QNT101: Built-in name 'to' is redefined` (it is the range operator, `1.to(5)`).
Same for `min`/`max`, which is why the kernel exposes `minInt`/`maxInt`. Use
`recipient`, `caller`, `holder`. `from` happens to be accepted but reads as a
keyword; avoid it.

**K3 — `respec_lint.py` D2 misreads a wrapped assignment.** Its regex is
`\bvar'\s*=\s*([^,\n]*)`, so

```
lpBalance' = lpBalance
  .put(k, v)
```

captures `lpBalance` and is scored as a **frame no-op**. That cost a false D2
("5 frame no-ops, 1 substantive write") on the first draft of this spec. **Rule:
never start an assignment's right-hand side on the next line.** Put at least the
head of the expression on the `=` line. (The converse is safe — wrapping an
identity assignment still scores as a frame.)

**K4 — `respec_lint.py` D3 fires on ordinary commentary.** D3 flags a comment
containing any of `socializ, accru, liquidat, distribut, apply, enforc, absorb,
impact, waterfall, subordinat, haircut, discount, penalt, slash, writedown,
bad debt, loss, fee, premium, settle` when ≥2 identity assignments follow within
its scan window — and **every action's frame block is a run of identity
assignments**. `fee` and `loss` are the ones that bite. Two facts about the
scanner that make this manageable: it *skips* blank and comment-only lines
without breaking, and it *breaks* on the first non-identity code line. So a guard
line between the comment and the frame block protects you. **Rule: keep
mechanism-naming commentary in the header and above `pure def`s, never within
five lines of a frame block.**

**K5 — `respec_lint.py` skips any file literally named `kernel.qnt`.** The kernel
is never linted. Do not read a clean `--dir` run as covering it.

**K6 — Quint's `--invariant` is a single-state predicate.** There is no
two-state, action-level or temporal form in 0.32. Everything in §5 follows from
this. Plan your `wit_*` predicates before you write the actions, because the
state you need may have to be *representable* — e.g. `proportionalBurn`'s witness
here required the pool to be drainable to exactly the lock, which constrained
`BURN_SHARES`.

**K7 — `if` is lazy, and you should rely on it.** `if (bootstrap)
geometricMint(a0,a1) else proportionalMint(a0, a1, reserve0, reserve1, ...)`
never divides by `reserve0 = 0`; verified by the run, whose first transition is a
mint from `(0, 0)`.

**K8 — a `pure val` T0 block costs almost nothing at runtime.** `inv_T0` alone is
86 ms at 2000 traces; `inv_all` with the six state invariants is 202 ms. There is
no reason to skimp on vectors.

**K9 — build the mutant.** It is one `sed` at the definition site plus fixing the
kernel import path to `../kernel`. It took under a minute and it produced the
single most informative line in this report: `inv_conservation [ok]` under M1.
A contrast set that is only *declared* is exactly the "fourth trap" shape —
a check that passes because it was never run.

**K10 — F3 parsimony is reporting-only (R1). Recorded candidates, not deleted:**
`lastOp` (deletable if 6d's `wit_fired_*` obligations are dropped — they are not);
`FEE_BPS` (derivable as `FEE_DEN − FEE_NUM`, kept because `:180-181` writes the
`3` literally and rounding direction is never dropped); the split of `swap0for1`
and `swap1for0` into two actions (one parameterised action would do, kept because
the contract's `swap(amount0Out, amount1Out, ...)` is genuinely one function with
two directions and 6d wants each direction witnessed separately). None passes the
contract-facing droppability test of `P2-FIDELITY` §2, so none is deleted.
