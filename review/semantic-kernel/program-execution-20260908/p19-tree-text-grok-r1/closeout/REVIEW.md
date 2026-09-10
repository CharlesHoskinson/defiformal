# P19 R21 independent review — generic serialized TreeJson text inverse

- **Role**: Independent auditor. Continuation of session `01a08cf0-d95c-7841-bbfa-0df382cd9d45` (original 30-turn cap left IN_PROGRESS placeholders). Sole reviewer. AGY R22 not inspected. Live author worktrees not inspected.
- **Requested alias**: `grok-4.6` high. **Original terminal reported model**: `grok-4.6-build` (`original-terminal/process.json`). **This closeout returned model**: unknown until this closeout's terminal metadata is valid.
- **Candidate**: Frozen R21 archive `41726f194c0d3640a32bddf32b31ce83e81cc5ba92be657fcb68f57deac571d4`. Root stated 3601 frozen files. This closeout did not re-hash the tarball.
- **Sandbox**: `/home/charl/.cache/defiformal-program/program-execution-20260908/p19-tree-text-grok-r1-sandbox` (immutable).
- **Parent output**: `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-tree-text-grok-r1` (immutable except this `closeout/` write).
- **Original-terminal snapshot**: `original-terminal/` with root seal. Immutable.
- **Lean**: 4.33.0-rc2 (`d8b18978322de05a8f3dba51ef03cf5461676c17`), mathlib `51e6992efd06126df61a496bebf8f49482a4e129`.
- **Profile**: lean4-skills `scripts_only+review_only`. Preflight `--codex` exit 0. Layer-2 mathlib advisory (`repository_kind other-lean`, `intent.source default`). No LSP. No subagents, Foreman, network, source edits, branches, commits, or pushes. No new builds or probes in this closeout.
- **R20 root adjudication** (`PARTIAL_GENERAL_TOKEN_INVERSE_CONFIRMED_FULL_P19_CHANGES_REQUIRED`) is historical input. It is not this R21 review.
- **Root has not yet adjudicated this final review.**

## Verdict (two scopes)

| Scope | Classification |
|---|---|
| Generic serialized TreeJson text inverse (`tokenize_tree`, `parseCanonicalJson_tree`) | **USABLE** |
| Full P19 acceptance | **CHANGES_REQUIRED** |

Overall `CHANGES_REQUIRED`: the new theorems invert `TreeJson.encode` `String` text. They do not close `encodeModule` / `decodeBytes`, `scanLexical` admission, or `EncodeDecodeRoundtripStatement`. Full P19 remains false. The generic text inverse is not a token-only leftover from R20.

## Lean4 Review Report

**Scope:** R21 changed `CanonicalJson.lean` only. Correspondence/Decode/Encode/Schema byte-equal to R20. Independent private rebuild target was `DefiKernel.Certificates.Correspondence`.

**Resolved inputs:** `--scope=file` on frozen R21 CanonicalJson plus required Correspondence inventory; `--mode=batch`; Layer-2 advisory from `lean4-skills-project-context`.

## 1. Independent rebuild identity

Private Lean copy: `../private-lean` (excluded from the manifest as growing cache). Packages: read-only symlink to the pinned mathlib tree. Build cache copied from the completed frozen R20 review, not live AGY.

```
cwd:  .../p19-tree-text-grok-r1/private-lean
argv: lake build DefiKernel.Certificates.Correspondence
start: 2026-09-10T20:17:15.870808+00:00
end:   2026-09-10T20:21:43.143781+00:00
exit: 0
stderr: empty (sha256 e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855)
stdout sha256: 6ed28b1188830b462495564a55409992e05d02e5ef0e9a5ccfdb1c7c28bf5eef
jobs: 932
```

Actual log jobs (do not credit modules absent from this log):

| Module | Log |
|---|---|
| DefiKernel.Certificates.CanonicalJson | Built 8.7s |
| DefiKernel.Certificates.Encode | Built 1.7s (source byte-equal to R20; rebuilt as CanonicalJson importer) |
| DefiKernel.Certificates.Decode | Built 3.3s (source byte-equal to R20) |
| DefiKernel.Certificates.Check | Built 2.5s |
| DefiKernel.Certificates.Observation | Built 1.2s |
| DefiKernel.Certificates.Correspondence | Built 248s |
| DefiKernel.Certificates.Schema | Replayed |
| DefiKernel.Typed.Transition | Replayed |
| Soundness / Tests / Verify / Audit | **not in the log; not rebuilt** |

