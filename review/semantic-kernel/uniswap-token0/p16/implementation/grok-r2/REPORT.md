# P16 r2 proof/recorder/audit candidate — native Grok 4.6

**Status: pending independent GPT-6 review. Not P16 acceptance. Not source/EVM/mutant credit.**

Fresh native Grok 4.6 author session after root SIGINT on process 33469 (exit 130, no native end event). This closeout does not label that interruption as normal completion. The preserved partial archive `p16-r2-partial-at-guidance.tar.gz` SHA-256 `356e5bd390cde4818086ca4889d8fd8ebd3b9876aca4bc3ddc2436dd11eedb2d` remains historical. No `--restore-code` and no resume of the stalled session.

Independent confirmed diagnosis (not production acceptance): `p16-equation-diagnostic-review/REVIEW.md` SHA-256 `715e7d35ae437da51dfead0f5a2be6f90308d29d69a5b7c8177a7b502d62a469`. Core `Nat.mul` recurses on its second argument. `numerator1 L := L.value * Q96` unfolds a concrete `2^96` recursive argument. The commutative form `Q96 * L.value` with `Nat.mul_comm` in the existing bound proof is the applied repair.

## What this batch did

Owned edits only: `lean/DefiKernel/ConcentratedLiquidity/**` and `scripts/token0_p16/**`. New evidence only under `review/semantic-kernel/uniswap-token0/p16/implementation/grok-r2/**`. All 77 grok-r1 evidence files left in place. Original planning checkboxes unchanged. No commit, push, Foreman, subagents, or global install.

### 1. Recorder

`scripts/token0_p16/record_cmd.py` starts an owned session/process group, terminates and reaps that group on timeout/cancellation, and returns genuine child 0/1/3 at the wrapper boundary. Timeout is blocked 3 with non-null `timeout_blocked` and child `exit` null.

Fresh controls, denominator 5, failures 0:

| Control | wrapper exit | receipt exit | classification |
| --- | --- | --- | --- |
| child-0 | 0 | 0 | ok |
| child-1 | 1 | 1 | failure |
| child-3 | 3 | 3 | blocked |
| empty-cmd | 3 | (no receipt) | empty command blocked |
| timeout-descendant | 3 | null | timeout_blocked; owned grandchild reaped; outsider process left alive |

Empty command is blocked 3 and is not a semantic or mutant failure. Crash/setup/timeout are not scored as semantic failure.

### 2. Arithmetic orientation

Snapshot before orientation:

- `snapshots/SqrtPriceMath.lean.pre-orientation` SHA-256 `3f5d7479593fb4ac84256dd77c1c451128d82df6af5c1bcfeb82936b40fe04ac`
- `snapshots/Token0Proofs.lean.pre-orientation` SHA-256 `0f7fc855197e157b3e7cd38525ef2d93f61d5e66bca146efd365df07f71042da`

Production change: `def numerator1 L := Q96 * L.value`, and `rw [Nat.mul_comm (2 ^ 96) L.value]` in `numerator1_lt_u256`. Public types and bound statement unchanged. Lemma `numerator1_comm` records `numerator1 L = L.value * Q96` by `Nat.mul_comm`. Both orientations are mathematical equivalents; kernel reduction is not.

Builds after orientation, with the then-current FullMath wrappers still present:

- `lake build DefiKernel.ConcentratedLiquidity.SqrtPriceMath` 909ms, exit 0 (`logs/lake-sqrt-orientation.json`)
- `lake build DefiKernel.ConcentratedLiquidity.Token0Proofs` 827ms, exit 0 (`logs/lake-proofs-orientation.json`)

The previous r2 Token0Proofs attempt without orientation was timeout-blocked at 40s (`logs/lake-proofs-fullmath-eq.json`).

### 3. Wrapper detours removed after consumer evidence

Snapshot of the oriented wrapped source: `snapshots/SqrtPriceMath.lean.oriented-with-wrappers` SHA-256 `2be0863412c7c42bb79a0e80c93b9bba8e7cacdb487ee7f712b5b1c4956c4037`.

