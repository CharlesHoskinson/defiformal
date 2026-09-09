# P17 vault platform reuse — independent repair review of the Grok R5 candidate

**Verdict: CHANGES_REQUIRED**, on one item. `implementation_accepted = false`,
`source_execution_accepted = false`, `P17.platform_reuse` not set. Root alone accepts.

| | |
|---|---|
| Candidate | `p17-implementation-grok-r5-candidate.tar.gz`, native Grok 4.6 (`grok-4.6-build`, effort high), terminal |
| SHA256 before review | `df5521cca52a53ff38858611befb82044cb676d64f50c8dea29d0291a4ede74c` |
| SHA256 after review | `df5521cca52a53ff38858611befb82044cb676d64f50c8dea29d0291a4ede74c` (unchanged) |
| Overlay files verified | 22632 / 22632 before, 22632 / 22632 after, 0 mismatches |
| Reviewer | native Claude Opus; requested `opus`, reported `claude-opus-5` |
| Sandbox | `/home/charl/.cache/defiformal-program/program-execution-20260908/p17-opus-review-sandbox` |
| Toolchain | `leanprover/lean4:v4.33.0-rc2`, commit `d8b18978322de05a8f3dba51ef03cf5461676c17` |
| Author worktree | never read, never written |
| Repairs closed | 13 of 14 |
| Applicable repair | `RR4-NEG-FALSIFIER` (inside `ROOT-RR4`) |

I read `root-adjudication.json` from the R1 review first, then the R1 `REVIEW.md`/`verdict.json`,
then the R5 candidate summary. Every number below comes from my own execution in my own sandbox
with fresh write-once evidence directories under `work/`, not from the author's receipts. Full
argv/cwd/UTC/exit records are in `commands.json`; the complete scenario, proof, task and RR
reconciliation is in `inventory-mapping.json`; per-repair reasoning is in `repair-verdicts.json`.

## 1. What I actually ran

| Check | Result | Exit |
|---|---|---|
| `elan show` / `lake env lean --version` | 4.33.0-rc2, override from `lean/lean-toolchain` | 0 |
| `lake build DefiKernel.Vault.Verify` (changed modules purged first) | 995/995 jobs, empty stderr | 0 |
| Vault axiom audit | 175/175 theorems, 184/184 decls, forbidden 0 | 0 |
| Token0Bridge axiom audit | **78/78** theorems (was 73), 62/62 decls, forbidden 0 | 0 |
| Vault RuntimeAudit | denominator 20, 20 true rows | 0 |
| **Vault source campaign (full)** | denominator **17**, ok 17, fail 0, blocked 0 | 0 |
| **Token0 source campaign (full)** | denominator **12**, ok 12, fail 0, blocked 0 | 0 |
| Vault production mutants | 2 compiled, 2 detected, controls intact | 0 |
| Token0 production mutants | 6 compiled, 6 detected, controls intact | 0 |
| Token0 detector controls | 4/4 incl. non-distinguishing witness | 0 |
| Setup controls (ROOT-T2.5) | 5/5 | 0 |
| Dump smoke (ROOT-T2.3) | intact roundtrip ok + missing dump blocked/3 | 0 |
| RR-4 metadata diagnostics | 10/10 as shipped — **4 of 5 falsifiers sound** | 0 |
| Parser harness | 30/30 (7 real refusals + 23 grammar) | 0 |
| Logs + R-9 projection harness | 10/10 | 0 |
| Discrimination harness | **7/7**, c6 consumer exit **1** | 0 |
| Model-consumer harness | 10/10 | 0 |
| Reviewer R-3 direction probe | 7/7 | 0 |
| Reviewer full-coverage probe | 3/3 | 0 |
| Reviewer Lean premise diagnostics | all compile, no `sorryAx` | 0 |

