# Independent P17 vault planning repair r2 review — native Claude Opus

**ACCEPT_WITH_LIMITATIONS, for the concrete planning slice only, conditional on recording the two
editorial interpretations in §7 verbatim.** The three r1 required repairs R1, R2 and R3 are closed.
I verified each independently, by re-deriving the fixture behaviour from the captured Solidity rather
than by reading the author's diagnostics, and by constructing controls that make every check I relied
on actually fail. Five residual defects remain (§6); none is a mathematical error in the plan and none
blocks the planning freeze, but all are binding repairs on the next edit of this slice.

This accepts **no** source execution, **no** implementation, **no** production-mutation credit and
**no** substantive platform reuse. `source_execution_accepted`, `implementation_accepted`,
`platform_reuse` and `wider_family_gate_open` all remain **false**.

## 1. Identity, scope and independence

- **Reviewer role:** native Claude Opus, independent nonauthor. Requested model alias `opus`,
  effort `high` (`dispatch.json`). This runtime self-identifies as **Opus 5**, exact model ID
  `claude-opus-5`. That is a runtime self-report, not a provider attestation: the provider-returned
  model identity is captured by root in this directory's native log, which I deliberately do not
  restate or bind here. No exact provider build string is exposed to me. I invented no identity.
- The user's dispatch for this task names me as the native Opus reviewer and states that this latest
  reviewer role overrides the historical GPT review roles in `AGENTS.md`. The candidate's own
  `remaining-gates.json` still records `independent_gpt6: "required_not_run"` and `STATUS.md` says
  `pending_independent_gpt6_review`. Those strings are the author's binding, written before this
  dispatch; my review does not retroactively satisfy a binding that names GPT-6, and the separate
  GPT-6 r2 report at `p17-planning-r2-review/` is **not** relabelled Opus. Both reports stand under
  their own identities.
- **Author under review:** requested `grok-4.6`, effort high. The authoritative reported identity is
  `grok-4.6-build` from `p17-planning-r2-process.json` (session `01a084ca-957c-7b00-815f-c15fd32816c3`,
  request `c7fa43b2-17e1-433f-8c2c-82c88e901e43`, 22 turns, `end_turn`, process exit 0). The author's
  own `result.json` says `"reported_model": "Grok 4.6"`; the receipt is the finer and authoritative record.
- No Foreman, no subagents, no other agents launched. No commit, no push, no integration. All writes
  are confined to this review directory. Native CLI and read-only diagnostics only.

**Candidate.** `p17-planning-candidate-r2.tar.gz`, SHA-256
`fe36fb051a97aac8ca3f7cdfec037d4faf9351fa0447c909f2353504d921f0fe`, author base
`2ad464397cd207bca647768d77d57abb1f8e575c`, 67 files, planning path
`openspec/changes/vault-platform-reuse-p17`.

**Integrity.** All 67 manifest rows matched by SHA-256 and byte length; no file on disk is absent from
the manifest and no manifest row is absent from disk. The candidate bytes and the archive hash were
re-verified **after** all of my checks and are unchanged. `lean/DefiKernel/Typed/Transition.lean` is
byte-identical at the candidate base `2ad46439` and at primary `HEAD edc258ec`
(`73f26463…`), so the kernel contract the plan cites has not drifted under it.

## 2. What I did before consulting the GPT-6 report

Per the brief I completed my own inspection and all bounded checks first, then read
`p17-planning-r2-review/REVIEW.md` (SHA-256 `3f157752…`). That report is evidence, not authority.
Where we agree I say so; §7 records where I go further.

My primary instrument is `work/checks/independent_model.py`, a Python re-derivation of
`SUsds.deposit/mint/withdraw/redeem`, `_mint`, `_burn`, `drip` and `UsdsMock.transfer/transferFrom`
written **from the captured source**, not from the candidate's `diagnose.py`. It replays each scored
fixture's stored pre-state and compares status, return value, revert string, every declared post cell,
every observed cell **omitted** from the post, and the full ordered log array. It is a model, not
solc/EVM execution, and earns no source-execution credit.

