## Context

See proposal.md. Inputs are accepted P15 contracts at delivery `66ec8833186ca24066dbc5427c399c165a995cee`, delivered Arithmetic and Typed/Composition APIs at this worktree HEAD `2ad464397cd207bca647768d77d57abb1f8e575c`, accepted P16 planning (`038be241`) and proof/recorder subset (`e53d78fd`), and published P17 source acquisition under `review/semantic-kernel/program-execution-20260908/p17-source-acquisition/` with compiler smoke `p17-compiler-readiness/compile-smoke.json`. P16 source-gate R1/R2 repairs may still be in review. This design does not implement Lean, does not score source, and does not claim `P17.platform_reuse` or P16 source acceptance.

Host observation, not the Lean pin: implementation SHALL use `lean/lean-toolchain` `leanprover/lean4:v4.33.0-rc2` and mathlib `51e6992efd06126df61a496bebf8f49482a4e129`.

## Goals / Non-Goals

**Goals:**

- Exact P17 source-entry freeze for Sky/Spark sUSDS vault conversion and source-selected transfer/authorization refusal.
- Concrete compiler/EVM/harness assumptions, observation relation, fixtures, production mutants, proof obligations, and platform-reuse experiment.
- Honest overflow premises, mock/external-call boundaries, and claim-class distinctions.

**Non-Goals:**

- Lean modules, lake build, `#eval`, or proofs in this increment.
- Campaign solc compile, EVM scoring, or compiled mutants in this increment.
- Accrual/`_rpow`/drip yield realization, UUPS upgrade, permit/IERC1271, referral overloads, L2 token, mainnet identity.
- P21/P30 widening, held/untouched payload access, token0-to-vault sequential workflow.
- Self-acceptance, ticking frozen program tasks 18.1–18.7, or assuming the P16 source gate closed.

## Decisions

### 1. Selected source (not L2, not a second AMM)

**Selected pin:** Sky/Spark sUSDS `https://github.com/sky-ecosystem/sdai.git` commit `dfc7f41cb7599afcb0f0eb1ddaadbf9dd4015dce`, file `src/SUsds.sol` SHA-256 `9fe0c713751142e75a1da60ad6c0127d5ad01cb6d24289183ac48b202f3c5d69` (16399 bytes, git blob `efe937675bbbbc7f93bde453fd5648fa885655ab`).

The moving `susds` branch was only the locator.

**Rejected as the vault case:** `src/l2/SUsds.sol` SHA-256 `bcf6dfabed3c99f200d0c184943f88a9361c11e35c1adbf6212d33c4dc8165fa`. That file is a bridged ERC20 with `auth` `mint`/`burn`, no `chi`/`rho`/`ssr`, no ERC-4626 `deposit`/`mint`/`withdraw`/`redeem`, and no asset/share conversion. Using it would be a second token, not a contrasting vault, and not a second AMM substitute.

**Justification that this is a contrasting vault, not token0-like AMM math:** public `deposit`/`mint`/`withdraw`/`redeem` convert USDS assets and sUSDS shares with chi-scaled directed rounding, mutate `balanceOf`/`totalSupply`, and call `UsdsLike.transferFrom` / `transfer`. Token0 is an `internal pure` next-price helper with no storage and no token movement.

OpenZeppelin upgradeable `723f8cab09cdae1aca9ec9cc1cfa040c2d4b06c1`; nested core `dbb6104ce834628e473d2173bbc9d47f81a9eec3`. `ERC1967Proxy.sol` is an explicit additional capture root for a possible deployment harness. It is not a deployed-proxy identity.

Import closure is ten Solidity keys (see `source-pin.json`). Closure does not discharge `VatLike`, `UsdsJoinLike`, `UsdsLike`, or `IERC1271`.

### 2. Selected operations and ordered effects

Public functions in campaign scope:

| Function | Source lines | Conversion | Then |
| --- | --- | --- | --- |
| `deposit(uint256 assets, address receiver)` | 352–355 | `shares = assets * RAY / drip()` (floor) | `_mint(assets, shares, receiver)` |
| `mint(uint256 shares, address receiver)` | 371–374 | `assets = _divup(shares * drip(), RAY)` (ceil) | `_mint` |
| `withdraw(uint256 assets, address receiver, address owner)` | 390–393 | `shares = _divup(assets * RAY, drip())` (ceil) | `_burn(assets, shares, receiver, owner)` |
| `redeem(uint256 shares, address receiver, address owner)` | 403–406 | `assets = shares * drip() / RAY` (floor) | `_burn` |

