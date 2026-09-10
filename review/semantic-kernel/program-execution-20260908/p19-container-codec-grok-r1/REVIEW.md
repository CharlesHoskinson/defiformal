# P19 R11 container/payload codec proof review

**Mark:** `CONTAINER_CODEC_COMPONENT_REVIEW_ONLY_FULL_P19_OPEN`  
**Disposition:** `CHANGES_REQUIRED`  
**This is not full P19 acceptance and does not close any task.**

Requested model: `grok-4.6` effort high. Returned model identity is for root `modelUsage`; this report does not invent one.

Frozen candidate: AGY R11 archive SHA256 `9cb41eabb251c0f813a8fbc74e1b7fdc6eecb9c40d9d1851f7bb68ffd466adb6` (3455 files, root-verified). Author reports `PARTIAL_PROOF_WORK` and catalog **165**. Independent source count is **167** theorems (15 CanonicalJson + 152 Correspondence) plus lemma `exprDepth_pos`. AGY R12 is out of scope.

Compiler: Lean `4.33.0-rc2` commit `d8b18978322de05a8f3dba51ef03cf5461676c17`. Binary SHA256 `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`. Private copied build cache under this review directory. Frozen sandbox sources were not written.

**lean4-skills profile:** `scripts_only` + `review_only`. `lean4-skills-preflight --codex` exit 0 using literal `/home/charl/.codex/plugins/cache/lean4-skills/lean4/4.8.7/bin/lean4-skills-preflight`. No live LSP tools in this harness. File-level `lake env lean` used. Project context: `repository_kind=other-lean`, Layer-2 mathlib findings advisory.

## Verdict

Component theorems in CanonicalJson and Correspondence compile. Exact-name `#print axioms` on all **167** source theorems: standard Lean axioms only (`propext`, `Classical.choice`, `Quot.sound`); three rationals depend on no axioms; zero `sorry` in Encode/Decode/CanonicalJson/Correspondence. The 17 new container/payload lemmas are **helper `*ToJson` inverses**, not `encodeModule`/`decodeBytes`. `EncodeDecodeRoundtripStatement` remains `def Prop`.

Public parser resource classification is repaired for `decodeBytes` (array 4097 → `resourceLimit max_array_length`; nesting 65 → `resourceLimit maxDepth`). Whole-document `jsonDepth` counts scalars as 1, so guard AST 58 **decodes** (`ok-eq`) at production nest 64 while computed depth **65** fails `≤ 64`. Report fuels 256/65536 are **100** in source. Runner default `--out` still targets frozen `agy-r5`. Full P19 remains open.

## What the 17 lemmas actually prove

They invert Correspondence helper `*ToJson : … → Lean.Json` against Decode functions on that JSON, under extra hypotheses:

| Lemma | Extra hypotheses | Production connection |
|---|---|---|
| `decodeLibraryRef_libraryRefToJson` | none | Helper `none` is a JSON **string**; production `encodeLibraryRef` emits `{"theorem":…}` |
| `decodeNat_natToJson` / `decodeNatList_map_num` | none | Inline `JsonNumber.mantissa.toNat`, not `encodeModule` |
| `decodeState_stateToJson` | den≠0, gcd=1, num≥0, `eraseDups` uniqueness | Helper JSON, not byte encoder |
| `decodeRequest_requestToJson` | `RequestCanonical` | packed-value canonical arguments |
| `decodeOperationInterface_operationInterfaceToJson` / `decodeComponent_componentToJson` | none | empty lists admitted |
| `decodeConfig_configToJson` | `RegistryCanonical` only | catalog/store uniqueness not required here |
| `decodeWorld_worldToJson` | state rational+uniqueness | `decodeStore` does **not** check `Nodup`; theorem does not require `StoreCanonical` |
| `decodeBoundary_boundaryToJson` | `BoundaryCanonical` | environment packed values |
| `decodeInputSource_inputSourceToJson` | `InputSourceCanonical` | literals only |
| `decodeInvocation_invocationToJson` / `decodeStep_stepToJson` | invocation/step canonical | `.unsupported` is `False` (`contradiction`), not inverted |
| `decodeOutputObservation_outputObservationToJson` | packed-value canonical | helper JSON |
| typed/step/run payload inverses | registry/env/request/history/step/state hypotheses | compose the helpers; still not `decodeBytes (encodeModule ir)` |

