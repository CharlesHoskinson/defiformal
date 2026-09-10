# P19 R26 whole-module decoder additions — independent Grok review

**Verdict: `CHANGES_REQUIRED`.** Full P19 is not complete. After independent source, private rebuild, and the complete 608-name axiom probe, the new module decoder `decodeDecodedIR_moduleToTreeJson_of_structurallyAdmissible` is scoped usable. It discharges `h_dec` from existing `StructurallyAdmissibleIR`. It does not prove `EncodeDecodeRoundtripStatement`. `h_depth` and `h_lex` remain explicit on the new strongest compiled theorem.

Requested model: `grok-4.6` high. Returned model is unknown until this session's terminal telemetry is valid. Fresh session. Lean4 skill profile: `scripts_only` + `review_only`. Literal `/home/charl/.codex/plugins/cache/lean4-skills/lean4/4.8.7/bin/lean4-skills-preflight --codex` ran exit 0 at 2026-09-10T23:20:23.650241+00:00. One auditor. No production edits, network, subagents, Foreman, branches, commits, pushes, extra windows, or AGY R27 inspection. Author recorder was not invoked.

Frozen archive claimed `2d7708e64b58b954972b417a4b46280814165e01f8b789e3b3e200d123b2e97a` (root-stated 5483 files, 834 new). Independent walk of the extracted sandbox counted 5949 files; that walk is not a rehash of the tarball. Production source changed only `Roundtrip.lean` (117644 bytes, SHA `c3d860eb5ac7618f7bdfa1367bc5b14520ef95a16dabf6ad4c6053d157921f5f`, 160 theorems, 27 new). `CanonicalJson`, `Correspondence`, `Encode`, `Decode`, `Schema`, `Check`, `Tests`, `Verify`, `Observation`, `Soundness`, `Audit`, and `RunFixtures` hashes are unchanged from reviewed R25.

R25 adjudication (`p19-typed-payload-grok-r1/root-adjudication.json`) remains context: three typed-payload lemmas usable; `h_depth`, `h_dec`, `h_lex` were then open; full P19 open. This review does not reopen those frozen proofs except as callers of the 27 new lemmas.

## Independent rebuild

Private Lean copy under this output directory. Initial `.lake/build` copied from completed R25 review `p19-typed-payload-grok-r1/private-lean/.lake/build`. Packages are a read-only symlink to `p19-r7-root-verification`. No author cache and no live AGY R27 cache. Roundtrip and Verify oleans were deleted before rebuild.

One shell attempt to run `python3 tools/setup_private_lean.py` from the sandbox cwd failed with exit 2 (`No such file or directory`). That failed attempt is preserved. Setup then ran from this outdir.

Recorded commands:

| id | start | end | exit | credit |
|---|---|---|---|---|
| `lean-version` | 23:20:23.619196Z | 23:20:23.649505Z | 0 | yes |
| `lean4-skills-preflight` | 23:20:23.650241Z | 23:20:23.658120Z | 0 | yes |
| `lean4-skills-project-context` | 23:20:23.658654Z | 23:20:23.700407Z | 0 | yes |
| `lake-rebuild-roundtrip` | 23:20:35.799323Z | 23:21:36.738784Z | 0 | yes |
| `lake-rebuild-verify` | 23:21:36.739577Z | 23:21:45.901515Z | 0 | yes |
| `sorry-analyzer-roundtrip` | 23:21:45.903037Z | 23:21:45.941676Z | 0 | yes |
| `probe-axioms608` | 23:22:09.906321Z | 23:22:11.484308Z | 0 | yes |

Pinned Lean: `Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)`. `lean` SHA `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`. `lake` SHA `60330ab6f07dce20f3fa9ebb08e8b984ea9549eac172afeb15d9d2227060e2b3`. `libleanshared.so` SHA `0e2ffc1639d133cfccf1552c0d59772b77ed56e3e0c5a00e33d8c7c324a9470f`. Project context: `repository_kind other-lean`; mathlib layer is advisory (`intent.source default`).

Lake stdout prints only warning/info-bearing jobs. Silent replays are not listed.

| Target | Jobs | Visible Built | Visible Replayed | Exit |
|---|---|---|---|---|
| `DefiKernel.Certificates.Roundtrip` | 933 | Roundtrip (60s) | Typed.Transition, Schema, Check | 0 |
| `DefiKernel.Certificates.Verify` | 938 | Verify (8.5s) | Typed.Transition, Schema, Check, Tests, Audit, Roundtrip | 0 |

Named Verify target is 938 jobs. That is not a full `DefiKernel` build and not 938 newly built modules. Author GATE-02 938 jobs is the same named target class.

