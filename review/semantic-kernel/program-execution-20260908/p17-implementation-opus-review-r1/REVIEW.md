# P17 vault platform reuse — independent implementation review (native Claude Opus, r1)

**Verdict: CHANGES_REQUIRED.** `implementation_accepted = false`. `P17.platform_reuse` must not be set.

| | |
|---|---|
| Candidate | `p17-implementation-agy-r4-candidate.tar.gz`, AGY `gemini-3.8-flash-high` (effort high) |
| SHA256 before review | `47ad3d6787affbbe8e96d402c74f307fb377360a4fee5847bab83eb18b6bed6f` |
| SHA256 after review | `47ad3d6787affbbe8e96d402c74f307fb377360a4fee5847bab83eb18b6bed6f` (unchanged) |
| Candidate files verified present in overlay | 16735 / 16735 |
| Frozen planning files byte-identical to primary | 67 / 67 |
| Baseline Lean files unchanged / new | 180 unchanged, 10 new, 0 modified |
| Reviewer sandbox | `/home/charl/.cache/defiformal-program/program-execution-20260908/p17-opus-review-sandbox` |
| Toolchain | `leanprover/lean4:v4.33.0-rc2`, selected explicitly via `elan run` |
| Author worktree | never read, never written |

## 1. What I actually ran

Every number below is from my own execution in my own sandbox with fresh evidence directories, not
copied from the author's receipts. Full argv/cwd/exit records are in `commands.json`.

| Check | Result | Exit |
|---|---|---|
| `lake build DefiKernel.Vault.Verify` (fresh) | 995/995 jobs | 0 |
| Vault axiom audit | 175/175 theorems, 184/184 decls, forbidden 0 | 0 |
| Token0Bridge axiom audit | 73/73 theorems, 62/62 decls, forbidden 0 | 0 |
| Vault RuntimeAudit | denominator 20, 20 true rows | 0 |
| Vault source campaign | denominator **17**, ok 17, fail 0, blocked 0 | 0 |
| Vault production mutants | 2 compiled, 2 detected, controls intact | 0 |
| Token0 source campaign | denominator **12**, ok 12, fail 0, blocked 0 | 0 |
| Token0 production mutants | 6 compiled, 6 detected, controls intact | 0 |
| Token0 ordinary-add probe | returns 2^95, matches `ordinary_effect_nonzero` | 0 |
| Retargeted R3 model-consumer boundary suite | **10/10** matched | 0 |
| Protocol parser controls (retargeted) | 30/30 (7 real refusals + 23 grammar) | 0 |
| Extended log falsifiers (retargeted) | 6/6 | 0 |
| Reviewer discrimination controls | 6/7 — **c6 exposes a defect** | — |
| Scoring-grammar boundary probes | 7/7 as specified | 0 |

No cached `.olean` existed for `DefiKernel/Vault/*` or `ConcentratedLiquidity/Token0Bridge`, so all ten
new modules genuinely compiled from source in my build. `grep` over the Vault and Token0Bridge sources
finds no `sorry`, no `native_decide`, no `axiom`, no `implemented_by`, no `unsafe`.

One setup attempt failed and is preserved: my first run of the retargeted parser replay exited 1 with
`FileNotFoundError: inputs/expected-refusals.json` because I had not copied the inputs directory
(`work/logs/r4-parser-retarget.attempt1-FAILED.stderr`). I copied the inputs and re-ran; nothing was
overwritten.

## 2. The substance is real

This is **not** a scalar-only, wrapper-only or arithmetic-only delivery, and it is not a green summary
resting on author headings. The load-bearing claims survive independent inspection.

**One engine, two cases.** `scripts/platform_engine/` holds one parameterized
compile/prestate/observe/score stack. `token0_campaign.py` and `vault_exec.py` both drive
`common.py`, `compile.py`, `evm.py`, `prestate.py`, `abi.py`, `keccak.py` and `score.py`; they differ
only in solc pin, fork, calldata shape and observation schema. I ran both. This is not two campaigns
behind a shared function name.