| File | sha256 | vs R20 |
|---|---|---|
| CanonicalJson.lean | `26f2f675b8ed8b49f2bab16196fc72d5017fe84dca1ddd67d1ec15f8877b3fbb` | changed by append |
| Correspondence.lean | `93a3a29e90a3c844b3d2309240d266b782b3fc7b137e671d12964a217d6ceaa9` | byte-equal |
| Decode.lean | `7561716fe3f2bdba355015de7c1b81e3c594f1d6a51df0009294be248c38a23d` | byte-equal |
| Encode.lean | `9b4fdc4c0b6fd07a13f7552506cf2c6f0d0eaa3e3a31fb590ea974c1261ca3b8` | byte-equal |
| Schema.lean | `24e99089cb0380ab8150ffde06f0f60b4362d345436e4c1e06199b46f9fb961b` | byte-equal |

Historical CanonicalJson prefix: first 1657 lines equal the frozen R20 copy. First mismatch is line 1658 (`end DefiKernel.Certificates` in R20 versus the `NonDigitHead` docstring in R21). R20 1660 lines, R21 2088 lines, net +428 (30 new theorems + `NonDigitHead` + namespace end; two R20 trailing blanks gone). `end DefiKernel.Certificates` is now line 2088.

Sorry-analyzer `--report-only`: 0 sorry statements on CanonicalJson and Correspondence, exit 0, stdout sha256 `ca6b5a162191465a7b9728a46f1914076d5d60aec74fe586f2af3f00a938b679`. `sorry` / `native_decide` in Correspondence occur only in comments (lines 24 and 1015). No custom `axiom` declarations.

Pinned compiler hashes: lean `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`, lake `60330ab6f07dce20f3fa9ebb08e8b984ea9549eac172afeb15d9d2227060e2b3`, `libleanshared.so` `0e2ffc1639d133cfccf1552c0d59772b77ed56e3e0c5a00e33d8c7c324a9470f`.

Unrecorded setup failure: first lake-launch Python used relative `PYTHONPATH=tools` against the sandbox cwd and raised `ModuleNotFoundError: No module named 'record_cmd'` before `record_cmd` ran. `failed-probes/lake-rebuild-import-error.json` preserves that fact. No start/end/stdout/stderr exist for that attempt. It is not a build receipt and is not credited.

## 2. Exact 448 named theorem/lemma set

Independent `^theorem|^lemma` extraction from frozen source, including dotted `TreeJson.*` names and lemma `exprDepth_pos`:

| Count | Value |
|---|---|
| CanonicalJson theorems | 136 |
| CanonicalJson lemmas | none |
| Correspondence theorems | 311 |
| Correspondence lemmas | `exprDepth_pos` |
| Named theorem/lemma total | **448** |
| New R21 theorem/lemma names | **30** |
| New definition (not in 448) | `NonDigitHead` |

There is no R21 author 434/465 inventory claim. Definitions and generated declarations are separate from this 448.

Independent `#print axioms` command `probe-axioms448` against the **private rebuild** (not the author worktree):

```
exit: 0
start: 2026-09-10T20:27:09.742290+00:00
end:   2026-09-10T20:27:12.056274+00:00
stdout sha256: a864b6893ed3d4c9f751462dbaed0e9b3b532e60364b7f582dda975845be69d9
stderr: empty
NAMED=448
Lean error lines: none
```

Parsed records: **448**, **415** standard-axiom, **33** zero-axiom, **0** forbidden. Names match source order. Name/axiom pairs equal the root inventory stdout (`adf2480c42410039a6126a2cd8b5d5221a512aa4e5a946af25212f9cfd95ef7a`). Dotted names present: `TreeJson.size_pos`, `TreeJson.mem_sizeList`, `TreeJson.mem_sizeObj`, `TreeJson.valid_of_mem_validList`, `TreeJson.valid_of_mem_validObj`. `exprDepth_pos` present (standard axioms). Five new `nonDigitHead_*` theorems are among the 33 zero-axiom records (28 R20 none + 5).

Stdout hashes differ because the independent probe is not byte-identical to root `Axioms.lean`. Examined content: `Probe.lean` wraps the same 448 `#print axioms` lines with three `#eval IO.println` lines (`PROBE_AXIOMS_START`, `PROBE_AXIOMS_END`, `NAMED=448`). Root `Axioms.lean` / `RootAxioms.copied.lean` have no those wrappers and **no `set_option`**. Probe stdout therefore starts with `PROBE_AXIOMS_START` and ends with `PROBE_AXIOMS_END` / `NAMED=448`. The 448 axiom-pair lines themselves match.

### Inline axiom helper (actual raw result; not the 448-name gate)

`lean4-skills-check-axioms-inline --report-only` on CanonicalJson, exit 1, credit false:

- Found **157** declarations
- Only **86 of 157** resolved — file marked unverified
- Files checked: **0**
- Declarations checked: 86
- Zero credit. Do not treat 86 as the 448-name inventory. R20's "86 of 126" is a different file snapshot.

Same helper on Correspondence, exit 0, credit true on the receipt:

- Found **436** declarations
- Files checked: 1
- Declarations checked: **436**
- "All declarations use only standard axioms"
- 436 is the helper's declaration walk of Correspondence (theorems, lemmas, and other declarations it resolved). It is **not** the 448 explicit theorem/lemma set (136+312). Do not default completeness from 448 or from 312.

