# P19 mutation campaign independent review

**ACCEPT the 16-mutant bounded runtime campaign at its captured pre-assumptions-repair snapshot.** All 16 designated sensitivity observations and protected positives are supported by actual Lean logs. This does not accept all P19/P20 or transfer evidence to a changed candidate. No reruns, builds, archives or cache changes were performed.

Evidence: `p19-m01-current-replay/`, `p19-m09-current-replay/`, and the 14 completed directories under `p19-remaining-mutants/`. Exact per-run manifest/results/SPEC hashes and the full shared source inventory are recorded in `P19-MUTATION-CAMPAIGN-RECONCILIATION.json`.

All 16 have the same **30-file** source map. Check.lean SHA-256 is `a9d985e094dd14e34d8ed5a8070967c2eb54a36943627cb2af71715bbca69bf0`; runner is the independently accepted `ff4903c354a44ba6c9a258323d6e65d7768bf073dd3be18aef77e3a6d8b41a82`. Every captured input hash, generated Lean hash, recorded raw-log hash and SPEC hash verified. Source/spec/runner/HEAD stability flags are true, and initial/final source maps agree. Each generated mutant equals its intact generated source with exactly one occurrence of the planned needle replaced.

Every intact control exits **0 with 43/43 true checks**. Every mutant exits **1**, prints exactly the same 43 unique check names, contains its designated false observation and retains its protected true observation. Each mutant log has exactly one Lean error, the runtime-comparison failure with the correct actual false count; no compiler-only or partial-output failure receives semantic credit. Additional false observations are preserved below.

| Mutant | Actual false observations | Protected true |
|---|---|---|
| M01 | cert.delivered.library-bound, cert.typing.recomputed | cert.transfer.alice7 |
| M02 | cert.execute.recomputed | cert.typing.recomputed |
| M03 | cert.accounting.recomputed | cert.transfer.alice7 |
| M04 | cert.authority.debit | cert.transfer.alice7 |
| M05 | cert.catalog.nodup | cert.catalog.export-not-private |
| M06 | cert.access.reads | cert.step.alice7 |
| M07 | cert.rational.canonical | cert.rational.zero-den |
| M08 | cert.precedence.actor-mismatch | cert.transfer.alice7 |
| M09 | cert.library.outstanding | cert.prop.not-executable |
| M10 | cert.prop.not-executable | cert.library.outstanding |
| M11 | cert.refusal.constructor | cert.funds.insufficient |
| M12 | cert.delivered.library-bound, cert.execute.recomputed, cert.step.alice7, cert.transfer.alice7 | cert.accounting.recomputed |
| M13 | cert.capability.fresh-id | cert.authority.debit |
| M14 | cert.catalog.export-not-private | cert.catalog.nodup |
| M15 | cert.env.missing-observation | cert.typing.recomputed |
| M16 | cert.unsupported.rejected | cert.rational.canonical |

The explicit P19 invocation gate was separately independently checked: all 16 SPECs contain exactly one planned mutation and the exact singleton planned protected check (`P19-MUTATION-SPEC-CHECK.json`). Generic runner batch capability is not used to satisfy that protocol.

`p19-remaining-mutants/outer-process.log`, SHA-256 `fdaada1a9d8d80c389b2e23df08278217b8cde5fabc50a0b94bf66a3ebf3948a`, records 14 individual outer exits 0 from 22:53:23 through 23:03:13 UTC on 2026-09-19, ending `ALL_REMAINING_OK count=14`. M01/M09 reuse the previously reviewed completed receipts: child exits and finished manifests were independently rechecked here; root observed actual outer exit 0 in exec sessions 57788 (M01) and 1889 (M09), with no contemporaneous separate outer-receipt file or launch timestamp in those directories. These root-observed exits are distinguished from this reviewer’s independently checked child records. No timeout or empty-output execution appears in this campaign.

Projection and failure-classification support comes from `astra-p19-mutation-runner-review/REVIEW.md` and its unchanged historical adversarial controls. These 43-observation discriminations are not the full 54-fixture report campaign, universal proofs, or an assumptions-classification completeness test. The forthcoming computeAssumptions repair must receive its own source-bound review and affected-evidence assessment; this accepted snapshot remains dated and unchanged.