**P16 survives extraction.** I exercised the extracted r6 grammar directly: empty selection → blocked/3
with denominator 0; missing id, duplicate ids, wrong required set, absent `comparison.gate` and an
unrecognized gate all → blocked/3; a blocked row dominates a fail row. The token0 path scores against
the canonical 12-id required list. The P16 Lean binding rows are *generated from* `P16_FIXTURES`, the
same dict that drives the EVM calls, so the model inputs and the source inputs are single-sourced.

**The vault fixtures are complete witnesses.** Each of the 17 rows compares all 19 observed cells on
both the prestate and the poststate, and the Lean model now exports all 19 cells per success row. For
`P17-DEP-D0` I confirmed shares `10^18`, the finite USDS allowance consumed to `0`, and the full
ordered emitter-bound log list `[vault.Drip(chi,diff=0), usds.Transfer(S,vault,10^18), vault.Deposit,
vault.Transfer(0,R,10^18)]`. I recomputed the D1 literals independently: deposit floors to
`999999999999999999 = ⌊10^18·RAY/(RAY+1)⌋`, mint ceils to `10^18+1 = divup(10^18·(RAY+1),RAY)`, and the
D1 mint fixture is funded at `10^18+1`, not `10^18`. `P17-DEP-MUL-OVF` uses `assets = 2^256/RAY + 1`
exactly and observes `Panic(0x11)`. The redeem controls declare shares, totalSupply and vault USDS
directly in `pre_overrides`; none is produced by a deposit.

**RR-5 is done.** `P17-RED-DELEGATED` succeeds with `owner = O`, `msg.sender = P`, and the observed
post-state shows `susds.allowance.O.P` decremented `10^18 → 0`, shares burned `O → 0`, assets
transferred `vault → R`, with the complete ordered log list including the underlying `usds.Transfer`.
Its prestate is funded independently of any deposit. The Lean side has
`burnShares_success_delegated` with the full post-state including the allowance decrement.

**The proofs are not vacuous.** `deposit_floor_shares` derives the floor characterization *from a
successful deposit* under `chi > 0` and `assets·RAY < 2^256`; `deposit_mulOverflow` refuses under
`2^256 ≤ assets·RAY` through `Operations.mul` at width 256, and the unbounded `Rounding.mulDiv` is
never equated to that refusal. `deposit_invalid_zero` proves the address refusal *even under the
hypothesis that conversion succeeded*, and `guardReceiver` structurally precedes the irreducible
`mintAfterGuard`, so invalid-address genuinely refuses before `transferFrom`. `mintShares_success` and
`burnShares_success_self/delegated` give complete post-state equalities with real overflow premises
rather than the source's "shares totalSupply will always be ≤ usds totalSupply" comment.

**Both root inspection points are resolved.** `Examples.runtimeChecks` no longer contains the three
literal-`true` placeholder rows; `P17-POS-DEPOSIT-CREDIT`, `P17-NEG-MINT-NO-CREDIT` and
`P17-TOKEN0-BRIDGE` now evaluate real comparisons — the negative row includes an actual falsifying
perturbation (`creditPredicate st WAD && !creditPredicate (noCreditPerturb st) WAD`) — and the file
carries an explicit erratum naming the historical placeholders. On the second point,
`Adapter.library_convert` proves `convertToShares libraryAssets rayChi = .ok librarySharesWord`, so the
share quantity is bound to an actual conversion result rather than being a `wadQ/wadQ` specialization.

**The negative is the right shape.** `Adapter.no_credit_is_observation` proves `Valid` **holds** on the
pre-state and that the rejected candidate fails only the `execute_ok_iff` post equality. The
`not_predicate` is correctly *not* `Evaluated.Valid`. `Adapter.positive_credit` supplies the matching
positive under the same premises. `execute_ok_iff` itself is byte-identical to the baseline.

