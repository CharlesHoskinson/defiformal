# P17 vault platform reuse — independent repair review of the Grok R6 candidate

**Verdict: ACCEPT_WITH_LIMITATIONS.** `implementation_accepted = false`,
`source_execution_accepted = false`, `P17.platform_reuse` not set. Root alone
accepts. This is evidence for the one remaining adopted repair
`RR4-NEG-FALSIFIER` inside the original full P17 scope, not a replacement
scope.

| | |
|---|---|
| Candidate | `p17-implementation-grok-r6-candidate.tar.gz`, native Grok 4.6, terminal |
| SHA256 before review | `8e575d70c9db331acfb427baaba87fb01db23af5afce3f60da066037f048c5a2` |
| SHA256 after review | `8e575d70c9db331acfb427baaba87fb01db23af5afce3f60da066037f048c5a2` (unchanged) |
| Overlay files verified | 22655 / 22655 before, production recheck after, 0 mismatches |
| Reviewer | native Grok 4.6 high; requested `grok-4.6`; fresh session, not the author conversation |
| Preceding independent review | native Claude Opus (`claude-opus-5`) R2, `CHANGES_REQUIRED` |
| Toolchain | `leanprover/lean4:v4.33.0-rc2`, commit `d8b18978322de05a8f3dba51ef03cf5461676c17` |
| Author worktree | never read, never written |
| Adopted repair | `RR4-NEG-FALSIFIER` (parent `ROOT-RR4`) |
| Closed repairs carried forward | 13, none invalidated by the R5-to-R6 delta |

Root's 12/12 diagnostic is not this review. Every number below is from my
execution in this sandbox with write-once directories under `work/`. Full
argv/cwd/UTC/exit records are in `commands.json`. The 34/10/23 inventory is
referenced by hash in `carry-forward.json`; the only override is RR-4.

## 1. R5-to-R6 delta

Shared files: **22630 unchanged**, **2 changed**, **23 added**, **0 removed**.
No `.lean` file changed.

| Path | Change |
|---|---|
| `scripts/platform_engine/rr4_metadata_diagnostics.py` | `ce0a230a…` → `3c1d016a…`; negative-predicate validator now scores compiled `RuntimeAudit` `#eval` rows; `fail_negative` calls that same validator |
| `scripts/platform_engine/common.py` | `_DEFAULT_EVIDENCE` `grok-r5` → `grok-r6` only |

The 23 added files are grok-r6 author reports and the author's RR4 run. Lean
consumers of the closed proofs (`Adapter.lean`, `Examples.lean`,
`RuntimeAudit.lean`, `Token0Bridge.lean`, `vault_exec.py`, `score.py`,
`compile.py`, and the rest of the engine) are byte-identical to R5. I therefore
did not rerun the two full source campaigns, production mutants, or
`lake build DefiKernel.Vault.Verify`. Those remain Opus R2 evidence under their
original identity.

The `common.py` default-path retarget does not change scoring, campaign, or
harness logic. Portable `DEFIFORMAL_EVIDENCE_DIR` / `DEFIFORMAL_RUN_DIR` still
select the current run; my RR4 driver wrote under
`work/20-diagnostics/grok-r1/`.

## 2. The adopted repair

R2 found that `fail_negative` wrote `fail \`Evaluated.Valid\`` and grepped that
same string, never calling `check_negative_predicate`, while the validator
itself grepped `Adapter.lean` / `RR-COMPLIANCE.md`.

**Current validator.** `check_negative_predicate` scores a parsed
`RuntimeAudit` `#eval` observation: credit if and only if
`P17-POS-DEPOSIT-CREDIT` is `true` and `P17-NEG-MINT-NO-CREDIT` is `true`.
Missing, malformed, empty-denominator, or non-boolean required rows return
blocked **3**. It does not open source or prose.

**Connection to the compiled row, not a label.** I compiled
`DefiKernel/Vault/RuntimeAudit.lean` myself (`lake env lean`, exit 0). Stdout
is denominator 20, both required rows `true`. `Examples.runtimeChecks` computes
those rows as:

- POS: successful D0 deposit and `creditPredicate st WAD` (`vault USDS = WAD`)
- NEG: `creditPredicate st WAD && !creditPredicate (noCreditPerturb st) WAD`

A reviewer Lean inspect of the same functions printed
`intact_credit=true`, `intact_neg=true`, `identity_neg=false`,
`vault_usds=10^18`, `perturbed_usds=0`, `identity_usds=10^18`. Replacing the
perturb with identity makes the no-credit conjunct false, so the compiled row
is computed, not a hardcoded `true`.

