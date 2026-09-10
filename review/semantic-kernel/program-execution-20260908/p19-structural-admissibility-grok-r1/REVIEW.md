## Lean4 Review Report
**Scope:** frozen P19 R14 `Correspondence.lean` and `scripts/test_certificate_fixture_runner.py` (file/changed)

### Resolved Inputs
- target: `lean/DefiKernel/Certificates/Correspondence.lean` plus the live-relative-link runner regression
- scope: `file` on the changed module; runner sentinels only
- mode: `batch`
- Layer-2 mathlib: **advisory**
- Layer-2 source: `intent.source` default; `facts.repository_kind` = `other-lean`
- profile: `scripts_only` + `review_only`
- helpers: literal `/home/charl/.codex/plugins/cache/lean4-skills/lean4/4.8.7/bin/lean4-skills-preflight --codex`
- no edits, commits, branches, pushes, subagents, Foreman, or network
- probes and writable copies only under the output directory

### Build Status
Private `lake build DefiKernel.Certificates.Correspondence` from copied R13 oleans plus pinned mathlib `51e6992`: child compiler exit 0, 932 jobs, Correspondence 155s. Frozen CanonicalJson/Encode/Decode hashes match R13. Compiler Lean 4.33.0-rc2 `d8b1897`.

### Sorry Audit (0 remaining)
sorry-analyzer `--report-only` on CanonicalJson, Encode, Decode, Correspondence: `total_count` 0 each.

### Axiom Status
Exact 217 named theorems (23 CanonicalJson + 194 Correspondence) `#print axioms` via `lake env lean ProbeAxioms.lean`, child compiler exit 0. Parsed 217/217: 210 standard (`propext`, `Classical.choice`, `Quot.sound`), 7 none, 0 forbidden. Lemma `exprDepth_pos` is extra. `lean4-skills-check-axioms-inline` without lake env is a failed helper (`unknown module prefix DefiKernel`) and is not the 217 inventory.

### Style Notes
Advisory only. `Correspondence.lean` already disables `linter.style.longLine`. Lake rebuild printed Check.lean long-line warnings; Check.lean is unchanged in this freeze.

### Golfing Opportunities
Not blocking. Fuel and TreeMap proofs are induction, not golf targets for this audit.

### Recommendations
1. Keep `EncodeDecodeRoundtripStatement` as an open `Prop` until a recursive whole-document `decodeBytes` proof exists.
2. Treat `decodeDecodedIR_of_structurallyAdmissible` as the object-decoder theorem it is, not as production byte roundtrip.
3. Do not relabel `parser_max_*` or `jsonMaxArrayLengthFuel_adequate` as parser-state agreement.
4. Keep report labels (`grok-4.6-high`, Verify.lean 1296) distinct from the 217-name inventory.

## P19 R14 independent audit

Frozen archive `12345ec9e4d0e5bf4c509543dae9754f9c5cac62096acf90c519f4bbd9c8fd75`, 3476 files. Author disposition `PARTIAL_PROOF_WORK` is correct. Full P19 acceptance is false.

R14 does close the generic source-map inverse (`decodeSourceMap_sourceMapToJson` from `SourceMapSorted`, `ofList_toList_eq`) and removes decoder-success hypotheses from envelope/execution field theorems. `decodeDecodedIR_of_structurallyAdmissible` is the actual `decodeDecodedIR` on `decodedIRToJson` over typed, step, and run. Audit and codec are `False` in `SupportedIR`/`CanonicalIR` and are discharged by contradiction; that is the declared domain, not a hidden extra restriction. No `sorry`, custom axiom, or `native_decide` in the changed proofs.

Fuel theorems `jsonDepthFuel_stable` and `jsonMaxArrayLengthFuel_stable` are induction on arrays and objects under `jsonDepthFuel f j < f`. ProbeR14 measured exhaustion: depth-2 array/object is 0 at fuel 0, 1 at fuel 1, 2 at fuel 2, and stable at fuel 3/100. `parser_max_depth_bound` / `parser_max_array_bound` print as `fun ir h => h`. `jsonMaxArrayLengthFuel_adequate` still proves only `jsonDepth j < 100`.

Production `jsonObj` preserves list order. `encodeSourceMap` qsorts then `jsonObj`. Helper `Json.mkObj` sorts. ProbeR14 AB/BA maps have equal `.compress` and equal production strings. That inequality class is not a defect.

The live relative-symlink regression is a real sibling link (`readlink == "real_rel_dir"`), refused at exit 2, sentinel intact. Six sentinel tests passed in a private copy. F01 and the 54/99/16/21 suites were not re-run. Author `results.json` text that existing targets must be non-empty directories is a report typo; the runner requires an existing path to be an empty directory. `REPORT.md` body already says empty.

Author `auditor_model` `grok-4.6-high` is a requested role label, not this native review identity. This session requested `grok-4.6` / `high`. Root records the actual returned model. Verify.lean hash is unchanged; aggregate 1296 is not the 217-name evidence.

**Verdict:** `CHANGES_REQUIRED`. **Acceptance:** false. Component progress is not full P19.
