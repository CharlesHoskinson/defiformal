# P19 R10 general codec proof review (closeout)

**Mark:** `GENERAL_CODEC_COMPONENT_REVIEW_ONLY_FULL_P19_OPEN`  
**Disposition:** `CHANGES_REQUIRED`  
**This is not full P19 acceptance and does not close any task.**

Requested model: `grok-4.6` effort high. Returned model identity is for root `modelUsage`; this report does not invent one.

This closeout continues session `01a08acb-1748-7ff2-986e-cf06a229462b`. It is not a fresh review. The first process stopped at 25 turns (`native_process_exit` 1, `cancelled_at_max25_turns`) after parent `REVIEW.md` / `verdict.json` and after rebuild plus ProbeAxioms / ProbeR10, and before `commands.json` / `findings.json` / `MANIFEST.json`. Root sealed that work as `attempt1-work.tar.gz` SHA256 `ac63bc3b207d768ad50188bcee54f2c5e0325cbeaa94566e36717ea4e15397e6`. Parent reports, probes, and logs are immutable. This directory only adds closeout artifacts.

Frozen candidate: AGY R10 archive SHA256 `6b4b06bb5854f979032746f6a30fcbddd572dd95085d317fc0b4482df58d74ca` (3447 files). Author reports `PARTIAL_PROOF_WORK`. Root R10 precheck already required changes on depth fidelity and recorded the public-resource classification bug. AGY R11 is out of scope.

Compiler: Lean `4.33.0-rc2` commit `d8b18978322de05a8f3dba51ef03cf5461676c17` via pinned `lake` / `lean` in `private-lean/`. `bin/lean` SHA256 `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`.

Private rebuild: `lake build +DefiKernel.Certificates.CanonicalJson +DefiKernel.Certificates.Encode +DefiKernel.Certificates.Decode +DefiKernel.Certificates.Correspondence`. Child compiler and wrapper echo both 0. Lake printed `Build completed successfully (932 jobs).` Runtime and axiom probes import those private oleans. Olean hashes were not captured; they are absent, not inferred.

Credit: only commands with `child_compiler_exit` 0 and no Lean `error:` line. There is no failed Lean probe in this audit. Native process exit 1 is session cancellation.

Parent initial REVIEW/verdict said axiom counts and rebuild were pending. Those are now the sealed probe logs, not still pending.

## Answer

R10 does not close general production codec or whole-document resource-domain obligations.

1. Named theorem count is CanonicalJson 15 + Correspondence 135 = **150**, not author 148. ProbeAxioms (`child_compiler_exit` 0) printed axioms on all 150 names; standard axioms only; three theorems depend on none; `string_fromUTF8?_toUTF8` retains the question mark. `theorems.json` lists 148 and omits `decodeParty_encodeParty` and `decodeRat_fromRat`. REPORT's 138 Correspondence / 10 CanonicalJson split is wrong.

2. New general work is real helper progress: arbitrary reduced rational inversion (`decodeRat_ratToJson`, `decodeRat_fromRat`), packed-value inversion through `packedValueFullToJson` (`decodePackedValue_canonical`), fuelled expression inversion (`decodeExprFuel_exprToJson`, `decodeExpr_exprToJson` under `ExprCanonical` and AST depth ≤ 64), container `*ToJson` inversions including `decodeTemplate_templateToJson` and `decodeRegistry_registryToJson` under uniqueness hypotheses, and tokenizer/parser lemmas `tokenizeFuel_string` / `parseTokens_*`. Those invert Lean.Json helpers or token lists. They are not `encodeModule` / `decodeBytes` proofs.

3. `EncodeDecodeRoundtripStatement` remains `def Prop`. Prior-decode lemmas `decodeBytes_encode_canonical` and `decode_encode_roundtrip_of_decode` assume `decodeBytes = .ok`. That is not the universal IR theorem.

4. `ExprDepthBounded` is still `exprMaxStackDepth e ≤ 52 ∧ exprDepth e ≤ 55`. REPORT's claim that the old 55 cap was eliminated is false. ProbeR10: a now-unary guard of AST/stack 53–58 encodes at document JSON depth 59–64 and `decodeBytes` returns `ok-eq`. The 52 cap excludes those documents. Outer framing on the typed-execute guard path is 6, not REPORT's 10.

