# P17 Reviewer Requests (RR-1 through RR-5) Implementation Compliance and Errata

**Worktree**: `/home/charl/defiformal-wt-p17-implementation-grok-opus-20260909`  
**Author Provenance**: AGY Gemini (`gemini-3.8-flash-high`, `--effort high`)  
**Independent Reviewer**: Claude Opus (native `opus` model alias)  
**Execution Candidate**: `agy-r2`  
**Date**: 2026-09-09  

This document provides binding implementation errata and verification evidence addressing Reviewer Requests **RR-1** through **RR-5** specified in `P17-PLANNING-ACCEPTANCE.md` and the native Claude Opus planning review (`p17-planning-r2-opus-review/REVIEW.md`), incorporating the full scope resolution required by root directives SC1 through SC5.

---

## 1. Comprehensive Historical Errata

### 1.1 Grok r2 Planning Batch Erratum
In the historical Grok-authored r2 planning batch, `grok-r2/failed-attempts/README.md` opened with the claim: *"No failed OpenSpec or intact-diagnose attempt occurred in this r2 batch."* However, subsequent paragraphs described an initial intact run that exited with code 1 on the un-narrowed check `mutant_V-DEP-CEIL_unaffected_not_from_deposit`, which was then narrowed to redeem/withdraw controls only, with the failing JSON artifact overwritten by the passing one.

**Binding Erratum**:
1. We plainly record that the initial intact run in Grok r2 exited code 1 on `mutant_V-DEP-CEIL_unaffected_not_from_deposit` before narrowing to redeem/withdraw controls.
2. The failing JSON artifact from that run was overwritten during that historical session and was not preserved in candidate bytes. In compliance with strict instructions, no artificial replacement artifact has been manufactured.
3. The narrowing itself was substantively correct: `P17-DEP-D0` is self-funded directly from its prestate, whereas the intention was to ensure redeem and withdraw controls were not pre-funded via a mutated deposit call.

### 1.2 AGY r1 Multi-Attempt Campaign Overwrite Erratum
During the initial AGY r1 implementation, native steps 668, 686, 692, 700, and 716 repeatedly invoked `vault_campaign.py` into the same `agy-r1/run-1/` directory before achieving a passing run. Root preserved their native terminal and task logs in `review/semantic-kernel/program-execution-20260908/p17-agy-campaign-attempt-history-r1/`.

**Binding Erratum**:
1. We explicitly record that the initial `agy-r1` campaign did **not** succeed on its first invocation. The initial execution exhibited 10 blocked fixtures and 7 refusal-ok fixtures due to call-depth and prestate initialization mismatches.
2. Because earlier campaign attempts wrote into the same `run-1` directory, intermediate receipt, stdout, and artifact bytes were overwritten. Those intermediate missing bytes cannot be recreated and are not claimed to be preserved.
3. The native logs preserved in `p17-agy-campaign-attempt-history-r1` provide indisputable proof that failures occurred.
4. To guarantee absolute immutability and write-once compliance going forward, `agy-r2` executes into a completely fresh, write-once directory structure (`review/semantic-kernel/vault-platform-reuse/p17/implementation/agy-r2/run-1/`) protected by `refuse_nonempty_dir()`, which fails closed before writing if any target directory is non-empty.

### 1.3 Parser Regressions Erratum (SC5)
Root's diagnostic precheck `p17-agy-parser-precheck-r1` replayed 30 EVM protocol test records against the partial `agy-r1` parser. While all 7 real source refusal records decoded correctly, 2 protocol controls exposed regressions:
- `0x1234` payload accompanied by `error: invalid opcode: invalid`
- Truncated `Panic(0x11)` payload accompanied by `error: invalid opcode: invalid`

In both cases, `agy-r1` erroneously classified the transaction as a semantic exception rather than blocking on malformed extra output.

**Binding Erratum & Resolution**:
In `scripts/platform_engine/evm.py`, `classify_evm_stdout` was repaired to strictly inspect the hex payload accompanying `ERROR_INVALID`. In standard EVM semantics, the `INVALID` opcode (`0xfe`) halts execution without returning returndata. A non-empty hex payload accompanying an invalid opcode line indicates malformed or corrupted protocol output and is strictly classified as `_blocked("unknown_output", ...)`. Replaying all 30 tests in `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p17-agy-parser-precheck-r1/replay.py` yielded **30/30 matches (0 failures)**.

### 1.4 Log Protocol Falsifier Erratum (SC3)
Root's preflight snapshot in `p17-agy-scope-precheck-r1` demonstrated that the `agy-r1` log parser did not track EVM call frames, guessed emitter addresses from transfer fields (mapping `ZERO` to `vault`), ignored `LOG0` and unknown topics, and zero-padded truncated log memory. Running `replay_logs.py` failed with exit code 1 on `extra-LOG0-record` and `truncated-Drip-memory`.

