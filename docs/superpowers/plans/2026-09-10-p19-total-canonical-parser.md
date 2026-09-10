# P19 Total Canonical Parser Implementation Plan

> **For agentic workers:** Use the executing-plans workflow in the existing native AGY session. The user's AGY-author/Grok-auditor routing supersedes generic subagent and commit suggestions. Root alone publishes. This plan states interfaces and proof obligations; AGY authors the implementation.

**Goal:** Prove the universal supported-canonical IR roundtrip through the production byte codec.

**Architecture:** A total integer-JSON parser feeds the existing schema/IR decoder. Structural bounds and reusable serialization inverses connect the actual encoder, parser and IR decoder. Retain the production canonical-byte admission condition.

**Tech Stack:** Lean4.33.0-rc2, mathlib51e6992efd06126df61a496bebf8f49482a4e129, existing Certificates namespace and pinned grammar.

## Global constraints

- Preserve the accepted finite grammar and full supported typed/step/run universe, including meaningful nonempty cases.
- No sorry, custom axioms, native_decide, decoder-image domain or desired-result hypothesis in accepted proofs.
- Preserve all previous evidence and source pins. Use `agy-r7-proof` for new evidence and explicit fresh output paths for every runner.
- Missing upstream reduction equations authorize the scoped parser refactor; they do not defer the assigned proof.
- The whole roadmap remains open. No full P19 acceptance follows from this task alone.

## 1. Total production parser and resource bounds

Files: create `lean/DefiKernel/Certificates/CanonicalJson.lean`; modify `Decode.lean`, `Encode.lean` if escaping requires repair, and structural predicates in `Correspondence.lean`.

Interface: `parseCanonicalJson : ByteArray → Except DecodeFailure Lean.Json`, importing schema types. Keep the parser independent of the proof module to avoid import cycles.

- [ ] Implement total parsing for the accepted integer-JSON forms and wire it into `decodeBytes`.
- [ ] Preserve lexical errors, unknown/duplicate key handling, unsupported forms and canonical admission behavior.
- [ ] Express whole-document byte/depth/collection bounds structurally and prove sufficient parser/expression fuel. Include string sizes and envelope nesting.
- [ ] Check targeted canonical positives and exact refusal/resource boundaries, including quotes, backslashes, C0 control characters, Unicode and nested arrays/objects.

Run from `lean/`: `lake build DefiKernel.Certificates.CanonicalJson DefiKernel.Certificates.Decode`. Expected: successful elaboration of total production definitions. A build alone grants no roundtrip proof.

## 2. Serialization and complete constructor inverses

Files: create `lean/DefiKernel/Certificates/CodecProofs.lean` if needed; extend `Correspondence.lean`. Keep reusable lemmas separate from policy proofs in `Soundness.lean`.

- [ ] Prove actual UTF-8/string and integer/rational serialization inverses.
- [ ] Prove array/object inverses and every supported value/operator/expression case by induction.
- [ ] Prove arbitrary nonempty registry/store/world/envelope and typed/step/run inverses under the structural domain. Empty-container and closed-expression lemmas remain supporting results.
- [ ] Bind any declarative Json representation to the actual encoder and schema decoder; do not introduce an unconnected alternate codec.

Run `lake build DefiKernel.Certificates.Correspondence DefiKernel.Certificates.Tests`. Expected: each claimed lemma elaborates; failed and scratch attempts remain distinct from proof evidence.

## 3. Universal theorem and proof audit

File: `lean/DefiKernel/Certificates/Correspondence.lean`.

- [ ] Prove a theorem inhabiting `EncodeDecodeRoundtripStatement` through the production parser and IR decoder.
- [ ] Retain `decodeBytes_encode_canonical` and the canonical-byte-direction theorem.
- [ ] Demonstrate structural-domain membership for meaningful nonempty typed and sequential examples, plus discriminating invalid normal forms.
- [ ] Run `#print axioms` for the final theorem and its helpers, then the three nonempty `Verify.lean` scopes. Preserve exact compiler identity, commands, exits, outputs and source hashes.

Expected: the universal theorem itself is kernel-checked with standard axioms only. A Prop declaration, finite test or opposite-direction theorem is insufficient.

## 4. Frozen evidence and independent review

Directory: `review/semantic-kernel/certificates/p19/implementation/agy-r7-proof/` in the author worktree.

- [ ] Write `REPORT.md`, exact theorem/axiom records, commands, source manifest and targeted results. Continue implementation while safe progress remains available.
- [ ] Preserve all earlier attempts, including R6's separately captured misdirected outputs. Never run a command that overwrites R5/R6 evidence.
- [ ] Collect all author child processes before the terminal checkpoint. Root freezes the exact result and obtains fresh Grok review.
- [ ] Keep the full fixture/mutant campaign, overlay provenance/IR-equality repair, trusted host boundary and remaining correspondence work visible for subsequent acceptance gates.