Referral overloads (357–360, 376–379) are out of campaign scope.

`_divup` (184–189): `x != 0 ? ((x - 1) / y) + 1 : 0`. Note: `_divup(0,0)` returns 0; native `/` would revert. Campaign domain has `chi > 0` after initialize, so `drip()` is not 0 in D0/D1.

**`_mint` order (284–296):**

1. `require(receiver != address(0) && receiver != address(this), "SUsds/invalid-address")`
2. `usds.transferFrom(msg.sender, address(this), assets)`
3. Unchecked `balanceOf[receiver] += shares`; unchecked `totalSupply += shares`
4. `emit Deposit`; `emit Transfer(address(0), receiver, shares)`

**`_burn` order (298–322):**

1. `require(balanceOf[owner] >= shares, "SUsds/insufficient-balance")`
2. If `owner != msg.sender` and allowance is not `type(uint256).max`: `require(allowed >= shares, "SUsds/insufficient-allowance")`, then unchecked allowance decrease
3. Unchecked share/supply decrease
4. `usds.transfer(receiver, assets)`
5. `emit Transfer(owner, address(0), shares)`; `emit Withdraw(...)`

**`drip` (214–229)** is always called first by the four public converters. When `block.timestamp > rho` it computes `_rpow`, may `vat.suck` and `usdsJoin.exit`, then writes `chi`/`rho`. When `block.timestamp <= rho` it returns stored `chi` and still `emit Drip(nChi, diff)` with `diff = 0`. A successful `vat.suck` / `usdsJoin.exit` / `usds.transferFrom` / `usds.transfer` return is **not** proof that USDS or Vat balances moved. Those cells are observed separately.

### 3. Domain freeze (initialized stable-time, not the whole source)

**D0 (exact conversion):** `initialize()` has run once; `chi = RAY = 10**27`; `ssr = RAY`; `block.timestamp == rho`; `chi > 0`. Then `drip()` takes the else branch (no `_rpow`, no `vat.suck`, no `usdsJoin.exit`). `deposit`/`redeem` floor and `mint`/`withdraw` ceil coincide on exact multiples of `chi/RAY = 1`.

**D1 (directed rounding):** same as D0 except stored `chi = RAY + 1` and still `timestamp == rho` (drip still a no-op). Floor and ceil diverge on `assets = 10**18` (see `fixtures.json`).

**Why this domain is chosen:** P17's contrasting case is share/asset conversion plus transfer/authorization, not Maker yield realization. Accrual (`_rpow`, `vat.suck`, `usdsJoin.exit`, `chi` growth) is a named remainder. The four public converters and `_mint`/`_burn` still execute for real.

**Not claimed:** whole source domain; drip with `timestamp > rho`; `file("ssr")`; UUPS; permit; IERC1271; referral; protocol-reachability of near-`uint256` supply from initialize without storage poke.

### 4. Width, overflow, and unchecked updates

Solidity `^0.8.21` checked `*` and `/` on the public converters. `assets * RAY` reverts with Panic `0x11` on uint256 overflow. That is a source refusal (fixture `P17-DEP-MUL-OVF`), not a wrap.

Lean `Rounding.mulDiv` uses an **unbounded** natural product. It MUST NOT be used as silent source semantics for that overflow partition. Campaign conversion theorems use either:

- `Operations.mul` at width 256 then `Rounding.divideNat`, or
- `Rounding.mulDiv` **under the premise** `assets * RAY < 2^256` (and the symmetric `shares * chi < 2^256`).

`_mint`/`_burn` use **unchecked** share/supply updates. Source comments claim overflow checks are unnecessary because `balanceOf[receiver] <= totalSupply` and `shares totalSupply will always be <= usds totalSupply`. Those comments are **not** premises of a success theorem and MUST NOT be used as a desired accounting conclusion.

**Actual premises for modelled successful `_mint`:**

1. `receiver ≠ 0 ∧ receiver ≠ vault`
2. `usds.transferFrom` is observed to move `assets` from sender to vault (not merely to return)
3. `totalSupply + shares < 2^256`
4. `balanceOf[receiver] + shares < 2^256`

If (3) or (4) fail, source wraps; a Lean `Operations.add` model refuses. That mismatch is named gap `G-UNCHECKED-SUPPLY-WRAP`. Claimed campaign fixtures satisfy the premises. A storage-poked wrap, if later executed, is source-observation without model agreement, not a proof that wrap is impossible.

`_burn` success premises: `balanceOf[owner] >= shares`, authorization as in source, `totalSupply >= shares`, and observed `usds.transfer` of `assets` to `receiver`.

