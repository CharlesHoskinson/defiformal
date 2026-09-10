# P19 R22 independent stuck review — module-map scratch stall

**Scope:** Frozen R22 scratch proofs. `--mode=stuck`. Lean4-skills profile `scripts_only` + `review_only` from the brief. Requested absolute `lean4-skills-preflight --codex` was **not executed**. Layer-2 mathlib context helper was **not executed**. Layer-2 findings stay advisory and are omitted.

**Role:** Independent auditor. Continuation of session `01a08d18-60dd-7c12-ae42-5c8d622712e5`. Original 20-turn cap left no reports. This closeout writes the five required files. Sole reviewer. Live AGY R23 was not inspected.

**Requested alias:** `grok-4.6` high. **Original terminal reported model:** `grok-4.6-build` (`../original-terminal/process.json`). **This closeout returned model:** unknown until this closeout's terminal metadata is valid.

**Candidate:** Frozen archive `230d7c586699350f31d3f49df149a4186986f5e6ceb43418e46531269596adc2`. Root stated 3664 frozen files, 3601 prior files unchanged, 63 new (59 scratch Lean + 4 IN_PROGRESS placeholders). Production source unchanged from independently reviewed R21. This closeout did not re-hash the tarball.

**Sandbox (immutable):** `/home/charl/.cache/defiformal-program/program-execution-20260908/p19-module-map-stuck-grok-r1-sandbox`

**Parent output (immutable except this `closeout/` write):** `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-module-map-stuck-grok-r1`

**Original-terminal snapshot:** `../original-terminal/` with root seal. Immutable.

**Compiler commands this review:** none. No lake/lean probe was launched. Root's three scratch runs are root evidence, not this reviewer's compiler credit.

**R21 generic serialized TreeJson text inverse** is historical review (`USABLE` for `tokenize_tree` / `parseCanonicalJson_tree`). It is not this R22 review and does not accept full P19.

**Root has not yet adjudicated this final review.**

## Verdict

| Scope | Classification |
|---|---|
| R22 production module/envelope/typed/step/run TreeJson map | **not delivered** (production bytes unchanged from R21) |
| R22 scratch proofs as production progress | **CHANGES_REQUIRED** |
| Full P19 acceptance | **CHANGES_REQUIRED** |

Author `agy-r22-proof/commands.json` is `[]`. Author `MANIFEST.json` `files` is `[]`. Author `REPORT.md` and `verdict.json` remain `IN_PROGRESS`. Native author SUCCESS/exit 0 is launch/wait, not compiler evidence.

Root recovered three exact scratch files and compiled them. All three Lean processes exited 1. Header counts after the unknownIdentifier correction: `test_typed_roundtrip` 12, `test_all_structures` 4, `test_template_fix` 4.

## Stuck Review — R22 scratch module map

**Primary blocker class:** typeclass / coercion / elaboration (capabilityIds `List Nat` → `TreeJson.num : Int → TreeJson`)

**Top 3 blockers:**

1. **Request/Invocation `capabilityIds` elaborate to `List.flatMap` of singleton `Nat→Int` coercions, not a direct `List.map`.** Root goals show `List.flatMap (fun a => [↑a]) r.capabilityIds` / `inv.capabilityIds`. Production encode is `capabilityIds.map toString` (`Encode.lean` 181, 232). Length hypothesis `ids.length ≤ 4096` does not unify with the coerced list. Explicit `map` plus a length lemma is required.

2. **`Json.mkObj` / `JsonNumber.fromNat` defeat `rfl` on `toJson`.** `TreeJson.toJson` of `.obj` calls `Lean.Json.mkObj` (`CanonicalJson.lean` 884). `mkObj` is `obj (Std.TreeMap.Raw.ofList o)` (`Lean/Data/Json/Basic.lean` 225–226). Production `*ToJson` lists are often already sorted. Scratch `TreeJson.obj` lists follow encode/declaration order. This review did **not** prove `ofList` of two permutations are Lean-equal trees. Do not treat JSON semantic order-insensitivity as `Json` equality. Separately, leftover template goals compare `Json.num { mantissa := ↑n, exponent := 0 }` with `Json.num (JsonNumber.fromNat n)`. `fromNat` is `⟨n, 0⟩` (`Basic.lean` 32), not the `normalize` function used by `lt` (`Basic.lean` 48–61).