I purged the `Token0Bridge`, `Vault.Examples`, `Vault.ProofAudit` and `Vault.Verify` build artifacts
before building, so the changed module genuinely recompiled from source rather than reusing my R1
cache. `grep` over the Vault modules and `Token0Bridge` finds no `sorry`, `native_decide`, `axiom`,
`implemented_by` or `unsafe`. Every load-bearing theorem I audited depends only on
`[propext, Classical.choice, Quot.sound]`.

**Integrity.** 67/67 frozen planning files and 48/48 source-acquisition files are byte-identical to
primary. The captured `src/SUsds.sol` still hashes to its pin. 184 baseline Lean files are unchanged
with **0 modified** and 10 new — so there is no cloned dispatcher, no new global induction and no
checker exemption, and `Typed.execute_ok_iff` is the unchanged baseline statement. I modified no
candidate source to make anything pass.

## 2. The thirteen closed repairs

**R-1 is genuinely closed, and I checked the premises rather than the build result.**
`preQ` and `postQ` are now *definitions* — `(lift sqrtP_Q96).amount` and `(lift postWord).amount` —
where `lift` is `Quantity.toQuantity` at `scale1 = 1`. This is not a new unused lemma beside bare
literals. `library_ordinary_add` proves `libraryWord sqrtP_Q96 L1 amt1 true = .ok postWord`, so
`postWord` is the actual successful library `Word 160`. To make sure that binding is real rather than
a numeric coincidence, I proved in my own diagnostic:

```lean
theorem diag_postQ_is_lift_of_actual_library_result
    (w : U160) (h : libraryWord sqrtP_Q96 L1 amt1 true = .ok w) :
    postQ = (lift w).amount
```

— i.e. `postQ` is the lift of *whatever* word the library actually returns. On the input side,
`preRegister_binds_library_input` binds the register cell to `(lift sqrtP_Q96).amount`, and that
exact `preRegister preQ preQ_nonneg` is the state carried through `execute_ok_iff_quote` and through
`evaluated_Valid`. The lift is load-bearing in the premises, not decorative: `evaluated_nonneg`
actually rewrites through `postQ_eq_lift_library_result` and `lift_scale_one`. I closed the loop with
`diag_execute_forces_lifted_library_post`, which routes a successful `execute` through
`execute_ok_iff_quote` to the lifted library result with a nonzero effect. Preserved as required:
nonzero ordinary-add effect, raw-Q96 `scale1`, model-only register, unchanged P16 statements, and no
assumed desired poststate — the post equality is a derived conjunct, never a hypothesis.

**R-3 is closed, and I reproduced it myself rather than trusting the shipped harness.** The real
consumer now sets `gate = "fail"` when a well-formed model row claims success against a source
refusal. I drove `vault_exec.run_fixtures` directly with my own perturbed Lean rows:

| reviewer probe | result |
|---|---|
| intact control | `ok` / 0 |
| model says success, source refuses | **`fail` / 1** |
| model says refusal, source succeeds | **`fail` / 1** |
| model row missing | `blocked` / 3 |
| `status=error` with no `failure` | `blocked` / 3 |
| unmapped refusal label | `blocked` / 3 |
| malformed status | `blocked` / 3 |

Root's caution about the R1 driver is satisfied: the harnesses now record real per-check consumer
exits, and `c6` reports 1, not a driver exit of 0 hiding a blocked classification.

**R-4 is closed and the six earlier detections stay real.** Detection is now disagreement with
`intact_expected`, and each mutant records `agrees_with_intact` and `planned_matches_intact`. A
planned witness equal to the intact expectation is **blocked with no detection credit**; unavailable
or malformed execution is blocked; a compile failure returns `blocked` before detection is even
computed. All six production mutants reproduced as detected in my run with runtime change and both
unaffected and equality controls preserved. I did not relabel the previous six detections false.

**R-9 is closed by computing and scoring the projection, not by narrowing anything.** On my actual
`P17-DEP-D0`, the full log list retains all four ordered emitter-bound events including
`usds.Transfer(S, vault, 10^18)`, and `vault_projection` holds only the three `vault` events. Both a
projection mismatch and a USDS leak into the projection set the row gate to `fail`. `compare_logs`
still demands the complete ordered list, so the accepted clause was not narrowed.

