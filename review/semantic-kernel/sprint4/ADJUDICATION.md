# Sprint 4 review adjudication

Final source candidate: `76c99e44689fcdd3422d998f4b82cf2f8e794c57`.
All required native reviews returned **ACCEPT WITH LIMITATIONS**. No blocking
finding remains. GPT-6 implemented and verified the work through the stock
Codex harness; Foreman was not used. Review is advisory source/evidence analysis,
not independent command execution or a substitute for Lean proof checking.

| Scope | Exact reviewed revision | Grok | Fable |
| --- | --- | --- | --- |
| Types, expressions, authority and their tests | `5107c7f` | Accepted with limitations | Accepted with limitations |
| Registered executor, proofs and tests | `3a44e4e` | Accepted with limitations | Accepted with limitations |
| Financial libraries and semantic review fixes | `1c1485b` | Accepted with limitations | Accepted with limitations |
| Verification tooling and measured evidence | `1c1485b` | Accepted with limitations | Accepted with limitations |
| Focused evidence fixes and final source binding | `76c99e4` | Accepted with limitations | Accepted with limitations |

`review-results.json` records full revisions, identical bundle hashes per review
pair, requested/reported model identities, terminal status and exact raw response
hashes. Requested Grok `grok-4.6` reported `grok-4.6-build`; Fable reported
`claude-fable-5-1`. Fable's client sometimes also reported auxiliary Haiku usage.
Grok read its offloaded prompt files despite the empty tools flag. No independent
build, proof checking or test execution is attributed to either reviewer.

## Findings and actions

| Finding | Disposition |
| --- | --- |
| Inactive-branch state-read test checked only length | Now compares exact references; eager boolean evaluation is documented and separately tested |
| Thin executor positive outputs and administrative fallback fixtures | Transfer/mint positives pin every finite cell, mint totals and store; provisioning/tombstone pins added. Exact negative refusals and positive siblings prevent fallback masking |
| Timestamp/current-time, foreign supply/observation and net-zero coverage | Added separate comparisons through the real executor |
| Evaluation/guard/funds/footprint refusal precedence | Documented actual order and added combined-failure comparisons; general theorems remain success statements |
| Debit grant could be mistaken for owner consent | Documented administrator-issued exact-cell authority to invoker; no separate owner-consent claim |
| Read checks occur after evaluation | Explicit successful-execution scope; no refused-path confidentiality claim |
| Price-positivity refusal could be masked by collateral guard | Added zero-debt/zero-collateral positive sibling and zero/negative-price refusals; the positivity-only mutation now flips precisely those checks |
| Development test registry and issuance should be identical | Development helper now derives its grant configuration from the exact registry it executes |
| Test drivers below proof markers | Intentional and verified: all comparison definitions survive projection; central Audit is the sole mutation driver |
| Imported test-proof coverage absent from first bundle | Final import source, actual module-scope output and automatic audit cover all ten imported Typed modules; 52 named proofs also inventoried |
| Missing required observation could be classified as assertion failure | Runner validates required labels against the unchanged inventory and blocks missing evidence |
| Tagged compiler error plus real comparison failure could masquerade as a discriminating mutant | Actual pre-fix reproduction saved; tagged diagnostics now count as errors, and the combined case blocks |
| Two exit-1 branches lacked controls | Added real required-target-stays-true and positive-flips controls; 17/17 CLI cases pass |
| Synthetic fixture reused source Git metadata | Final harness initializes isolated temporary Git metadata |
| Typing diagnostic filter lagged tagged-error fix | Aligned regex and reran the positive and three actual compiler refusals |
| Execution-start HEAD could be mistaken for source revision | Original metadata retained; explicit verified-input candidates, actual Git blob/SHA256 checks and final tree delta saved |
| Mutation summary omitted tool identity/count detail | Original manifest identity included; full 189-name map and actual per-run error/hash validation retained |

After focused acceptance, metadata wording was clarified without changing source:
the control's required-false check is explicitly a passed check with count zero;
supporting toolchain/manifest/audit-helper blob equality and the exact two-file
post-build commit delta were added to `candidate-binding.json`. Full build evidence
is for the earlier candidate whose Lean sources are byte-identical to final source;
the two changed Python scripts were separately retested. Installed dependency
artifacts are not represented as a complete filesystem snapshot.

## Limits carried forward

The trusted-store boundary remains explicit; no initial capability-store
provenance or deployment `WellFormed` theorem is claimed. General duplicate-ID
irrelevance follows from existential membership; the directly named duplicate
lemma concerns a head duplicate. Conservative observation reads cover entire
records. Broader mutation inventories, including fresh-ID assignment and all
possible effect/composition changes, are not claimed complete. The isolated
vault-liquidity fixture suggested by Grok remains optional coverage; general
nonnegativity checks and the current withdrawal tests are retained.

Exact rational finite-carrier net effects, trusted registries/adapters, development
examples and import-closure audit scope remain the acceptance boundaries.
Composition, claim lifecycle, allowances, replay prevention, machine refinement,
deployed protocol fidelity and general solvency remain future work.