3. **`stepToTreeJson_encode` is stated for every `StepEnc`, including `.unsupported tag`.** Production `encodeStep` interpolates `"\"" ++ tag ++ "\""` (`Encode.lean` 242). `TreeJson.str` encodes with `escapeTreeString` (`CanonicalJson.lean` 921–931). Existing admission already excludes unsupported constructors (`StepCanonical`, `SupportedIR`, `CanonicalIR`). `decodeStep_stepToJson` already takes `h_can : StepCanonical s` and uses `contradiction` on unsupported (`Correspondence.lean` 3094–3114). Source-level mismatch. No diagnostic snippet was executed. Not a supported-input codec bug.

**Evidence:**

- searches — native `grep` of frozen Encode/Correspondence/CanonicalJson, pinned `Lean/Data/Json/Basic.lean`, `Init/Data/List/Lemmas.lean`, `Std/Data/TreeMap/Raw/Lemmas.lean` (toolCallIds in `commands.json`)
- returned lemmas — `List.map_inj_left`, `List.map_eq_flatMap`, `List.length_map`, `List.length_flatMap`, `List.flatMap_singleton'`, `List.map_flatMap`, `Std.TreeMap.Raw.ofList_nil`, `ofList_singleton`, `ofList_cons`, `ofList_eq_insertMany_empty`, `ofList_equiv_foldl` (`~m`, not `=`), production `encode_obj_eq_jsonObj`, `encode_arr_eq_jsonArr`, `escapeTreeString_eq_escapeJsonString`
- attempts — none by this reviewer. Root Lean exit 1 on the three named probes. Original session `ls` of output/toolchain paths only (`call-ee3c1e08-8a4f-48a3-8a13-c0d98da85852-60`). No lake/lean argv.

**Flag:** `stepToTreeJson_encode` on arbitrary unsupported tags may be false. Confirmed by source comparison only.

**Recommended next action:** Repair scratch representation lemmas with explicit Nat→Int maps, `StepCanonical` (already implied by admission) on step encode, and `toJson` proofs that do not assume `mkObj` list-order `rfl`. Move compiling maps into production. Do not unfold whole `TreeJson.encode` to close template goals.

**Why first:** capabilityIds coercion blocks Request/Invocation encode, validity, and every consumer. The unsupported statement is a contract-shape error, not a missing tactic.

**next_action:** `repair` for named-identifier/syntax/coercion issues. `redraft` for the unsupported-tag encode statement.

## Confirmed causes (three files)

Root streams: sandbox `root-context/p19-r22-root-probe-recovery/` plus `p19-r22-root-scope/scope.json`. Original root summary missed two `error(lean.unknownIdentifier)` headers on `test_template_fix`. Correct counts are 12 / 4 / 4. Raw stdout hashes in root `command.json` files.

### A. `test_typed_roundtrip.lean` — 12 errors (root)

Scratch `requestToTreeJson` (`root-context/.../test_typed_roundtrip.lean` 483–490) maps `capabilityIds` with `TreeJson.num (x : Int)`. `TreeJson.num` takes `Int` (`CanonicalJson.lean` 870). Root goals after elaboration:

```
List.map (fun x => (TreeJson.num x).toJson)
  (List.flatMap (fun a => [↑a]) r.capabilityIds)
```

versus production `List.map natToJson r.capabilityIds` (`Correspondence.lean` 432, 440). Encode side matches `List.flatMap` versus `List.map toString` (`Encode.lean` 181). `simp` / `rewrite` then miss the `do`/`flatMap` form (root lines 518–519). Validity (`line` 537) applies `valid_arr_map` at `h_caps : r.capabilityIds.length ≤ 4096` while the mapped list is the coerced `flatMap` list.

`invocationToTreeJson` in `test_all_structures.lean` 399 uses `inv.capabilityIds.map TreeJson.num` without an explicit lambda. Same `flatMap` goal.

