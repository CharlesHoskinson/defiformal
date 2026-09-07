The new [standalone verifier](verify-final-evidence.py) passed **1,028 supplementary
assertions** over the final accepted production, CLI-control, and history artifacts.
Its [six actual CLI controls](supplementary-verifier/controls/summary.json) also
passed: the intact evidence is accepted; altered source bytes, a partial mutant
log, a false protected comparison, a false CLI exit record, and false funded-history
values are each rejected for the intended cause.

This code was added after the native evidence reviews to address Fable's low
reproducibility note. It is **not** the source of the original 160-assertion
production report or 470-assertion CLI-control report. Those historical reports
and reviewed source/design/report files remain unchanged. The new checker and
its counts are supplementary evidence with their own source hash and run record.

From the repository root, reproduce the check with a new external output path:

```sh
python3 review/semantic-kernel/sprint6/mutations/verify-final-evidence.py --repo . --out /tmp/NEW-UNUSED-VERIFIER-OUTPUT
```

The verifier reads saved artifacts and Git objects; it does not invoke Lean or
rebuild dependency packages. It checks 14 unique source mutations, every complete
131-comparison inventory, five surviving positives, designated false comparisons,
expected runtime-error records, exact generated-source projection and edits,
45 actual CLI outcomes against the committed harness case definitions, and two
history diagnostics. The 30 distinct source/specification/script Git bindings use
`fae07caa2620c7a1d4ba1a39cb9a9be171ff137d`. Captured process exits and logs remain
historical execution evidence; this check does not independently rerun or attest
those processes.

The actual command, exit, verifier hash, and report/log hashes are in the
[invocation record](supplementary-verifier/invocation.json). The
[run log](supplementary-verifier/run.log) and
[new report](supplementary-verifier/report.json) preserve the outcome, inspected
artifact hashes and individual supplementary checks. The
[CLI-control source](supplementary-verifier/verify-final-evidence-controls.py)
reproduces the six checks using temporary artifact copies and real verifier CLI
calls. It invokes no Lean command.

The exact appended history diagnostic is now exposed separately as
[history-diagnostic-suffix.lean](supplementary-verifier/history-diagnostic-suffix.lean).
The verifier checks that each complete diagnostic source is exactly the accepted
control or mutant source plus this suffix, with no other edit. It checks the base
hash against the final accepted generated source and parses the recorded values:
control refusal at local index 1, Alice/Bob USD7/3; mutant success at local index 2,
USD2/8. The independently specified difference is a funded USD5 transfer. The
suffix reads the actual branch failure, cursor index and ledger cells; it does
not print hardcoded outcomes.

Mutation-needle uniqueness is checked on the **proof-stripped computational
projection**, after local import removal, not on the accepted full source file.
In the captured full files, the expression-read, output-dependency, zero-target,
and reverse-conflict needles each occur twice because a proof restates the
computational expression. Each occurs exactly once in the projected mutation
module. The verifier reconstructs that projection and compares every generated
variant byte-for-byte. Accepted proof/source files are never changed by this
projection or by the supplementary verifier.