Sorry-analyzer on Roundtrip: 0 sorry. Source scan of Roundtrip/Verify/CanonicalJson/Encode/Decode/Schema: 0 `sorry`, 0 `native_decide`, 0 custom `axiom`. Correspondence lines 24 and 1015 mention those words only in comments (unchanged R25 file).

## 608-name axiom set after fresh reviewer probe

Root-supplied complete probe `Axioms.lean` SHA `4800055e780e0768c88f46a47dd408b39236888423ce4cd73f1927e4f775cfe9` (39261 bytes) was copied from `root-context/p19-r26-root-inventory` and executed against the reviewer private-lean oleans. This is not an incomplete inline helper and not a redundant Correspondence scan.

Command `probe-axioms608`:

- argv: pinned `lake env lean` on `probes/axioms608/Axioms.lean`
- cwd: this `private-lean`
- start `2026-09-10T23:22:09.906321+00:00` end `2026-09-10T23:22:11.484308+00:00`
- exit 0
- stdout SHA `4729d243a41db01146bd6debe3759dbe70988d4b8f632b9a739eb54370f74dbf` equals root `axioms.stdout`
- stderr empty SHA `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

Independent source extraction: 136 CanonicalJson + 312 Correspondence + 160 Roundtrip = 608 `theorem`/`lemma` names. Source FQ names equal root print names and root inventory. After rebuild and this probe:

- print count 608
- 550 standard (`propext` / `Classical.choice` / `Quot.sound` subsets)
- 58 none
- 0 forbidden

Root inventory 550/58 is imported terminal author build. Matching stdout is independent confirmation on the reviewer oleans, not a substitute for this run.

All 27 new names are standard. Depth helpers use `propext` and `Quot.sound` only. The module decoder and `_of_depth_and_lex` use the three standard axioms.

## Strongest theorems vs actual source

Old `decodeBytes_encodeModule_of_depth` remains unchanged (Roundtrip.lean:2253):

```lean
theorem decodeBytes_encodeModule_of_depth (ir : DecodedIR)
    (h_adm : StructurallyAdmissibleIR ir)
    (h_depth : TreeJson.depth (moduleToTreeJson ir) ≤ 64)
    (h_dec : decodeDecodedIR ((moduleToTreeJson ir).toJson) (encodeModuleString ir) = .ok ir)
    (h_lex : scanLexical (encodeModule ir) = .ok ()) :
    decodeBytes (encodeModule ir) = .ok ir
```

New derived theorem (Roundtrip.lean:2261):

```lean
theorem decodeBytes_encodeModule_of_depth_and_lex (ir : DecodedIR)
    (h_adm : StructurallyAdmissibleIR ir)
    (h_depth : TreeJson.depth (moduleToTreeJson ir) ≤ 64)
    (h_lex : scanLexical (encodeModule ir) = .ok ()) :
    decodeBytes (encodeModule ir) = .ok ir :=
  decodeBytes_encodeModule_of_depth ir h_adm h_depth
    (decodeDecodedIR_moduleToTreeJson_of_structurallyAdmissible ir h_adm (encodeModuleString ir))
    h_lex
```

`h_dec` is derived. `h_depth` and `h_lex` remain explicit. `EncodeDecodeRoundtripStatement` remains a `def Prop`:

```lean
∀ (ir : DecodedIR), StructurallyAdmissibleIR ir → decodeBytes (encodeModule ir) = .ok ir
```

`WholeDocumentDepthBounded` in unchanged Correspondence is `jsonDepth (decodedIRToJson ir) ≤ 64`, not `TreeJson.depth (moduleToTreeJson ir) ≤ 64`. Admission does not discharge `h_depth`. Parser inversion of tokens does not prove `scanLexical`.

No new 4096-string or 1e18-rational caps. No added decoder-success or image predicate in admission. Do not accept remaining depth/scanner premises as the final roundtrip.

## `decodeDecodedIR_moduleToTreeJson_of_structurallyAdmissible`

Statement (Roundtrip.lean:2171):

```lean
theorem decodeDecodedIR_moduleToTreeJson_of_structurallyAdmissible (ir : DecodedIR)
    (h_adm : StructurallyAdmissibleIR ir) (raw : String) :
    decodeDecodedIR ((moduleToTreeJson ir).toJson) raw = .ok ir
