# P19 R3 roundtrip-domain diagnostic

**Mark:** `ROUNDTRIP_DOMAIN_DIAGNOSTIC_ONLY_NO_ACCEPTANCE`  
**Disposition:** current nonempty `SupportedIR` / `CanonicalIR` plus the actual encoder/decoder cannot sustain the required universal P19 roundtrip and canonical-byte obligations.  
**This is not full P19 acceptance and does not close any task.**

Requested model: `grok-4.6` effort high. Returned model identity is for root `modelUsage`; this report does not invent one.

Frozen candidate: R3 archive SHA256 `86935796922a00aa463927678531b874e8846863f2ffa27286a49f59355304b3` (1523 files), partial/unaccepted. Source hashes for Correspondence/Encode/Decode/Schema/Check matched `inputs.json` and the terminal manifest (21 key paths, `mismatch_count=0`). The archive tarball was not present in this sandbox.

Compiler used for rebuild and probes: Lean `4.33.0-rc2` commit `d8b18978322de05a8f3dba51ef03cf5461676c17` via `lake` in the private tree (`lean-toolchain` pin). Host default `elan` `stable` is `4.33.1` / `819816b2e0a3bf405af45ae5c7af2491d8f5bee6` and was not used. `bin/lean` SHA256 `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`; `libleanshared.so` SHA256 `0e2ffc1639d133cfccf1552c0d59772b77ed56e3e0c5a00e33d8c7c324a9470f`.

Private rebuild: `lake build +DefiKernel.Certificates.Correspondence +DefiKernel.Certificates.Decode +DefiKernel.Certificates.Tests` in `private-lean/` with packages symlinked and a fresh `.lake/build`. Exit 0, 932 jobs. Runtime probes used those oleans, not the sandbox's 2026-09-06 cache.

Root-already-known reporting defects (scenario overclaim, audit-exit gate, missing 38-task REPORT, incomplete M07–M16) were not rediscovered as the work of this pass.

## Answer

The required statements are still unproved `def` Props. Independently, they are not even true of the current predicates plus the actual codec:

1. `EncodeDecodeRoundtripStatement` has evaluated nonempty counterexamples inside `SupportedIR ∧ CanonicalIR`.
2. `DecodeEncodeCanonicalBytesStatement` fails on the actual accepted F13/F25/F27/F28 compact documents (32 cells, store 12), and on several permissive-decode mutations.

Bounded `#eval` is not a kernel proof of negation. The statements remain unsupported.

## What the source actually contains

`lean/DefiKernel/Certificates/Encode.lean` is a real encoder (`encodeModuleCanonical`; `decodeBytes` wraps it as `encodeModule`). The old encoder-stub diagnostic does not describe this tree.

`Correspondence.lean` still only declares:

```lean
def EncodeDecodeRoundtripStatement : Prop :=
  ∀ (ir : DecodedIR), SupportedIR ir → CanonicalIR ir → decodeBytes (encodeModule ir) = .ok ir

def DecodeEncodeCanonicalBytesStatement : Prop :=
  ∀ raw ir, decodeBytes raw = .ok ir → CanonicalIR ir → encodeModule ir = raw
```

Proved in that module: `decode_error_no_kernel`, `decode_error_resource_limit`, `rational_decode_canonical`, `rat_fromRat_num_den`, `rational_roundtrip`. Those are rationals and codec-error routing, not RC01 / T-canonical-bytes.

`SupportedIR` checks mode, `cells.length = 32`, nonnegative amounts with `den > 0`, registry-id `Nodup`, and (for step/run) no `.unsupported` constructor. It does not check types enumerations, cell identity/uniqueness/declaration order, store shape, nested terms, env, catalog, envelope/source_map, or PackedValue unused fields.

`CanonicalIR` checks only state-cell `RatEnc` lowest terms and `den > 0`. It does not check `claimed_next_state` rationals, request/env/history packed values (those are `ℚ` after decode), source_map order, envelope completeness, or byte-level key order / whitespace.

## Classification of failures

### (c) Declared, not proved

Task 2.4 / RC01 / T-roundtrip and T-canonical-bytes have no theorem. Finite Tests.lean / F25-like encode-decode success is bounded evidence only.

