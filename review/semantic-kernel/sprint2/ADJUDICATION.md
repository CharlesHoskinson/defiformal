# Sprint 2 review and verification record

Final source candidate: `8a75bf7bfc468958f673f4842395129cdfe78e19`.
Initial candidate: `b1167bf496755d72137fa9f39410854796279c93`.
Base: `4c25efc41c4c2b6d6ad3c9fd68d081e71043f387`.
GPT-6 (`gpt-6-astra`) implemented through native Codex agents. Codex launched
Grok and Fable's native CLIs directly; Foreman was not used.

## Delivered behavior

The generic contract wrapper gates the original executor with a trusted
state/environment/proposal predicate. Successful execution entails that
predicate, all original checks, and the original precise state update.
Library contracts compare complete finite effects, supply changes and actor
against trusted operation parameters. Borrow conditions are independent of
the proposal guard. Contract refusal and base refusal remain distinct.

Original broad-policy counterexamples remain accepted by the old checker.
They are refused by the selected reference operation contracts. This is not
an assertion that arbitrary contract selection is safe; an always-true contract
recovers the base executor, and its selection is explicitly trusted.

Automatic axiom inspection discovers imported theorem constants by module
provenance in the elaborated environment. It includes generated/private helper
constants present there and follows transitive dependencies using Lean's
collector. Scope is the imported `DefiKernel` module prefix. Current-module
and unimported declarations are excluded. The revised audit also inspects
imported definitions, opaque declarations and unused axioms in that scope.
Inductives, constructors and recursors are not separate supplemental roots;
Lean's collector follows dependencies reached from inspected declarations.

## Observed parent verification

| Check | Result | Evidence |
| --- | --- | --- |
| Full ordinary Lean build | Exit 0, 994 jobs at both candidates | `full-build.log`; `r2-full-build.log` |
| Fresh original runtime audit | Exit 0, 33/33 | `old-audit.log` |
| Fresh contract runtime audit | Exit 0, 43/43 | `contract-audit.log` |
| Fresh automatic axiom audit | Exit 0, 278/278 theorem constants and 234/234 supplemental declarations, no forbidden axioms | `r2-axiom-audit.jsonl` |
| Actual axiom-command test driver | Exit 0, 99 assertions at revised candidate (57 initially) | `r2-axiom-tests/results.json`; original `axiom-tests/results.json` |
| Contract mutation replay | Control 43 true; bypass 15 false; borrow-condition bypass six false, at both candidates | `r2-contract-mutations/results.json`; original `contract-mutations/results.json` |

The 278 constants comprise Core 58, original Acceptance 74, original Examples
18, Contracts 26, ContractExamples 16, and ContractAcceptance 86. This includes
generated helpers and is not a count of separately stated financial results.
Allowed dependencies are `propext`, `Classical.choice`, and `Quot.sound`.
Existing copyright-header style warnings remain in build output.
The 234 supplemental declarations include the audit helper itself; it has no
module exemption. They are reported separately and are not additional theorems.

Both mutation variants execute all 43 comparisons. The required positive
controls stay true, and the only compiler-reported error is the explicit runtime
comparison failure. A compilation failure alone does not count as detection.
The replay uses bounded executable/proof markers and the actual ContractAudit
runtime list. It tests the wrapper branch and independent borrow check; it is
not exhaustive mutation coverage or a proof of source extraction correctness.

The audit driver exercises automatic theorem addition with unchanged command
bytes, module provenance distinct from theorem namespace, a clean transitive
helper, forbidden custom-axiom and sorryAx dependencies through an imported
helper definition, and empty/missing scopes. The revised driver adds clean
definition/opaque controls, an unused custom axiom, a sorry-dependent definition,
and a sorry-dependent opaque declaration. It checks exact diagnostic identity.
Lean returns exit 1 for both forbidden axioms and empty scope; the command labels
them FAILED/FORBIDDEN and BLOCKED respectively. The Python replay distinguishes
setup errors (exit 3) from failed test assertions (exit 1).

The two portable replays record candidate HEAD, per-input clean status, hashes
before and after, and actual tool identity. Their input hashes match the candidate.
Other tree paths contain pending review/ledger records, so an empty per-input
status must not be read as a claim of a wholly clean working tree during capture.
The original Core, Examples, Acceptance, Audit and historical algebra sources
are unchanged from the sprint base.

## Native review

Both requested reviewers received the same frozen `r1-bundle.md`, bound by
`r1-manifest.json`. Native response, process status, model usage and invocation
hashes are retained. Their analysis is source review; observed Lean executions
above were performed by the implementation/parent harness, not independently
by the native reviewers. An empty requested tool list is not proof of tool-free
CLI behavior, because Grok has previously offloaded and loaded long prompts.