```

This is production `decodeDecodedIR` (`Decode.lean:1498`): match `.obj fields`, then `decodeEnvelope fields.toList` and `getField fields.toList "payload"`, then mode dispatch. `raw` is used only in codec mode. `StructurallyAdmissibleIR` excludes audit and codec, so the arbitrary `raw` parameter is unused on the admitted domain. That is faithful, not a hidden extra hypothesis.

Proof cases typed / step / run and excludes audit/codec by contradiction from `SupportedIR`. Conditions come from unchanged `SupportedIR ∧ CanonicalIR`:

| Branch | Schema/mode | Registry | Environment / request / step | State cells | Optional next state |
|---|---|---|---|---|---|
| typed | `schema_version = 1`, `typed-execute` | `RegistryCanonical` from registry Nodup + templates | `EnvironmentCanonical`, `RequestCanonical` | den ≠ 0, gcd = 1, num ≥ 0; uniqueness from `cells.map = standard32CellKeys` (length 32) | `ClaimedNextStateCanonical` |
| step | `composition-step` | config registry canonical | `BoundaryCanonical` = `EnvironmentCanonical` of `boundary.env`; `HistoryCanonical`; `StepCanonical` | same rational/uniqueness facts on `pre.state` | same |
| run | `composition-run` | config registry canonical | `BoundaryCanonical` on each boundary; `StepCanonical` on each step | same facts on `world.state` | same |

Store inverse `decodeStore_storeToJson` is unconditional. `StoreCanonical` in admission is capability-entry Nodup, not a rational reduced-form check and not a new desired-success premise. Cell rationals are the state-cell amounts above. `omega` turns `den > 0` into `den ≠ 0`.

Libraries invert by `decodeLibraries_tree_ok` with no extra canonical hypothesis. Optional `claimed_next_state` uses `Json.null` for none and `decodeClaimedNextState_tree_some` for `WorldCanonical` some.

## Envelope field list, not Json.mkObj equality

`envelopeToTreeJson_fields` (Roundtrip.lean:1990) is equality of the constructed object's `toList` traversal to the sorted 14-field list `envelopeTreeFields`. It is not `Json.mkObj` equality of two objects. Author REPORT architecture text that says otherwise is incorrect.

`decodeDecodedIR_envelopeToTreeJson_eq` reduces production decode through that sorted field list by `dsimp`/`rfl` on `claimed_next_state`. The existing arbitrary Raw-tree permutation equality counterexample remains binding. The new proof avoids it: it never claims unsorted `TreeJson.obj` equals a sorted Raw tree.

`decodeEnvelope_treeFields` inverts the field list from `schema_version = 1`, `SourceMapSorted`, and `ClaimedNextStateCanonical`, using existing `decodeSourceMap_sourceMapToJson`. That is sorted-source-map inverse, not assumed decoder success.

## Depth helpers are not a depth bridge

`depthList_le`, `depthObj_le`, and `depthList_map_le` bound `TreeJson.depthList` / `depthObj` given child bounds. They are not used by `_of_depth_and_lex`. They do not equate `TreeJson.depth (moduleToTreeJson ir)` with `jsonDepth (decodedIRToJson ir)`. Root guidance records an invalid duplicate-key tree of syntactic depth 3 versus semantic depth 1 after `toJson`; that is outside `TreeJson.Valid` and is not an admitted counterexample.

## Author evidence (frozen only)

Author `agy-r26-proof` is in the frozen sandbox. Independent checks:

- MANIFEST 38/38 bindings match, including selected probes. It binds 0 of 318 raw stdout/stderr streams and omits many logs. Root terminal archive binds all 5483 files; this review does not rehash that archive.
- source-manifest 13/13, not 15.
- 159 `native_author` command records, 318 raw streams, exits 119/36/4. No `root_preflight` origin. Commands are stored lexicographically; chronological order differs. Use recorded timestamps / root chronological view.
- Author `auditor: grok-4.6` is a requested future identity, not this review's approval.
- Failed scratch probes include `sorry` (`test_full_decode_dec.lean`, `test_envelope_fields_lem.lean`, `test_envelope_eq.lean`, `test_depth_bound_proof.lean`, and others). Scratch gets no production proof credit. Named 608 inventory has 0 forbidden.

Unchanged 54 fixtures / 21 tests / 7 runner checks were not rerun. They do not close 99 scenarios, 16 mutants, overlay, schema, hash, expectedIR, or host obligations.

## Open after this scoped candidate

- Prove `EncodeDecodeRoundtripStatement` without decoder/scanner-image premises.
- Discharge `h_depth` from faithful structural admission, or prove TreeJson depth equals/≤ `jsonDepth decodedIRToJson` without a false `=` on Json RB trees. Keep Valid/Nodup; do not treat the invalid duplicate-key diagnostic as an admitted counterexample.
- Discharge `h_lex` from admission. Token parser inversion is not a separate lexical-pass proof.
- Keep production byte order and direct decoder semantics.
- Repair overlay / expectedIR / hash / schema / host / campaign issues with actual end-to-end evidence.

Root verifies, adjudicates, and publishes. No full P19 acceptance from partial proofs. Full core roadmap remains active.
