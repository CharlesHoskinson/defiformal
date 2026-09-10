# P19 R23 production module TreeJson mapping — independent Grok review

**Verdict: `CHANGES_REQUIRED`.** Full P19 is not complete. Author REPORT claim that R23 completes the codec and verification agenda is false.

Requested model: `grok-4.6` high. Returned model: unknown until terminal telemetry. Lean4 skill profile: `scripts_only` + `review_only`. Absolute `lean4-skills-preflight --codex` ran exit 0. One auditor. No production edits, network, subagents, Foreman, branches, commits, pushes, or windows. AGY R24 was not inspected.

Frozen archive `b6dd366023f893e1ced869b05218b4c66da1699631a506cc7de2d10020874c42` (root-stated 4131 files). Production source changed only `Roundtrip.lean` (60391 bytes, 102 theorems) and `Verify.lean` (Roundtrip import). `CanonicalJson` / `Correspondence` / `Encode` / `Decode` / `Schema` hashes are unchanged from completed R21.

## Independent rebuild

Private Lean copy under this output directory. Initial `.lake/build` copied from completed R21 review `p19-tree-text-grok-r1/private-lean/.lake/build`. Packages are a read-only symlink to `p19-r7-root-verification`. No author or live cache.

| Target | Jobs | Visible Built | Visible Replayed | Exit | Credit |
|---|---|---|---|---|---|
| `DefiKernel.Certificates.Roundtrip` | 933 | Roundtrip (2.4s) | Typed.Transition, Schema, Check | 0 | yes |
| `DefiKernel.Certificates.Verify` | 938 | AxiomAudit, Tests, Soundness, Audit, Verify (8.2s) | Typed.Transition, Schema, Check, Roundtrip | 0 | yes |

Lake stdout prints only warning/info-bearing jobs. Silent replays are not listed. `Correspondence.olean` mtime `2026-09-10T20:21:42Z` is the R21 rebuild; Roundtrip olean mtime is this review's Built job. Named Verify target is 938 jobs. That is not a full `DefiKernel` build.

Sorry-analyzer on Roundtrip: 0 sorry. Source scan of Roundtrip/Verify: 0 `sorry`, 0 `native_decide`, 0 custom `axiom`. Correspondence lines 24 and 1015 mention those words only in comments.

## 550-name axiom set after fresh build

Root-supplied complete probe `Axioms.lean` sha256 `3c6f6ca12eac19a0bee47e9c1e73629b9d92148d9af779a51d02f37ba5369145` was copied and run with `lake env lean` against the independent oleans. Not an incomplete inline helper and not a 4-minute Correspondence helper.

Independent source extraction: 136 CanonicalJson + 312 Correspondence + 102 Roundtrip = 550 `theorem`/`lemma` names. After rebuild:

- print count 550
- names equal source FQ names and root inventory
- 495 standard (`propext` / `Classical.choice` / `Quot.sound` subsets)
- 55 none
- 0 forbidden
- stdout sha256 `060459161e9fa056996ef406eac83a6dfa668bb6c39b063cb405ec94bcb1be71` equals root `axioms.stdout`

Author `theorems.json` named 536 = 107+327+102 is wrong.

## Strongest theorem vs actual source

Actual `decodeBytes_encodeModule_of_valid_and_depth` (Roundtrip.lean:1289):

```lean
theorem decodeBytes_encodeModule_of_valid_and_depth (ir : DecodedIR)
    (h_adm : StructurallyAdmissibleIR ir)
    (h_valid : TreeJson.Valid (moduleToTreeJson ir))
    (h_depth : TreeJson.depth (moduleToTreeJson ir) ≤ 64)
    (h_dec : decodeDecodedIR ((moduleToTreeJson ir).toJson) (encodeModuleString ir) = .ok ir)
    (h_lex : scanLexical (encodeModule ir) = .ok ()) :
    decodeBytes (encodeModule ir) = .ok ir
```

Author REPORT quotes a different signature: extra `raw : ByteArray`, `h_raw`, and `h_eq := decodeDecodedIR ... raw = .ok ir`. Actual source uses `encodeModule ir` and requires `h_dec` and `h_lex`. Actual source is authoritative.

`moduleToTreeJson_encode` proves declaration-order `TreeJson.encode = encodeModuleString` for admitted typed/step/run IR. Unsupported forms are excluded by existing `StructurallyAdmissibleIR` / `StepCanonical`. Audit/codec cases close because `CanonicalIR` is false there.