`sourcePinToJson` omits `compiler_record`/`audit_record`. `decodeSourcePin_sourcePinToJson` requires both `none`. Production `encodeSourcePin` always emits those keys (`null` or string). Probe: helper of a `some` pin still decodes as `none`/`none`.

`decodedIRToJson` maps `.audit`/`.codec` to `Json.null`. `SupportedIR` is `False` on those modes. Null helpers for excluded modes are not themselves a scoped-execution defect. Full envelope/sourcePin byte connection remains open.

Two serializers exist: Encode.lean compact strings (`jsonObj`) used by `encodeModule`, and Correspondence.lean `Lean.Json.mkObj` used by the proofs. Helper inversion is not the whole-IR byte theorem.

## Independent measurements (ProbeR11, child compiler exit 0)

- Scalars: `jsonDepth` of str/num/null/bool = **1**. `nestJson 63` = 64 (`≤64` true). `nestJson 64` = 65 (`≤64` false).
- Guard AST 58 (`wrapNow 57`): encode nest **64**, `decodeBytes` **ok-eq**, helper `jsonDepth` **65**, `≤64` false. Production `parseCanonicalJson` of those bytes also `depth=65`.
- Witness: helper depth **7**, encode nest **6** (same scalar extra).
- Array 4095/4096: scan ok, parse ok, decode/check **malformed schemaVersion** (parser admitted; not an explicit success class).
- Array 4097: scan **ok**, parse/decode **`resourceLimit max_array_length`**, check **`blocked:max_array_length`**. Scanner still admits 4097; parser refuses; `decodeBytes` now preserves the parser error.
- Nest 63/64: scan/parse ok (jsonDepth 64/65), decode/check malformed. Nest 65: scan/parse/decode `resourceLimit maxDepth`, check `blocked:maxDepth`.
- `jsonDepth` / `jsonMaxArrayLength` fuels in source: **100**, not REPORT 256/65536.

`lean4-skills-check-axioms-inline` without `lake env` failed (`unknown module prefix 'DefiKernel'`). That helper run has **zero credit**. Exact-name inventory is `ProbeAxioms.lean` via `lake env lean`.

## Findings

1. **Whole-codec obligation open.** `EncodeDecodeRoundtripStatement` is still `def Prop`. Do not credit helper inversion as the byte/IR theorem.
2. **Depth metric excludes decode-admitted IR.** `WholeDocumentDepthBounded` uses `jsonDepth (decodedIRToJson ir) ≤ 64` with scalars contributing 1. Guard AST 58 is a real `decodeBytes` success at nest 64 whose computed depth is 65.
3. **sourcePin helper ≠ production encoder.** Omitted keys; inverse restricted to both-none. Execution-only `SupportedIR` makes audit/codec nulls non-defects by themselves.
4. **Resource classification repaired, limits remain.** Public blocked class now holds for parser 4097/65. In-limit Tests classify as malformed. Scanner/parser 4097 disagreement remains. `maxBytes` still in `scanLexical`.
5. **Report/catalog identity.** Fuels 100 vs 256/65536. Catalog 165 misses `decodeParty_encodeParty` and `decodeRat_fromRat` (same two names as R10).
6. **Runner `--out` default** is still `review/semantic-kernel/certificates/p19/implementation/agy-r5` with `mkdir exist_ok`. No sealed-path rejection. Root restored the three overwritten R5 files before freeze. This review did not mutate historical evidence and did not rerun the 54/99 campaign. F13 expectedIR-null/host/overlay remains open and outside this bounded review.

## Valid progress (not full acceptance)

- 17 named helper inverses compile; 167/167 `#print axioms`; 0 sorry; standard axioms only.
- `decodeBytes` preserves `parseCanonicalJson` `.resourceLimit`; check maps it to `.codec (.blocked …)`.
- Whole-document predicates exist and replaced the R10 `exprMaxStackDepth ≤ 52 ∧ exprDepth ≤ 55` conjuncts. They are not yet a faithful container-only correspondence with the parser cap.

Historical 54-fixture / 99-scenario output is not treated as a universal proof.