**ROOT-FULL-COVERAGE is closed, and I falsified it rather than reading it.** With a reviewer-reduced
fixture file missing `P17-DEP-MUL-OVF`, the default campaign still reported denominator **17** with
that member `blocked` and the campaign `blocked` / exit 3 — not a smaller successful full campaign. A
named two-fixture subset still scores `ok` / 0 at denominator 2, so the previously rejected blanket
subset ban is not reinstated. Token0 keeps its canonical 12.

**ROOT-T2.2 is closed and I reproduced it independently.** `bytecode_sha256` is recorded for all 8
contracts alongside the solc pin, the settings and 13 source hashes. I recompiled and reproduced all
four SUsds values exactly — creation hex-text `b04a0230…`, creation raw `9f813856…`, runtime hex-text
`e0f712bd…`, runtime raw `16f3e78d…`. The document states the encoding explicitly and explains the
difference from the historical IPFS smoke hashes as `bytecodeHash none` vs `ipfs` on the same source
pin. Nothing historical was mutated.

**R-2, R-5, R-6, R-7, R-8, ROOT-T2.3 and ROOT-T2.5** are closed as detailed in
`repair-verdicts.json`. Briefly: the case-two inventory now measures assumptions, interfaces and
effort with an explicit baseline and units, does not sum cumulative native usage and does not invent
person-hours, and its module counts match the actual tree (10 Lean, 17 engine) including a correct
deposit-only Adapter erratum; the negative-theorem prose now says `Valid` **holds**; all 34 scenario
citations exist and the six R1 citation defects are repaired; the gates record names all seven
remainders and marks three superseded frozen statuses without editing frozen bytes; the four
candidate-local harnesses bound to *my* engine and *my* evidence via the portable env settings and
preserve the reviewer authorship of the tests they retarget; and the `evm --dump` smoke and
missing-tool controls are real separate deliverables driving real consumers.

## 3. The one applicable repair

### RR4-NEG-FALSIFIER — the negative-theorem falsifying mode is vacuous *(moderate)*

`ROOT-RR4` required five named falsifying modes with actual exits and named failures, using real
validators, "not copied logic or source greps". Four of the five are genuine: `check_merge`,
`check_finite_allowance`, `check_d1_seed` and `check_funding_label` are each invoked by an intact
control at exit 0 **and** by a falsifier that mutates a deep copy of the real `fixtures.json` and
re-invokes the *same* validator, yielding exit 1 with a named failure.

The fifth is not. `fail_negative` writes a file containing the string `` fail `Evaluated.Valid` ``
and then runs its own inline check over that same string:

```python
def fail_negative():
    rr = out / "false-rr-prose.md"
    rr.write_text("`no_credit_mismatch` proves credit perturbations fail `Evaluated.Valid`\n")
    text = rr.read_text()
    if "fail `Evaluated.Valid`" in text:
        return 1, "prose claims Valid failure"
```

It never calls `check_negative_predicate`. Its exit 1 is a tautology — a test that writes its own
expected input and then asserts the input contains itself. It demonstrates nothing about the
validator, so the shipped `10/10` overstates coverage: 4 modes are falsified, not 5. Secondarily,
`check_negative_predicate` is itself a source-text grep over `Adapter.lean` and `RR-COMPLIANCE.md`,
which is the method `ROOT-RR4` excludes.

**This is a defective diagnostic, not a false claim, and I say so explicitly.** I established the
underlying fact independently: `no_credit_is_observation` compiled in my own build and proves `Valid`
holds while only the post equality fails, on standard axioms. I also showed the validator *is*
falsifiable when actually invoked — two reviewer-built trees (prose inverted to claim a `Valid`
failure; `no_credit_is_observation` renamed away) each drove `check_negative_predicate` to exit 1
with a named failure (`work/30-reviewer-diagnostics/rr4-negpred-probe.json`).