`parseCanonicalJson_encodeModuleString_tree` still assumes whole `TreeJson.Valid` and `depth ≤ 64`, then rewrites along `moduleToTreeJson_encode` into historical `parseCanonicalJson_tree`.

`h_dec` is the desired decoder success on `(moduleToTreeJson ir).toJson`. That is not `decodedIRToJson ir`. Correspondence already has `decodeDecodedIR_of_structurallyAdmissible` on `decodedIRToJson`; this theorem cannot use it without a missing toJson correspondence. `h_lex` is scanner success. Neither is discharged from admission.

Existing `EncodeDecodeRoundtripStatement` remains a `def Prop`, not a proved theorem:

```lean
∀ (ir : DecodedIR), StructurallyAdmissibleIR ir → decodeBytes (encodeModule ir) = .ok ir
```

Do not accept tautological decoder/scanner-image premises as the final roundtrip.

## Encoding maps and Request decode

**Scoped usable — string encoding maps.** New TreeJson maps follow production encoder field order. `packedValueFullToTreeJson` is the unit/value wrapper, not the inner bool/rat payload. Request, storage/state/store, interface, invocation, step, and run forms exist as TreeJson objects. `sourceMapToTreeJson_encode` requires existing `SourceMapSorted`. Envelope has the 14 production fields in declaration order matching `encodeEnvelope`. Map coercions are avoided with explicit `List.map` equalities. Array `Valid` lemmas reuse the existing 4096 `TreeJson.Valid` bound. No new 4096-string or 1e18-rational caps and no new parser-image premises were added.

**Scoped usable — Request decode.** `decodeRequest_requestToTreeJson` decodes declaration-order `(requestToTreeJson r).toJson` under `RequestCanonical`. The `h_order` `rfl` equates `decodeRequest` of two `Json.mkObj` field lists because `mkObj` sorts keys in the `Json` value. That is not a Raw-tree permutation premise and does not claim `TreeJson.obj` declaration-order equals sorted-order Raw trees.

**Not proved, so not a toJson cover-all.** After Request/sourcePin/typesEnum, later maps are primarily `*_encode` (world, boundary, envelope, registry, component, config, invocation, step, payloads, module). `libraryRefToTreeJson` has encode and Valid only. Root's object diagnostic (root execution, not this review) already shows libraryRef declaration-order `TreeJson.toJson` versus sorted `libraryRefToJson` are structurally unequal while `BEq` is true. Remaining toJson lemmas do not paper over that. Unsupported quote encoding mismatch is outside admission (`cases h_can` on `.unsupported`).

**Full P19: `CHANGES_REQUIRED`.** Whole-module Valid/depth, `scanLexical` success, module toJson/decode, overlay/hash/schema/decodedIR/host obligations, and 99-scenario / 16-mutant closure remain open.

## Author evidence, with frozen-file confirmation

Author `agy-r23-proof` is present in the frozen sandbox. `MANIFEST.json` is absent despite the sealed-complete claim. `source-manifest.json` has 15 bindings; all 15 match frozen bytes/hashes.

Frozen `commands.json` has 83 records: 81 native_author (42 exit 0, 38 exit 1, 1 exit -15) plus 2 root_preflight (exit 7 and 0). Intermediate command sources differ from the final candidate. Only final-bound gates receive final-candidate credit: `build-verify`, `compile-verify-audit`, `compile-verify-audit-2`, `eval-runtime-checks`, `probe-c0-controls`, `probe-mixed-error`, `probe-mixed-error-2`, `probe-mixed-error-clean`, `probe-unterminated`, `run-fixtures`, `run-probe42`, `run-tests`, `test-runner`. Author `build-roundtrip` bound Roundtrip hash `384bfcab…` and old Verify `47ba130e…`, not the final files.

Author GATE-02 “full DefiKernel 938 jobs” is the Certificates.Verify target. Fixtures 54 / negatives 54 / regression 2 and runner 7 were executed on final-bound commands. Known overlay / expectedIR / host constraints remain. 99 scenarios and 16 mutants are not closed. Those unchanged suites were not re-run here.

R22 Grok source diagnosis is historical. The new root libraryRef diagnostic is root execution, not this review.

## Classification

| Artifact | Status |
|---|---|
| New encoding maps (admitted typed/step/run string encode) | scoped **USABLE** |
| Direct Request decode on declaration-order TreeJson | scoped **USABLE** |
| Full P19 codec / RC01 / campaigns | **CHANGES_REQUIRED** |
| Author REPORT “completes full P19” | **false** |
| This review acceptance | **false** |

Root verifies, adjudicates, and publishes. The full core roadmap remains active.