| Reviewer | Requested model | Reported model | Verdict |
| --- | --- | --- | --- |
| Grok R1 | `grok-4.6` | No response | Timed out after 600 seconds; no verdict |
| Fable R1 | `claude-fable-5-1` | `claude-fable-5-1` main usage; auxiliary Haiku usage also reported | Spec pass; implementation pass; advisory findings |
| Grok semantics retry | `grok-4.6` | `grok-4.6-build`; native `end_turn` | Spec pass; implementation pass within semantics scope |
| Grok regression retry | `grok-4.6` | `grok-4.6-build`; native `end_turn` | Spec pass; implementation pass within regression/mutation scope |
| Grok audit retry | `grok-4.6` | `grok-4.6-build`; native `end_turn` | Spec pass; implementation pass within audit/integration scope |
| Fable R2 | `claude-fable-5-1` | `claude-fable-5-1` main usage; auxiliary Haiku usage also reported | Spec pass; implementation pass; R1 medium resolved |

The empty Grok response and failed invocation are preserved. Its retry divides
the final candidate into three smaller source bundles, whose scope/file coverage
is recorded in `r2-manifest.json`. Fable's targeted bundle covers the changed
audit, its replay, the mutation recipe correction and integration documentation.
The contract semantics and regression sources remain byte-identical to R1.

## R1 findings and remediation

1. **Unused custom axioms and sorry-dependent definitions escape theorem-only
   audit (Fable, medium): confirmed and fixed.** GPT-6 reproduced passing bad
   fixtures with the original command, then extended inspection to imported
   axiom, definition and opaque constants. New tests require specific refusals
   and clean positive controls. `AXIOM-FOLLOWUP.md` records the probes and fix.
2. **No repayment contract (Fable, low): deferred and scoped.** Debt erasure is
   rejected as an invalid borrowing proposal. The sprint specifies transfer,
   deposit, withdrawal and borrowing; it does not model repayment validity.
3. **Locality theorem is relative to the proposal's write set (Fable, low):
   retained as a follow-up.** Complete trusted effect equality still constrains
   every cell. A separate trusted-effect frame/locality lemma remains useful.
4. **Shape-weakening mutations (Fable, low): deferred.** This sprint's required
   wrapper and borrow-check mutations discriminate. Dropping individual actor,
   effect or supply comparisons is additional targeted coverage, not claimed.
5. **Mutation recipe name in docstring (Fable, trivial): corrected.** Fable also
   incorrectly said both recipes already rejected repository-local output. The
   contract recipe lacked that guard; it now rejects before creating a directory.
   `output-path-guard.json` records exit 3, the exact diagnostic and no write.

## Follow-up notes

Fable R2 retains low-priority notes about adding inductive types as explicit audit
roots and protecting the script's own checkout when `--repo` selects a different
checkout. The current guard protects the selected input repository. Trivial
notes concern a possible empty temporary directory when `TMPDIR` points inside
the repository and future log volume. None changes the measured final replay
results or imported-declaration coverage claimed here; these are recorded for
later tooling work, not silently counted as fixed.

Grok's semantics retry confirms the trusted-selection boundary: a transfer
contract selected with the vault-drain parameters accepts that transfer.
The wrapper is not a policy for choosing safe operations. Its accepted semantics
verdict applies to that conditional boundary. The native CLI loaded an offloaded
prompt despite the empty requested tool list; no independent build is claimed.

Grok's regression retry passed and notes that mutation acceptance requires named
false sentinels and positive controls rather than locking the entire observed
false set. Counts 15 and six are recorded measurements of these exact inputs,
not promises enforced as fixed future golden sets. It also notes that the new
43 checks omit the original wrong-asset accounting example; that remains in the
unchanged original audit's 33 checks, separately executed by the parent.
The wrong-supply proposal lacks a base-accepted pair: with fixed complete effects,
base accounting itself determines the allowed supply change. Its new regression
checks the distinct contract refusal before that base accounting refusal.

Grok's audit retry passed. Its additional advisory notes concern a dedicated
current-module-exclusion fixture, explicit future roots for inductive/recursor
constants, foreign unused axioms outside the prefix, and the separate test-driver
command. These are existing scope limits or follow-ups. The recorded no-directory
output-path experiment is specifically the contract recipe's `--out` check;
Grok's shorthand `--output` should not be read as a second observed experiment
against the axiom driver. Non-JSON Lean output is correctly treated as a blocked
driver invocation rather than a failed mathematical assertion.

## Reproduction

From the repository root, with pinned Lean dependencies available:

```sh
cd lean
lake build
lake env lean DefiKernel/Audit.lean
lake env lean DefiKernel/ContractAudit.lean
lake env lean --json DefiKernel/VerifyAxioms.lean
cd ..
python3 scripts/test_kernel_axiom_audit.py --output /tmp/kernel-axioms-NEW
python3 review/semantic-kernel/sprint2/check-contract-mutations.py \
  --repo . --out /tmp/kernel-contract-mutations-NEW
```

Use new output directories for the replay scripts. The saved native invocation
records contain exact CLI arguments; native model wording may vary on replay.
The sprint is complete: Fable passed the initial candidate and focused revision;
Grok's three bounded retry scopes each passed spec and implementation. The
original Grok timeout remains no verdict. Source changes stop at `8a75bf7`;
the final evidence commit adds review and progress records only.
Raw logs, JSON diagnostics and review bundles preserve their bytes and hashes;
prose whitespace checks exclude these immutable capture artifacts.
General identities, dimensioned IR, capability lifecycle, composition,
corpus normalization, certificates and deployed-contract fidelity remain open.
