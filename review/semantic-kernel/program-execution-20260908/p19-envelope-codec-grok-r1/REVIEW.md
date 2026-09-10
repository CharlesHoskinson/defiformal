# P19 R12 envelope/execution inverse, resource fidelity and runner-safety review

**Mark:** `ENVELOPE_CODEC_COMPONENT_REVIEW_ONLY_FULL_P19_OPEN`  
**Disposition:** `CHANGES_REQUIRED`  
**This is not full P19 acceptance and does not close any task.**

Requested model: `grok-4.6` effort high. Returned model identity is for root `modelUsage`; this report does not invent one.

Frozen candidate: AGY R12 archive SHA256 `d49463e3583b522329edb31d162af09af6206d8c0da80c6844b988a4947bf5d6` (3464 files, root-verified). Author reports `PARTIAL_PROOF_WORK` and catalog **178**. Independent source count is **178** theorems (15 CanonicalJson + 163 Correspondence) plus lemma `exprDepth_pos`. Punctuation name `string_fromUTF8?_toUTF8` is present. Eleven new theorem names versus sealed R11 167. AGY R13 is out of scope.

Compiler: Lean `4.33.0-rc2` commit `d8b18978322de05a8f3dba51ef03cf5461676c17`. Binary SHA256 `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`. Private copied build cache under this review directory. Frozen sandbox sources were not written.

**lean4-skills profile:** `scripts_only` + `review_only`. `lean4-skills-preflight --codex` exit 0 using literal `/home/charl/.codex/plugins/cache/lean4-skills/lean4/4.8.7/bin/lean4-skills-preflight`. No live LSP tools in this harness. File-level `lake env lean` used. Project context: `repository_kind=other-lean`, Layer-2 mathlib findings advisory.

## Verdict

Component theorems in CanonicalJson and Correspondence compile. Exact-name `#print axioms` on all **178** source theorems: standard Lean axioms only (`propext`, `Classical.choice`, `Quot.sound`); three rationals depend on no axioms; zero `sorry` in Encode/Decode/CanonicalJson/Correspondence. The 11 new declarations are helper/list/field lemmas, not `encodeModule`/`decodeBytes`. `EncodeDecodeRoundtripStatement` remains `def Prop`.

Scalar-depth 0 is a real runtime repair: guard AST 58 now has encode nest **64**, helper `jsonDepth` **64**, production parse depth **64**, `decodeBytes` **ok-eq**. Scalar lemmas do not prove general fuel adequacy. `jsonDepthFuel 64 (nestJson 65) = 64` undercounts the refusal threshold; production `jsonDepth` uses fuel **100**, which reports 65.

`decodeEnvelope_*` and `decodeDecodedIR_fields_*` still require `source_map = []` and `claimed_next_state = none`. The decoder and `CanonicalIR` admit more. `decodeDecodedIR_fields_*` is an inlined lookalike `do` expression, not a theorem about `decodeDecodedIR`. `libraryRefToJson none` remains a JSON string; production `encodeLibraryRef none` is `{"theorem":…}`. `sourcePinToJson` now always emits both optional keys as null-or-string; the author REPORT snippet is the omitted-none form.

Runner `--out` is required. Nonempty targets refuse with exit 2 and no sentinel mutation. Relative paths are `.resolve()`d before the symlink test; dangling targets bypass `exists()`. Full P19 remains open.

## Independent inventory (source, including punctuation)

CanonicalJson (15): `hexVal_hexDigit`, `bool_cond_of_lt32`, `lexString_quote`, `lexString_slash`, `lexString_u00`, `lexString_normal`, `lexString_char`, `lexString_escapeChars`, `lexString_escapeJsonString`, `string_fromUTF8?_toUTF8`, `tokenizeFuel_string`, `parseTokens_str`, `parseTokens_num`, `parseTokens_bool`, `parseTokens_null`.

Correspondence adds 11 names versus sealed R11 167: `jsonDepth_scalar`, `jsonDepthFuel_zero_of_scalar`, `decodeStringList_ok`, `decodeLibraries_ok`, `decodeEnvelope_orderedFields`, `decodeEnvelope_sortedFields`, `envelopeSortedFields_no_commands`, `envelopeToJson_eq_mkObj_sortedFields`, `decodeDecodedIR_fields_typed`, `decodeDecodedIR_fields_step`, `decodeDecodedIR_fields_run`.