After orientation compiled, `fullMathUp` / `addPrimaryResult` / `mapBare` / `mapSafeCast` and the compound `congrArg` equations were removed. `addPrimary` / `removePrimary` are again the source match on `FullMath.mulDivRoundingUp`. `addPrimary_fullmath` and `removePrimary_fullmath` remain as `rfl`. Public statements were not weakened.

`lake build DefiKernel.ConcentratedLiquidity.Token0Proofs` without wrappers: SqrtPriceMath 849ms, Token0Proofs 809ms, exit 0 (`logs/lake-proofs-nowrappers.json`). The wrappers were therefore unused after the orientation repair. Historical wrapper-search logs and snapshots from the interrupted r2 session are kept.

### 4. Public branch equations, guard bridges, bounds

`Token0Proofs.lean` now includes:

- Bool/Prop bridges: `product_fit_iff`, `product_overflow_iff`, `wrap_fit_iff`, `wrap_overflow_iff`, `remove_guard_iff`
- Identity and six selectors (unchanged working proofs)
- Public ordered composition: `primary_add`, `wrap_fallback`, `prod_fallback`, `remove_require`, `remove_primary`
- Pre-cast successful-add bound: `primary_add_precast_le` uses `FullMath.mulDivRoundingUp_ok_iff` and `Arithmetic.Rounding.mulDiv_up_ok_iff` leastness at `k = sqrtP` with non-wrapping denominator `Nat.mod_eq_of_lt`
- Reachable fallback positivity: `wrap_fallback_sqrtP_pos`, `prod_fallback_sqrtP_pos` (`sqrtP > 0` from fallback selection), `fallback_inner_pos` (`Operations.add_ok_iff`, amount ≥ 1)
- Fallback pre-cast bound: `fallback_precast_le` relates `divRoundingUp` to `divideNat .up` under positive inner, then `divideNat_le` from `N < P*(floor(N/P)+1) ≤ P*inner`
- Public add success: `add_result_le` (`q.value ≤ sqrtP.value` before relying on bare uint160)

Source keeps bare uint160 on add, wrapped denominator sum, checked fallback add, FullMath then SafeCast on remove, full representable domain. No sorry, custom axioms, or `native_decide`.

Failed bound-compile attempts (exit 1, not timeout) are `logs/lake-proofs-bounds.json`, `bounds2`, `bounds3`. Successful compile: `logs/lake-proofs-bounds4.json`, Token0Proofs 1.0s, exit 0.

### 5. Runtime, Verify, ProofAudit

`lake build DefiKernel.ConcentratedLiquidity.RuntimeAudit` exit 0. `#eval` printed 22 true comparisons, nonempty unique IDs: F01–F09 (F03 down/up) and P16-I-ADD, P16-I-REM, P16-I-ZERO-LIQ, P16-ADD, P16-ADD-ROUND, P16-REQ, P16-REQ-STRICT, P16-REM, P16-SAFECAST, P16-ADD-DEN0, P16-PROD, P16-WRAP. This is bounded Lean execution against independent literals, not 22 universal proofs or Solidity execution. Same fixtures after orientation: semantic preservation at the executable table.

`lake build DefiKernel.ConcentratedLiquidity.ProofAudit` exit 0. `#audit_axioms DefiKernel.ConcentratedLiquidity`:

- theorems 138/138, forbidden 0
- supplemental declarations 108/108, forbidden 0
- axiom sets observed: empty 48; `{propext}` 47; `{propext, Quot.sound}` 14; `{propext, Classical.choice, Quot.sound}` 29
- allowlist only: `propext`, `Classical.choice`, `Quot.sound`

`lake build DefiKernel.ConcentratedLiquidity.Verify` exit 0 (imports RuntimeAudit and ProofAudit). No skipped failing proof module.

Source theorem types: `logs/theorem-types.json` (62 source `theorem` signatures). Transitive axioms: `logs/axiom-inventory.json`.

## Requirement mapping (this proof/runtime/audit scope)

