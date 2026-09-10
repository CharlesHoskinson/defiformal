# P19 R25 typed payload decoder additions — independent Grok review

**Verdict: `CHANGES_REQUIRED`.** Full P19 is not complete. The three new Roundtrip lemmas are scoped usable after independent source, rebuild, and 581-name axiom-probe checks. They do not prove `EncodeDecodeRoundtripStatement` and do not discharge whole-module `h_dec`.

Requested model: `grok-4.6` high. Returned model is unknown until this session's terminal telemetry is valid. Fresh session. Lean4 skill profile: `scripts_only` + `review_only`. Literal `/home/charl/.codex/plugins/cache/lean4-skills/lean4/4.8.7/bin/lean4-skills-preflight --codex` ran exit 0 at 2026-09-10T22:32:15.638179Z. One auditor. No production edits, network, subagents, Foreman, branches, commits, pushes, extra windows, or AGY R26 inspection. Author recorder was not invoked.

Frozen archive claimed `b0dca747257dd65df506b1e7a34b68b94ee6313001b8a9510a61a18135dec432` (root-stated 4649 files, 182 new). Independent walk of the extracted sandbox counted 5107 files; that walk is not a rehash of the tarball. Production source changed only `Roundtrip.lean` (82858 bytes, SHA `3590b4fa10f50ba28533ee05e2c1d1467358049644b90c0579c7fc1bd2f295d5`, 133 theorems, 3 new). `CanonicalJson`, `Correspondence`, `Encode`, `Decode`, `Schema`, `Check`, `Tests`, `Verify`, `Observation`, `Soundness`, `Audit`, and `RunFixtures` hashes are unchanged from reviewed R24.

R24 adjudication (`p19-module-validity-grok-r1/root-adjudication.json`) remains context: 28 module-validity/component-decoder lemmas usable; full P19 open. This review does not reopen those frozen proofs except as callers of the three new lemmas.

## Independent rebuild

Private Lean copy under this output directory. Initial `.lake/build` copied from completed R24 review `p19-module-validity-grok-r1/private-lean/.lake/build`. Packages are a read-only symlink to `p19-r7-root-verification`. No author cache and no live AGY R26 cache. Roundtrip and Verify oleans were deleted before rebuild.

Two shell attempts to run `python3 tools/setup_private_lean.py` from the sandbox cwd failed with exit 2 (`No such file or directory`). Those failed attempts are preserved. Setup then ran from this outdir.

Recorded commands:

| id | start | end | exit | credit |
|---|---|---|---|---|
| `lean-version` | 22:32:15.578817Z | 22:32:15.637291Z | 0 | yes |
| `lean4-skills-preflight` | 22:32:15.638179Z | 22:32:15.646782Z | 0 | yes |
| `lean4-skills-project-context` | 22:32:15.647579Z | 22:32:15.693857Z | 0 | yes |
| `lake-rebuild-roundtrip` | 22:32:44.340449Z | 22:33:03.888471Z | 0 | yes |
| `lake-rebuild-verify` | 22:33:03.889098Z | 22:33:13.239115Z | 0 | yes |
| `sorry-analyzer-roundtrip` | 22:33:13.240575Z | 22:33:13.281153Z | 0 | yes |
| `probe-axioms581` | 22:33:41.545715Z | 22:33:43.151829Z | 0 | yes |

Pinned Lean: `Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)`. `lean` SHA `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`. `lake` SHA `60330ab6f07dce20f3fa9ebb08e8b984ea9549eac172afeb15d9d2227060e2b3`. `libleanshared.so` SHA `0e2ffc1639d133cfccf1552c0d59772b77ed56e3e0c5a00e33d8c7c324a9470f`. Project context: `repository_kind other-lean`; mathlib layer is advisory (`intent.source default`).

Lake stdout prints only warning/info-bearing jobs. Silent replays are not listed.

| Target | Jobs | Visible Built | Visible Replayed | Exit |
|---|---|---|---|---|
| `DefiKernel.Certificates.Roundtrip` | 933 | Roundtrip (18s) | Typed.Transition, Schema, Check | 0 |
| `DefiKernel.Certificates.Verify` | 938 | Verify (8.7s) | Typed.Transition, Schema, Check, Tests, Audit | 0 |

Named Verify target is 938 jobs. That is not a full `DefiKernel` build and not 938 newly built modules. Author GATE-02 938 jobs is the same named target class.

Sorry-analyzer on Roundtrip: 0 sorry. Source scan of Roundtrip/Verify/CanonicalJson/Encode/Decode/Schema: 0 `sorry`, 0 `native_decide`, 0 custom `axiom`. Correspondence lines 24 and 1015 mention those words only in comments (unchanged R24 file).