Root precheck names match source byte-for-name. Author `theorems.json` 178 matches source. Lemma `exprDepth_pos` remains extra and is not in the 178.

Sealed R11 missing catalog names were `decodeParty_encodeParty` and `decodeRat_fromRat`. The R12 REPORT claim that R11 omitted `string_fromUTF8?_toUTF8` and `decodeParty_encodeParty` is inaccurate.

## What the new inverses actually prove

| Lemma | Extra hypotheses | Production connection |
|---|---|---|
| `jsonDepth_scalar` / `jsonDepthFuel_zero_of_scalar` | non-array/non-object | Scalars are 0. Does not prove fuel 100 equals parser depth on arrays/objects |
| `decodeStringList_ok` / `decodeLibraries_ok` | none | List `mapM` on helper JSON |
| `decodeEnvelope_orderedFields` / `decodeEnvelope_sortedFields` | `schema_version=1`, `source_map=[]`, `claimed_next_state=none` | Field-list `decodeEnvelope`, not `decodeBytes`. Runtime decoder accepts nonempty sorted `source_map` and `claimed_next_state some` |
| `envelopeSortedFields_no_commands` / `envelopeToJson_eq_mkObj_sortedFields` | none | Helper field list / `mkObj` equality |
| `decodeDecodedIR_fields_typed/step/run` | empty map, none next-state, payload canonicals, unused `raw : String` | Inlined lookalike of `decodeDecodedIR`'s `do` block over `envelopeSortedFields`. Does **not** mention `decodeDecodedIR` or `decodeBytes` |

`libraryRefToJson none` is `Json.str`. Production `encodeLibraryRef none` is `{"theorem":"T"}`. ProbeR12: both decode to `ok thm=T mod=none`. Helper inversion is not production equivalence.

`sourcePinToJson` always includes `compiler_record` and `audit_record` as null or string. `decodeSourcePin_sourcePinToJson` no longer requires both `none`. ProbeR12 helper keys for none and some are `audit_record,checker_candidate,compiler_record,git,lean_toolchain,mathlib_rev`. Production none is `{"git":"g",…,"compiler_record":null,"audit_record":null}`. The REPORT `sourcePinToJson` snippet that omits none-keys is not the source.

Two serializers remain: Encode.lean compact strings (`jsonObj`) used by `encodeModule`, and Correspondence.lean `Lean.Json.mkObj` used by the proofs.

## Remaining mathematical chain

1. `EncodeDecodeRoundtripStatement` is still  
   `∀ (ir : DecodedIR), StructurallyAdmissibleIR ir → decodeBytes (encodeModule ir) = .ok ir`  
   as `def Prop`. `decode_encode_roundtrip_of_decode` only rewrites an already-successful `decodeBytes`.
2. Bridge helper JSON to production decode: prove `decodeDecodedIR (envelopeToJson …) raw`, then `decodeBytes (encodeModule ir)`. Do not credit the lookalike `do` expression as that bridge.
3. Drop or justify `source_map=[]` / `claimed_next_state=none`. `CanonicalIR` requires `SourceMapSorted` and `ClaimedNextStateCanonical`, not emptiness. ProbeR12: `decodeEnvelope` returns `ok sm=1` and `ok cns=some`.
4. Production `encodeLibraryRef` object inverse, not the helper string.
5. Fuel adequacy for `jsonDepthFuel 100` versus parser container depth; scalar lemmas are not that theorem.

## Independent measurements (ProbeR12, child compiler exit 0)