| Obligation | Evidence | Status in this candidate |
| --- | --- | --- |
| 2.1 Types U128/U160/U256/Q96, no Signed | `Types.lean` | present |
| 2.2 FullMath F01–F09 | RuntimeAudit 10 FullMath rows true | present |
| 2.3 FullMath floor/ceil specs | `mulDiv_ok_iff`, `mulDivRoundingUp_ok_iff` | present |
| 3.1 public helper wrap/fallback/bare/SafeCast | `SqrtPriceMath.lean` | present |
| 3.2 12 token0 fixtures | RuntimeAudit 12 P16 rows true | present |
| 3.3 public branch equations + bounds | `Token0Proofs.lean` | present |
| 5.3 RuntimeAudit/ProofAudit/Verify nonempty | lake-runtime, lake-proofaudit, lake-verify exit 0 | present |
| P16-TH-IDENTITY | `identity` | present |
| P16-TH-PRIMARY-ADD | `primary_add` | present |
| P16-TH-WRAP-FALLBACK | `wrap_fallback` | present |
| P16-TH-PROD-FALLBACK | `prod_fallback` | present |
| P16-TH-REMOVE-REQUIRE | `remove_require` | present |
| P16-TH-REMOVE-PRIMARY | `remove_primary` | present |
| P16-TH-ADD-RESULT-BOUND | `add_result_le` | present (was planned future) |
| P16-TH-FALLBACK-POSITIVE-DENOM | `fallback_inner_pos`, fallback `sqrtP_pos` | present (was planned future) |
| recorder 0/1/3 + timeout group | test_record_cmd.py 5/5 | present |

Original OpenSpec task boxes in `openspec/changes/uniswap-token0-p16/tasks.md` remain unchecked historical planning text.

## Remaining gates for the immediately following batch

Not claimed here:

- 4.1–4.4 pinned solc 0.7.6 / Token0Probe compile / EVM fixture observations (tool cache may exist; campaign not run)
- 5.1–5.2 six compiled source mutants T0-ID-SKIP, T0-WRAP-SKIP, T0-PROD-SKIP, T0-REQ-SKIP, T0-FLOOR, T0-CHECKED-ADD with unaffected controls
- 5.4 M09 control-plan handoff
- 6.1–6.3 independent review, remainders, original 1.2
- Signed/token1/TickMath/SwapMath, original 45 fixtures, P17 reuse, P21, P30 source/assembly refinement

Runtime success is not source agreement. This candidate is not full P16, source, or operation acceptance.

## Tool identity

- Lean 4.33.0-rc2, binary SHA-256 `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`
- lake SHA-256 `840179e70803ef373c2ec53342d6a45ea7d022533e4145489fc1278b4f716385`
- mathlib pin `51e6992efd06126df61a496bebf8f49482a4e129` unchanged
- `record_cmd.py` SHA-256 `31057e00d0ec5e4f5edcfcfe7594d29a86a985ff8c863d5fb9c3bd5d52baaed1`

## Owned source hashes (current)

| File | SHA-256 |
| --- | --- |
| Types.lean | `638141c7c1298d0d20fc04f616f64330ff9c249cf85403ee02ac7bd374a4f72e` |
| FullMath.lean | `9cbc0c2d7c31fd184c6cfd3288966277bafa9c979ae6098103d1bdab774b7632` |
| SqrtPriceMath.lean | `437ceee45ca2b9aa4910128672a7781fc352aba306412a450a6de3523452c82f` |
| Token0Proofs.lean | `fd2e1ffadf85649f20b8b61280dc00282eee7bc02bdc1d828f7ef6094eabc3f9` |
| Examples.lean | `bab89a33ed8ab5fb3edcecdd8803ea397aec595e4cd76a498c84877190850a4d` |
| Tests.lean | `f1905c7b6dffc8d4409ba6947508bc33b251e6e80277c181a6fadd9252228940` |
| RuntimeAudit.lean | `934734d842d81e4fd4b49756035e27e2cfbdb55593ac5a6fc1f32975d6bc8324` |
| ProofAudit.lean | `dac625fcb3ac09623718696f71b59f54d0f941142f32309fa1ed14542e1c949d` |
| Verify.lean | `8fb0921c3d9e33bbe470defd9fc1f95d254393c678813d1b44673d066038d125` |

Author: native Grok 4.6. Checker: independent GPT-6, not executed in this session. Root integrates accepted bytes to `semantic-kernel-pivot` only after that review.