**Repair.** Have the falsifier call `check_negative_predicate` against a redirected `ROOT` holding
the inverted prose, exactly as `work/bin/rr4_negpred_probe.py` does, and assert exit 1 *from the
validator*. Preferably also bind the check to the compiled Lean fact rather than to text matching —
for example by scoring the `P17-NEG-MINT-NO-CREDIT` runtime row, which already evaluates a real
falsifying perturbation, instead of grepping source text.

Nothing else in this candidate needs redoing for this repair.

## 4. Two minor observations (not repairs)

- In the default full-campaign branch of `run_fixtures`, rows are re-projected onto the canonical
  list, so a row whose id is *not* canonical would be silently dropped rather than blocked. This is
  currently unreachable — the fixture file contains no non-canonical scored id — and the required-set
  check is what matters for coverage, so I raise it only as a robustness note.
- `score_rows` compares the required id list by order as well as membership. That is fail-closed and
  correct, but callers passing named subsets must use canonical order; my own first probe attempt hit
  this and is preserved as a failed attempt.

## 5. Failed attempts, preserved

Both failures were mine, not the candidate's, and neither is overwritten:

- `lean-reviewer-diag-r2` attempt 1, exit 1 — `U160` auto-bound as an implicit sort because
  `lake env lean` does not apply the lakefile's `leanOptions`. Preserved at
  `work/cmd/lean-diag-r2.attempt1-FAILED/` and
  `work/30-reviewer-diagnostics/Token0LiftPremises.attempt1-FAILED.lean`.
- `r3-direction-probe` attempt 1, exit 1 (4/7) — I passed the named subset out of canonical order and
  `score_rows` fail-closed it to `blocked`/3. The per-row gates were already correct. Preserved at
  `work/cmd/r3-direction-probe.attempt1-FAILED/` and
  `work/30-reviewer-diagnostics/r3-directions.attempt1-FAILED-reviewer-subset-order/`.

## 6. Scope, limits and qualifications

Complete 19-cell model/poststate comparisons apply to the **ten** successful vault rows; my run
produced exactly 10 rows with a post observation and 7 without. The seven refusals retain the
supplied prestate plus the actual specific refusal — no independently observed rollback postworld is
claimed or required. D1 storage-seeded `chi` carries no protocol-reachability claim, and
non-reachability has **not** been proved. The declaration audit counts (184 and 62) include generated
declarations and are not independent financial guarantees. The token0 quote register is model-only:
not Uniswap pool storage, not cash settlement, not a source observation. Bounded EVM execution and
Lean `#eval` rows are finite witnesses, not proofs; the Lean theorems are the mathematical authority.

Out of scope and not claimed: accrual with `timestamp > rho`, `_rpow`, `vat.suck`, `usdsJoin.exit`,
UUPS, permit/IERC1271, the L2 token, deployment identity, mainnet address, bytecode identity or
codehash, P21, P30, and any sequential token0-to-vault composition. No generic refinement or
whole-program completion claim follows from this review.

My diagnostics under `work/bin/` and `lean/review_opus_diag_r2/` are reviewer-authored, separately
identified, carry intact controls, and grant the candidate no credit. I used no Foreman, no
subagents, made no commits or pushes, touched neither `main` nor Atlas, and wrote only to this review
directory and the private sandbox. The R1 evidence directory is untouched.

## 7. Recommendation

Return `RR4-NEG-FALSIFIER` to the author as a single narrow repair to
`scripts/platform_engine/rr4_metadata_diagnostics.py` plus a re-run of that one diagnostic. Carry the
thirteen closed items forward with their actual source identity; the campaigns, proofs, mutants and
harnesses do not need to be redone.

Root adjudicates and publishes accepted scope only. I publish no acceptance, and this review is
evidence for that adjudication rather than implementation acceptance by itself. P18 and the remaining
core program stay queued under their real gates; the whole core program remains open beyond this
scoped P17 review.
