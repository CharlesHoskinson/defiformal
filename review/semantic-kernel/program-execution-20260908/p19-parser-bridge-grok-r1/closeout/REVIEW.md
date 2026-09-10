# P19 R13 parser-bridge / production-decoder review

**Mark:** `PARSER_BRIDGE_COMPONENT_REVIEW_ONLY_FULL_P19_OPEN`  
**Disposition:** `CHANGES_REQUIRED`  
**This is not full P19 acceptance and does not close any task.**

Same-session closeout of native session `01a08bdf-5a94-7ba0-b04d-697686708e06` after the 25-turn cap. Requested model: `grok-4.6` effort high. Native receipt model identity is `grok-4.6-build`. This closeout does not invent a different model.

Frozen candidate: AGY R13 archive SHA256 `6b93b433355f15eaaa613cca947e5eb4ebbea3ef80574cd7ec00f47d78bd5fa6` (3470 files, root-verified). Author reports `PARTIAL_PROOF_WORK` and catalogue **200**. Independent source count is **200** theorems (23 CanonicalJson + 177 Correspondence) plus lemma `exprDepth_pos`. Twenty-two new theorem names versus sealed R12 178. AGY R14 is out of scope and was not read.

Compiler: Lean `4.33.0-rc2` commit `d8b18978322de05a8f3dba51ef03cf5461676c17`. Binary SHA256 `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`. Private copied build cache under the parent review directory. Frozen sandbox sources were not written. All new closeout writes are in this directory only.

**lean4-skills profile:** `scripts_only` + `review_only`. `lean4-skills-preflight --codex` exit 0 using literal `/home/charl/.codex/plugins/cache/lean4-skills/lean4/4.8.7/bin/lean4-skills-preflight`. Empty stdout and stderr. No live LSP tools in this harness. File-level `lake env lean` used. Layer-2 mathlib findings advisory. `repository_kind` was not recorded by a project-context helper in this session.

## Verdict

Component theorems in CanonicalJson and Correspondence compile after an independent private rebuild. Exact-name `#print axioms` on all **200** source theorems: standard Lean axioms only (`propext`, `Classical.choice`, `Quot.sound`); four declarations depend on no axioms; zero `sorry` in Encode/Decode/CanonicalJson/Correspondence (analyzer `total_count` 0). `EncodeDecodeRoundtripStatement` remains `def Prop`.

Useful new proofs exist and must be credited only at their actual strength:

- `tokenize_escapeJsonString` / `parseCanonicalJson_escapeJsonString` are general string inverses.
- `decodeDecodedIR_envelopeToJson_eq` is definitional equality with production `decodeDecodedIR`.
- typed/step/run inverses now mention `decodeDecodedIR` through that lemma.
- `libraryRefToJson none` is now a `{"theorem":…}` object matching production `encodeLibraryRef none`.
- `decodeClaimedNextState_of_canonical` inverts none and canonical `some w`.

They do not close the universal production byte/IR theorem.

R13 still assumes `h_sm : decodeSourceMap (mkObj …) = .ok map` on envelope and execution inverses. Only `decodeSourceMap_nil` and `decodeSourceMap_single` are proved. Arbitrary nonempty `SourceMapSorted` inverse remains open. Assumed decoder success cannot close the full target.

Fuel-named lemmas `jsonDepthFuel_adequate_of_le64` and `jsonMaxArrayLengthFuel_adequate` both conclude `jsonDepth j < 100` from `jsonDepth j ≤ 64` by `omega`. `parser_max_depth_bound` / `parser_max_array_bound` return their hypotheses. These true weak statements are not fuel stability, max-array correctness, or parser agreement. ProbeR13 attempt 2: `jsonDepth (nestArr 64) = 64` and fuel 100 reports 64; nest 65 reports 65 (`< 100` true). That does not falsify fuel 100 at depth 64; it also does not prove it.