## 3. R1 — the no-credit negative (closed)

The r1 defect was real and I re-confirmed it at the source. `Typed.Evaluated.Valid`
(`Transition.lean:189-197`) takes `store, ctx, request, state, e`. `state` is the **pre**-state; there
is no candidate post-state argument. The post equality is a separate conjunct of `execute_ok_iff`
(`Transition.lean:219`): `∀ c, post.state.balance c = state.balance c + e.effect c`.

The r2 negative is now stated correctly. `P17-TH-NEGATIVE` sets `predicate: observation_correspondence`
and `not_predicate: Evaluated.Valid`, fixes the honest deposit template with `assets > 0`, derives
`post.USDS.vault = pre.USDS.vault + assets` from `execute_ok_iff`, and rejects
`candidate.USDS.vault = pre.USDS.vault` as an **incorrect proposed observation**
(`executor_refusal: false`), not an executor refusal. `desired_postcondition_assumed` is false.
`design.md §6.1` and `specs/vault-conversion-observation/spec.md:73` carry the same statement in prose.
The matching positive `P17-POS-DEPOSIT-CREDIT` carries an identical effect map and the same positive
amount; I checked the two fixtures field by field.

The r1 review's second point is also incorporated rather than skated over: the negative fixture's own
note now says *"A different template that mints sUSDS without USDS deltas can still be accountingOK"*,
so generic per-asset accounting is no longer offered as cross-asset backing.

I checked the effect map against `applyEvaluated_accounting`: USDS effects `−assets` (sender) and
`+assets` (vault) sum to `0`, matching `USDS.supply: 0`; sUSDS effects `+shares` (receiver) sum to
`+shares`, matching `sUSDS.supply: +shares`. Consistent.

**Honest limit on what this negative is worth.** Once stated correctly it reduces to
`x + a ≠ x` for `a > 0`. It is a genuine but shallow statement, and it is exactly what r1 required.
Its substance depends entirely on `P17-TH-ADAPTER-DEPOSIT` — the claim that the honest template is
*library-derived* — which is `PLANNED_NOT_PROVED`. No credit is due here beyond a correctly framed
planning obligation.

## 4. R2 — deterministic stateful witnesses (closed)

`fixtures.json` now carries a `construction` contract: 19 common default cells, a `D1` domain overlay,
and per-fixture `pre_overrides`, with the rule *"defaults, then domain overlay, then fixture
pre_overrides; stored pre must equal the merge."* I recomputed that merge for all 16 scored fixtures:
**16/16 stored pre-states equal their merge.**

I then re-derived each fixture from the captured source. **All 82 independent checks pass, exit 0**
over 16 fixtures (9 success, 7 refusal). Specifically confirmed against `src/SUsds.sol` and
`test/mocks/UsdsMock.sol`:

- **D1 arithmetic.** `deposit`: `⌊10^18·10^27/(10^27+1)⌋ = 10^18−1` ✓. `mint`:
  `_divup(10^18·(10^27+1), 10^27) = 10^18+1` ✓. `withdraw`: `_divup(10^45, 10^27+1) = 10^18`
  (remainder nonzero) ✓. `redeem`: `⌊10^18·(10^27+1)/10^27⌋ = 10^18` ✓.
- **D1 mint funding.** The r1 finding is confirmed as load-bearing. My control `c2` refunds
  `P17-MINT-D1` at `10^18` instead of `10^18+1`; my model then returns
  **`revert Usds/insufficient-balance`** instead of success. The r2 funding of `10^18+1` in
  `usds.totalSupply`, `usds.balance.S` and `usds.allowance.S.vault` is necessary and correct.
