# P19 codec diagnostic (closeout)

**The current `EncodeDecodeRoundtripStatement` and `DecodeEncodeCanonicalBytesStatement` do not hold for the predicates declared next to them.** This is a diagnostic, not P19/P20/task acceptance. Scope: `DIAGNOSTIC_ONLY_NO_ACCEPTANCE`. A declared `Prop` is not a proved theorem. `¬ Statement` was not kernel-proved; the evidence is compiled `#eval` of the imported `encodeModule`/`decodeBytes` plus transparent reduction of `SupportedIR`/`CanonicalIR`.

Frozen snapshot SHA-256 `e5d7f4b0df2b7ec56b06d6ec68b485febdcecb9c086d7aa639892caa4e0ed5d1`. Closeout re-hash: 428/428 `inputs.json` files unchanged, including all nine candidate Certificate modules. Sandbox: `/home/charl/.cache/defiformal-program/program-execution-20260908/p19-codec-diagnostic-grok-r1-sandbox`. Lean via `lake env`: `4.33.0-rc2` commit `d8b18978322de05a8f3dba51ef03cf5461676c17`. Requested model `grok-4.6` high; attempt-1 session `01a089ac-8633-77e0-8703-f9997ace8531` (pid 975324) cancelled at max 24 turns; this closeout resumes that session (dispatch pid 1007235). Independent GPT/Opus review of a later complete candidate remains required.

## Answer

`encodeModule` is a stub. For every `.execution` and `.audit` value it emits the two bytes `{}`. `decodeBytes` of `{}` is `.error .schemaVersion`. Therefore encode-then-decode never recovers a typed/step/run/audit IR. Decode-then-encode of a document that actually parsed as typed or audit emits `{}`, which is not the original bytes.

The smallest compiled witnesses, all from retained `probes/DecodeOnly.lean` run `decode-only-r2` (exit 0, 1.476s, stdout SHA-256 `3fe21464ae26bb1d3fa677137eb3d57a183bd06903198f887a2dabcf748c1109`):

| Witness | Input (imported encoder/decoder) | Output |
|---|---|---|
| empty codec IR | `emptyCodec := .codec {}` then `encodeModule` / `decodeBytes` | encode UTF-8 empty size 0; decode `.error emptyDocument`; `emptyCodec.neq true` |
| default typed/step/run/audit IR | `.execution (.typed default default)` and the three siblings | encode `{}` size 2; decode `.error schemaVersion`; `emptyTyped.neq` / `emptyAudit.neq true` |
| valid audit JSON | compact `mode=audit` object in `auditJson` | decode `ok:audit`; `encodeAfter equal=false`; encode `{}`; re-decode `schemaVersion` |
| valid typed JSON | compact `mode=typed-execute` with empty payload in `typedJson` | decode `ok:typed cells=0`; `encodeAfter equal=false`; encode `{}`; re-decode `schemaVersion` |

These refute the **current** statements:

```lean
-- Correspondence.lean:42-47
def EncodeDecodeRoundtripStatement : Prop :=
  ∀ (ir : DecodedIR), SupportedIR ir → CanonicalIR ir →
    decodeBytes (encodeModule ir) = .ok ir

def DecodeEncodeCanonicalBytesStatement : Prop :=
  ∀ raw ir, decodeBytes raw = .ok ir → CanonicalIR ir → encodeModule ir = raw
```

because the current predicates make the premises hold:

```lean
-- Correspondence.lean:15-38
SupportedIR  | .audit _ => True | .codec _ => True
CanonicalIR  | .audit _ => True | .codec _ => True
-- typed/step/run: List.all on cells; empty cells ⇒ true = true
```

and the current encoder discards the IR:

```lean
-- Decode.lean:1256-1260
def encodeModule (ir : DecodedIR) : ByteArray :=
  match ir with
  | .codec doc => doc.rawText.toUTF8
  | .audit _ => "{}".toUTF8
  | .execution _ => "{}".toUTF8
```

`encodeModule` does not inspect payload, envelope, types table, or rationals. The required 4-party / 4-asset / 2-domain sequential Typed universe is therefore also unroundtrippable: the stub is independent of table size. Do not repair by shrinking that universe or by defining `SupportedIR` as “roundtrip holds”.

Proof status: **compiled counterexample of encoder/decoder behaviour**, not a kernel proof of `¬ EncodeDecodeRoundtripStatement`. `probes/RoundtripStatements.lean` exists (SHA-256 `0ec3b663e6c333b8bf89481536f498a0d3b354c711c442eeb1ffdac2fbdda1c1`) and was **not compiled** in attempt 1 or this closeout. `SupportedIR`/`CanonicalIR` were not `#eval decide`d; their codec/audit/`List.all []` reductions are source-transparent.