Runner: lexical final-component symlink of `--out` is refused (live relative, dangling relative, absolute live: exit 2, sentinel unchanged). The author relative-link regression constructs `symlink_to(rel_tmp / "real_rel_dir")`, which duplicates the temp parent and dangles. A fresh child under a parent symlink is **not** refused as a symlink (exit 1 later opening fixtures in the private runner-tree). No new blanket parent-symlink ban is required. F01 was not rerun.

Full P19 remains open.

## Independent inventory (source, including punctuation)

CanonicalJson (23): prior 15 plus `parseTokens_empty_arr`, `parseTokens_empty_obj`, `parseCanonicalJson_true`, `parseCanonicalJson_false`, `parseCanonicalJson_null`, `parseCanonicalJson_empty_arr`, `parseCanonicalJson_empty_obj`, `tokenizeFuel_empty`.

Correspondence adds 14 names versus sealed R12 163: `jsonDepthFuel_adequate_of_le64`, `jsonMaxArrayLengthFuel_adequate`, `parser_max_depth_bound`, `parser_max_array_bound`, `tokenize_escapeJsonString`, `parseCanonicalJson_escapeJsonString`, `world_unique_of_canonical`, `world_valid_of_canonical`, `decodeClaimedNextState_none`, `decodeClaimedNextState_some`, `decodeClaimedNextState_of_canonical`, `decodeSourceMap_nil`, `decodeSourceMap_single`, `decodeDecodedIR_envelopeToJson_eq`.

Author sandbox `theorems.json` SHA256 `68ee642c45d5470e66a53e9c15fd8f2ceaf70238f3b51c29035c2797a562008a` reports 200. Independent source count matches. Lemma `exprDepth_pos` remains extra and is not in the 200.

Empty-axiom names from this session’s `#print axioms`: `rational_decode_canonical`, `rat_fromRat_num_den`, `rational_roundtrip`, `world_unique_of_canonical`.

## What the new inverses actually prove

| Lemma | Extra hypotheses | Production connection |
|---|---|---|
| `tokenize_escapeJsonString` / `parseCanonicalJson_escapeJsonString` | none | Canonical escaped string → `[JsonToken.str s]` / `Json.str s`. Not recursive array/object/whole-byte inverse |
| `parseTokens_empty_*` / `parseCanonicalJson_{true,false,null,empty_*}` / `tokenizeFuel_empty` | none | Empty containers and literals. Not general AST inversion |
| `decodeDecodedIR_envelopeToJson_eq` | none | `rfl` equality with production `decodeDecodedIR` |
| `decodeDecodedIR_fields_typed/step/run` | `h_sm`, `ClaimedNextStateCanonical`, payload canonicals, unused `raw` | Now rewrite through `decodeDecodedIR`. Still not `decodeBytes (encodeModule ir)` |
| `decodeEnvelope_*` | `schema_version=1`, **`h_sm`**, `ClaimedNextStateCanonical` | Field-list `decodeEnvelope`. `h_sm` is assumed decoder success |
| `decodeSourceMap_nil` / `_single` | none | Empty and singleton only |
| `decodeClaimedNextState_of_canonical` | `ClaimedNextStateCanonical` | Null and canonical world JSON. Runtime empty world also decodes |
| `libraryRefToJson` none | none | Object `{"theorem":…}` matching production none |
| `jsonDepthFuel_adequate_of_le64` / `jsonMaxArrayLengthFuel_adequate` | `jsonDepth j ≤ 64` | Both: `jsonDepth j < 100` by `omega`. Second name does not mention array length |
| `parser_max_depth_bound` / `parser_max_array_bound` | the bound hypothesis | Return the hypothesis |

`Json.mkObj` key order and production compact `jsonObj` field order can differ and still parse as the same JSON. ProbeR13 attempt 2: helper some `.compress` is `{"module":"M","theorem":"T"}`; production some is `{"theorem":"T","module":"M"}`. Both decode to `ok thm=T mod=some:M`. Different `.compress` alone is not a defect; no byte-equality claim was proved for those strings.

Two serializers remain: Encode.lean compact strings (`jsonObj`) used by `encodeModule`, and Correspondence.lean `Lean.Json.mkObj` used by the proofs.

## Remaining mathematical chain