**Library names inspected:** `List.map_eq_flatMap` (`Init/Data/List/Lemmas.lean` 2177), `List.length_map` (1081), `List.length_flatMap` (2125), `List.flatMap_singleton'` (2153). Untested repair: write `ids.map (fun id : Nat => TreeJson.num (Int.ofNat id))` and rewrite the coerced form with `map_eq_flatMap`. Do not keep `List.map TreeJson.num` on `List Nat`.

`requestToJson` field list is already sorted (`Correspondence.lean` 437–444): `arguments`, `capabilityIds`, `claimedActor`, `operation`, `parties`. Scratch `TreeJson.obj` uses encode order (`operation`, `parties`, `arguments`, `capabilityIds`, `claimedActor`). Root `rfl` at line 502 compares those two `mkObj` lists. `Json` objects are `obj : TreeMap.Raw String Json` (`Basic.lean` 186). `BEq` on objects walks keys (`beq'`, `Basic.lean` 199–206). Structural `=` is the Raw tree. `ofList_equiv_foldl` is map equivalence `~m`, not `=`. **Unfinished:** whether two `ofList` permutations of unique keys are `=`. Do not claim they are equal from JSON semantics.

`JsonNumber.fromNat` (`Basic.lean` 32) is `@[expose] protected def fromNat (n : Nat) : JsonNumber := ⟨n, 0⟩`. Exponent is `Nat`. The `normalize` function is separate and used by `lt`. Root template leftover is constructor versus `fromNat`. Prospective untested tactic: `dsimp [JsonNumber.fromNat]` or `simp [JsonNumber.fromNat]`. Root error stream for `test_typed_roundtrip` starts at line 502. Scratch theorems `numToTreeJson_toJson_nat` / `numToTreeJson_encode_nat` at lines 6–7 are not in the 12 headers. This closeout did not compile them.

`typesEnumToTreeJson_toJson` (`test_typed_roundtrip.lean` 585–595) uses `simp profile_map`. That is malformed syntax. Intended lemma from other proofs in the same file: `List.map_inj_left`. Errors: unsolved goals at 586 and 589, `unexpected identifier` at 590. Tactic/syntax mistake. The statement shape matches `typesEnumToJson` (`Correspondence.lean` 420–425) with the same declared key order.

`libraryRefToTreeJson_toJson` `rfl` fails (632–633). Production `libraryRefToJson` for `some m` lists `module` then `theorem` (`Correspondence.lean` 430). Scratch TreeJson lists `theorem` then `module` (624–627). Encode production lists `theorem` then `module` (`Encode.lean` 272–275), matching the scratch TreeJson order. Encode rewrite of `escapeTreeString` fails (642, 646) because the goal contains `(TreeJson.str _).encode`, not `escapeTreeString`. Prospective untested: unfold `TreeJson.encode` on `.str` or rewrite with `escapeTreeString_eq_escapeJsonString` after that unfold (`Correspondence.lean` 3995). Encode both sides escape. This is not the unsupported raw-quote case.

### B. `test_all_structures.lean` — 4 errors (root)

Same Invocation `capabilityIds` `flatMap` (414–415). Grant encode leftover (`line` 459): `(TreeJson.num ↑g.operation).encode` versus `toString g.operation` (`Encode.lean` 152). Prospective untested: reuse scratch `numToTreeJson_encode_nat` if it is available, or `TreeJson.encode` on `.num`.

Unsupported case (`line` 494): goal

```
jsonObj [("tag", (TreeJson.str tag).encode)]
  = jsonObj [("tag", "\"" ++ tag ++ "\"")]
```

`encodeStep .unsupported` is raw quote concatenation (`Encode.lean` 242). `TreeJson.encode (.str s) = escapeTreeString s` (`CanonicalJson.lean` 931). `escapeTreeString` uses `escapeChars` (`CanonicalJson.lean` 921–922), same helper as `escapeJsonString` (`Encode.lean` 9–10). `escapeTreeString_eq_escapeJsonString` is `rfl` (`Correspondence.lean` 3995–3996). For a tag that needs escaping, the two strings differ **by source**. No `#eval`/`decide` diagnostic was run. Label: source-level mismatch. Not an executed counterexample. Not a defect of supported encode.

Admission already false on unsupported:

- `StepCanonical | .unsupported _ => False` (`Correspondence.lean` 115–119)
- `SupportedIR` step/run branches (`Correspondence.lean` 907, 919)
- `CanonicalIR` uses `StepCanonical` (`Correspondence.lean` 946, 954)
- `StructurallyAdmissibleIR = SupportedIR ∧ CanonicalIR` (`Correspondence.lean` 962–963)

**Repair scope (untested, contract-preserving):** prove a representation lemma with `h : StepCanonical s` (derivable from admission). Cases `invoke` / `issue` / `revoke`. `contradiction` on unsupported. Same shape as `decodeStep_stepToJson`. Do not narrow `StructurallyAdmissibleIR`. Do not add decoder-success premises. Do not change public grammar, parser, or replacement codec. Do not assert the current scratch theorem for arbitrary tags.

### C. `test_template_fix.lean` — 4 errors (root)

`templateToTreeJson_toJson` (`line` 146): maps rewritten. Leftover `partyArity` `Json.num { mantissa := ↑t.partyArity, exponent := 0 }` versus `Json.num (JsonNumber.fromNat t.partyArity)`. Field order matches `templateToJson` (`Correspondence.lean` 327–338). This is the fromNat unfolding issue, not a permutation of keys.

Unknown identifiers (`lines` 172, 174): `cellDeltaToJson_encode`, `supplyDeltaToJson_encode`. Production string encoders are `encodeCellDelta` and `encodeSupplyDelta` (`Encode.lean` 112–116). Json mappers are `cellDeltaToJson` / `supplyDeltaToJson` (`Correspondence.lean` 319–324). Naming mistake.

`whnf` heartbeat 200000 at `line` 185 after `dsimp [TreeJson.encode]; rfl`. Do not raise heartbeats as a universal fix. Use existing structural lemmas: `encode_obj_eq_jsonObj` (`Correspondence.lean` 4034–4039), `encode_arr_eq_jsonArr` (4028–4031), scratch `encode_arr_map` if moved into production, and child `*ToTreeJson_encode` lemmas. Stop before unfolding the whole encoder.

## What is not claimed

- This review did not rebuild Correspondence or rerun the incomplete CanonicalJson inline axiom helper.
- This review did not rerun the 448-name inventory. R21 root adjudication remains historical (`448` named theorem/lemma, `415` standard, `33` none).
- This review did not run 54/99/16 or 7/21 campaigns.
- Author R22 has zero compiler/test command credit.
- Generic TreeJson text inverse remains the R21 scoped result. Full `encodeModule` / `decodeBytes` from unchanged `StructurallyAdmissibleIR` is still open, including envelope/module/typed/step/run maps, `scanLexical` admission, resource validity/depth composition, then overlay / decodedIR / host / campaign work.
- Preserve 1 MiB / depth 64 / array 4096 / full canonical strings, production field order, sourceMap sorting, and historical signatures/docstrings.

## Recommendations for AGY (author)

1. Replace `List.map TreeJson.num` on `List Nat` with an explicit `Int.ofNat` map. Prove length with `List.length_map`. Untested here.
2. Prove string encode (`TreeJson.encode = encode*`) along declaration order using `encode_obj_eq_jsonObj`. Do not use `rfl` on `Json.mkObj` of differently ordered lists. For `toJson`, either match the existing `*ToJson` list order or prove Raw-tree equality. The second proof is unfinished in this review.
3. If `fromNat` remains in goals, unfold `JsonNumber.fromNat`. Do not confuse it with `JsonNumber.normalize`.
4. Fix `simp profile_map` to `simp only [List.map_inj_left]`.
5. Name `encodeCellDelta` / `encodeSupplyDelta`. Do not invent `cellDeltaToJson_encode`.
6. Do not `dsimp [TreeJson.encode]` on template/module objects.
7. Scope step encode to `StepCanonical` (or an equivalent supported-constructor hypothesis implied by admission). Leave `StructurallyAdmissibleIR` unchanged.

## Lean4 hygiene (stuck, no golf)

Sorry/axiom scans were not rerun. Production Correspondence/CanonicalJson were not edited. Scratch files are evidence only. No `sorry` was required to classify the 12/4/4 root errors: they are compiler diagnostics.

## Review Complete

Stuck mode. No action-plan prompt. Author implements. Independent GPT/Opus check is outside this session.