**The six R3 model-consumer failures are genuinely fixed.** Root's `replay.py` cannot show this,
because it imports the frozen R3 engine (§4). I retargeted the same ten checks at the R4 engine using
my own deployment, genesis and Lean rows: all ten match, including the four that previously failed on
the vault side and the two on the token0 side.

## 3. Required repairs

### R-1 — the token0 wrap never uses the lift it defines *(moderate)*

`Token0Bridge.lift` and `lift_scale_one` are defined and **never used**. The template quantities are
bare rational literals:

```lean
def preQ : ℚ := (2 ^ 96 : Nat)
def postQ : ℚ := (2 ^ 95 : Nat)
```

No theorem relates them to `sqrtP_Q96` or to the library result `postWord`. But
`P17-TH-TOKEN0-BRIDGE` names the mechanism explicitly — `lift: Quantity.toQuantity`,
`pre_register_binding: quoteHolder QuoteSqrtP balance equals input sqrtPX96` — and task 4.1 requires
the wrap be implemented "via `Quantity.toQuantity` from the actual library result". Compare the vault,
which does exactly this: `wadQ` and `sharesQ` *are* `Quantity.toQuantity` images, and
`library_derivation` bundles the conversion proof with them.

This is a stated-ness gap, not unsoundness. My diagnostic `review_opus_diag/Token0LiftBinding.lean`
(reviewer-authored, not candidate source) proves both bindings in one line each, exit 0:

```lean
theorem diag_preQ_is_lift_of_input : preQ = (lift sqrtP_Q96).amount := by rw [lift_scale_one]; rfl
theorem diag_postQ_is_lift_of_library_result : postQ = (lift postWord).amount := by rw [lift_scale_one]; rfl
```

**Repair:** define `preQ := (lift sqrtP_Q96).amount` and `postQ := (lift postWord).amount`, or state
the equalities and rewrite with them, so the register quantities are the scale-1 lift of the actual
library input and the actual successful library `Word 160`.

### R-2 — the case-two inventory is incomplete, and that is the reuse gate *(blocking for `platform_reuse`)*

`case-two-inventory.json` has `new_definitions` with `lean_modules` and `engine_modules`. There is no
measurement of **new assumptions**, **interface changes**, or **effort**, in either the JSON or
`CASE-TWO-INVENTORY.md`.

The accepted spec is not ambiguous about the consequence:

> **WHEN** adapters exist but case-two additions/assumptions/interfaces/effort are not measured
> **THEN** `P17.platform_reuse` remains false

That THEN clause is active. The reuse gate cannot be opened on this candidate however good the
campaigns are.

**Repair:** measure (a) the assumptions case two introduced — the Usds/Vat/Join mocks as harness, the
storage-seeded D1 `chi`, the stable-time D0/D1 domain, `G-UNCHECKED-SUPPLY-WRAP`,
`G-MULDIV-UNBOUNDED-PRODUCT`, absence of deployment identity; (b) the engine interface changes case two
forced — `run_fixtures` signature, `validate_model_receipt`, the 19-cell observation schema,
`VAULT_ERROR_CONTEXT_MAP`, compiler-settings parameterization; (c) an effort figure.

### R-3 — model-says-success against a source refusal is scored 3, not 1 *(moderate)*

In the revert branch of `vault_exec.py`:

```python
if lean_status != "error" or not lean_failure:
    gate = "blocked" if not lean_failure else "fail"
```

A Lean row with `status = "ok"` has no `failure` field, so a model that claims success where the source
genuinely refuses lands in `blocked`. My control **c6** reproduces this: an intact-shaped model row with
`status=ok` for `P17-DEP-BAD-RECV` yields `blocked / exit 3` where the accepted grammar requires
`fail / exit 1`. The mirror case **c7** — model claims refusal where the source succeeds — correctly
yields `fail / exit 1`. The classification is asymmetric.