- **D1 `chi` provenance.** `chi_setup: storage_seed_chi_after_initialize`,
  `chi_setup_protocol_reachable: false`, `chi_setup_is_harness_assumption: true`, with the note that
  `initialize()` sets `chi=RAY`, `file("ssr")` cannot set `chi`, and `drip` with `timestamp==rho`
  does not write `chi`. I verified all three source facts (`SUsds.sol:204-209`, `214-228`). Correctly
  classified as an honest harness seed, not reachability.
- **Independently funded protected controls.** `P17-RED-D0/D1`, `P17-WD-D0/D1` and `P17-RED-ALLOW`
  each seed `susds.balance.O`, `susds.totalSupply` and `usds.balance.vault` directly in
  `pre_overrides`. I checked mechanically that **no** scored redeem/withdraw control has an empty
  funding override, i.e. none requires invoking a deposit to reach its prestate. The r1 requirement
  that a mutated `_mint` cannot poison these controls is satisfied.
- **`max_or_assets` eliminated.** `fixtures.json` sets it to `null` and
  `allowance_branch: finite_equal_to_transferred_amount_on_success_entry`. Every success-entry fixture
  sets a finite `usds.allowance.S.vault` equal to the transferred assets and a post of `0`; I confirmed
  the mock decrements it (`UsdsMock.sol:117-123`) rather than treating it as infinite.
- **Refusal partitions are the real first failure.** `UsdsMock.transferFrom` checks **balance**
  (line 114) **before** allowance (line 116). `P17-DEP-TF-BAL` funds the allowance so the first failure
  really is `Usds/insufficient-balance`; my control `c8` flipping that to
  `Usds/insufficient-allowance` fails on `error_matches`. `P17-DEP-BAD-RECV`/`P17-DEP-SELF` hit the
  `receiver != 0 && receiver != address(this)` require before `transferFrom`
  (`SUsds.sol:285-287`), so `transferFrom_called: false` is right. `P17-DEP-MUL-OVF` uses
  `115792089237316195423570985008687907853269984665641`, which I confirm is
  `⌈2^256/10^27⌉` — the first `assets` whose `assets·RAY` does not fit `uint256`.

## 5. R3 — observation projection (closed)

The observation contract now binds `log_mode: full_evm_logs_and_vault_emitter_projection` with an
explicit `vault_projection_filter: "emitter == vault"`, `vault_projection_is_not_full_log: true`, and
`unrelated_logs: "retained; MUST NOT be equated to vault events"`. `usds_allowance_observed`,
`usds_transfer_in_full_logs` and `finite_usds_allowance_consumed_on_success_entry` are true;
`retaining_prestate_is_rollback_verification` is **false**.

I re-derived the log sequence for all 9 success fixtures from the source emit order and compared
**every field of every entry**: emitter, name, from/to/value/sender/owner/assets/shares. **9/9 match
exactly, in order.** The order is source-correct: `deposit`/`mint` are `vault.Drip`,
`usds.Transfer(S,vault,assets)`, `vault.Deposit`, `vault.Transfer(0,receiver,shares)`
(`SUsds.sol:294-295`, `UsdsMock.sol:132`); `redeem`/`withdraw` are `vault.Drip`,
`usds.Transfer(vault,receiver,assets)`, `vault.Transfer(owner,0,shares)`, `vault.Withdraw` — note
`usds.transfer` at `SUsds.sol:318` precedes both `_burn` events at `320-321`, and the fixtures get
that ordering right. My controls `c3` (drop the underlying `usds.Transfer`) and `c4` (swap the two
`_burn` events) both fail on `full_logs_match`.

Refusals carry `post: "omitted"`, `pre_retained: true`, `rollback_verification: false`. The honest
distinction the r1 review asked for is kept.

## 6. Findings

### F1 — The failed-attempt record contradicts itself and two other receipts omit the failure (medium)

`grok-r2/failed-attempts/README.md` opens: *"No failed OpenSpec or intact-diagnose attempt occurred in
this r2 batch."* Two paragraphs later the same file says the first intact run **exited 1** on
`mutant_V-DEP-CEIL_unaffected_not_from_deposit`, that the check was then narrowed, and that *"the
failing intact JSON was replaced by the passing one."* The headline is false by the body's own account.
`REPORT.md`'s Checks table and `commands.json` record only the five final commands and omit the failure
entirely, so two of the three receipts a reader would consult give no hint of it. This is the
`defi-footguns` "trusting a gate's summary line" / "reading only the last line" pattern.