**Theorem intact.** `Adapter.no_credit_is_observation` is unchanged
(`0c32dac8…`) and still `Valid ∧ ¬ post equality`. `#print axioms` on that
theorem, `wad_Valid`, and `no_credit_mismatch` is
`[propext, Classical.choice, Quot.sound]`. No `sorryAx`. Bounded `#eval` is
not that proof.

**Same validator on intact and falsifying paths.** The shipped
`fail_negative` inverts the compiled `P17-NEG-MINT-NO-CREDIT: true` line in the
real stdout, re-parses it, and returns `check_negative_predicate(false_obs)`.
My independent probe imported that function (did not copy its body) and fed it:

| Input | Exit | Named result |
|---|---|---|
| My compiled intact stdout | **0** | POS true and NEG true |
| Same stdout with NEG flipped | **1** | no-credit candidate no longer violates post equality |
| Same stdout with POS flipped | **1** | honest credit/Valid analogue does not hold |
| `None` / garbage / denom 0 / missing NEG row | **3** | blocked, no success credit |
| Compiled identity-perturb observation | **1** | same named NEG failure |

`run_case` on the intact observation with expected 1 reports `matched=false`.
The driver sets `exit = 0 if matched == len(results) else 1`.

**Shipped driver, my evidence directory.**
`python3 -B scripts/platform_engine/rr4_metadata_diagnostics.py` with
`DEFIFORMAL_EVIDENCE_DIR=…/work/20-diagnostics` and `DEFIFORMAL_RUN_DIR=grok-r1`:
**12/12 matched, process exit 0**. Kind:
`metadata_diagnostic_not_compiled_mutation`.

## 3. Five RR4 modes

All five required intact/falsifying modes remain covered. The four already-valid
modes still mutate a deep copy of `fixtures.json` and re-invoke the same
validator. I called those four functions independently as well as through the
shipped driver.

| Mode | Intact | Falsifier |
|---|---|---|
| merge rule | 0 | 1 `P17-DEP-D0` chi mismatch |
| finite allowance | 0 | 1 UINT256_MAX on `P17-DEP-D0` |
| D1 seed classification | 0 | 1 `chi_setup_protocol_reachable=True` |
| funding label | 0 | 1 `produced_by_deposit` on `P17-RED-D0` |
| negative-theorem predicate | 0 | 1 compiled NEG row false |

Missing/malformed negative observations stay blocked 3.

## 4. Thirteen closed repairs

None is invalidated. Lean, `vault_exec.py`, `score.py`, compile/dump/setup
consumers, fixtures, and grok-r5 reports (`scenario-map.json`,
`remaining-gates.json`, `RR-COMPLIANCE.md`, `case-two-inventory.json`,
`BYTECODE-BINDINGS.md`) are unchanged. Carry-forward identities are in
`carry-forward.json`.

Inventory override: R2 `rr_items.RR-4` was `partially_verified`; it is now
`verified` on this candidate. Scenarios 34, obligations 10, tasks 23, and
program tasks 18.2–18.7 are otherwise unchanged and are not re-listed.

## 5. Failed reviewer attempts (not candidate defects)

1. `lean-nocredit-inspect` attempt 1, exit 1: unused `Failure` branch lacked
   `ToString`; `#eval` aborted. Axiom prints still succeeded. Preserved.
2. `rr4-consumer-probe` attempt 1, exit 1: reviewer local named `inspect`
   shadowed the stdlib module. Preserved.

## 6. Limits (unchanged)

Full 19-cell poststate comparisons cover ten successful vault rows. Seven
refusals retain supplied prestate plus actual refusal, without an observed
rollback-postworld claim. D1 seed has no protocol-reachability claim, and
non-reachability has not been proved. Token0 quote register remains
model-only/raw-Q96 scale 1, not pool storage or cash settlement. Bounded
execution is not proof. Wider accrual/`_rpow`, UUPS, permit/IERC1271, L2
token, deployed identity, P21/P30 and sequential token0-to-vault composition
remain outside this P17 acceptance scope. P18 and the rest of the authorized
core program remain queued. Whole-program completion is false.

A naive substring search for `grep` hits the validator docstring phrase
"not a source grep". That is not source-text matching of Adapter/RR prose.
No new acceptance condition is taken from that note.