## 581-name axiom set after fresh reviewer probe

Root-supplied complete probe `Axioms.lean` SHA `6692f8048e28ae7467aac5d76e39b3c5e0daf45d3a6b09d4917e66597191347d` (37320 bytes) was copied from `root-context/p19-r25-root-inventory` and executed against the reviewer private-lean oleans. This is not an incomplete inline helper and not a redundant Correspondence scan.

Command `probe-axioms581`:

- argv: pinned `lake env lean` on `probes/axioms581/Axioms.lean`
- cwd: this `private-lean`
- start `2026-09-10T22:33:41.545715+00:00` end `2026-09-10T22:33:43.151829+00:00`
- exit 0
- stdout SHA `8d5aa49ec2c9b6ebb5c8470c42fb6c5c150afe82717368132b6a08403f5ac458` equals root `axioms.stdout`
- stderr empty SHA `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

Independent source extraction: 136 CanonicalJson + 312 Correspondence + 133 Roundtrip = 581 `theorem`/`lemma` names. Source FQ names equal root print names and root inventory. After rebuild and this probe:

- print count 581
- 523 standard (`propext` / `Classical.choice` / `Quot.sound` subsets)
- 58 none
- 0 forbidden

Root inventory 523/58 is imported terminal author build. Matching stdout is independent confirmation on the reviewer oleans, not a substitute for this run.

The three new names are all standard:

| name | axioms |
|---|---|
| `qualifiedPortToTreeJson_toJson` | propext, Classical.choice, Quot.sound |
| `decodeOutputObservation_outputObservationToTreeJson` | propext, Classical.choice, Quot.sound |
| `decodeTypedExecutePayload_typedExecutePayloadToTreeJson` | propext, Classical.choice, Quot.sound |

## New lemmas — actual proofs

Old 130 Roundtrip headers are preserved modulo whitespace (independent comparison against R24 private-lean Roundtrip; 0 mismatches, 0 removals).

### `qualifiedPortToTreeJson_toJson`

```lean
theorem qualifiedPortToTreeJson_toJson (qp : QualifiedPortEnc) :
    (qualifiedPortToTreeJson qp).toJson = qualifiedPortToJson qp
```

Representation equality. `dsimp` of the two-field TreeJson object plus two `natToTreeJson_toJson` rewrites. No alternate codec. Used by the output-observation TreeJson decoder.

### `decodeOutputObservation_outputObservationToTreeJson`

```lean
theorem decodeOutputObservation_outputObservationToTreeJson (o : OutputObservationEnc)
    (h_can : PackedValueCanonical o.value) :
    decodeOutputObservation (outputObservationToTreeJson o).toJson = .ok o
