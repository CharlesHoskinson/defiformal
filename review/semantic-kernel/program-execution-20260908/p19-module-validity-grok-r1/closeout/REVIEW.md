# P19 R24 production module validity and decoder additions — independent Grok review

**Verdict: `CHANGES_REQUIRED`.** Full P19 is not complete. Scoped new validity and decoder lemmas are usable after independent source, build, and axiom-probe checks. They do not prove `EncodeDecodeRoundtripStatement`.

This closeout continues session `01a08d5a-6db8-7181-8988-6638af9cbdf4`. It is the same independent reviewer, not a second reviewer. Original parent reports and six command logs are immutable under `original-terminal/` and the parent output directory. AGY R25 was not inspected. Author recorder was not invoked.

Requested model: `grok-4.6` high. Original process reported `grok-4.6-build`. Closeout returned model follows this run's native telemetry and is unknown until that terminal metadata is valid. Lean4 skill profile: `scripts_only` + `review_only`. Absolute `lean4-skills-preflight --codex` ran exit 0 at 22:14:40. One auditor. No production edits, network, subagents, Foreman, branches, commits, pushes, or windows.

Frozen archive claimed `e511d9face7289d94c69c2bab12a682507210765a5bebc34bcb62a6aad87fe6e` (root-stated 4467 files). Independent walk of the extracted sandbox counted 4925 files; that walk is not a rehash of the tarball. Production source changed only `Roundtrip.lean` (79949 bytes, SHA `f31d7bf8ae52d9474253a45b8423c4ebaf2bbc8ad17b4d984124564a93fb7f68`, 130 theorems, 28 new). `CanonicalJson`, `Correspondence`, `Encode`, `Decode`, `Schema`, and `Verify` hashes are unchanged from reviewed R23.

## Independent rebuild (original receipts)

Private Lean copy under the parent output directory. Initial `.lake/build` copied from completed R23 review `p19-module-tree-grok-r1/private-lean/.lake/build`. Packages are a read-only symlink to `p19-r7-root-verification`. No author or live cache. Roundtrip and Verify oleans were deleted before rebuild.

Original recorded commands (parent logs, not re-timestamped):

| id | start | end | exit | credit |
|---|---|---|---|---|
| `lean-version` | 22:14:40.755676Z | 22:14:40.784783Z | 0 | yes |
| `lean4-skills-preflight` | 22:14:40.785486Z | 22:14:40.792845Z | 0 | yes |
| `lean4-skills-project-context` | 22:14:40.793361Z | 22:14:40.835881Z | 0 | yes |
| `lake-rebuild-roundtrip` | 22:14:55.039782Z | 22:14:58.242840Z | 0 | yes |
| `lake-rebuild-verify` | 22:14:58.243771Z | 22:15:06.939896Z | 0 | yes |
| `sorry-analyzer-roundtrip` | 22:15:06.941360Z | 22:15:06.980233Z | 0 | yes |

Pinned Lean: `Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)`. `lean` SHA `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`. `lake` SHA `60330ab6f07dce20f3fa9ebb08e8b984ea9549eac172afeb15d9d2227060e2b3`. Project context: `repository_kind other-lean`; mathlib layer is advisory.

Lake stdout prints only warning/info-bearing jobs. Silent replays are not listed.

| Target | Jobs | Visible Built | Visible Replayed | Exit |
|---|---|---|---|---|
| `DefiKernel.Certificates.Roundtrip` | 933 | Roundtrip (2.6s) | Typed.Transition, Schema, Check | 0 |
| `DefiKernel.Certificates.Verify` | 938 | Verify (8.1s) | Typed.Transition, Schema, Check, Tests, Audit | 0 |

Named Verify target is 938 jobs. That is not a full `DefiKernel` build. Author GATE 21:40:22→21:40:31 / 938 jobs is the same named target class.

Sorry-analyzer on Roundtrip: 0 sorry. Source scan of Roundtrip/Verify: 0 `sorry`, 0 `native_decide`, 0 custom `axiom`. Correspondence lines 24 and 1015 mention those words only in comments.

## 578-name axiom set after fresh reviewer probe

Root-supplied complete probe `Axioms.lean` SHA `5bcdc02df3162150b3761006195366db2a91663452bb346cf61cd3852290e4a0` was **prepared** in the original session and **not executed** then. Closeout ran it as a fresh reviewer execution against the completed private-lean oleans. Probe file was not modified. This is not the root inventory run relabelled as reviewer.

Closeout command `probe-axioms578`:

- argv: pinned `lake env lean` on `original-terminal/probes/axioms578/Axioms.lean`
- cwd: parent `private-lean`
- start `2026-09-10T22:18:39.019255+00:00` end `2026-09-10T22:18:40.584185+00:00`
- exit 0
- stdout SHA `b37409dfa972a751f4e71c284163826d7855165892a7f1d1ab939d0a95d7bd29` equals root `axioms.stdout`
- stderr empty SHA `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

Independent source extraction: 136 CanonicalJson + 312 Correspondence + 130 Roundtrip = 578 `theorem`/`lemma` names. After rebuild and this probe:

- print count 578
- names equal source FQ names and root inventory
- 520 standard (`propext` / `Classical.choice` / `Quot.sound` subsets)
- 58 none
- 0 forbidden

Root inventory 520/58 is imported terminal author build. Matching stdout is independent confirmation on the reviewer oleans, not a substitute for this run.

## Strongest theorem vs actual source

Actual `decodeBytes_encodeModule_of_depth` (Roundtrip.lean:1668):

```lean
theorem decodeBytes_encodeModule_of_depth (ir : DecodedIR)
    (h_adm : StructurallyAdmissibleIR ir)
    (h_depth : TreeJson.depth (moduleToTreeJson ir) ≤ 64)
    (h_dec : decodeDecodedIR ((moduleToTreeJson ir).toJson) (encodeModuleString ir) = .ok ir)
    (h_lex : scanLexical (encodeModule ir) = .ok ()) :
    decodeBytes (encodeModule ir) = .ok ir