5. `exprMaxStackDepth` is not exact `encodeExpr` nesting. Balance is claimed 3, measured 4. `unary`/`.neg` and `binary`/`.add` around `.now` are claimed 2, measured 3. REPORT's displayed leaf definition (all 1) disagrees with source (2 or 3 for several leaves). There is no whole-document depth equivalence.

6. Nested collection predicates were added (`OperationInterfaceLengthBounds`, `ComponentLengthBounds`, `ConfigLengthBounds`, `ClaimedNextStateLengthBounds`). This review does not reassert the R9 omitted-array finding as a current source hole. Predicate text is not a kernel proof of parser 4096, and 4097 catalog campaigns were not repeated.

7. Public resource classification is unchanged: parser `resourceLimit max_array_length` on a 4097-element array becomes `decodeBytes` `notJsonObject` and `checkBytes` `malformed`. Grammar requires `blocked`. Scanner admits 4097; the whole decoder still refuses. SupportedIR membership was not required.

Historical 54-fixture / 99-scenario files are not fresh evidence. Known F13 null/host/overlay holes remain historical.

## 1. Named theorems and meaning

Source `^theorem` count: 15 CanonicalJson + 135 Correspondence = 150. `exprDepth_pos` is a `lemma`, not a theorem. `EncodeDecodeRoundtripStatement` and `DecodeEncodeCanonicalBytesStatement` are `def Prop`.

ProbeAxioms imported Correspondence after the private rebuild and `#print axioms` every source theorem name, including the `?` in `string_fromUTF8?_toUTF8`. Empty axiom lists (must count): `rational_decode_canonical`, `rat_fromRat_num_den`, `rational_roundtrip`. Remaining printed axioms are subsets of `{propext, Classical.choice, Quot.sound}`. No `sorry`, custom axiom, or `native_decide` appeared in that print.

Author `theorems.json` 148 ≠ 150. Missing names: `decodeParty_encodeParty`, `decodeRat_fromRat`. REPORT 138 Correspondence is a third number. results.json `theorems_count` 148 is the same undercount as `theorems.json`, not an independent 138.

**What the new theorems mean.**

- Rationals: `decodeRat_fromRat` / `decodeRat_ratToJson` invert `ratToJson` for reduced ℚ / `RatEnc`. They do not invert `encodeRat` UTF-8.
- Packed values: `decodePackedValue_canonical` inverts `packedValueFullToJson` under `PackedValueCanonical`. `packedValueToJson` still maps bool to `Json.bool`. Production `encodePackedValue` emits `{unit,value}`.
- Expressions: `decodeExprFuel_exprToJson` is well-founded in fuel on `ExprEnc.depth`, assuming `ExprCanonical`. `decodeExpr_exprToJson` instantiates fuel 64. Production `decodeExpr` also uses fuel 64. The JSON tree is `exprToJson`, not `encodeExpr` bytes. AST depth 64 is not JSON depth 64.
- Registry: `decodeRegistry_registryToJson` needs `RegistryCanonical` (Nodup ids + `TemplateCanonical`). Duplicate ids are grammar `uniqueness.registry`; the Nodup hypothesis is the successful-decode side, not an extra exclusion of valid unique registries. `nodup_eraseDups_length` is a list lemma used there.
- Source pin: `decodeSourcePin_sourcePinToJson` requires `compiler_record = none` and `audit_record = none`. `sourcePinToJson` omits those keys. Production `encodeSourcePin` always emits them. That helper is disconnected from the production encoder.
- State cells: `decodeStateCell_stateCellToJson` requires nonnegative reduced amounts. Grammar already refuses `stateNonneg`.
- Tokenizer: `tokenizeFuel_string` is an inductive step on escaped character lists. `parseTokens_str/num/bool/null` invert singleton token lists. There is no theorem that `parseCanonicalJson` of `encodeModule` bytes recovers the IR.

No `componentToJson` inversion exists. Production `encodeComponent` / `decodeComponent` remain unconnected at the helper layer.

`decode_error_resource_limit` says `decodeBytes = error (resourceLimit lim)` implies `checkBytes = codec (blocked lim)`. That theorem is true of Check's match. It does not apply when `decodeBytes` has already rewritten a parser resource error to `notJsonObject`.

## 2. Depth 52/55 and constructor shape

`TemplateDepthBounded` now bounds guard, every `deltas.amount`, and every `supplyDeltas.amount`. That repairs the R9 guard-only omission at the predicate-text level.

The bound itself is still `exprMaxStackDepth ≤ 52 ∧ exprDepth ≤ 55`. ProbeR10 production outcomes:

| wrapNow n | AST | stack | stack≤52 | depth≤55 | expr nest | document nest | decodeBytes |
|---|---:|---:|---|---|---:|---:|---|
| 51 | 52 | 52 | true | true | 52 | 58 | ok-eq |
| 52 | 53 | 53 | false | true | 53 | 59 | ok-eq |
| 55 | 56 | 56 | false | false | 56 | 62 | ok-eq |
| 57 | 58 | 58 | false | false | 58 | 64 | ok-eq |

Witness document nest is 6. Guard document nest equals 6 + stack for now-unary chains. REPORT's "10 outer + 52 ≤ 62" is not the typed-execute guard path.

AST 53–58 as guard is production-admitted and excluded by `SupportedIR`'s 52 cap. That is domain shrinking. Root already named depths 56/58. This audit measured 53 as the first excluded admitted case.

Constructor accuracy, ProbeR10 `encodeNest` versus `exprMaxStackDepth`:

- Match: `now`, bool/numeric lit, `arg`, `timestamp`, `observe`, `unary not now`, `binary and now now`.
- Miss: `balance` 3 vs 4; `unary neg now` 2 vs 3; `binary add now now` 2 vs 3.

The measure ignores nested `op` objects and the extra `partyRef` object under `balance`. It is not a proof that stack ≤ 52 implies JSON depth ≤ 64, and it can undercount.

Whole-document depth is not characterized. Envelope/payload/registry/template framing is counted only by the runtime nestMax of `encodeModule`, not by a kernel relation.

## 3. Collections

R10 source adds explicit 4096 bounds on operation inputs/outputs, component `privateCells`/`exports`/`imports`/`operations`, config catalog/registry/domainAdmin, and claimed-next-state capability entries (cells remain 32). Those were the R9 omitted families. This closeout does not treat them as still missing from the predicate text. It does not claim a kernel proof of parser 4096 over `SupportedIR`, and it did not rerun 4097 catalog probes.

## 4. Public resource classification

`Decode.lean` `decodeBytes`: after `scanLexical`, `parseCanonicalJson` errors all become `notJsonObject`. `Check.lean` `checkBytes`: `resourceLimit` is `blocked`; any other decode error is `malformed`.

ProbeR10 raw `{"a":[0,...]}` with 4097 zeros (8201 bytes):

- `scanLexical`: ok
- `parseCanonicalJson`: `resourceLimit max_array_length`
- `decodeBytes`: `notJsonObject`
- `checkBytes`: `malformed:notJsonObject`

Grammar `resource_limits.exceeded` is `CodecResult.blocked`. The public classification is malformed. The document is still refused. This is source-confirmed plus a raw-byte runtime, not a SupportedIR membership test.

## 5. Report identity and historical evidence

Frozen Schema/Encode/Decode/CanonicalJson/Correspondence/Check hashes match REPORT and `source-manifest.json`. `source-manifest.json` records Lean version string `4.33.1` against the rc2 executable path. Author `commands.json` cwd is `/home/charl/defiformal-wt-p19-certificates-grok-opus-20260909/lean`. Header auditor `grok-4.6-high` is not this review's observed identity.

54/54 fixtures and 99 scenarios are copied historical files. They retain known F13 null/host/overlay holes. They were not re-run. They do not accept P19.

Author `compiler-axiom-audit.log` campaign counts (1266/420/287) were not independently replayed here. The independent axiom evidence is ProbeAxioms over the 150 named CanonicalJson/Correspondence theorems.

## Missing universal production obligations

Still open, and not discharged by the 150 helpers:

- Byte-level `∀ ir, StructurallyAdmissibleIR ir → decodeBytes (encodeModule ir) = .ok ir`
- Tokenization of compact production UTF-8 through `tokenize` / `parseCanonicalJson` into the same JSON the AST helpers invert
- JSON-depth 64 as a proved function of constructor shape plus actual envelope framing, without an extra 52/55 cut
- Resource-limit classification `blocked` for parser `maxDepth` / `max_array_length` / `tokenizeFuel` errors that currently become `notJsonObject`
- Component/request/invocation/envelope/world/DecodedIR production inversions
- Optional `compiler_record` / `audit_record` on source pins through the production encoder

UTC timestamps for individual lake/lean commands are absent from `.meta` files. Olean hashes are absent. `source-hash-check.json` was not written.

Root independently verifies and adjudicates. Full P19 remains open.
