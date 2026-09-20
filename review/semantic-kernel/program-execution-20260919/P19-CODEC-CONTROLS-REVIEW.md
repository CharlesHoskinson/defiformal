# P19 codec controls review

**Reusable for S13 and the positive structural-IR/comparator subobligations; not sufficient to close literal S14 without a separately reviewed contract addendum.** No codec rerun is indicated by the examined source changes. This is a read-only reassessment of native-author executions on **2026-09-19 20:56:59–20:57:58 UTC**, not a new execution or acceptance of whole R6.

Evidence root `E` is `/home/charl/defiformal-wt-p19-certificates-grok-opus-20260909/review/semantic-kernel/certificates/p19/implementation/grok-20260919-r6/`.

## What was actually checked

`canonical-positive-companions.json` contains four explicit fixtures. C13-canonical and C13-permuted parse to identical JSON values and differ only in the ordering of dynamic `source_map` keys. I checked that sorting that object alone transforms the permuted bytes exactly into the canonical bytes. The permuted document is byte-for-byte the original frozen F13, not a new negative with another defect. C28-canonical likewise preserves F28's JSON values while sorting those keys.

`logs/companions-canonical/command.json` records actual invocation of `scripts/run_certificate_fixtures.py` selecting C13-canonical, C13-permuted and C28-canonical: outer exit **0**, three selected fixtures, three passes. Each per-fixture record invokes actual `lake env lean --run DefiKernel/Certificates/RunFixtures.lean decode`, exit 0. Canonical documents returned codec `ok`; the permuted document returned malformed `noncanonicalWhitespace`, null IR. The hard-coded `/54` display denominator is misleading; the actual selected counts are **3**, then **1** below.

C13's independently supplied `ir_struct` checks mode, type universes, source-map values, context, time, operation and destination party. These values come from the input/fixture, not actual checker output. The runner copies these expected fields, removes the `ir_struct` wrapper for the outer comparison, then applies `deep_compare_subset` to the decoded IR. Positive fixture records preserve exactly the supplied expectations; actual raw-byte echoes equal their supplied inputs. This is a meaningful **subset comparison**, not full expected-IR equality. All ten required envelope fields are also present in the recorded positive IR on inspection. C28's structural subset is narrower (mode/source_map).

C13-changedIR uses exactly C13-canonical's raw input and changes only expected `payload.request.parties` from `["bob"]` to `["vault"]`. `logs/companions-changedIR-negative/command.json` records outer exit **1**; its actual Lean decode still exited **0** and returned `ok`. The failure is specifically `ir_struct: Value mismatch at payload.request.parties[0]: actual 'bob' != expected 'vault'`. This is the decisive comparator control; the generic `controls_discriminated` totals are not needed to establish it.

## Identity and reuse

Both command records' stdout/stderr hashes match retained logs and their full recorded Lean source maps are unchanged before/after. Main and author spec hashes match `d49d8f90ca974a6fdcaa7809c728dcda54de2b33d4a65c23764c5f0d91c1e4ff`. Recorded Schema, Decode, CanonicalJson, Lexical, IRDepth, CompositionDepth, DepthBridge, Correspondence, Roundtrip and RunFixtures hashes match integrated source.

There is one codec-file hash difference: R6 Encode is `d02ef8446aad819c9dd3511870feee08699b922391a3adc7dd76fd72235ce959`, integrated Encode is `9b4fdc4c0b6fd07a13f7552506cf2c6f0d0eaa3e3a31fb590ea974c1261ca3b8`. The exact sole hunk changes `encodeReport`'s unsupported-field rendering. `decodeBytes`/`encodeModule` and the CLI decode branch are unchanged and do not call `encodeReport`. Delivered/host/checker differences therefore do not require rerunning these decode controls. This does not qualify those other paths or reuse R6's broader audit claims.

SHA-256 bindings under E:

| Artifact | SHA-256 |
|---|---|
| `canonical-positive-companions.json` | `0aac0510c83ecaa686623347b77b52d080bdaf5158a73d3fccaa386a02450986` |
| `logs/companions-canonical/command.json` | `7585973f94838d4f70bb8b2cd470e47100a357549e12fbc3da098ceb5e8020e7` |
| `logs/companions-canonical/stdout` | `021cb23ddb13ef26140058f2b64b66a7fca70fbf51ade1ea4cedac70c3c08322` |
| `logs/companions-changedIR-negative/command.json` | `2d556bd41f2b8047fc04c6877c51feeeaa5ee0ca85a5c0056066456157da2664` |
| `logs/companions-changedIR-negative/stdout` | `bc926d334a98e4c7fa2886c6871b0ab0f28405b27501656ac396fad5250f8066` |
| `companions-run/fixture-results.json` | `563b292e29c4f2502e41a313694091e2cd7846bef3e702504b65dd2358377926` |
| `companions-changedIR/fixture-results.json` | `22ca7e4e9a35cd40ef10f240c04688ee38bdd3a3b02eb7cf885cf73fab1b1bf4` |

Fixture/result hashes above were checked during this review; do not backdate them as recorder input seals. Outer records bind Lean sources and logs, not a fixture-file or Python-runner hash. The currently inspected runner hash is `8f611c63a2b4e6e78d4285170c8bad21266d524d87a7efdc4cfe29ae026c0c2e`; no claim is made that this hash was recorded at the old execution. Reuse is bounded historical evidence from the preserved inputs, detailed results, actual command logs and unchanged codec path, not a newly sealed whole-runner qualification. Whether the comparator script changed since execution cannot be established from these records. If an exact source-bound comparator gate is required, recover an independently bound historical runner snapshot or perform one bounded rerun with the runner/input hashes recorded; a path match alone cannot discharge it.

## S14 inconsistency and minimum proposed adjudication

Original F13 raw SHA-256 is `147d3f956a7c316338e151c11d679d953fb9b38aab30e08648c77d922c8c84c8`; original F28 is `c3f1e7f3215967056e398a92ff31dc21bf574207d7fb987abfb99bfbefeb4bd9`. Both originals remain unchanged. C13-canonical/changedIR raw hash is `9b8c2b4206e59de2f35c145024d3f25327c8660e4f43be66a729341ba01b66a9`.

Rejection is required by the **decoder contract**, not merely inferred from encoder ordering. Design D7 points to nested canonical order and UTF-8 fallback; grammar `canonical_nested_key_order.SourceMap` specifies lexicographic dynamic keys. Crucially, grammar **`canonical_decoder_match` explicitly requires raw bytes to equal encodeModule(decoded IR) and rejects key-order differences**, and `entrypoints.encodeModule.bytes` explicitly identifies decoder acceptance with canonical compact form. S13 likewise admits only the canonical representative.

S14's WHEN names original F13, while its THEN requires codec `ok`. Original F13 orders `transfer` before `store`, so that positive expectation conflicts with those explicit decoder clauses. Accepting unsorted original F13 would require weakening them; no decoder fix is justified by this evidence.

Smallest separately reviewed addendum: preserve S14's frozen statement and F13/F28 bytes/expectations as historical evidence; explicitly acknowledge that S14's positive-fixture designation was inconsistent, and assign the prospective positive envelope/IR check to **named C13-canonical**, whose only change is source-map key order. Retain original F13/C13-permuted as the canonicality negative, and retain C13-changedIR as the comparator negative. Bind the above input hashes and document the scenario-map translation separately. Proposed addendum wording: “S14’s original F13 positive designation conflicts with the mandatory canonical decoder contract. For current verification, C13-canonical at raw SHA-256 `9b8c2b4206e59de2f35c145024d3f25327c8660e4f43be66a729341ba01b66a9` is the explicitly designated positive companion; original F13 at `147d3f956a7c316338e151c11d679d953fb9b38aab30e08648c77d922c8c84c8` remains the rejected noncanonical input. Original statements, fixtures and outcomes remain preserved. This role correction does not weaken canonical decoding or constitute automatic acceptance of the evidence.”

This report proposes that adjudication; it does not approve changed expectations automatically or silently mark S14 passed.

No full P19, production-checker, host-binding, compiler-audit or broader-program acceptance follows.