I did not take either the accusation or the excuse at face value. I reconstructed the overwritten
pre-narrowing predicate (`work/checks/prenarrow_recon.py`) and ran both versions against the frozen
r2 bytes:

- The **un-narrowed** predicate (every unaffected control must be independently funded) fails on
  **exactly one** row: `V-DEP-CEIL` / `P17-DEP-D0`, a deposit labelled `self_funded_sender`. This
  reproduces the author's prose account precisely.
- The **shipped narrowed** predicate (redeem/withdraw controls only) passes.
- Substantively, **no** control's prestate requires invoking a deposit: every scored redeem/withdraw
  control funds its cells directly in `pre_overrides`, and `P17-DEP-D0` is itself funded from its own
  prestate.

So the narrowing was **substantively correct**, not goalpost-moving: the r1 requirement was about
redeem/withdraw controls not being initialised through a mutated deposit, and demanding
"not-from-deposit" funding of a *deposit* sibling was a mis-specified check. The defect is the
reporting, not the mathematics. The failing artifact is nevertheless unrecoverable from the frozen
candidate.

**Repair RR-1.** Delete or correct the opening sentence of `failed-attempts/README.md` so it does not
deny what the same file records; add the initial failing run to `REPORT.md`'s Checks table and to
`commands.json` with its actual exit; and state plainly that the failing JSON was overwritten and is
not preserved. Do not re-run to manufacture a replacement artifact.

### F2 — "Success fixtures state complete post" is false as written (medium)

`design.md §6` asserts: *"Success fixtures state complete `post`."* `observation-contract.json:38` and
`compiler-harness-plan.json:82` both say the post observation is *"same cells on success"*. Measured:
the observed cell set is **19** cells, and the success fixtures declare **6 or 7** of them —
`P17-DEP-D0/MINT-D0/DEP-D1/MINT-D1/DEP-ZERO` declare 7, `P17-RED-D0/WD-D0/RED-D1/WD-D1` declare 6.
No success fixture states a complete post. `specs/vault-conversion-observation` permits *"either
expected post-state or a complete common transition"* — but the candidate states a complete common
transition rule only for the **pre**-state merge, not for the post.

Nothing in the candidate says omitted cells are to be read as unchanged. The candidate's own gate
cannot catch this: `success_has_post_{fid}` only asserts a nonempty dict.

I verified the intended reading independently: for all **9/9** success fixtures, every observed cell
omitted from `expected.post` is in fact **unchanged** under my source-derived model
(`omitted_post_cells_are_unchanged`). Control `c6` — deleting `usds.balance.vault`, a cell that does
change, from `P17-DEP-D0`'s post — makes that check fail, so it is not always-on.

The substance is therefore recoverable, but the artifact currently asserts the opposite of what it
does. The live risk is that an implementer reads "complete" plus a 7-cell dict and implements a 7-cell
comparison: a future mutant perturbing an undeclared cell (`usds.totalSupply`, `susds.balance.S`, …)
would then escape. Neither planned mutant does so today.

**Repair RR-2.** Either state every observed cell in each success `post`, or state the complete
common post transition rule in the candidate (§7 interpretation #1 is adequate wording), and correct
`design.md §6`, `observation-contract.json` and `compiler-harness-plan.json` so they no longer claim
completeness the data does not have. Task 3.3 must compare all 19 observed cells.

### F3 — Inaccurate rationale on the zero-asset deposit (low)

`P17-DEP-ZERO.independent` says *"transferFrom of 0 from sender to self-path skips allowance"*. It does
not. `SUsds._mint` calls `usds.transferFrom(msg.sender, address(this), assets)` with the **vault** as
`msg.sender`, so `from = S ≠ msg.sender` and the allowance branch at `UsdsMock.sol:116` **is** entered;
`allowed = 0`, `value = 0`, `require(0 >= 0)` passes vacuously, and `allowance` is decremented by 0.
The fixture's expectations (success, 0 shares, post allowance 0, a zero-valued `usds.Transfer` in the
logs) are all **correct** — only the explanation is wrong.