## What the compiled cases do and do not show

**Compiled, using imported `DefiKernel.Certificates.Decode`:**

1. T-roundtrip fails on Lean-constructed `.codec {}`, `.audit default`, and `.execution` defaults (`DecodeOnly.lean:24-35,62-66,78-80`).
2. T-canonical-bytes fails on raw `auditJson` and `typedJson` that `decodeBytes` accepted (`DecodeOnly.lean:37-44,69-74`): `equal=false`.
3. Codec identity encoder: `codecJson` and whitespace `wsCodecJson` decode and re-encode equal to the original raw (`DecodeOnly.lean:40-47,71-76`). That makes `DecodeEncodeCanonicalBytesStatement` hold *accidentally* on codec documents because `encodeModule` dumps `rawText` (`Decode.lean:1258`, `decodeDecodedIR` stores `raw` at `Decode.lean:1240-1241`). Extra whitespace is accepted (`wsCodecJson.decode ok`), so the grammar rule “extra whitespace is `DecodeFailure.noncanonicalWhitespace`” is not implemented. `scanLexical` (`Decode.lean:32-144`) never constructs `.noncanonicalWhitespace` (`Schema.lean:668`).
4. `reorderedRat` with keys `den` before `num` decoded `ok:typed cells=1` (`DecodeOnly.lean:49-50,77`). Encode-after was not printed for that case. Combined with `encodeModule` of every execution being `{}`, the inequality is the same stub, not a separate compiled encodeAfter line.

**Source-inspection, not compiled as failing `#eval`:**

- `decodeExpr` has no `timestamp`/`now` tags (`Decode.lean:433-483`) although `ExprEnc` and grammar list them (`Schema.lean:184-194`; `grammar.json` `expr_constructors_supported`).
- `ite` decoder fields are `cond`/`thenExpr`/`elseExpr` (`Decode.lean:431,475-481`); grammar canonical keys are `condition`/`yes`/`no` (`grammar.json` `canonical_nested_key_order.Expr`).
- `decodeEnvRead` has no `currentTime` (`Decode.lean:342-354`); `EnvReadEnc` includes it (`Schema.lean:155-162`).
- Audit decode drops payload: `.audit ⟨env, [], 1, [], none, none⟩` (`Decode.lean:1242-1243`).
- `checkBytes` maps every `decodeBytes` error, including `.resourceLimit`, to `.codec (.malformed e)` (`Check.lean:750-753`). Grammar requires exceeded limits to be blocked, not malformed (`grammar.json` `resource_limits.exceeded`).
- Registry/state-cell uniqueness and complete `|D|×|P|×|A|` table are not decode guards. `PackedValueEnc.valRat : ℚ` (`Schema.lean:100-104`) drops the canonical `num`/`den` pair after `decodeRat` (`Decode.lean:260-261`).

**Missing proofs (not counterexamples):**

- No theorem `encode_decode_roundtrip` / `decode_encode_canonical_bytes`.
- `Correspondence.lean:8-12` defers universal RC01/T-roundtrip to P20 while only declaring Props. That does not discharge P19 task 2.4.
- Finite fixture comments are not proofs.
- `decode_error_no_kernel` (`Correspondence.lean:50-54`) only rewrites `checkBytes`; it does not restore encode.

Failed compile attempt preserved: `logs/decode-only.json` exit 1 (2.46s) because `Decode.olean` did not yet exist. Successful module build: `logs/lake-build-decode.json` exit 0 (8.66s). Do not treat the failed first probe as a semantic counterexample.

## Required domain versus current predicates

Accepted `correspondence-theorems.json` `supported_ir_domain` is **DecodedExecution** on which decode succeeds, types enumerations are nonempty finite, the state table is complete `|domains|×|parties|×|assets|` nonnegative cells in declaration order, registry ids unique, and step tags are `invoke|issue|revoke`. Canonicality is RatEnc lowest terms with `den>0`, compact UTF-8, `canonical_nested_key_order` plus lexicographic UTF-8 fallback, no duplicate keys.

The required P19 Typed/sequential universe remains the declared Schema enumerations (`Schema.lean:15-31`: 4 parties, 4 assets, 2 domains → 32-cell table in the baseline fixtures). 32 is that universe’s size, not a licence to shrink types.

Current `SupportedIR`/`CanonicalIR` are weaker and also **too wide**: codec/audit are `True`, empty cell lists pass, completeness/uniqueness/key-order/whitespace are absent. `typedJson` (empty types, 0 cells) is a counterexample to the *current* statements and would be **outside** the accepted nonempty-types domain. That is not permission to ignore the stub: `encodeModule` still maps a 32-cell execution IR to `{}`.

Do **not**:

- set `SupportedIR ir := decodeBytes (encodeModule ir) = .ok ir`
- drop sequential `run` / Typed `timestamp`/`now` / `currentTime` to make a fragment roundtrip
- treat codec identity-on-`rawText` as canonical-bytes
- claim P20 closed because a Prop exists

## Repair mapped to task 2.4 and program 21.1 / P20

P19 candidate task 2.4 (`openspec/.../tasks.md` item 2.4): prove encode/decode roundtrip for every **supported canonical** `DecodedIR`, with F25/F27/F28 only as bounded evidence, and refused decode returning no kernel object. Program task 20.2 includes 2.1–2.6. Program **21.1** (`reusable-verification-platform-program/tasks.md`) is the later P20 quantified encode/decode **and** checker-to-Lean `checkIR_execute_ok/_error` and step/run forms over that same supported domain. Overlap is not permission to omit 2.4; 21.1 still separately needs real correspondence, compatibility, and library instantiation.

Necessary distinctions, from the actual schema/plan:

1. **Support domain (IR).** `SupportedIR` on `DecodedExecution` only: Schema `Party`/`Asset`/`Domain` enumerations nonempty and matching the envelope `types` table; complete declaration-order state table; unique registry ids; steps `invoke|issue|revoke`; cell amounts `den>0` and nonnegative. `unsupportedForm` (`treeJoin`/`naryAdvance`, `Decode.lean:1009`) is not supported. Codec and audit documents are not execution-supported; they have `checkBytes`/`checkAudit` contracts, not `rawExecute`.
2. **Canonical rationals (IR).** Every stored rational is lowest terms, `den>0`. Prefer retaining `RatEnc` through packed values rather than `toRat` (`Decode.lean:260-261`) if encode must emit the same `num`/`den`.
3. **Canonical bytes (document).** Unique compact UTF-8 JSON: no extra whitespace, declared nested key order, lexicographic fallback, no duplicate keys. `decodeBytes` accepts a document iff `encodeModule` of the decoded IR equals those bytes (`grammar.json` `canonical_decoder_match`). Non-canonical order or pretty-print is `DecodeFailure`, not a second representative. Implement `encodeModule` as a real encoder of envelope+payload, not `"{}"`.
4. **Resource limits.** `maxBytes` 1048576, `maxDepth` 64, `max_array_length` 4096, harness timeout: `CodecResult.blocked`, never malformed and never kernel refusal. `scanLexical` already errors `.resourceLimit` (`Decode.lean:33-34,95,107`); `checkBytes` must not collapse that into `.malformed`.

Implement those, then prove 2.4 over that domain. Leave 21.1/P20 checker-to-kernel obligations explicit.

## Adjacent Soundness (bounded; not a 54-fixture review)

`rawExecute` / `checkIR` were not executed in this diagnostic. Source-only flags for the later correspondence gate:

- Run-event invoke reconstruction drops `inputs` (`Check.lean:711`); step results store `outputs := []` (`Check.lean:725`).
- `payload.steps.filterMap StepEnc.toStep?` (`Check.lean:702-703`) silently drops `.unsupported` instead of `unsupportedForm`.
- `checkIR` on audit is always `.passed` with `claimed_covered some true` (`Check.lean:747`); codec is `.codec (.ok …)` (`Check.lean:748`).
- `checkCertificate` ignores bytes and returns `.accepted` (`Check.lean:756-757`).
- Typed `rawExecute` receipt is a second `Args.check`/`evaluate` path (`Check.lean:640-650`), not a proved projection of `Typed.execute`’s post-state/receipt. `rawExecute_typed_ok` (`Soundness.lean:55-72`) does not mention receipt.

These are missing full raw world/receipt/run projection correspondence. They are not this codec verdict.

## Commands and limitations

Attempt-1 probes/logs are frozen (`attempt1-work.tar.gz` SHA-256 `4cae2238fcd01f3e23b84d64b1f5fac39c5bcaf7fcc6d1079104d7e95bc904c2`) and were not overwritten. Ancillary helper, not candidate evidence: `p16-equation-diagnostic-review/logs/run_bounded.py` SHA-256 `7168f2cb0f6a1800f7ad6c5becce807e29b864fa2bee45a67bf462fdd8d68795`; the diagnostic copy is `probes/run_bounded.py` SHA-256 `e88859cc5224ac8972a56ddc7cc6de0a89dbe4426ed84f5876b840a408ff4702`. Exact argv/cwd/exit/hashes: `commands.json`.

Unverified here: kernel `¬` proofs; `decide SupportedIR`; Check/Correspondence compile of `RoundtripStatements.lean`; F01–F54; M01–M16; `#audit_axioms`; live AGY worktree. Production sandbox sources were not edited.