1. `EncodeDecodeRoundtripStatement` is still  
   `∀ (ir : DecodedIR), StructurallyAdmissibleIR ir → decodeBytes (encodeModule ir) = .ok ir`  
   as `def Prop`.
2. Derive `decodeSourceMap (mkObj (map string pairs)) = .ok map` from `SourceMapSorted` for arbitrary nonempty maps. Do not keep `h_sm` as a closing hypothesis.
3. Prove fuel 100 adequacy and parser agreement for documents of depth ≤ 64 / array length ≤ 4096. Do not credit the `omega` `< 100` lemmas as that theorem.
4. Bridge helper JSON through `decodeDecodedIR` (now started) to `decodeBytes (encodeModule ir)`.

## Independent measurements (ProbeR13 attempt 2, child compiler exit 0)

Successful replay target: `../logs/probe-r13-attempt2.stdout` SHA256 `ef28fd0341f6f37d30f439d52dffa73f2164df6f30fa5f7b18845fb0cbd9d42e`.

- `parseCanonicalJson (escapeJsonString "a\"b")` = `ok:"a\"b"`; slash and empty likewise.
- `decodeSourceMap` nil / singleton / two-key `mkObj` (input `ab` or `ba`) = `ok:[(a, 1), (b, 2)]`. Runtime two-key success is not the missing `SourceMapSorted` theorem.
- `decodeClaimedNextState` null = `ok:none`; empty world = `ok:some cells=0`.
- `libraryRef` none helper and production both `{"theorem":"T"}`.
- `decodeEnvelope` / `decodeDecodedIR` codec on two-entry source map: `ok sm=[(a, 1), (b, 2)]`.
- Depth: scalar 0; nestArr 64 = 64 (`≤64` true, `<100` true); nestArr 65 = 65 (`≤64` false, `<100` true); `jsonDepthFuel 100 (nestArr 101) = 100` (truncates).

Attempt 1 `lake env lean ProbeR13.lean` failed: `invalidField` on `c.envelope.map (·.source_map)` (stdout SHA256 `dc696812cacdd107444cbcdfbf53d61621620577bb35fafdff09168885f69d4d`). Zero credit. The attempt-1 probe source was overwritten by attempt 2 at `../probes/ProbeR13.lean` SHA256 `cddc30783d75862dcada4cc233e1e327b2990501a69544fc291e31bb61cdde59`. This closeout does not reconstruct attempt-1 bytes.

`lean4-skills-check-axioms-inline` on Correspondence after private-lean cwd reports 281 declarations, standard axioms only. That is not the 200-name inventory. Exact-name credit is `ProbeAxioms.lean`. An earlier inline run from the sandbox cwd failed (`unknown module prefix 'DefiKernel'`) and those log bytes were overwritten; that failed run has zero credit and no preserved log.

## Runner sentinels (private copy of runner SHA256 `6012df02…`; no historical mutation)

| Sentinel | Exit | Meaning |
|---|---|---|
| live relative symlink `--out` (target `live-rel-target`, sentinel unchanged) | 2 | lexical `is_symlink` refusal |
| dangling relative symlink | 2 | lexical refusal; missing target not created |
| absolute live symlink | 2 | lexical refusal |
| author-style `symlink_to(rel_tmp/real_rel_dir)` | not a runner run | `readlink=tmpPARENT/real_rel_dir`, exists false, resolves through duplicated parent |
| parent symlink + fresh child | 1 | **guard passed**; later `FileNotFoundError` opening fixtures in the private tree |

No F01 pipeline check. No full 54/99/16 campaign.

## Decode refactor versus sealed R12

R13 extracts `decodeSourceMap` and `decodeClaimedNextState` from the previous inline `decodeEnvelope` matches. The extracted bodies keep the R12 object/sorted-key/`jsonType "source_map"` and null-or-`decodeWorld` classes. `decodeDecodedIR` mode dispatch is unchanged. This session did not rerun array/depth resource campaigns; those classes are not implemented in the extracted helpers.

Root independently checks the exact 200 names and replays successful ProbeR13 attempt 2 after this closeout.