**Repair RR-3.** Reword to: the allowance branch is entered and passes with `allowed = 0 ≥ value = 0`;
no allowance is consumed.

### F4 — The shipped negative control exercises one literal (low)

The candidate ships exactly one falsifying mode, `--wrong-literal`, which perturbs only
`P17-DEP-D1.expected.ok_shares`. Nothing in the candidate's own evidence demonstrates that the
R1-, R2- and R3-specific checks can fail, so by the `GATE-REGISTER.md` standard those rows are
unproven rather than `DISCRIMINATES`.

I supplied the missing controls myself. **21 controls, all firing on the named check, plus two intact
negative controls that stay green** (§8, P-01…P-12 and c1…c9). So the checks are in fact discriminating
and not always-on — but that is now *my* evidence, not the author's.

**Repair RR-4.** Add falsifying modes covering at least the merge rule, the finite-allowance
consumption, the full-log content, the D1 seed classification, the control-funding label and the
negative-theorem predicate fields, and record each mode's exit and named failure.

### F5 — No success witness for the sUSDS allowance-consumption branch (low, coverage)

`_burn` decrements `allowance[owner][msg.sender]` when `owner != msg.sender` and the allowance is
finite (`SUsds.sol:302-309`). All four exit **successes** have `owner == msg.sender == O`, and no
success fixture's post touches `susds.allowance.O.P`. That branch therefore has a refusal witness
(`P17-RED-ALLOW`) but no success witness, so the *decrement* is never observed. The observation
contract lists the cell; the fixture table never exercises it on a passing path.

**Repair RR-5.** Add one delegated-exit success fixture (`owner = O`, `msg.sender = P`, finite
`susds.allowance.O.P`) with the post allowance decremented, or record the omission explicitly in
`remaining-gates.json` as a named gap.

### Quantified limit on the author's 199 checks (not a defect; a scope statement)

Of the 199 intact checks: **0** compare any full-log entry's field values against an independently
derived expectation (the 20 log checks are structural — array length, one positional emitter/name,
and counts of 1 `usds` and 3 `vault` entries); **4** compare a post-state cell, and only against the
constant `"0"`; **9** merely assert `expected.post` is a nonempty dict; **13** recompute a returned
`shares`/`assets` literal. The candidate's diagnostics validate return values and the *shape* of
posts and logs, not post-state cell values or log contents. My model and GPT-6's
`source-witness-review.json` are what supply that comparison. This is honest for a planning freeze,
but the author's `REPORT.md` should not be read as claiming semantic post/log validation.

## 7. The two proposed editorial interpretations

**#1 — sparse `expected.post`, all other observed cells unchanged. SOUND; adoptable only if the
GPT-6 wording is recorded verbatim, and it does not retire repair RR-2.**

Soundness is independently established, not assumed: 9/9 success fixtures have every omitted observed
cell unchanged under my source-derived model, and control `c6` proves that check fires. GPT-6's wording
is precise enough to adopt — it states the complete transition (entry debits sender USDS, credits vault
USDS, consumes the finite allowance, credits receiver shares, increases share supply; exit debits owner
shares and share supply, consumes the finite share allowance when applicable, debits vault USDS,
credits receiver USDS; all other observed cells unchanged in this stable-time domain) and explicitly
adds that it *"does not permit omitting observed cells from future comparison."*

But it is **not explicit in the candidate**, and this is not a gloss over a silence: `design.md §6`
affirmatively states the opposite. An editorial interpretation that contradicts a sentence in the
artifact is a correction, and per `defi-footguns` a stated limitation is a claim like any other.
Adopt it for this freeze **and** carry RR-2, so the artifact and its interpretation do not permanently
disagree. One caveat on the wording: no success fixture exercises the "consumes the finite share
allowance when applicable" clause (F5), so that clause is currently vacuous.