### 5. Source-selected refusals

**Transfer refusal (primary):** `_mint`'s `usds.transferFrom` reverts. With captured `UsdsMock`, that is `Usds/insufficient-balance` or `Usds/insufficient-allowance`. The mock is a test-harness assumption, not mainnet USDS.

**Authorization refusal (primary):** `_burn` when `owner != msg.sender` and finite allowance `< shares` → `SUsds/insufficient-allowance`. Also `SUsds/insufficient-balance` when owner shares `<` redeemed shares.

**Address refusal:** `SUsds/invalid-address` for receiver `0` or `address(this)`, checked **before** `transferFrom` in `_mint`.

Do not invent other refusals. Do not treat zero-asset `deposit(0)` as refusal: source mints 0 shares and `transferFrom` of 0 may succeed.

### 6. Observation relation

Stateful. Refusal has no post-world; retain the supplied pre-state beside the revert.

**Observed on every scored operation:**

- Pre/post: `balanceOf[owner]`, `balanceOf[receiver]`, `totalSupply`, `chi`, `rho`, `ssr`, `allowance[owner][msg.sender]` when `_burn` authorization applies
- Pre/post **USDS** `balanceOf[sender]`, `balanceOf[vault]`, `balanceOf[receiver]` (asset credit). A successful external call is insufficient.
- Return value (`shares` or `assets`)
- Events in source order, including no-op `Drip`
- Revert string / Panic code on refusal
- `msg.sender`, `block.timestamp`

**Not observed as source truth:** Vat `dai`/`sin` in D0/D1 (drip else-branch); IERC1271; implementation slot as deployed identity; Python diagnostics.

Token0 source observations remain the four inputs plus `uint160 | revert`. The token0 kernel bridge below is **not** a source observation.

### 7. Compiler / EVM / harness (planned, not scored here)

Repo `foundry.toml`: solc `0.8.21`, optimizer enabled, 200 runs. Official binary `/home/charl/.cache/defiformal-program/program-execution-20260908/p17-source-readiness/solc-linux-amd64-v0.8.21+commit.d9974bed`, SHA-256 `f2857a898be15c69e8de5598dcd3f3e169e94964a0ce9a0bbb1b111f145a81df`. Root smoke selected Shanghai/IPFS and compiled the ten-key closure; that is administrative feasibility. **Campaign freeze:** optimizer 200, `evmVersion shanghai`, `metadata.bytecodeHash none`. Smoke artifact hashes MUST NOT be reused as campaign bytecode identities.

**EVM identity (from P16 administrative readiness, re-pinned here for method):** geth `evm` 1.15.11-stable, path `/home/charl/.cache/defiformal-program/program-execution-20260908/p16-tools/evm`, SHA-256 `d298ce2c811de089d650ed4f9535c0c58efc72e7adee9b61a40b6c10cc26fb5c`. Token0 uses an Istanbul prestate. Vault uses a **separate** Shanghai prestate (`config.shanghaiTime = 0` or equivalent). Same binary, different prestate files. Fork/state method is not P16's Istanbul genesis and is not bound until implementation records the genesis JSON hash.

**Planned execution method:** one `evm run --prestate <json>` engine. Token0: one call. Vault: chained `run` + `--dump` for deploy/initialize/mock-mint/approve, then one scored operation. Implementation MUST verify dump→next-prestate roundtrip with an unscored smoke. If dump is not a legal next prestate, `blocked_missing_evm`, not agreement.

**Deployment harness:** SUsds constructor takes `(usdsJoin, vow)` and `_disableInitializers()`. Campaign calls MUST go through `initialize()` on an ERC1967 proxy (captured proxy source is the harness root, not a mainnet proxy). Direct implementation `deposit` with `chi = 0` is excluded.

Captured `test/mocks/{VatMock,UsdsJoinMock,UsdsMock}` MAY be used. They remain explicit test-harness assumptions. Never present them, or the `susds` branch URL, as mainnet fidelity. No address/block/codehash/runtime identity is established.

Portable settings: tool paths, genesis files, and evidence directories are configuration, not hardcoded W16 paths. Missing/malformed receipts are setup-blocked (exit 3) at the campaign consumer. Recorder missing-executable remains child 1 / no receipt (P16 lesson). Semantic success requires child 0, wrapper 0, classification `ok`, complete protocol, and actual Lean comparison truth. Compiler failure with partial rows is blocked 3. Malformed extra protocol rows are blocked 3. Child 1 / timeout / crash is not mutation detection.

### 8. Platform reuse experiment (designed, not executed)

Claim classes, kept distinct:

| Class | This slice |
| --- | --- |
| `arithmetic_reuse` | Directed `Rounding.divideNat` / `mulDiv` under overflow premises. Publishable later without closing the platform gate. |
| `platform_reuse` | Predicate below. Stays false here. |
| `bounded_source_execution` | Pinned solc/EVM observations. Zero campaign runs here. P16 source gate may still be open. |
| `model_bridge` | Token0 quote-register Typed wrap and vault Typed adapter. Not source refinement. |
| `source_refinement` | P30. Open. |

**One common harness engine:** generalize delivered `scripts/token0_p16/record_cmd.py` plus compile/prestate/score into `scripts/platform_engine/` (proposed path). Both token0 and vault campaigns call that engine. A wrapper that shells out to two independent campaigns does not count. A cloned dispatcher does not count. Future implementation must preserve P16's accepted semantic observations and repaired fail-closed consumer behavior; it must not assume the unrepaired r4/r5 source gate is accepted.

**Named shared financial contract / lemma (used in both):**

- `DefiKernel.Arithmetic.Rounding.divideNat_down_ok_iff` and `divideNat_up_ok_iff` (`lean/DefiKernel/Arithmetic/Rounding.lean`, SHA-256 `0bd0c65af77bc809f4ff3b8cb5d98ab7eca5be0e0e7216e9e88263e4e02649f0`), plus `mulDiv_down_rational_error` / `mulDiv_up_rational_error` under the no-product-overflow premise.
- Token0: FullMath wrap of `Rounding.mulDiv` at width 256 (already delivered).
- Vault: `convertToShares`/`deposit` floor and `previewMint`/`mint`/`withdraw` `_divup` as `divideNat` down/up after a checked or premised product.

This lemma is directed conversion, not token0 wrap-fallback and not 0.8.21 checked-mul overflow (those stay case-specific).

**Named shared executor theorem:** `DefiKernel.Typed.execute_ok_iff` (`lean/DefiKernel/Typed/Transition.lean` line 219, SHA-256 `73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2`). Supporting conservation: `applyEvaluated_accounting` (line 248). Observation shape: `Arithmetic.Reference.observeExecution` (`lean/DefiKernel/Arithmetic/Reference.lean` lines 67–71, SHA-256 `6bfa5e3e0a31947d3fea3078106df6e43311254cabbc291d004463d0a617325d`).

Both adapters instantiate the **same** `execute_ok_iff` premises (registry hit, actor/domain/arity/args, invoke authority, `evaluate = ok e`, `e.Valid`, post capabilities/store, post balance = pre + effect). Neither adapter assumes the desired post-state as a premise. A vault-only theorem does not count.

**Token0 library-to-kernel bridge (model_bridge, not source history):**

- Library remains `Except Failure (Word 160)` with no ledger. Source observations stay `{sqrtPX96, liquidity, amount, add} → uint160 | revert`.
- Bridge: `Quantity.toQuantity` (`Quantity.lean` SHA-256 `df223e39db3d3de1070deba403075331bb801805cd95f02ccb8eeafed0ae569e`) lifts the successful word to a Typed quantity. A **quote-register** template has one asset `QuoteSqrtP`, one holder `quoteHolder`, supply equal to the quoted price. Ordinary add `(2^96,1,1,true) → 2^95` is a **nonzero** debit and supply decrease of `2^95`. Identity `amount = 0` is zero effect of that same template, not the whole experiment.
- Financial meaning: the adapter represents the quoted next sqrt-price as the unique holder balance of a non-transferable quote-register asset. This is **not** Uniswap reserve accounting and is **not** a token0 source observation.
- Source/model boundary: Uniswap helper has no such cell. The wrap is kernel-platform evidence. Vacuous empty-delta templates are rejected. Inventing Uniswap pool storage or sequential token0-then-vault cashflow is rejected.

**Vault Typed adapter:** two assets (`USDS`, `sUSDS`). Deposit success: USDS sender `−assets`, vault `+assets`, supply 0; sUSDS receiver `+shares`, supply `+shares`. Accounting is proved from those deltas, not assumed. Debit of USDS requires debit authority; sUSDS mint requires `changeSupply`. Asset-credit is a template delta **and** a source observation of USDS balances. If USDS did not move, `e.Valid` for this template does not describe the source.

**Composition:** not claimed. Token0 next-price and vault deposit do not financially compose. No token0-to-vault sequential workflow. Narrow interface/library/executor reuse remains valid. `Composition.executeStep_sound` is not required for this gate.

