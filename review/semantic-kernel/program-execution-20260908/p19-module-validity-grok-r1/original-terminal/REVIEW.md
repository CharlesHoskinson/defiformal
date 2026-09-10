# P19 R24 production module validity and decoder additions — independent Grok review

**Status: in progress.** Independent compile and 578-axiom probe not yet finished. Source-scope facts below are from frozen sandbox reads. Verdict will be finalized after the isolated rebuild.

**Working verdict: `CHANGES_REQUIRED`.** Full P19 is not complete. Scoped new validity lemmas are useful if they compile. They do not close `EncodeDecodeRoundtripStatement`.

Requested model: `grok-4.6` high. Returned model: unknown until terminal telemetry. Lean4 skill profile: `scripts_only` + `review_only`. Absolute `lean4-skills-preflight --codex` is required and will be recorded. One auditor. No production edits, network, subagents, Foreman, branches, commits, pushes, or windows. AGY R25 was not inspected. Author recorder was not invoked.

Frozen archive claimed `e511d9face7289d94c69c2bab12a682507210765a5bebc34bcb62a6aad87fe6e` (4467 files). Production source changed only `Roundtrip.lean` (79949 bytes, claimed SHA `f31d7bf8ae52d9474253a45b8423c4ebaf2bbc8ad17b4d984124564a93fb7f68`, 130 theorems, 28 new). `CanonicalJson` / `Correspondence` / `Encode` / `Decode` / `Schema` / `Verify` are claimed unchanged from reviewed R23.

## Independent rebuild (pending)

Private Lean copy under this output directory. Initial `.lake/build` to be copied from completed R23 review `p19-module-tree-grok-r1/private-lean/.lake/build`. Packages are a read-only symlink to `p19-r7-root-verification`. No author or live cache.

Named Verify target is `DefiKernel.Certificates.Verify`. That is not a full `DefiKernel` build. Author GATE 21:40:22→21:40:31 / 938 jobs is a Verify target, not full-kernel evidence.

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

`WholeDocumentDepthBounded` in unchanged Correspondence is `jsonDepth (decodedIRToJson ir) ≤ 64`, not `TreeJson.depth (moduleToTreeJson ir) ≤ 64`. Admission does not discharge `h_depth`.

`h_dec` is decoder success on `(moduleToTreeJson ir).toJson`. Correspondence `decodeDecodedIR_of_structurallyAdmissible` is on `decodedIRToJson`. Root libraryRef diagnostic already shows declaration-order `TreeJson.toJson` and mapped `libraryRefToJson` are structurally unequal while `BEq` is true. Do not reintroduce a false permutation/`=` bridge.

Existing `EncodeDecodeRoundtripStatement` remains a `def Prop`, not a proved theorem:

```lean
∀ (ir : DecodedIR), StructurallyAdmissibleIR ir → decodeBytes (encodeModule ir) = .ok ir
```

Do not accept tautological decoder/scanner-image premises as the final roundtrip. No desired-success or image predicate in admission. No new 4096-string or 1e18-rational cap. Full roadmap remains active.

## `moduleToTreeJson_valid`

From unchanged `StructurallyAdmissibleIR` (`SupportedIR ∧ CanonicalIR`). `TreeJson.Valid` is recursive validity, distinct object keys, and array length ≤ 4096. It does **not** require object fields sorted.

The proof cases typed / step / run, excludes audit/codec by contradiction, and uses envelope/source-map/payload Valid lemmas. Envelope includes optional `claimed_next_state`. 32-cell world bounds come from admission `cells.length = 32` via `omega` into ≤ 4096. Source-map Nodup is from existing `SourceMapSorted` plus `nodup_of_pairwise_lt_string`.

Compile of this theorem is pending the isolated rebuild.

## New semantic maps and direct decodes

New `*_toJson` maps: cellDelta, supplyDelta, envRead, template, registryEntry, registry. These are semantic `TreeJson.toJson = *ToJson` equalities, not Raw-tree permutation claims.

`decodeWorld_worldToTreeJson` goes through `stateToTreeJson_toJson` / `storeToTreeJson_toJson`, then `Json.mkObj` / `TreeMap.Raw.ofList compare`, then `decodeState_stateToJson` / `decodeStore_storeToJson`. Extra hypotheses: reduced non-negative rationals and unique cells. Those are actual canonical assumptions, not admission-only.

`decodeLibraryRef_libraryRefToTreeJson` is `rfl` after unfolding `TreeJson.toJson`/`decodeLibraryRef`/`checkObjectKeys`/`getField`. `checkObjectKeys` is an allowed-key containment check, not an order-sensitive list equality. This is decode of the `toJson` Json value, not `TreeJson.obj` structural equality with a sorted Raw tree. The root libraryRef counterexample remains valid and is not reintroduced as a permutation bridge in the source as read.

## Author evidence (frozen only)

Author `agy-r24-proof` is in the frozen sandbox. Author `MANIFEST.json` lists 10 files. Root already recorded `commands.json` stale (`0ffcf5a8…` claimed vs `2152b907…` actual). Independent hash check is pending setup. `auditor: grok-4.6` in the author MANIFEST is a requested future identity, not this review's approval.

All 62 recorded author commands occurred during AGY R24. Two `root_preflight` labels are AGY-created controls, not root execution. Origin labels 60 native + 2 root are inaccurate actor classification. Only successful final-source-bound gates support the final candidate. Root inventory 520 std / 58 none is imported terminal author build, not this review's build.

No 99-scenario / 16-mutant closure from status mapping or 54 fixtures. Overlay / hash / schema / independent expected IR / host executor concerns remain. Unchanged fixtures are not re-run unless a new concern appears.

## Open after this scoped candidate

- Prove `EncodeDecodeRoundtripStatement` without decoder/scanner-image premises.
- Discharge `h_depth` from faithful structural admission, or prove TreeJson depth equals/≤ `jsonDepth decodedIRToJson` without a false `=` on Json RB trees.
- Discharge `h_dec` / `h_lex` from admission.
- Keep production byte order and direct decoder semantics.
- Repair overlay / expectedIR / hash / schema / host / campaign issues with actual end-to-end evidence.

Root verifies, adjudicates, and publishes. No full P19 acceptance from partial proofs.
