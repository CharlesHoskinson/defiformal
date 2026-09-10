# Draft findings — P19 R17 independent audit (turn 12)

Status: draft. Independent `#print axioms` gate still pending private Correspondence rebuild.
Native identity: unknown (root captures terminal telemetry). Requested alias grok-4.6.
Live AGY R18: not inspected.

## Proposed verdict

`CHANGES_REQUIRED`. Full P19 acceptance false. Author disposition `PARTIAL_PROOF_WORK` is accurate for the rational component and must not be promoted to whole-P19 acceptance.

## Independently measured so far

- Named inventory from frozen sandbox source (`^theorem|^lemma`): CanonicalJson 62 theorems, Correspondence 236 theorems + lemma `exprDepth_pos` = 237 named, total **299**. Matches root `Axioms299.lean` name list exactly.
- Previous R16 269 theorem names: all present (`missing_previous_theorems: []`). New theorem names: **29**. `exprDepth_pos` is not new; it is the R16 lemma.
- Decode/Encode/Schema sha256 byte-equal to frozen R16. CanonicalJson and Correspondence changed by addition: R16 line sets are ordered subsequences of R17; 0 R16 lines absent.
- Sorry-analyzer `--report-only` on both files: 0 sorry statements, exit 0. `native_decide` occurs only in comments.
- Pinned Lean 4.33.0-rc2 `d8b18978322de05a8f3dba51ef03cf5461676c17`; mathlib `51e6992efd06126df61a496bebf8f49482a4e129`. Preflight `--codex` exit 0. Profile: scripts_only+review_only. Layer-2 mathlib review is advisory (`repository_kind: other-lean`).
- Frozen author Verify log prefixes (author-captured, not re-run): Certificates 1486/2539, Typed 420/677, Composition 287/408.

## Actual new theorem statements (source inspection)

Genuine general component:

- `lexDigits_of_all_digits`: all-digit list + non-digit-or-empty suffix reconstructs `Nat.ofDigitChars`.
- `tokenizeFuel_nat` / `tokenizeFuel_int`: arbitrary Nat / Int (including `negSucc`) with non-digit suffix; number token is inverted; suffix remains `tokenizeFuel fuel rest` bind.
- `parseTokens_rat`: `rfl` on the nine-token canonical rational sequence; no extra hypothesis.
- `parseCanonicalJson_encodeRat (r : RatEnc)`: `parseCanonicalJson (encodeRat r) = .ok (ratToJson r)` for all `r`, no scalar bound.
- `rat_end_to_end_universal`: composes that parser inverse with `decodeRat_ratToJson`, requiring `r.den ≠ 0` and `Int.gcd r.num.natAbs r.den = 1`.

Support, not hidden success of the number itself:

- `tokenizeFuel_digit_step` takes `h_lex`; discharged by `lexDigits_head_tl` in `tokenizeFuel_nat`.
- `tokenizeFuel_encodeRat_chars` discharges suffix `h_end` with `rfl` because rest starts with `,` / `}`.

Not closed:

- `EncodeDecodeRoundtripStatement` remains `def Prop`.
- `decodeBytes_encodeModule_of_lex_and_parse` still assumes `h_lex` and `h_parse`.
- `parseCanonicalJson_of_tokenize_parseTokens` still assumes `h_tok` and `h_parse`.
- `parse_obj_field_step` / `parse_arr_feed_elem` still assume child `foldlM` success (`h_val` / `h_feed`).
- No theorem inverts arbitrary nested payload / list / object / envelope encoder bytes.

## Author-report flaws (do not edit historical reports)

- `commands.json` has no actual start/end timestamps or raw stdout/stderr hashes.
- CMD-03 claims Decode “strictly maintaining … error precedence”. Decode bytes are unchanged from R16; mixed-error precedence regression remains. Not replayed here (root already measured; R18 has the repair brief).
- REPORT cites Verify 287/408. That is Composition `#audit_axioms` only.
- `new_theorems_in_r17` lists `exprDepth_pos` as new. It is the pre-existing lemma.

## Remaining obligations (block whole P19)

1. Prove `EncodeDecodeRoundtripStatement`.
2. Derive `h_lex` and `h_parse` from `StructurallyAdmissibleIR` and compose an unconditional byte roundtrip.
3. Recursive parser inversion for arbitrary nested objects/arrays/payloads/lists/envelopes, using induction hypotheses rather than assumed child `foldlM` success.
4. Restore mixed-error precedence while keeping C0 key identity (R18 scope; Decode unchanged here).
5. Successful independent 299-name `#print axioms` on this review’s private rebuild (pending).

No 54/99/16 or 7/21 rerun. No new scanner diagnostic without a new concern.