**#2 — the overwritten initial failed diagnostic. SOUND as to substance; NOT explicit enough as
stated, and it understates the problem.**

GPT-6 correctly identifies the contradiction and correctly rules the concrete failure record
authoritative over the opening denial. But its `verdict.json` records `required_edits: []`, which
leaves a receipt that denies its own content standing in the accepted bytes; and it does not note that
`REPORT.md` and `commands.json` omit the failure too, nor does it test whether the narrowing was
legitimate. I did test it (F1): the narrowing is substantively correct and the r1 requirement is not
violated. Adopt the interpretation with that reconstruction attached and with RR-1 required, not as a
no-edit gloss.

## 8. Tests actually run, with actual exits

All checks ran in fresh output paths under this review directory. The frozen candidate and all project
sources were treated as immutable; probe mutations were applied only to owned copies.

| # | Check | Exit / result |
|---|---|---|
| 1 | `sha256sum p17-planning-candidate-r2.tar.gz` | 0 — `fe36fb05…d921f0fe`, matches brief and manifest |
| 2 | 67 manifest rows vs candidate (sha256 + bytes) | 0 — 67/67 match; 0 extra on disk; 0 missing |
| 3 | Author `grok-r2/manifest.json` rows vs candidate | 0 — 43/43 match; totals 133601 / 301076 bytes recomputed; manifest self-excluded (nonrecursive) |
| 4 | r1 author evidence preserved byte-for-byte in r2 | 0 — 23/23 identical, 0 differing, 0 missing |
| 5 | r1 vs r2 plan diff | 15 files changed; `source-pin.json`, `compiler-harness-plan.json`, `proposed-api.json`, `specs/vault-source-readiness/spec.md` unchanged |
| 6 | `openspec validate vault-platform-reuse-p17 --strict` (composite root) | **0** — "Change 'vault-platform-reuse-p17' is valid", openspec 1.10.0 |
| 7 | openspec strict **negative control** (delete a scenario) | **1** — names the requirement lacking a scenario; restored → 0. Not always-green |
| 8 | `openspec list` | 0 — `0/23 tasks` |
| 9 | `diagnose.py` against the **frozen candidate root alone** | **3 — BLOCKED** (`evaluated_valid_lift`, `lean/` and the capture are not in the archive). Correctly blocked, not a false pass |
| 10 | `diagnose.py` intact, composite root (frozen plan bytes + primary `lean/` + primary capture) | **0** — 199 checks, 0 failures, 18 fixtures, 2 mutants, 23 requirements, 34 scenarios, 23 unchecked tasks |
| 11 | `diagnose.py --wrong-literal` | **1** — `independent_P17-DEP-D1`, `sim_shares_P17-DEP-D1` |
| 12 | `diagnose.py --empty-corpus` | **3** — fixtures 0, partitions 0, mutants 0 (denominator printed) |
| 13 | `diagnose.py --unavailable` | **3** — `evaluated_valid_lift` |
| 14 | Author-recorded logs vs my four runs | 0 — identical check-name/ok vectors, counts and failures for all 4 modes; only the recorded absolute `repo_root` differs |
| 15 | Independent source model, intact | **0** — 82 checks over 16 fixtures, 0 failures |
| 16 | Independent model controls c1–c8 | **1 each**, named: `ok_shares_matches`; `status_matches`+`ok_assets_matches`+`no_post_declared`; `full_logs_match` (×2); `declared_post_cells_match_model`; `omitted_post_cells_are_unchanged`; `merge_rule_matches_stored_pre`; `error_matches` |
| 17 | Independent model control c9 (intact copy) | **0** — not always-on |
| 18 | Candidate-gate probes P-01…P-12 (drop `usds.Transfer`; unconsumed allowance; obs flag flip; broken merge; underfunded D1 mint; D1 claimed reachable; relabelled control funding; negative reverts to `Valid`; negative assumes desired post; drop positive witness; `platform_reuse=true`; `model_only=false`) | **1 each**, each naming the specific check: `usds_transfer_in_full_logs_*`; `finite_allowance_consumed_*`; `obs_usds_transfer`; `pre_merge_*`; `d1_mint_usds_funded`; `d1_chi_seed`; `independent_funding_*`; `neg_predicate_observation`; `neg_desired_not_assumed`; `positive_present`; `platform_reuse_false`; `quote_model_only`. Baseline P-00 exits **0** |
| 19 | Reconstruction of the overwritten pre-narrowing check | 0 — un-narrowed predicate would exit 1 on exactly `V-DEP-CEIL`/`P17-DEP-D0`; shipped predicate exits 0; 0 controls actually require a deposit call |
| 20 | Token0 quote-register witness recomputed from `SqrtPriceMath.getNextSqrtPriceFromAmount0RoundingUp` | 0 — `(2^96,1,1,true)` → `addPrimary` → `2^95`; decrease is exactly `2^95`. Claim correct |
| 21 | Cited Lean/tool identities | 0 — `Transition.lean` `73f26463…`, `Rounding.lean` `0bd0c65a…`, `Word/Operations/Quantity/Reference` hashes, `execute_ok_iff` at line 219, `applyEvaluated_accounting` at 248, `observeExecution` at 67-71, `scripts/token0_p16/record_cmd.py` present — all as declared. All four cited `Rounding` theorems exist |
| 22 | `Transition.lean` at base `2ad46439` vs `HEAD edc258ec` | 0 — byte-identical |
| 23 | Captured source pin | 0 — `src/SUsds.sol` `9fe0c713…` matches `source-pin.json`; `UsdsMock.sol` `38417768…` |
| 24 | Candidate integrity re-verified after all checks | 0 — 67/67 unchanged; archive hash unchanged |