Tasks 4.3 / 5.1 / 5.2 cannot be treated as discharged by the current `Soundness.lean` names: `checkIR_execute_ok` / `checkIR_executeStep_ok` / `checkIR_run` are routing `rfl` lemmas (`checkIR` equals `checkTyped`/`checkStep`/`checkRun`). Closer kernel lemmas (`checkTyped_execute_ok`, `rawExecute_*`, `checkRun_cursor_*`) exist but are not the required quantified supported-domain correspondence. Keep genuine P20 remainder (compatibility, libraries, Claims/Tree) separate.

### (a) Predicate too weak to express canonical admissibility

Evaluated, still inside the current quantified domain:

| IR | SupportedIR | CanonicalIR | encode then decode |
|---|---|---|---|
| Tests F25-like 32-cell/store-12 typed | true | true | `ok` and IR equal |
| Tests F27-like step | true | true | `ok` and IR equal |
| 32 duplicate `(main,alice,usd,0/1)` cells | true | true | `ok` and IR equal |
| reversed 32-cell table | true | true | `ok` and IR equal |
| empty `types` enumerations with 32 cells | true | true | `ok` and IR equal |
| bool lit `valRat = 5` in template guard | true | true | `ok` but IR unequal (`5` dropped to `0`) |
| unsorted `source_map` `[z,a]` | true | true | `ok` but IR unequal (sorted to `[a,z]`) |
| `claimed_next_state` cell `2/4` | true | true | `error:illegalRational.noncanonical` |

So a 32-cell table that is not the unique declaration-order universe still satisfies the predicate. Nested non-canonical `RatEnc` on `claimed_next_state` is invisible to `CanonicalIR`. PackedValue unused fields and `source_map` order are invisible.

### (b) Encoder/decoder drops or transforms, or decoder is more permissive than the contract

Encoder (intended normalization vs defect):

- `source_map` keys are lexicographically sorted. Grammar asks for that. Planning F13/F25/F27/F28 raw bytes use `transfer` then `store`. After decode, Lean `Json.obj` already yields `[store, transfer]`; `encodeModule` emits that lex form. Same size 9699, first difference at byte 705: `"store"` vs `"transfer"`. F13 mutated to lex `source_map` then `encodeModule ir = raw`. This is intended canonical normalization, not data loss, but it falsifies `DecodeEncodeCanonicalBytesStatement` on the accepted fixture bytes because the decoder accepted the non-lex document.
- Bool `PackedValueEnc` / expr lit emits only the boolean; unused `valRat` is dropped. That is a representation defect relative to IR equality, not a JSON-canonicalization feature. Evaluated: `guard1 valRat=5` vs `guard2 valRat=0`.
- `claimed_next_state` `RatEnc` is emitted as stored `num/den`. Unreduced `2/4` is then refused by `decodeRational`. Encoder does not normalize `RatEnc` (unlike `ℚ` packed values).

Decoder versus grammar `canonical_decoder_match` (“accept iff `encodeModule` equals raw”):

| Input | decodeBytes | notes |
|---|---|---|
| F13/F25 compact 9699 B, 32 cells, store 12, registry `[0,4,5,6]` | ok | encode ≠ raw (source_map order) |
| F27 compact 10664 B, composition-step, 32/12 | ok | encode ≠ raw (source_map order) |
| F28 compact 1/2 argument | ok | encode ≠ raw (source_map order) |
| envelope keys `mode` before `schema_version` | ok | encode restores grammar order |
| omit `"invariants":[]` | ok | encode re-inserts the field |
| omit `"claimedActor":null` | ok | encode re-inserts null |
| extra `"index":0` on `{"tag":"caller"}` | ok | extra variant key ignored; encode drops it |
| extra `"quote":"debt"` on amount unit | ok | union `checkObjectKeys` allows unused keys |
| unknown envelope field `extra` | `unknownExecutableField:extra` | correct refusal |
| unreduced arg `6/2` or state `20/2` | `illegalRational.noncanonical` | correct refusal; outside decoded domain |
| space after `:` or newline after `{` | `noncanonicalWhitespace` | correct refusal |
| principal `mallory` | `unknownIdentifier:mallory` | correct refusal |