This is fail-closed in the sense that no `ok` credit is granted, but it corrupts the 1-vs-3 distinction
the P16 r6 grammar rests on, and it has a concrete downstream consequence: `vault_mutants.py` counts
detection only when the designated gate is `fail`, so **a future mutant whose designated falsification
lands on a refusal fixture would be recorded as not detected**.

**Repair:** when the model row is present, well-formed and complete but its success/refusal disposition
disagrees with the observed source disposition, set `gate = "fail"`. Keep `blocked` for absent,
malformed or unmapped rows — the unmapped-label path (my control c5) is already correct.

### R-4 — token0 mutation detection never looks at the intact expectation *(moderate)*

```python
detected = (des_status == "ok" and des_ret_uint == des_planned["value"])
```

Detection is defined as the mutant reproducing its own pre-registered mutated prediction. Nothing
asserts that this prediction differs from `P16_FIXTURES[designated]["expected"]`. A mutant whose
planned output happened to coincide with the intact expectation would be recorded as detected while
being invisible to the scored campaign. `vault_mutants.py` does this correctly (`detected = (desig_gate
== "fail")`); the token0 path does not.

I checked the data — all six do differ, so today's 6/6 is substantively real:

| mutant | designated | intact expected | planned mutated | differs |
|---|---|---|---|---|
| T0-ID-SKIP | P16-I-ADD | 79228162514264337593543950336 | revert | yes |
| T0-WRAP-SKIP | P16-WRAP | 340269576638287423012608907232989748562 | 1430089493431239948923811608424801982436782118539 | yes |
| T0-PROD-SKIP | P16-PROD | 4294967296 | 79228162514264337593543950336 | yes |
| T0-REQ-SKIP | P16-REQ-STRICT | revert | 1 | yes |
| T0-FLOOR | P16-ADD-ROUND | 26409387504754779197847983446 | 26409387504754779197847983445 | yes |
| T0-CHECKED-ADD | P16-WRAP | 340269576638287423012608907232989748562 | revert | yes |

**Repair:** assert `planned_designated != intact expected` (blocked otherwise), or define detection as
the scored comparison against the intact expectation failing.

### R-5 — the candidate's prose contradicts its own negative theorem *(moderate)*

`RR-COMPLIANCE.md`, RR-4:

> **Lean Falsifiers**: `no_credit_mismatch` proves credit perturbations fail `Evaluated.Valid`.

That is exactly what `P17-TH-NEGATIVE` forbids (`not_predicate: Evaluated.Valid`) and what the scenario
"No-credit candidate is not `Valid` failure" exists to exclude. The candidate's own Lean proves the
opposite: `no_credit_is_observation` asserts `Valid` **holds** and only the post equality fails. The
mathematics is right; the sentence describing it is wrong, and a stated claim is a claim.

**Repair:** restate as an `execute_ok_iff` observation-correspondence mismatch under a `Valid` that
holds.

### R-6 to R-9 — evidence and record corrections *(low)*

- **R-6** `scenario-map.json` marks all 34 scenarios `ok`, but six citations do not support their
  scenario: entry 2 (locator branch) cites `fixtures/score.json`; entries 30/31/32 cite the same 17/17
  score file for the planning `diagnose.py --empty-corpus / --wrong-literal / --unavailable` modes;
  entry 33 cites the *intact* campaign's `P17-RED-D0` row rather than `mutants/V-TF-SKIP/result.json`;
  entry 27 cites the artifact that fails its own scenario; entry 34 cites a document that never
  mentions gates. I re-verified the substance of 30/31/32 against the current engine and it holds — the
  citations are wrong, not the outcomes.