**Harness defect in my own first probe pass, recorded rather than discarded.** My initial ad-hoc probe
loop restored only three of the five files it mutated, so probes 11 and 12 ran with two mutations
active and probe 12 reported an extra unrelated failure (`platform_reuse_false`). I caught this from
the output, re-ran those two cleanly, and then rewrote the whole pass as
`work/checks/run_probes.py`, which builds a **fresh isolated root per probe** so no probe can
contaminate another and persists every artifact under `work/logs/probes/`. Row 18 reports the
isolated re-run. The frozen candidate was never the mutation target and was re-verified intact
afterwards.

**Not attempted, by design.** No Lean build or proof, no solc compile, no EVM run, no production
mutant, no mainnet verification, no commit, no push, no integration. A planning review does not require
them and they would earn no credit here. `scripts/platform_engine/` does not exist in the primary tree
— that is correct, it is a `proposed_path`.

## 9. Platform reuse assessment

The two-case reuse obligations remain real and are not inflated.

- **Shared law — delivered.** `Rounding.divideNat_down_ok_iff` / `divideNat_up_ok_iff` and the two
  directed `mulDiv` rational-error theorems all exist. `FullMath` genuinely routes through
  `Arithmetic.Rounding.mulDiv` at width 256 (verified in `FullMath.lean`), and the vault's floor/ceil
  can use the same contracts under its checked-product and positive-`chi` premises. This is real
  shared directed-conversion reasoning.
- **Shared executor theorem — planned only.** `execute_ok_iff` is a real delivered named theorem, but
  neither adapter instantiation exists. The plan requires real `e.Valid` premises on the pre-state,
  library-derived templates, and derivation rather than assumption of the post equality; it explicitly
  rejects a vault-only theorem, a vacuous zero-effect wrap, a cloned dispatcher and circular premises.
- **Common engine — proposed only.** `still_required_for_platform_reuse: true`,
  `wrapper_around_separate_engines: false`, `shared_child_recording_alone_insufficient: true`.