`checkObjectKeys` is a union of constructor keys, not an exact per-tag set, and it does not check order. `decodeEnvelope` defaults missing `invariants`/`libraries`/`source_map`/`claimed_judgments`/`claimed_next_state`/`require_*`. `decodeState` does not enforce completeness, uniqueness, or declaration order (grammar `missingField.stateCell` / `uniqueness.stateCell` are unimplemented). `decodeRegistry` does not enforce duplicate ids (grammar `uniqueness.registry`).

Whitespace refusal and unknown-field/unknown-identifier/unreduced-rational refusal are working. Key-order and omitted-default and extra-variant-key acceptance are the canonical-byte holes.

Do not treat encode-decode equality of selected fields, or of the decoded IR after lex sort, as whole-IR/whole-bytes identity.

## Smallest honest admissibility correction

Keep the nonempty 32-cell declared universe and invoke/issue/revoke forms. Do not switch to encoder-image (`decodeBytes (encodeModule ir) = ok` as a hypothesis), a circular “canonical means roundtrip”, one fixture, or the empty model.

Split byte-canonicality from IR-canonicality:

1. **Decoder must refuse non-canonical bytes** (grammar already says this). Required keys present; exact constructor key sets in `canonical_nested_key_order`; `source_map` lex UTF-8; compact whitespace; no extra variant keys; no omitted envelope/request fields that the encoder always emits. After that, `decodeBytes raw = ok ir → encodeModule ir = raw` can be an IR-independent byte theorem. `CanonicalIR` on `DecodedIR` cannot see original key order or whitespace; a permissive decoder plus an IR-only `CanonicalIR` makes T-canonical-bytes unprovable, as F13 demonstrates.

2. **`SupportedIR` structural (not assuming roundtrip):**
   - `types` enumerations nonempty and equal to the declared `{alice,bob,vault,pool} × {usd,share,collateral,debt} × {main,other}` in declaration order.
   - state table length `= |domains|×|parties|×|assets|` (32 for this universe), unique `(domain,party,asset)`, declaration-order nested loops.
   - amounts `den > 0`, `num ≥ 0`.
   - registry ids `Nodup` (and decode-time `uniqueness.registry`).
   - supported step tags only.
   - `PackedValueEnc` normal form: bool ⇒ `valRat = 0`; numeric ⇒ `valBool = false`.
   - store/env/catalog/registry/history lists as given; array order significant. Fixture store-12 is a fixture frame, not a reason to shrink the universal domain to one store.

3. **`CanonicalIR` on IR values:** every `RatEnc` anywhere (state, `claimed_next_state`, receipts if present) lowest terms `den > 0`; `source_map` already lex in the Lean list; no unused PackedValue fields. Nested request/env lits are `ℚ` and already reduced; do not pretend a state-cell-only gcd predicate covers them.

4. **Then prove** constructor lemmas (Rat, PackedValue, Expr, Template, Registry, State table, Envelope, Step, World) and compose. See `proof-obligations.json`.

If AGY cannot make the decoder refuse non-canonical bytes in this increment, say T-canonical-bytes is still open; do not weaken the statement to “encode equals raw up to Json.parse key order”.

Broader P20 (rawExecute/checkIR quantified correspondence beyond the routing lemmas, compatibility, libraries, Claims/Tree/Nary) stays independent.

## Failed attempts and unverified items

- Probe r1 (`logs/probe-roundtrip.log`) failed to compile: `Decode.lean` macro `.unsupportedForm hole` captured `.unsupportedForm r` in the diagnostic. Fixed in r2 by matching `DecodeFailure.unsupportedForm`. Not a semantic counterexample.
- Default `lean` on PATH is 4.33.1; ignored after identity check.
- R3 tarball bytes were not on disk here; only the declared SHA256 and extracted source hashes.
- No kernel proof of `¬ EncodeDecodeRoundtripStatement` was compiled; counterexamples are bounded execution.
- Not probed: `escapeJsonString` vs grammar `\uXXXX` for C0 controls other than `\n\r\t`; duplicate JSON keys; resource limits; `ite` cond/thenExpr aliases; encode of audit/codec documents (outside `SupportedIR`); full 54-fixture campaign.

Evidence class: proof vs bounded execution vs source identity are separated in `findings.json`.