- Scalars: `jsonDepth` of str/num/null/bool = **0**. `nestJson 63` = 63 (`≤64` true). `nestJson 64` = 64 (`≤64` true). `nestJson 65` = 65.
- Guard AST 58 (`wrapNow 57`): encode nest **64**, `decodeBytes` **ok-eq**, helper `jsonDepth` **64**, `≤64` true. Production `parseCanonicalJson` of those bytes `depth=64 arr=32`.
- Witness: helper depth **6**, encode nest **6**.
- Fuel: `jsonDepthFuel 64 (nestJson 65) = 64` (undercount). `jsonDepthFuel 100 (nestJson 101) = 100` (truncates). Production fuels in source: **100**.
- Array 4095/4096: scan/parse ok, decode/check malformed `schemaVersion`. Array 4097: scan ok, parse/decode `resourceLimit max_array_length`, check `blocked:max_array_length`.
- Nest 63/64: scan/parse ok (jsonDepth 63/64), decode/check malformed. Nest 65: scan/parse/decode `resourceLimit maxDepth`, check `blocked:maxDepth`. Public failure class preserved. Scanner still admits 4097.
- Runtime: `decodeDecodedIR (decodedIRToJson canonicalWitnessIR)` is `ok-eq` on that one witness. Bounded execution, not the missing bridge theorem.

`lean4-skills-check-axioms-inline` on Correspondence reported 267 declarations, standard axioms only. That is not the 178-name inventory. Exact-name credit is `ProbeAxioms.lean`.

## Runner sentinels (private copy of runner SHA256 `e20eb591…`; no historical mutation)

| Sentinel | Exit | Meaning |
|---|---|---|
| missing `--out` | 2 | argparse required; stderr SHA256 `ef3c4a1cbf89fdcbc80c5fe4e18f8ddf1a9fef80d29a391a4accf3760129b334` matches root |
| existing nonempty | 2 | refused; marker bytes unchanged |
| empty existing dir | 1 | **guard passed**; failed later opening fixtures |
| fresh missing path | 1 | guard passed; directory not created (fixtures open before `mkdir`) |
| absolute symlink to nonempty | 2 | refused (`exists` then `is_symlink`) |
| relative symlink to nonempty | 2 | refused as **resolved target** `…/nonempty`, not as symlink |
| dangling abs/rel symlink | 1 | **guard bypassed** (`exists()` false); fixtures FileNotFoundError |
| absolute symlink to empty dir | 2 | refused as symlink |

The REPORT snippet `if out_dir.is_symlink() or (out_dir.exists() and any(out_dir.iterdir()))` is not the source. Actual: relative `.resolve()` first; then `if out_dir.exists():` then symlink/not-dir/nonempty. Blanket symlink refusal is not established. F01 full fixture path was not rerun; guard admission of a missing path is the measured fresh-path fact. No 54/99/16 campaign in this review.

Author `fixture-results.json` records 54/54 and scenarios 99 with 1 open P20. Count that as bounded captured execution with the author's limitation, not universal proof. F13 host/overlay/IR oracle and other final gates remain separate and open.

## Findings

1. **Whole-codec obligation open.** `EncodeDecodeRoundtripStatement` is still `def Prop`. Helper inverses and the lookalike `decodeDecodedIR_fields_*` do not discharge it.
2. **Lookalike is not `decodeDecodedIR`.** Typed/step/run field theorems copy a `do` block over `envelopeSortedFields`. `#check` prints that block. No theorem states `decodeDecodedIR (envelopeToJson …) = .ok`.
3. **Envelope domain restrictions are not the full decoder/CanonicalIR domain.** Empty `source_map` and `claimed_next_state none` are proof hypotheses, not decoder requirements.
4. **`libraryRefToJson none` string versus production object** remains. Both decode; production connection is unproved.
5. **AST58 depth metric now matches container 64 at runtime.** Fuel adequacy is unproved; fuel 64 undercounts 65. Grammar/refusal class for 4097/65 preserved.
6. **Report identity.** sourcePin snippet omitted-none versus actual null-or-string; R11 missing names misidentified; `jsonDepthFuel` snippet uses `map`/`isObj` not the source `foldl`/match; full fixtures rerun despite deferral.
7. **Runner `--out` required is real.** Symlink/dangling overclaim remains.

## Valid progress (not full acceptance)

- 178/178 `#print axioms`; 11 new lemmas compile; 0 sorry; standard axioms only.
- Scalar depth 0: AST58 helper/production depth 64 and `decodeBytes` ok-eq.
- `sourcePinToJson` includes both optional records; inverse is no longer both-none-only.
- Runner `--out` is mandatory; nonempty/historical-style overwrite refused on sentinels.

Historical 54-fixture / 99-scenario output is not treated as a universal proof.
