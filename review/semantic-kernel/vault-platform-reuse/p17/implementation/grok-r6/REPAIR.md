# Grok R6 repair: RR4-NEG-FALSIFIER

**Parent item:** ROOT-RR4  
**Adopted repair:** RR4-NEG-FALSIFIER  
**Opus R2:** claude-opus-5, session `c13fcc98-dbac-4dbc-ba38-825f902f6fe8`, finish 2026-09-09T22:20:32.465693+00:00  
**Reviewer probe provenance (preserved, not copied as our result):** `p17-implementation-opus-review-r2/work/bin/rr4_negpred_probe.py`  
**Author:** native Grok 4.6. Does not accept implementation, source execution, or `P17.platform_reuse`.

## Defect

R5 `fail_negative` wrote the string `fail \`Evaluated.Valid\`` and grepped that same string. It never called `check_negative_predicate`. The 10/10 overstated five falsified modes. `check_negative_predicate` itself grepped Adapter.lean / RR-COMPLIANCE.md.

The theorem is sound and unchanged: `Adapter.no_credit_is_observation` is Valid ∧ ¬ post equality.

## Repair

`check_negative_predicate` now scores a **compiled** `RuntimeAudit` `#eval` observation:

- `P17-POS-DEPOSIT-CREDIT = true` — honest credit holds (runtime image of Valid/credit)
- `P17-NEG-MINT-NO-CREDIT = true` — `creditPredicate st WAD ∧ ¬ creditPredicate (noCreditPerturb st) WAD` (post equality fails)

Intact and `fail-negative-theorem-predicate` both call **the same** `check_negative_predicate` after `parse_runtime_negpred`. The falsifier inverts the compiled `P17-NEG-MINT-NO-CREDIT: true` line in the real stdout and re-parses it. Missing/malformed observations are blocked 3. The driver exits 1 if any expected classification is not observed.

Lean theorem files were not edited.

## This run

| Check | expected | actual |
|---|---|---|
| intact-merge | 0 | 0 |
| intact-finite-allowance | 0 | 0 |
| intact-d1-seed | 0 | 0 |
| intact-funding-label | 0 | 0 |
| intact-negative-predicate | 0 | 0 |
| fail-merge-rule | 1 | 1 |
| fail-finite-allowance | 1 | 1 |
| fail-d1-seed-classification | 1 | 1 |
| fail-control-funding-label | 1 | 1 |
| fail-negative-theorem-predicate | 1 | 1 |
| blocked-missing-negative-observation | 3 | 3 |
| blocked-malformed-negative-observation | 3 | 3 |

Driver: 12/12 matched, exit 0.  
Lean: `lake env lean DefiKernel/Vault/RuntimeAudit.lean`, cwd `lean`, 4.33.0-rc2, exit 0, 2026-09-09T22:26:55.646546+00:00 → 2026-09-09T22:26:58.190571+00:00.  
Evidence: `grok-r6/attempt-1/rr4-metadata-diagnostics/`. Kind: metadata/runtime diagnostic, not compiled production mutant credit.