- **Token0 quote-register — correctly bounded as model-only.** `model_only: true`,
  `pool_storage: false`, `cash_settlement: false`, `not_a_source_observation: true`, pre-register bound
  to the input `sqrtPX96`, `scale: "1"` meaning raw Q96 units. The positive scale matters mechanically:
  `Quantity.toQuantity` requires `hscale : 0 < scale`. The nonzero witness is verified above. Token0
  source observations remain four inputs plus `uint160 | revert`.
- **No overclaim found.** `composition_integration_claimed: false`, `p30_dependency: false`,
  `arithmetic_only_opens_platform_gate: false`, `case_two_inventory.measured_in_this_increment: false`
  with `missing_inventory_leaves_platform_reuse_open: true`. `must_not_claim` lists all thirteen
  prohibitions including "Evaluated.Valid as a post-state predicate" and "D1 chi storage seed as
  protocol reachability". Probes P-11 and P-12 confirm the gate flags cannot be flipped silently.

The two planned production mutants are characteristic and their controls are sound. **V-TF-SKIP**
(delete `usds.transferFrom` from `_mint`) is detected on `P17-DEP-D0` through observed USDS balances,
the finite allowance and the missing `usds.Transfer` log — all now in the contract; `P17-RED-D0` and
`P17-DEP-BAD-RECV` are genuinely unaffected. **V-DEP-CEIL** (floor→`_divup` in `deposit` only) is
detected on `P17-DEP-D1` (`10^18−1` → `10^18`, recomputed); `P17-DEP-D0` is genuinely unaffected
because at `chi = RAY` floor and ceil coincide (`_divup(10^45,10^27) = 10^18`), and `P17-RED-D1` uses
the redeem formula and is independently funded. None of this is mutation credit: `source_status` is
`PLANNED_NOT_COMPILED` and `production_mutation_credit` is 0.

## 10. Verdict, gates and limitations

**ACCEPT_WITH_LIMITATIONS** for the P17 concrete planning slice, conditional on recording §7's two
interpretations verbatim in the acceptance record. R1, R2 and R3 are closed on independent evidence.
RR-1…RR-5 are required repairs binding on the next edit of this slice or on the implementation
candidate; none blocks the planning freeze. I did not require an r3 planning round: the residual
findings are text, receipt and control-coverage defects whose substance I verified by other means, and
a third round on the same files for text-only fixes would hit the `defi-footguns` same-files tripwire.

Gates, unchanged and explicitly **false**: `source_execution_accepted`, `implementation_accepted`,
`platform_reuse`, `wider_family_gate_open`. Also false and untouched by this review:
`gate_accepted` in the candidate, `arithmetic_reuse`, and the P16 source gate.

Limitations of this review:

1. Planning only. No Lean, Solidity, EVM, production-mutation or mainnet evidence was produced or
   accepted. My source model is Python and is **not** source execution.
2. My model encodes the captured `SUsds.sol` and `UsdsMock.sol` semantics as I read them. It is a
   second opinion on the fixtures, not a proof, and shares an author with this review.
3. Mocks, the ERC1967 proxy harness, the `susds` branch pin, the D1 storage seed and the overflow
   premises are harness assumptions. No deployed address, block, codehash or runtime identity is
   established.
4. Compiler, genesis, `evm run --dump` roundtrip and deployment/storage-seeding identities are unbound;
   the Shanghai/no-metadata campaign freeze is distinct from the administrative IPFS smoke.
5. The frozen candidate cannot run its own diagnostics standalone (check 9, exit 3). My intact result
   depends on binding it to the primary `lean/` and capture; I verified the plan bytes were unaltered
   in that composite root.
6. I did not verify the author's native log contents, only the process receipt fields; the reviewer
   identity I report is a runtime self-report, and root's capture is authoritative for the
   provider-returned model.
7. Reviewer advice is evidence, not a mathematical proof, and this review does not perform root
   adoption, integration, commit or push.
