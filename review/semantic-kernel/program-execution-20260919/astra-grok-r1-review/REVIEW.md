# Independent R1 proof and evidence review

**ACCEPT_WITH_LIMITATIONS** for the frozen depth bridge and typed-execute conditional roundtrip. No proof repair is required in this scope. This does not accept full P19, P20, or P37.

Reviewer: GPT-6 Astra, medium reasoning. Author requested `grok-4.6`, native process reported `grok-4.6-build`; it ended at 100 turns with exit 1 and native stop reason `cancelled`. The capped process is not an acceptance event.

## Frozen inputs and preserved contract

All 335 root-inventory hashes matched before review and after compilation. The source archive matches SHA256 `8527a346f0def14da6e90ccfa9abb16ab47fd15dc7493cb9a7109294aba489e5`. Inputs were read only from the frozen private sandbox and root snapshot records; no live author source/cache or later candidate was inspected.

The 197-file pre-author Lean baseline has exactly two changed existing files: Roundtrip and Verify. Their only changes are imports of DepthBridge and IRDepth respectively. The two added modules are DepthBridge and IRDepth. Removing Roundtrip's single new import yields byte-identical R28 contents: all 246 theorem statements, bodies, and docstrings, and all 45 definitions, are preserved. Admission, grammar, production encoder/decoder, and toolchain remain unchanged. Source-manifest bindings match 15/15 sources.

## Mathematical scope

`jsonDepthFuel_toJson_eq_min` proves the claimed equality for every `TreeJson.Valid` tree and every natural fuel. Its induction is well founded on structural node size, with strictly smaller child sizes. Scalars contribute zero, arrays use list/array fold correspondence, and empty containers have depth one when fuel is positive. The max/min identity commutes fuel truncation through the child maximum.

Objects require distinct keys. Valid supplies `Nodup` keys; the proof transports that property through `toJsonObj`, uses lawful String comparison and Raw TreeMap well-formedness, establishes membership correspondence, and derives a permutation from membership plus no duplicates. A commutative maximum fold then ignores map ordering. No Boolean Json equality is substituted for propositional equality. The restriction matters: duplicate keys can overwrite a deeper earlier value, so the identity is not asserted for arbitrary invalid object trees. Valid's array-length bound is inherited, not newly added to admission.

At fuel 100, the equality is `jsonDepth t.toJson = min 100 t.depth`. From this value being at most 64, ordinary natural arithmetic implies `t.depth ≤64`: a tree deeper than 64 would yield a minimum greater than 64 because 100 > 64. This is not a premise that silently assumes fuel sufficiency.

IRDepth proves metric equalities across production JSON and TreeJson representations, including field permutations, arrays of libraries, request variants, and optional claimed next world. `jsonDepthFuel_envelope` accepts a child metric correspondence for every fuel and uses it at the decremented fuel. The typed payload correspondence supplies that premise universally. Registry correspondence uses the inherited theorem for an arbitrary RegistryEnc, not a witness or empty-list premise; registry entries and templates are unrestricted except by the unchanged admissibility contract. The config lemma has an explicit catalog correspondence premise and does not itself close general step/run depth.

`moduleToTreeJson_typed_depth_le_64` quantifies over every envelope and typed payload with `StructurallyAdmissibleIR`. It obtains Valid from the inherited admission theorem and semantic depth from the existing `SupportedIR` conjunct `WholeDocumentDepthBounded`. The new metric correspondence connects that existing condition to syntactic TreeJson depth. There is no circular roundtrip, parse-success, h_depth, empty-registry, or lexical premise in this depth theorem.

`decodeBytes_encodeModule_typed_of_lex` specializes the inherited general theorem using the new depth result. Besides unchanged structural admission, it retains exactly `h_lex : scanLexical (encodeModule typed) = .ok ()`. Its conclusion names the actual production `decodeBytes` and `encodeModule`; encodeModule is the canonical byte encoder and decodeBytes performs lexical scanning, UTF-8 conversion, canonical parsing, decoding, and byte re-encoding admission. There is no alternate codec in this proof.

Universal lexical acceptance remains unproved for all modes, including supported Unicode, rationals, byte/resource limits, and lexical state/fuel behavior. General composition-step and composition-run syntactic depth remain open. The general mixed-mode theorem retains both h_depth and h_lex. `EncodeDecodeRoundtripStatement` remains an unproved proposition definition.

## Independent compilation and axioms

The recorded private `lake build` of DepthBridge, IRDepth, Roundtrip and Verify exited 0. All four actually rebuilt; eight modules in total were marked Built. Its940 jobs are a dependency job count, not940 newly compiled modules. Private dependency and build directories were used; no shared build writes occurred. Lean/mathlib stay pinned to v4.33.0-rc2.

The exact new inventory in `declarations.json` is 25 DepthBridge theorems, one named RightCommutative instance, and 12 IRDepth theorems: 38 declarations total. There is no new private helper. Each of these 38 declarations received an explicit transitive `#print axioms` query against freshly built imports. Every closure contains only a subset of `propext`, `Classical.choice`, and `Quot.sound`; no sorryAx, native_decide, or custom axiom occurs. New source has no sorry/native_decide/axiom/unsafe token.

Verify also passed nonempty broader audits: Certificates 2272 theorems and 2775 supplemental declarations; Typed 420 and 677; Composition 287 and 408, all forbidden=0. Build warnings are style/tactic lints, not kernel failures. The unchanged 54/21/7 campaigns were not rerun; the build did compile its Tests dependency. These results are kernel proof checks, not new empirical coverage claims.

## Evidence defect R1-E01

The original author MANIFEST is invalid and remains preserved. Exactly two bindings are stale: `commands.json` and `logs/closeout-manifests/stdout`. The manifest was created at 17:43:09.237837 UTC inside a command that finished at 17:43:09.330623 UTC. Its stale commands hash exactly reconstructs the 23-receipt list before appending the 24th closeout receipt. Its stale stdout hash is the empty-stream hash before the closeout command printed its result.

All 24 terminal command receipts equal their commands.json entries and agree with started metadata. All 48 raw output hashes match those final receipts. The final 15 source bindings match. Independent 335-file root integrity and archive checks, plus fresh builds and axiom queries, make the root reconstruction sufficient for this scoped review. They do not retroactively create a clean author seal. Preserve the defect and bind the reconstruction independently; generate future seals only after recorder completion.

## Next required work

Complete general composition-step/run depth and universal lexical acceptance on the existing domain, then prove the full roundtrip statement and obtain a fresh independent review. Do not reuse this scoped verdict as a full-program gate. No production files were edited by this audit.

Verification commands, actual argv/cwd/times/exits, and complete raw-output hashes are in `commands.json`; raw streams are retained alongside it. `MANIFEST.json` is self-excluding and created only after the final recorded command completes.