```

R24 removes `h_valid` only, by `moduleToTreeJson_valid ir h_adm`. Remaining premises: `h_depth`, `h_dec`, `h_lex`.

`WholeDocumentDepthBounded` in unchanged Correspondence is `jsonDepth (decodedIRToJson ir) ≤ 64`, not `TreeJson.depth (moduleToTreeJson ir) ≤ 64`. Admission does not discharge `h_depth`. A metric correspondence is still required. Do not use Json RB-tree structural equality for that bridge.

`h_dec` is decoder success on `(moduleToTreeJson ir).toJson`. Correspondence `decodeDecodedIR_of_structurallyAdmissible` is on `decodedIRToJson`. Root libraryRef diagnostic already shows declaration-order `TreeJson.toJson` and mapped `libraryRefToJson` are structurally unequal while `BEq` is true. Do not reintroduce a false permutation/`=` bridge.

Existing `EncodeDecodeRoundtripStatement` remains a `def Prop`, not a proved theorem:

```lean
∀ (ir : DecodedIR), StructurallyAdmissibleIR ir → decodeBytes (encodeModule ir) = .ok ir
```

Do not accept tautological decoder/scanner-image premises as the final roundtrip. No desired-success or image predicate in admission. No new 4096-string or 1e18-rational cap. Full roadmap remains active.

## `moduleToTreeJson_valid` and the new 28 lemmas

**Scoped usable** after source, independent compile, and the 578-name probe.

`TreeJson.Valid` is recursive validity, distinct object keys, and array length ≤ 4096. It does **not** require object fields sorted.

`moduleToTreeJson_valid` is from unchanged `StructurallyAdmissibleIR` (`SupportedIR ∧ CanonicalIR`). The proof cases typed / step / run, excludes audit/codec by contradiction, and uses envelope/source-map/payload Valid lemmas. Envelope includes optional `claimed_next_state`. 32-cell world bounds come from admission `cells.length = 32` via `omega` into ≤ 4096. Source-map Nodup is from existing `SourceMapSorted` plus `nodup_of_pairwise_lt_string`.

Independent probe classifies the 28 new names as 25 standard + 3 none (`validObj_str_map`, `inputSourceToTreeJson_valid`, `outputObservationToTreeJson_valid`), 0 forbidden.

New `*_toJson` maps (cellDelta, supplyDelta, envRead, template, registryEntry, registry) are semantic `TreeJson.toJson = *ToJson` equalities, not Raw-tree permutation claims.

`decodeWorld_worldToTreeJson` is a proved **component** lemma. Extra hypotheses (reduced non-negative rationals, unique cells) are the local canonical assumptions of `decodeState`/`decodeStore`. Those facts are already present on admitted 32-cell worlds in `SupportedIR` / `CanonicalIR`. Extra hypotheses are not themselves a defect of the lemma. What remains missing is the **composition derivation** from `StructurallyAdmissibleIR` to a module-level world decode, not a repair of this component statement. The proof goes through `stateToTreeJson_toJson` / `storeToTreeJson_toJson`, then `Json.mkObj` / `TreeMap.Raw.ofList compare`, then existing decode lemmas. That is not a false permutation bridge.

`decodeLibraryRef_libraryRefToTreeJson` is `rfl` after unfolding `TreeJson.toJson` / `decodeLibraryRef` / `checkObjectKeys` / `getField`. `checkObjectKeys` is allowed-key containment, not order-sensitive list equality. This is decode of the `toJson` Json value, not `TreeJson.obj` structural equality with a sorted Raw tree. The root libraryRef counterexample remains valid.

## Author evidence (frozen only)

Author `agy-r24-proof` is in the frozen sandbox. Author `MANIFEST.json` lists 10 files. Independent hash: 9 match, `commands.json` stale (claimed `0ffcf5a8…` / 305428 bytes, actual `2152b907…` / 316782 bytes). Raw streams and probes are omitted from that MANIFEST. `auditor: grok-4.6` is a requested future identity, not this review's approval.

Author `source-manifest.json` has **13** source bindings. All 13 match frozen bytes. Do not copy a prior brief count of 15. Root will adjudicate the exact binding count.

All 62 recorded author commands occurred during AGY R24. Two `root_preflight` labels are AGY-created controls, not root execution. Origin labels 60 native + 2 root are inaccurate actor classification. Only successful final-source-bound gates support the final candidate.

No 99-scenario / 16-mutant closure from status mapping or 54 fixtures. Overlay / hash / schema / independent expected IR / host executor concerns remain. Unchanged fixtures were not re-run.

## Open after this scoped candidate

- Prove `EncodeDecodeRoundtripStatement` without decoder/scanner-image premises.
- Discharge `h_depth` from faithful structural admission, or prove TreeJson depth equals/≤ `jsonDepth decodedIRToJson` without a false `=` on Json RB trees.
- Discharge `h_dec` / `h_lex` from admission.
- Keep production byte order and direct decoder semantics.
- Repair overlay / expectedIR / hash / schema / host / campaign issues with actual end-to-end evidence.

Root verifies, adjudicates, and publishes. No full P19 acceptance from partial proofs.