**Binding Erratum & Resolution**:
In `scripts/platform_engine/vault_exec.py`, `parse_logs_from_trace` was re-engineered with call-frame stack tracking across `CALL`, `STATICCALL`, `CALLCODE`, and `DELEGATECALL`. In particular, for `DELEGATECALL` (used by the transparent proxy implementation), the child frame inherits the caller frame's `address(this) = vault`. Unpadded memory slicing strictly checks buffer length (`len(mem_hex) >= (offset + size) * 2`) and raises `ValueError` on truncated memory. `LOG0` and unknown topics are preserved in the emitted event sequence, ensuring extra or malformed logs fail `compare_logs`. Replay of `replay_logs.py` exits code 0 with all falsifiers detected.

---

## 2. Reviewer Requests Compliance

### RR-1: Explicit Diagnostic Accounting & Mathematical Proofs
- **Lean Mathematical Authority**: Clean build of `DefiKernel.Vault.Verify` (995/995 jobs clean, 0 `sorry`, 0 custom axioms, 0 forbidden axioms).
- **Audit Counts**:
  - `DefiKernel.Vault`: 175 audited theorems, 184 supplemental declarations.
  - `DefiKernel.ConcentratedLiquidity.Token0Bridge`: 73 audited theorems, 62 supplemental declarations.
- **Fail-Closed Execution**: Zero-credit on empty fixture selections; any unexpected error or mismatch terminates with code 3 (blocked) or code 1 (fail).

### RR-2: Complete Post-State Interpretation & 19 Observed Cells
- In accordance with root's adopted Opus interpretation, `vault_exec.py` evaluates all 19 observed state cells across both underlying USDS and vault share sUSDS:
  - Balances: `usds.balance.{vault, S, R, O, P}`, `susds.balance.{vault, S, R, O, P}`
  - Supplies: `usds.totalSupply`, `susds.totalSupply`
  - Allowances: `usds.allowance.{S.vault, O.vault, P.vault}`, `susds.allowance.{S.vault, O.vault, P.vault, O.P}`
- For every fixture, all 19 cells are observed via pre-state and post-state `eth_call` queries. All explicitly specified expected cells are checked, and all omitted cells are verified strictly unchanged (`post == pre`).

### RR-3: Zero-Asset Deposit Allowance Rationale
- We formally supersede the historical claim that zero transfers skip allowance checks.
- In `UsdsMock.sol`, `transferFrom(S, vault, 0)` is invoked by `vault` as `msg.sender`. Because `from != msg.sender`, the allowance decrement path is entered with `allowed = 0` and `value = 0`. The guard `require(0 >= 0)` passes vacuously, decrementing allowance by 0 and leaving `usds.allowance.S.vault = 0`. This is verified on EVM Shanghai in `P17-DEP-ZERO`.

### RR-4: Shipped Negative Controls & Mutation Campaigns
- **Vault Production Mutants** (`scripts/platform_engine/vault_mutants.py`):
  - `V-TF-SKIP`: Omits `usds.transferFrom` in `_mint`. Detected on designated false fixture `P17-DEP-D0` (`gate: fail`); controls `P17-RED-D0`, `P17-DEP-BAD-RECV`, `P17-RED-ALLOW` preserved (`gate: ok`).
  - `V-DEP-CEIL`: Substitutes `_divup` for `drip()` division in `deposit`. Detected on designated false fixture `P17-DEP-D1` (`gate: fail`); controls `P17-DEP-D0`, `P17-RED-D1` preserved (`gate: ok`).
- **Token0 Production Mutants** (`scripts/platform_engine/token0_campaign.py`):
  - 6 single-edit mutants compiled with Solc 0.7.6 Istanbul and executed on Istanbul prestate:
    - `T0-ID-SKIP`: Detected on `P16-I-ADD` (reverts); control `P16-ADD` preserved.
    - `T0-WRAP-SKIP`: Detected on `P16-WRAP` (returns 1430089...); control `P16-ADD` preserved.
    - `T0-PROD-SKIP`: Detected on `P16-PROD` (returns 79228...); control `P16-ADD` preserved.
    - `T0-REQ-SKIP`: Detected on `P16-REQ-STRICT` (returns 1); equality control `P16-REQ` (still reverts); control `P16-ADD` preserved.
    - `T0-FLOOR`: Detected on `P16-ADD-ROUND` (returns 26409...5); control `P16-ADD` preserved.
    - `T0-CHECKED-ADD`: Detected on `P16-WRAP` (reverts); control `P16-ADD` preserved.
- **Lean Falsifiers**: `no_credit_mismatch` proves credit perturbations fail `Evaluated.Valid`; `P17-NEG-MINT-NO-CREDIT` evaluates to `true`.

### RR-5: Delegated-Exit Success Coverage (`P17-RED-DELEGATED`)
- Implemented and evaluated on geth EVM Shanghai:
  - Caller `P` redeems 1 WAD shares owned by `O` to receiver `R`.
  - Initial `susds.allowance.O.P = 1 WAD`.
  - Poststate verifies `susds.allowance.O.P = 0` (finite allowance consumed), `susds.balance.O = 0`, `usds.balance.R = 1 WAD`.
  - Full ordered logs match: `Drip(vault)`, `Transfer(usds, vault -> R)`, `Transfer(vault, O -> ZERO)`, `Withdraw(vault, P, R, O)`.
  - Formally proved in Lean: `burnShares_success_delegated` and `redeem_success_assets`.