Axiom evidence for the named set is `probe-axioms448`, not the CanonicalJson helper.

## 3. Generic serialized text inverse

R21 appends general tokenizer/fuel/length/parser proofs. Strongest new theorems:

1. `NonDigitHead` — suffix head is empty or a non-digit. Required so `lexDigits` / `tokenizeFuel_int` stop at the numeric boundary. Witnesses: `nonDigitHead_nil`, comma, colon, `]`, `}`.
2. `tokenizeFuel_escapeTreeString` — quoted escaped key/string text produces `JsonToken.str s` and continues on `rest`.
3. List/object lexical composition — `encode_*_toList`, `tokenizeFuel_encodeList`, `tokenizeFuel_encodeObj` place commas/colons/brackets with `NonDigitHead` suffixes.
4. `tokens_length_le_encode_length` — well-founded on `TreeJson.size`. Token count ≤ encoded character count. Non-circular fuel bound for `tokenize` (`length + 1`).
5. `tokenizeFuel_tree` — induction on `TreeJson.size`. Fuel is exactly `tokens.length + residual`. Child IH is derived from `mem_sizeList` / `mem_sizeObj`, not assumed as tokenize/parse success of a string.
6. `tokenize_tree` — `tokenize (TreeJson.encode t) = .ok (TreeJson.tokens t)` for **every** `t : TreeJson`. Residual fuel is `encode.length - tokens.length + 1 ≥ 1` by the length bound; empty rest is `nonDigitHead_nil`; `tokenizeFuel_empty` supplies the empty-suffix success. Child success is derived.
7. `parseCanonicalJson_tree` — `parseCanonicalJson (TreeJson.encode t) = .ok (TreeJson.toJson t)` given `TreeJson.Valid t` and `TreeJson.depth t ≤ 64`. Proof: rewrite `tokenize_tree`, then `parseTokens_tree_valid`. This inverts **serialized `String` text**, not only an abstract token list.

Error propagation: list/object fuel lemmas case on `tokenizeFuel fuel rest` error/ok and `rfl` on error. Numeric suffix: after a number, encode places `,` / `]` / `}` / empty, all `NonDigitHead`. Keys are `escapeTreeString` (quote-delimited), not bare numbers. Zero residual fuel is excluded by the `+ 1` split. `tokenize_tree` does not require `Valid` or depth 64; the parser theorem does, because the token parser does.

This is **not** whole-byte-module success. `parseCanonicalJson_tree` does not mention `encodeModule`, `decodeBytes`, or `scanLexical`.

## 4. Full P19 remains open

Unchanged from R20, still live:

- `EncodeDecodeRoundtripStatement` is a `def Prop` (Correspondence:1061), not a theorem.
- `decodeBytes_encodeModule_of_lex_and_parse` still assumes `h_lex : scanLexical (encodeModule ir) = .ok ()` and `h_parse : parseCanonicalJson (encodeModuleString ir) = .ok (decodedIRToJson ir)`.
- Whole envelope/module TreeJson maps and actual `scanLexical` admission from unchanged `StructurallyAdmissibleIR` are unproved.
- `TreeJson.depth (exprToTreeJson e) ≤ 64` is not implied by `ExprCanonical` alone. Use the whole-IR structural bound later. Do not change `StructurallyAdmissibleIR`.
- `packedValueToTreeJson` is the inner bool/rat literal payload, not the production unit/value wrapper.
- Preserve 1 MiB / depth 64 / array 4096 / full canonical strings.
- Production envelope bytes, declaration-order 14 fields, sourceMap sorted fast path, and semantic `mkObj` sorting remain distinct. No bytes=compress assumption.

No fresh 7/21/54/99/16 campaign was run or credited. Prior R19/R20 scanner/fixture evidence stays historical.

## 5. Author evidence gap (explicit)

Requested `agy-r21-proof` directory is **absent**. Native author SUCCESS/exit 0 returned repeated waiting messages, not a proof completion report. Root preserved native gzip and 97 `run_command` observations; those may repeat steps, truncate commands, and lack per-command stdout/stderr/exit. They are not raw receipts. No R21 author build/test count is inferred from them. Root separately captured a 448-name axiom command against the terminal author build; that is not this reviewer's private rebuild. CLI exit 0 does not accept production source or this review.

## 6. What this review does not claim

- Full P19 acceptance
- Whole-module `encodeModule` / `decodeBytes` roundtrip
- `scanLexical` success on production bytes
- Rebuild of Soundness/Tests/Verify/Audit
- Completeness of the CanonicalJson inline axiom helper
- That Correspondence helper 436 equals the 448 named set
- New fixture/mutation campaign results
- That this closeout's model identity is already `grok-4.6-build` (that identity belongs to the original 30-turn terminal; this closeout follows its own telemetry)
