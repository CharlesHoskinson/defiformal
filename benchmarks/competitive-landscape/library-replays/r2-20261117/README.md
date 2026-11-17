# R2: fresh reusable-library replay, 2026-11-17

This is a new library-adapter record. The unchanged original R2 workload remains a
`new_model` benchmark and retains its original campaign, dates, authors and timings.
The new operation calls `DefiKernel.AMM.Rational.swapPool` at fee zero; its generic
Typed arithmetic trace is only a specification witness.

`R2Bridge.canonical` proves the complete original reserve-only contract over
independent, unbounded signed rational inputs. Positive reserves and amount produce
the exact unrounded output, strict output/reserve bounds and equal reserve product.
Malformed `Number` constructors take priority, followed by invalid reserves, then
nonpositive amount. Zero fee cannot yield `badFee`; native failures are not invented
or mapped to another refusal. No wallet funding, token settlement or EVM semantics
is assumed or established by this reserve-only contract.

[OriginalContractRelation.lean](OriginalContractRelation.lean) proves identical
observations for **every** original `Number` constructor triple, plus definitionally
identical Typed traces and `SuccessClaims`. The public runner compiles a byte-identical
copy of the [original SwapModel](../../upstream/rational-1/swap-2b60322-2/SwapModel.lean)
for that compatibility check. The original [driver](../../upstream/rational-1/swap-2b60322-2/driver.py)
remains unchanged: it is a namespace-bound proof/witness orchestrator. This new runner
does not claim to rerun its automatic search or performance campaign. The strings in
`Number.malformed`, including `"0.5"` and `"1/0"`, are formal tags; these checks prove
nothing about a JSON/raw-number parser. The output JSON is execution metadata.

From the repository root, with the pinned native Lean4.33.0-rc2 and dependencies
already installed:

```sh
python3 scripts/replay_amm_r2.py --toolchain /absolute/lean-4.33.0-rc2 --output /tmp/new-r2-evidence
```

The output directory must be new and outside the repository. The runner builds the
Rational/AxiomAudit dependencies, then elaborates a fresh combined copy of the exact
R2 source and 16 nonempty controls, without importing cached `R2Bridge.olean`. It
compiles the unchanged original model and the relation against that fresh artifact,
runs two nonempty axiom audits, discloses named theorem axioms, and kernel-replays
both fresh targets. Logs, exact commands, input/tool hashes and durations are retained.
Default `leanchecker` replay uses the same Lean kernel and trusts imported libraries;
it is not an independent kernel or a fresh elaboration of every import. Production
`AMM.Verify` also imports `R2BridgeAudit` for normal builds.

The final author invocation passed 16/16 controls, audits of 100 theorem constants /
67 supplemental declarations in the combined source and 22/10 in the compatibility
artifact, forbidden dependencies zero, and both kernel targets. Generated/private
constants contribute to those counts. The earlier standalone math audit was 100/65;
adding the executable controls changes the supplemental inventory. CLI controls
observe wrong expected value as exit1, and missing, empty, unreadable inputs and an
empty assertion inventory as blocked exit3. Intact replay exits0. The fresh-source
runtime mutations changed actual library routing (swapped reserves, amount+1) and
malformed refusal: each produced a false observation and exit1; unchanged full proofs
also rejected each mutation at compile time. Those are separately recorded outcomes,
not cached-module observations. They do not establish universal fault detection.

`accounting.json` binds explicit physical-line ranges, original file hashes and the
new shared author interval. Counts include comments/blank lines within each range;
classification is manually reviewed, not inferred semantic correctness. Shared
Rational, Typed, Mathlib and historical sources are excluded from new-component
counts. AI author: requested GPT-6.1 Sol, high effort, stock Codex harness; no separate
provider-reported identity is available to this child. Root records independent
Astra review of exact candidates. Attribution is separate from copyright ownership.
The interval begins 2026-11-17T13:36:18Z and includes shared investigation, proof,
controls and documentation, plus command/review waits. It is wall time, not measured
active effort or human/person-hours. Historical authoring effort remains unavailable;
this record does not close that evidence gap or the separate II.1 effort scenario.

Checked Word two-success no-profit, actual Typed wallet settlement/conservation,
external reproduction/adoption and wider roadmap completion remain separate work.
No historical source or measurement is replaced by this dated record.