**Unchanged-interface reuse criteria:** no new global induction; no cloned dispatcher; no case-specific checker exemption; `Typed.execute` / `execute_ok_iff` / `observeExecution` signatures unchanged; protocol adapters allowed; new assumptions counted in the case-two inventory. A new global induction, cloned dispatcher, or checker exemption blocks the unchanged-interface claim.

**If independent review rejects the quote-register embedding:** do not weaken `P17.platform_reuse`. Record the remaining design obligation: a Typed embedding of the pure helper that is non-vacuous, non-circular, and not fabricated Uniswap history. Arithmetic-only reuse may still be published in `arithmetic_reuse` while the platform gate stays open.

### 9. Case-two inventory design (measured later)

Relative to the accepted token0 arithmetic slice, implementation MUST record:

| Category | Planned vault additions (not measured here) |
| --- | --- |
| New definitions | `DefiKernel.Vault` types, conversion, adapters, quote-register token0 wrap, platform engine settings |
| New assumptions | Usds/Vat/Join mocks; initialize/proxy; D0/D1 time; overflow premises; no deployed identity |
| Interface changes | Stateful observation fields; Shanghai prestate; two-asset template; token0 Typed wrap (optional in P16, required for platform_reuse) |
| Effort | Wall-clock, new Lean LOC, new assumptions count, new engine modules — recorded at implementation |

Missing inventory leaves `P17.platform_reuse` open.

### 10. Namespace and files (proposed, not created)

`DefiKernel.Vault` under `lean/DefiKernel/Vault/`. Token0 wrap under `lean/DefiKernel/ConcentratedLiquidity/Token0Bridge.lean` or equivalent, reusing delivered token0 library without editing accepted theorem statements.

| Module | P17 content |
| --- | --- |
| `Types.lean` | RAY, chi/rho/ssr words, parties/assets, Failure/revert labels |
| `Conversion.lean` | floor/ceil convertToShares/Assets and `_divup` via Arithmetic |
| `Operations.lean` | deposit/mint/withdraw/redeem model under D0/D1 premises |
| `Adapter.lean` | Typed templates for deposit and redeem |
| `Token0Bridge` | quote-register wrap of delivered token0 library |
| `Examples.lean` / `Tests.lean` | P17 fixtures |
| `RuntimeAudit.lean` / `ProofAudit.lean` / `Verify.lean` | nonempty inventory, `#audit_axioms`, no `sorry` / custom axioms / `native_decide` |

Do not change historical theorem statements to make a new claim pass.

### 11. Alternatives considered

- Use L2 `SUsds` because it is simpler: rejected; not a vault.
- Use another AMM formula: rejected by the program spec.
- Whole-source domain including drip yield: rejected for this slice; remainder named.
- Treat `transferFrom` success as asset credit: rejected.
- Use `Operations.add` for `_mint` supply without overflow premises: rejected; source is unchecked.
- Use `Rounding.mulDiv` as source for `assets * RAY` overflow: rejected; 0.8.21 reverts.
- Vacuous token0 Typed wrap with empty deltas: rejected.
- Wrapper around separate token0 and vault engines: rejected.
- Vault-only theorem as the shared executor result: rejected.
- Fabricate token0-then-deposit workflow: rejected.
- Claim `platform_reuse` in this planning freeze: rejected.
- Wait for P16 source-gate close before writing this slice: rejected by the queued brief; reuse claim still waits.
- BytecodeHash ipfs to reuse smoke artifacts: rejected; campaign freezes `none` and recompiles.

## Risks / Trade-offs

- [P16 source gate still open] → This slice may proceed; `P17.platform_reuse` and dual-case engine scoring stay false/unrun.
- [geth `evm run --dump` may not be a legal next prestate] → Implementation smoke; else `blocked_missing_evm`.
- [Quote-register may be judged too invented] → Do not weaken the gate; repair the embedding or leave platform_reuse open.
- [Mocks ≠ mainnet USDS/Vat] → Explicit assumptions; no deployment claim.
- [Unchecked wrap vs checked Lean add] → Named gap; premises on success; no desired-accounting conclusion.
- [Author diagnostics mistaken for GPT-6 review] → `gate_accepted` false; result.json pending.

## Migration Plan

No runtime migration. If independent GPT-6 accepts this slice, root copies these bytes onto `semantic-kernel-pivot` and implementation may start in a later increment after P16 source-consumer conditions are respected. Rollback is leaving the change unintegrated. Do not merge to main.

## Open Questions

None that change this slice. Accrual, upgrade, permit, deployed identity, P21, and P30 remain later sprints. The quote-register embedding is the selected concrete design, not an unanswered question.
