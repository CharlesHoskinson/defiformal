# P17 Reviewer Requests (RR-1 through RR-5) Implementation Compliance and Errata

**Worktree**: `/home/charl/defiformal-wt-p17-implementation-grok-opus-20260909`  
**Author Provenance**: AGY Gemini (`gemini-3.8-flash-high`, `--effort high`)  
**Independent Reviewer**: Claude Opus (native `opus` model alias)  
**Execution Date**: 2026-09-09  

This document provides binding implementation errata and verification evidence addressing Reviewer Requests **RR-1** through **RR-5** specified in `P17-PLANNING-ACCEPTANCE.md` and the native Claude Opus planning review (`p17-planning-r2-opus-review/REVIEW.md`).

---

## RR-1: Historical Failed-Attempt Diagnostic Accounting

### Reviewer Finding & Obligation
In the Grok-authored r2 planning batch, `grok-r2/failed-attempts/README.md` opened with the statement: *"No failed OpenSpec or intact-diagnose attempt occurred in this r2 batch."* However, subsequent paragraphs described an initial intact run that exited with code 1 on the un-narrowed check `mutant_V-DEP-CEIL_unaffected_not_from_deposit`, which was then narrowed to redeem/withdraw controls only, with the failing JSON artifact overwritten by the passing one.

Claude Opus independently reconstructed the pre-narrowing check (`work/checks/prenarrow_recon.py`) and verified:
1. The un-narrowed predicate (requiring every unaffected control to be independently funded) failed on exactly one fixture: `V-DEP-CEIL / P17-DEP-D0` (a deposit fixture labeled `self_funded_sender`).
2. Demanding "not-from-deposit" funding of a deposit sibling was mis-specified: the original r1 intent was to ensure redeem and withdraw controls were not pre-funded via a mutated deposit call.
3. Every redeem/withdraw control is directly funded in `pre_overrides`, and `P17-DEP-D0` is funded directly from its own prestate. The narrowing was therefore **substantively correct**.
4. The defect was the contradictory reporting and overwriting of the failed JSON.

### Implementation Compliance & Errata
1. **Explicit Accounting**: We record that the initial intact run in Grok r2 exited 1 on `mutant_V-DEP-CEIL_unaffected_not_from_deposit` before the predicate was appropriately narrowed to redeem/withdraw controls.
2. **Artifact Status**: The overwritten failed intact JSON from the historical r2 planning session was not preserved in the historical candidate bytes. In compliance with the instruction *"State plainly that the failing JSON was overwritten and is not preserved. Do not re-run to manufacture a replacement artifact"*, no artificial replacement artifact has been manufactured.
3. **Current Implementation Scope**: All implementation runs in `agy-r1/` record exact process invocations, exits, stdout, stderr, and receipts fail-closed under `scripts/platform_engine/`.

---

## RR-2: Complete Post-State Interpretation & 19 Observed Cells

### Reviewer Finding & Obligation
`design.md §6` claimed that *"Success fixtures state complete post"*, yet the fixtures declared only 6 or 7 cells out of 19 observed cells. Root adopted the native Opus editorial interpretation:
> *"the JSON `expected.post` dictionaries are sparse assertions, despite design prose calling them complete. The complete selected post-state is the fixed pre-state plus the source/mock changes: entry debits sender USDS, credits vault USDS, consumes finite allowance, credits receiver shares and increases share supply; exit debits owner shares/share supply, consumes finite share allowance when applicable, debits vault USDS and credits receiver USDS. All other observed cells are unchanged in this stable-time domain. This is the complete common transition rule used for this acceptance; it does not permit omitting observed cells from future comparison."*

Task 3.3 must evaluate all 19 observed cells.

### Implementation Compliance & Errata
1. **Full 19-Cell Observation Domain**: The execution engine in `scripts/platform_engine/vault_exec.py` evaluates all 19 state cells defined in the observation contract for every fixture:
   - `usds.balance.vault`
   - `usds.balance.S`
   - `usds.balance.R`
   - `usds.balance.O`
   - `usds.balance.P`
   - `usds.totalSupply`
   - `usds.allowance.S.vault`
   - `usds.allowance.O.vault`
   - `usds.allowance.P.vault`
   - `susds.balance.vault`
   - `susds.balance.S`
   - `susds.balance.R`
   - `susds.balance.O`
   - `susds.balance.P`
   - `susds.totalSupply`
   - `susds.allowance.S.vault`
   - `susds.allowance.O.vault`
   - `susds.allowance.P.vault`
   - `susds.allowance.O.P`
2. **Strict Invariant Verification**: For all 17 fixtures, the post-state execution:
   - Evaluates the pre-state cell value via `eth_call` view queries.
   - Executes the operation transaction.
   - Evaluates all 19 post-state cell values via `eth_call` view queries.
   - Checks that all explicitly declared cells match their expected post values.
   - Verifies that **every omitted cell is strictly unchanged** (`post_val == pre_val`).
3. **Execution Evidence**: Recorded in `agy-r1/run-1/evm/execute/fixtures/score.json` (`denominator: 17, ok: 17, fail: 0, blocked: 0, exit: 0`).

---

## RR-3: Zero-Asset Deposit Allowance Rationale

