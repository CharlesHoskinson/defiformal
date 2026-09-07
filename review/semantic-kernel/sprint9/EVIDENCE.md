# Sequential congruence and configuration preservation

Native Grok and Fable accepted source `eec499d613688137a341f3556cd80ca461dd2ee9`
and its completed execution evidence with limitations. Branch delivery and
OpenSpec archival are recorded separately. See [acceptance](acceptance/acceptance.json),
[adjudication](ADJUDICATION.md), and the [current scenario map](acceptance/accepted-scenarios.json).

Recursive sequential groups execute actual kernel steps and preserve the complete
cursor when regrouped without changing leaf order. The observation relation keeps
the current world, store, ordered receipts and outputs, position and refusal; it
omits past raw event worlds. Restricted fixed-prefix/suffix contexts preserve that
relation. Sufficient configuration agreement preserves full results of the existing
sequential, parallel, interleaved and atomic executors under the same program,
starting world, boundaries, schedule and policy.

## Checked evidence

- 16 fresh Lean integration commands passed at the accepted source; 888 runtime
  comparisons include148 Metatheory checks.
- Imported audit:237 theorem constants, comprising109 explicit theorems
  (74 generic,35 concrete instances) and128 generated constants;342 supplemental
  declarations; zero forbidden axiom dependencies. All109 explicit statements
  remain unchanged across the fixture correction.
- 14 compiled production mutations were detected: eight execution-routing
  interventions and six synthetic observer sensitivity interventions.
  Each of15 variants executed all148 comparisons, totaling2220 outcomes.
- The production runner enforces two global positive checks: both remained true
  in every variant, giving30 true observations. Fourteen additional per-mutant
  siblings were measured and checked during postexecution reconciliation.
  They are not runner-protected controls.
- 65 actual CLI controls passed:10 valid,5 violated and50 blocked outcomes.
  Compiler-only failures earned no financial detection credit.
- 13 legacy suites executed at `c880acf`, including82 earlier mutants,215 earlier
  runner controls,99 axiom assertions, typing controls and20 corpus tests/76 CLI
  invocations. Exact relevant-source/tool equivalence supports retention at the
  accepted source; these were not rerun at `eec499d`.
- All55 normative scenarios retain their exact claims and evidence classes.
  The current map moves old development pending text into explicitly historical
  records. Original reviewed maps remain byte-identical.

[Integration](integration-final-r2/verification.json),
[complete proof inventory](proof-inventory-r2/proof-inventory.json),
[mutation results](mutations-r2/results.json),
[CLI controls](implementation/runner-controls-r2/summary.json), and
[legacy dependency equivalence](implementation/legacy-dependency-equivalence.json)
contain exact commands, source/tool identities and artifact bindings.

## Mutation overlap

The actual measured response is:

| Variant | World-chain check | History-chain check |
| --- | --- | --- |
| Unchanged control | true | true |
| Entry-world reset | false | true |
| History reset | false | false |

All14 successor false-result inventories are distinct, with overlaps preserved in
the [comparison report](mutations-r2/predecessor-comparison.json). This does not
establish an exclusive fault classifier. Source reasoning explains the last row:
a literal-input continuation can still execute after history reset while the
complete cursor differs because its first snapshot is missing. That explanation
is not a separately measured narrower oracle. The six observer interventions use
synthetic cursor pairs and make no reachable-trace claim.

## Limits

Configuration agreement is sufficient, with valid catalogs, supported complete
lookups/templates and all-domain administrator equality under shared types.
Contexts cannot introduce peers or move boundaries. Operator lifting proves no
shared-state commutation or atomic-boundary reassociation. Exact rational
arithmetic, trusted initial stores/configuration/boundaries and external
observations remain assumptions. There is no deployed fidelity, liveness,
machine arithmetic, holdout evaluation or general solvency claim. The inherited
proof-tail screen is lexical and does not analyze arbitrary command macros.
Reviews are advisory inspection; the reviewers did not rerun Lean or the tests.