```

`rfl` decomposes declaration-order Json lookup of `step` / `port` / `value` into `decodeQualifiedPort (qualifiedPortToTreeJson o.port).toJson` and `decodePackedValue (packedValueFullToTreeJson o.value).toJson`. Then `qualifiedPortToTreeJson_toJson` and `packedValueFullToTreeJson_toJson`, then existing `decodeQualifiedPort_qualifiedPortToJson` and `decodePackedValue_canonical`. Packed-value canonical plus qualified-port inverse. No alternate codec.

`PackedValueCanonical` is inactive-field zero/false (`unit = bool → valRat = 0`, numeric units have `valBool = false`). It is not a decoder-success image predicate and not a 4096-string or 1e18-rational cap.

### `decodeTypedExecutePayload_typedExecutePayloadToTreeJson`

```lean
theorem decodeTypedExecutePayload_typedExecutePayloadToTreeJson (p : TypedExecutePayloadEnc)
    (h_reg_can : RegistryCanonical p.registry)
    (h_env_can : EnvironmentCanonical p.env)
    (h_req_can : RequestCanonical p.request)
    (h_state_valid : ∀ c ∈ p.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0)
    (h_state_unique : (p.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = p.state.cells.length) :
    decodeTypedExecutePayload (typedExecutePayloadToTreeJson p).toJson = .ok p
```

`rfl` reduces `decodeTypedExecutePayload` on declaration-order `(typedExecutePayloadToTreeJson p).toJson` to the production 7-field decoder (`checkExactObjectKeys` of `registry`, `store`, `ctx`, `env`, `now`, `request`, `state`) with nested lookups becoming:

- `decodeRegistry (registryToTreeJson p.registry).toJson`
- `decodeStore (storeToTreeJson p.store).toJson`
- `decodeContext (contextToTreeJson p.ctx).toJson`
- `decodeEnvironment (environmentToTreeJson p.env).toJson`
- `decodeRequest (requestToTreeJson p.request).toJson`
- `decodeState (stateToTreeJson p.state).toJson`
- `now` recovered definitionally as `p.now`

Then known TreeJson-to-Json maps for registry/store/context/environment/state, existing Json inverses (`decodeRegistry_registryToJson`, `decodeStore_storeToJson`, `decodeContext_contextToJson`, `decodeEnvironment_environmentToJson`, `decodeState_stateToJson`), and the direct Request inverse `decodeRequest_requestToTreeJson`. Canonical conditions match the existing Correspondence Json theorem. They are registry/template/environment/request packed-value canonicality plus reduced nonnegative unique state cells. Not new 4096-string or 1e18-rational caps. `TypedPayloadLengthBounds` is used only by `typedExecutePayloadToTreeJson_valid`, not by this decoder inverse.

This theorem does **not** discharge whole-module `h_dec`. Envelope, step, run, and `decodeDecodedIR` composition remain open.

Root Raw-tree order counterexample remains valid. These proofs invert declaration-order `TreeJson.toJson` field lookup. They do not claim arbitrary structural permutation equality of Json RB-trees.

## Strongest theorem vs actual source

Actual `decodeBytes_encodeModule_of_depth` (Roundtrip.lean:1717), unchanged from R24 except surrounding new lemmas:

```lean
theorem decodeBytes_encodeModule_of_depth (ir : DecodedIR)
    (h_adm : StructurallyAdmissibleIR ir)
    (h_depth : TreeJson.depth (moduleToTreeJson ir) ≤ 64)
    (h_dec : decodeDecodedIR ((moduleToTreeJson ir).toJson) (encodeModuleString ir) = .ok ir)
    (h_lex : scanLexical (encodeModule ir) = .ok ()) :
    decodeBytes (encodeModule ir) = .ok ir
```

Remaining premises: `h_depth`, `h_dec`, `h_lex`. R24 already discharged `h_valid` via `moduleToTreeJson_valid`.

`WholeDocumentDepthBounded` in unchanged Correspondence is `jsonDepth (decodedIRToJson ir) ≤ 64`, not `TreeJson.depth (moduleToTreeJson ir) ≤ 64`. Admission does not discharge `h_depth`. A metric correspondence is still required. Do not use Json RB-tree structural equality for that bridge.

`h_dec` is decoder success on `(moduleToTreeJson ir).toJson`. Component inverses (request, world, libraryRef, output observation, typed execute payload) do not compose to `decodeDecodedIR`. Author language that `h_dec` is "partially discharged" is component progress only.

`EncodeDecodeRoundtripStatement` remains `def Prop`, not a theorem.

Canonical grammar preserved: 1 MiB / depth 64 / array 4096. No image/success predicates added to the domain.

## Author evidence hygiene (frozen R25, not re-executed)

Independent hash check of author `MANIFEST.json`: 181 listed bindings, 181 match, including final commands/probes/raw. Source-manifest: 13 bindings, 13 match. Not the earlier copied summary of 15.

Author `commands.json` is a 31-element list. Origins: 31 `native_author`, 0 `root_preflight`. Exits: 17 zero, 11 one, 3 two. 62 streams (stdout+stderr). Only successful final-source-bound commands receive candidate execution credit. Those ids: `build-verify-16`, `run-tests-17`, `run-fixtures-20`, `test-runner-22`, `gen-audit-log-23`, `gen-theorems-json-24`, `gen-src-manifest-25`, `gen-verdict-results-26`. `build-roundtrip-15` used non-final Roundtrip hash `71fb6cf2…`. `write-report-27` exited 1.

Author `auditor` field `grok-4.6` is requested future identity, not this approval. Author disposition `USABLE` is scoped progress language; author report keeps full P19 open. This review agrees that full P19 stays open.

Existing 54 fixtures, 21 tests, and 7 runner checks were author-executed again on the final tree. This review did not rerun them. They do not close 99 scenarios, 16 mutants, overlay, schema, hash, independent expected IR, or trusted-host obligations.

## Remaining obligations

- Finish module/envelope/step/run decoder composition so `h_dec` is derived, not assumed.
- Bridge `jsonDepth (decodedIRToJson ir)` to `TreeJson.depth (moduleToTreeJson ir)`.
- Prove lexical scanner success `h_lex`.
- Prove `EncodeDecodeRoundtripStatement` from the unchanged 1 MiB / depth 64 / array 4096 canonical domain.
- Overlay / schema / hash / expectedIR / host / 99-scenario / 16-mutant campaign closure.
- Preserve production field order, sourceMap sorting, historical signatures, `StructurallyAdmissibleIR`, no decoder-success premises in admission, no new 4096-string or 1e18-rational caps, and the libraryRef structural-inequality counterexample.

Scoped result: three new lemmas usable. Full P19 `CHANGES_REQUIRED`. Root verifies, adjudicates, and publishes.