- **R-7** The frozen `remaining-gates.json` is correctly unchanged but is now stale on three statuses
  the implementation has since closed (`bounded_source_execution: open_zero_campaign_runs`,
  `model_bridge: designed_not_implemented`, `G-EVM-DUMP-ROUNDTRIP`), and it never names the **L2
  token** remainder that task 6.3 requires. Publish a current superseding record rather than editing
  frozen bytes.
- **R-8** The headline "Model Consumer Precheck 10/10" ships **no artifact** in the candidate, and the
  published reproduction command runs the frozen **R3** engine against root paths — its own saved
  result is 4/10. The claim is nonetheless true; I established it by retargeting (§2). Ship the
  retargeted harness and fix the command.
- **R-9** The emitter-filtered vault projection is declared in `observation-contract.json`
  (`vault_projection_filter: emitter == vault`) and appears in two scenario clauses, but `grep -rn
  projection scripts/platform_engine/` returns nothing. The requirement body says the projection *MAY*
  be recorded, so this is scenario completeness rather than a hard violation; the full-log half is
  fully met.

## 4. On the stale reproduction command

Root flagged that R4's response lists `p17-agy-r3-model-consumer-precheck/replay.py` as a 10/10
reproduction command. I checked the script: it sets `ENGINE = p17-agy-r3-final-protocol-precheck/engine`
and `common.ROOT = /home/charl/defiformal`, so it exercises the **frozen R3 engine**, and its saved
`results.json` records `matched: 4` of 10.

Root's caution cuts both ways and I applied it both ways. The stale command does not prove the
implementation is wrong, and the author's 10/10 claim is not proof it is right. So I built my own
retargeted copy against the R4 engine with my own fresh deployment, genesis and Lean model rows, and
got **10/10**. The engine is fixed; the instructions are wrong. That is R-8, a documentation defect,
not an implementation defect.

I applied the same treatment to root's `p17-agy-r4-final-protocol-precheck`: I confirmed its `engine/`
copy is byte-identical to the frozen candidate engine, then re-ran both replays with the import
repointed at my sandbox — 30/30 and 6/6.

## 5. Scope and limits

Bounded EVM execution and Lean `#eval` rows are finite witnesses, not proofs; the Lean theorems are the
mathematical authority. No mainnet, deployed-address, block, bytecode-identity or codehash claim is
made or accepted — the Usds/Vat/Join mocks are harness assumptions. Accrual with `timestamp > rho`,
`_rpow`, `vat.suck`, `usdsJoin.exit`, permit/IERC1271, UUPS and the L2 token are out of scope. The
quote register is a model-only synthetic register: not Uniswap pool storage, not cash settlement, not a
source observation. D1 `chi` is a storage seed explicitly marked not protocol-reachable. P21 and P30
remain closed; no composition or sequential token0-to-vault workflow is claimed. This review covers the
frozen P17 candidate only and makes no whole-programme claim.

My diagnostics (`work/checks/*`, `lean/review_opus_diag/`) are review-authored, separately identified,
and carry intact controls. They are not candidate source and grant the candidate no credit. I did not
edit any frozen source to make anything pass, and I did not read or write the author worktree.

## 6. Recommendation

Return to the author for one targeted repair round on **R-1 through R-5**, carrying R-6 through R-9 in
the same pass. No re-planning, no re-running of the accepted planning gate, and no rollback experiment
is required — root has already ruled that supplied prestate beside an actual refusal is sufficient, and
I did not find anything that changes that.

The campaigns, proofs and mutants do not need to be redone from scratch. R-1 and R-5 are edits to two
files. R-3 and R-4 are localized predicate corrections in the shared engine that require re-running the
two mutant campaigns and the boundary suite. R-2 and R-6 through R-9 are evidence and record
corrections.

`P17.platform_reuse` must stay `false` until R-2 is closed, because that is the accepted contract's own
gate condition, and R-1 additionally weakens the token0 half of the two-case reuse witness.

Root adopts or rejects this recommendation and handles integration. I publish no acceptance.
