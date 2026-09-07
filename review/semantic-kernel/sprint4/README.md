# Sprint 4 evidence

The source candidate is `76c99e44689fcdd3422d998f4b82cf2f8e794c57`.
The final delivery commit adds evidence and progress records. GPT-6 implemented
the increment through the stock Codex harness. Native Grok and Fable reviews are
source-review evidence, not independent execution or mathematical proofs.

## Acceptance evidence

- `final-verification.json`: the scoped result summary and source identities.
- `candidate-binding.json`: actual Git blob IDs and SHA256 values tying each
  verification component to committed source. All final Lean inputs are the same
  bytes that passed the full build and imported audit. The two Python scripts
  changed after review were separately retested.
- `build-verification.json`, `final-*.log`: full 1005-job build, 189 named runtime
  comparisons, Typed 524 theorem / 978 supplemental declaration audit, and the
  legacy 278 / 234 audit. All commands exited zero; forbidden axioms zero.
- `proof-inventory.json`: 52 named theorems across eight modules, with bounded
  concrete claims distinguished from generic claims and explicit assumptions.
  Generated declarations remain covered by the automatic imported audit.
- `mutations/`: unchanged control plus 24 real source mutations; each runs all
  189 comparisons and preserves three positive controls. Logs, source/fixture
  hashes, exact specification and compressed fixture/input bytes are saved.
  `log-validation.json` independently rechecks the recorded log contents.
- `mutation-runner-controls.json`: 17 real CLI controls, including rejected
  empty/partial/compile-only evidence and all three tested assertion failures.
  The initial record preserves the discovered tagged-compiler-error defect and
  its actual pre-fix reproduction. The final harness uses isolated Git metadata.
- `typing/`: one compiled/executed positive and three actual compiler-rejected
  unit mismatches. These are typing refusals, not financial counterexamples.
- `axiom-controls/`: 99 existing audit-control assertions, with actual fixtures
  and logs. `legacy-*-runtime.log` retains the prior 33 + 43 runtime results.
- `preservation.json`: comparison with Sprint 4 base `77462b6`; historical proof
  and corpus files are unchanged. Only the old import root and progress ledger
  changed among preexisting tracked files.

Execution-start Git revisions remain in raw records. They are not substituted
for source identity: the implementation was committed during verification, and
`candidate-binding.json` checks the actual committed blobs. `.initial.json`
files and task reports are historical snapshots; final verification and binding
records supersede their intermediate counts or source hashes. Raw reviewer
bundles and compiler logs preserve their original bytes, including whitespace.

## Reproduction

Run from the repository root with its installed, pinned Lean dependencies:

```sh
cd lean
lake build
lake env lean DefiKernel/Typed/Audit.lean
lake env lean DefiKernel/Typed/Verify.lean
cd ..
python3 scripts/check_typed_kernel_mutations.py --spec review/semantic-kernel/sprint4/mutation-spec.json --out /tmp/typed-mutations-rerun
python3 scripts/test_typed_kernel_mutation_runner.py --out /tmp/typed-controls-rerun
python3 scripts/check_typed_kernel_typing.py --out /tmp/typed-typing-rerun
```

Each output path must be new and outside the repository. Mutation replay strips
proof-only suffixes only in temporary copies. It keeps executable check lists
and uses `Typed/Audit.lean` as the sole driver. Accepted files retain all proofs.

## Claim limits

The model uses arbitrary finite identity carriers and exact rational net effects.
Registry/admin/store authenticity, authenticated context and observation truth
are trusted inputs. A debit grant authorizes the invoker for the exact cell;
separate owner consent is not modeled. Read footprints and domain conditions
constrain successful execution, not confidentiality of refused paths. General
success theorems do not prove a complete refusal taxonomy. Composition, claims
lifecycle, consumable allowances, replay protection, machine arithmetic and
deployed protocol fidelity remain future work. All reference cases are development
examples; no untouched evaluation or general solvency claim is made.
