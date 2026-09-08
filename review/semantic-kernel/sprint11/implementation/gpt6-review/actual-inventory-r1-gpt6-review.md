# Independent GPT-6 review of actual Nary inventory r1

**ACCEPT WITH LIMITATIONS for the actual inventory of committed candidate `bc002dd49fd531ab0aac757613c3051cd94a9bb6`.** The retained execution supports complete discovery within its declared imported theorem/supplemental scope, full statements, exact axiom equality, and source/tool bindings. Source-declaration attribution remains explicitly incomplete. This is not whole-Sprint11 acceptance and does not accept the later label-repair candidate.

The reviewed outputs are `implementation/proof-inventory-final-r1/`; the outer `verification-commands-r1/inventory.json` records exit 0. Fresh Verify and the external full-types driver each exited 0, from 05:47:57 through 05:48:10 UTC on 2026-09-08. Their raw stdout/stderr hashes and lengths match the records. The builder is exactly the previously accepted r3 tool, SHA-256 `6cd53c0ecce6b0ff8abae666824c25593d44542cdebfde22e42dc2158cc20f6a`; driver SHA-256 `ff7620d5bfbd5a0479503c5ebc086964d61179e2622073eab43f4efbfee781ea`. Earlier tool acceptance was readiness only; this review checks the subsequent actual outputs.

## Actual discovery and proof-statement integrity

I independently parsed all **1,459 theorem rows and 1,130 supplemental rows** from `proof-types.log`, then compared every raw field with the saved inventory. Each set is nonempty and has unique names. Every statement is nonempty, byte-equivalent as a parsed string to the inventory, and contains none of the three checked ellipsis forms (`...`, `⋯`, `…`). The statements total 2,473,100 theorem characters and 375,272 supplemental characters; the longest theorem type is 31,373 characters. Full binders, typeclasses and premises remain available rather than source-signature summaries.

An independent parse of the fresh Verify log finds exactly the same theorem and supplemental names, modules and transitive axiom sets, with no duplicate audit names. Supplemental kinds also match. Both final audit totals are present and say forbidden=0. Every recorded axiom belongs to `propext`, `Classical.choice`, or `Quot.sound`; no sorry/custom-axiom dependency is present in this inspected scope.

Discovery comes from `Environment.constants`, constant kind and imported module provenance in the bound `DefiKernel.AxiomAudit`. It is not controlled by the source declaration index or a name-prefix grep. In particular, 128 theorem user names are outside `DefiKernel.Nary.*`, such as lazily produced equation/congruence constants for imported APIs, but their recorded module provenance is Nary and they are retained. They must not be discarded by a namespace-string filter.

All 1,130 supplemental rows in this run have kind `definition`. The supported supplemental scope also checks opaque and axiom constants when present; it does not promise every ConstantInfo kind such as inductive declarations, constructors and recursors. The theorem scope includes private/generated constants. This review verifies inventory completeness against the retained environment-discovery and fresh-audit outputs; it does not independently re-prove every inventoried theorem.

## Source closure and execution binding

I read the 57 source/config inputs from immutable Git objects at the candidate, saved review snapshots, and independently verified their SHA-256, byte lengths and Git blob identities. A separate comment-aware import traversal reproduces **54 local Lean files plus three pinned configuration files**. Every one of the **20 Nary source files** is included. Verify imports the other 19 Nary modules and AxiomAudit; its own body is import/audit-only. Thus 20 source modules and 19 modules contributing discovered declarations are consistent counts.

The inventory's before/after source dictionaries are identical and equal its exported bindings. The saved precommit integrated build exited 0; all 164 measured local build inputs are equal before/after, and each of the inventory's 57 input hashes matches that integration snapshot and the committed candidate. This supplies the recorded source-equivalence link from the preceding build to the inventory. I did not run or modify the parent-owned cache.

The saved Lean, Lake and Python binary hashes and lengths are equal before/after and match current read-only binary hashes. Driver and builder before/after hashes match their reviewed copies. External Lean/Mathlib imports retain pinned configuration/tool trust; no complete external cache or platform generalization is claimed. Reviewed input bytes and mtimes remained unchanged during this checker pass.

The actual tool path fails closed for missing/unsupported local imports, omitted Nary modules, missing candidate bindings, failed commands, empty or duplicate discovery, forbidden axioms, statement ellipses, audit name/module/axiom mismatches, missing totals, and source/tool drift. I checked those gates in the frozen builder and the Lean driver/AxiomAudit. This successful actual run exercises the positive path; it is not represented as newly executing every negative control from the prior tool reviews. The source index intentionally allows unresolved attribution while retaining the environment row.

## Attribution and classification limits

The independent count and pure-data attribution/classification replay reproduce:

| Source-attribution origin | Theorem constants |
| --- | ---: |
| Explicitly matched source theorem | 699 |
| Uniquely attributed generated constant | 443 |
| Unresolved source owner | 311 |
| Ambiguous source owner | 6 |
| Total | 1,459 |

The 317 unresolved rows retain actual name, full type, module, source-file hash/blob and axioms. They are unresolved **source-owner attribution**, not missing proofs or unbound files. Examples include generated-looking `.eq_1`/`.congr_simp` constants; the six ambiguous cases are four `Machine` equation constants and two `Roster` proof constants. No blanket rewrite of those origins to “generated” is justified by this review.

Role categories are a separate axis. The 310 `genericproof` entries comprise 228 explicit and 82 unresolved constants; the 428 `concreteproof` entries comprise 298 explicit and 130 unresolved constants. The 94 `privatehelper` entries comprise two explicitly mapped private Causal lemmas and 92 unresolved private constants. There are also 443 generated, 171 named counterexample-family and 13 reference-instance entries. These are not counts of 310 independently authored generic claims, 428 economic theorems, or 94 handwritten private lemmas. Counterexample-family classification includes positive supporting lemmas and is not a count of logical negations. The two explicit private identities are correctly keyed by module plus user name.

Full types remain authoritative. The inspected `continueMonitored_every_prefix` retains initial joint invariant, derivation, external-state, guarantee/rely/stability, and skip/refusal/success-update premises. `toBinary_runNary` specializes to the fixed binary participant representation; it does not prove participant-tree regrouping or arbitrary schedule equivalence. `FundedEnabledness.producer_execute` quantifies over a current state but uses the fixed F10 registry/store/boundary and nonnegative-effect premise; it is not generic solvency. Funded companions and Interface instances retain their fixed-configuration/negative-example roles. Selected full statements are preserved in the review evidence.

## Candidate boundary

The separate 310-line runtime-label grammar mismatch is not closed by these theorem/axiom results. Native repair of emitted strings in Tests/Audit changes candidate bytes even if proof propositions remain equal. Preserve this original inventory, commit the repair, rebind exact sources/tools and integrated evidence, and execute a new actual inventory. No current or future candidate acceptance is inferred from the old commit or unchanged theorem totals.

`actual-inventory-r1-inputs.json` and `actual-inventory-r1-evidence/` bind the raw artifacts, immutable Git-source snapshots, independent parser/closure/attribution audit, selected full statements and tool identities. One preliminary metadata-display probe treated a source list as a dictionary and failed; that diagnostic is retained and corrected in the audit. No source/tool edits, Lean/cache commands, or new runtime/mutation execution were performed by this checker.