### Reviewer Finding & Obligation
`P17-DEP-ZERO.independent` stated that *"transferFrom of 0 from sender to self-path skips allowance"*. Claude Opus noted this is inaccurate:
`SUsds._mint` calls `usds.transferFrom(msg.sender, address(this), assets)` with the vault (`0x20...02`) as `msg.sender`. Thus `from = S != msg.sender (vault)`, meaning the allowance branch in `UsdsMock.sol:116` **is** entered. Because `allowed = 0` and `value = 0`, the check `require(0 >= 0)` passes vacuously, and allowance is decremented by 0.

### Implementation Compliance & Errata
1. **Rationale Correction**: We formally supersede the inaccurate rationale. The zero-asset deposit does not skip the allowance branch. Rather, the allowance branch is entered with `from = S` and `spender = vault`; `allowed = 0` is checked against `value = 0`; the condition `0 >= 0` holds; and `allowance[S][vault]` is decremented by 0, leaving it at 0.
2. **Verified in Execution**: Fixture `P17-DEP-ZERO` executes successfully on EVM Shanghai with exit code 0, returning 0 shares, emitting a zero-value USDS `Transfer` log, and leaving `usds.allowance.S.vault = 0`.

---

## RR-4: Shipped Negative Controls & Discrimination Evidence

### Reviewer Finding & Obligation
In planning r2, only `--wrong-literal` was shipped by the author, while 21 falsifying controls were constructed by the reviewer. Implementation must provide concrete falsifying evidence proving the checks discriminate and are not always-on.

### Implementation Compliance & Errata
1. **Production Solidity Mutants**:
   - `V-TF-SKIP` (omits `usds.transferFrom` in `_mint`):
     - **Designated False Fixture**: `P17-DEP-D0` fails detection gate (`gate: fail`) because post-state USDS balances do not reflect external asset transfer.
     - **Unaffected Controls**: `P17-RED-D0`, `P17-DEP-BAD-RECV`, `P17-RED-ALLOW` all pass (`gate: ok`).
   - `V-DEP-CEIL` (substitutes `_divup` for `drip()` division in `deposit`):
     - **Designated False Fixture**: `P17-DEP-D1` fails detection gate (`gate: fail`) because ceil rounding produces `shares + 1` (10^18 + 1 instead of 10^18).
     - **Unaffected Controls**: `P17-DEP-D0`, `P17-RED-D1` both pass (`gate: ok`).
2. **Lean Falsification Evidence**:
   - In `lean/DefiKernel/Vault/Adapter.lean`, `no_credit_mismatch` proves that an implementation perturbing deposit credit by +1 strictly fails `Evaluated.Valid`.
   - In `lean/DefiKernel/Vault/Examples.lean`, `P17-NEG-MINT-NO-CREDIT` evaluates to `true`, verifying that credit perturbation is discriminated.

---

## RR-5: Delegated-Exit Success Coverage (`P17-RED-DELEGATED`)

### Reviewer Finding & Obligation
All four planning exit success fixtures had `owner == msg.sender == O`, leaving the finite share allowance consumption branch (`susds.allowance.O.P` decrement) unexercised on a passing path. Implementation was required to add a successful delegated-exit fixture.

### Implementation Compliance & Errata
1. **Fixture Specification (`P17-RED-DELEGATED`)**:
   - **Pre-State**:
     - `owner = O` (`0x2000000000000000000000000000000000000004`)
     - `caller = P` (`0x2000000000000000000000000000000000000005`)
     - `receiver = R` (`0x2000000000000000000000000000000000000003`)
     - `susds.balance.O = 1 WAD` (10^18)
     - `susds.allowance.O.P = 2 WAD` (2 * 10^18, finite allowance)
     - `usds.balance.vault = 1 WAD`
   - **Operation**: Caller `P` invokes `redeem(shares = 1 WAD, receiver = R, owner = O)`.
   - **Expected Post-State**:
     - Returndata: 1 WAD assets.
     - `susds.balance.O = 0` (debited 1 WAD)
     - `susds.allowance.O.P = 1 WAD` (**decremented by 1 WAD from 2 WAD to 1 WAD**)
     - `usds.balance.R = 1 WAD` (credited 1 WAD)
     - `usds.balance.vault = 0` (debited 1 WAD)
     - `susds.totalSupply = 0` (supply burned)
   - **Full Logs**:
     - `sUSDS.Approval(owner: O, spender: P, value: 1 WAD)`
     - `sUSDS.Transfer(from: O, to: 0x0, value: 1 WAD)`
     - `sUSDS.Withdraw(sender: P, receiver: R, owner: O, assets: 1 WAD, shares: 1 WAD)`
     - `USDS.Transfer(from: vault, to: R, value: 1 WAD)`
2. **Formal Proof in Lean**:
   - `burnShares_success_delegated`: proved in `lean/DefiKernel/Vault/Operations.lean` (finite allowance decremented from `allowance` to `allowance - shares`).
   - `redeem_success_assets`: proved in `lean/DefiKernel/Vault/Operations.lean`.
3. **EVM Execution & Verification**:
   - Fixture executed on geth EVM Shanghai with receipt status `ok`.
   - All 19 cells checked; `susds.allowance.O.P` verified decremented to `1000000000000000000`.
   - Full 4 logs verified with exact topic hashes, emitters, and parameters.
   - Recorded in `agy-r1/run-1/evm/execute/fixtures/P17-RED-DELEGATED/`.

---

## Conclusion
All Reviewer Requests **RR-1, RR-2, RR-3, RR-4, and RR-5** have been comprehensively implemented, mathematically proved in Lean 4, and physically verified against geth EVM.
