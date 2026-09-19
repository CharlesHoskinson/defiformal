# Independent recovered AGY R28 proof review

Scope: the 38 theorem declarations added to frozen R27 in `DefiKernel.Certificates.Roundtrip`, not P19, P20, P37, or whole-program acceptance. Historical author: AGY `gemini-3.8-flash-high`, high effort. Independent checker: requested `gpt-6-astra`, medium, through the current Codex checker session. No live Grok candidate or draft was inspected. No production source was edited.

Frozen R28 SHA-256: `bcdb0d87406e79ef61415fa5ef77f2cf5bfb4aa74fcc787adcaf0a8eae07f111`. Frozen R27 SHA-256: `216e2fcbed665b99a6e761516a0f0b4af3677cc2acb803ce9597e07f3ba61d5e`. All 211 supplied file bindings matched before review. Nine private package revisions match the pinned manifest. Lean reports 4.33.0-rc2, commit `d8b18978322de05a8f3dba51ef03cf5461676c17`.

The diff is one additive block at lines 2763–3189. R27 has 208 theorem declarations; R28 has 246. The full inherited prefix and closing suffix are byte-identical, which preserves all inherited statements, signatures, definitions and proof bodies. `new-declarations.json` records every new theorem's exact statement and source line. `inspect.py` records and checks the enumeration and preservation conditions; the diff command's exit 1 is the expected indication of differences.

The first 17 additions establish depth bounds for ports, interfaces, components, environment reads, deltas, templates, registries, configuration and payloads. Parameterized template and registry premises bound actual child encodings and lead to larger enclosing bounds; they are usable composition rules rather than restatements of their conclusions. Lists can be arbitrarily long without increasing depth beyond their maximum element depth, so no omitted array-length premise is needed for these particular depth claims. Array resource limits remain separate admissibility conditions.

The next six additions prove payload and module depth bounds under the explicit empty-registry restriction. Typed payload depth is at most 7; step and run payload depth is at most 9. Module bounds also cover the envelope through the inherited envelope theorem. The three ensuing roundtrip corollaries discharge depth only in this restricted domain and retain both structural admissibility and successful lexical scanning. They do not weaken or replace the inherited general theorem.

The final 12 additions describe actual lexical scanner transitions: empty numeric accumulator, zero fuel, empty input, opening and closing delimiters, colon, object and array commas, keys, and string values. Fuel exhaustion remains an error. Opening delimiters require depth + 1 ≤ 64; array commas require count + 1 ≤ 4096; key parsing requires an actual successful string parse and absence from the key list. The string-value theorem excludes object-key positions. Closing-delimiter equations permit either scope constructor because the lexical prepass itself behaves that way; they do not claim grammatical JSON validity. These are correct local reduction lemmas, not a full scanner preservation theorem.

General `h_depth` and `h_lex` remain open. `SupportedIR` already includes `WholeDocumentDepthBounded`, phrased using `jsonDepth (decodedIRToJson ir)`; relating that bound to `TreeJson.depth (moduleToTreeJson ir)` is still needed for general depth discharge. The lexical proof still needs an induction relating canonical encodings to scanner state, sufficient fuel, decoded keys, number forms, scope counters and bounds. Do not replace these obligations with smaller domains or claim a whole milestone from the present additions.

The existing 54/21/7 campaigns were not repeated for this proof-only audit. Their historical counts are neither new execution evidence nor substitutes for the new-theorem axiom inventory.

Validation and final scoped disposition are recorded below after the private build and probes complete.

## Final result: ACCEPT_WITH_LIMITATIONS

Accept the 38 declarations as a correct, useful partial proof contribution. No required mathematical source repair was found. This is not milestone acceptance.

- The actual target and dependencies compiled successfully in the private sandbox: `lake build DefiKernel.Certificates.Roundtrip`, 933 jobs, exit 0. Raw evidence: `170627465260.log`. Linter warnings are retained in that log.
- `lake env lean AstraR28Axioms.lean` succeeded. The complete transitive inventory covers 38/38 new declarations: 5 axiom-free, 33 using only subsets of `propext`, `Classical.choice`, `Quot.sound`. No `sorryAx`, native-decision axiom, or custom axiom occurs. See `axiom-inventory.json` and `171601015310.log`.
- Nonvacuity: the inherited `structurallyAdmissible_nonempty` establishes the canonical typed witness. Reviewer scratch separately proves structural admissibility for an empty-registry revoke step and a run containing one boundary and one revoke step; both proofs use only standard axioms. Actual scanner evaluations return `Except.ok ()` for all three concrete encodings. These evaluations are bounded execution evidence for the lexical premise, not a universal lexical proof. See `AstraR28Witnesses.lean` and final successful `171622650988.log`.
- The first supplementary witness attempt failed to synthesize `Decidable` because the reviewer had not unfolded the relevant concrete predicates and finite lists. Its source and failed log are retained as `AstraR28Witnesses-initial.lean` and `171601068855.log`. After correcting only reviewer scratch unfolding, both proofs compiled without `sorryAx`. This was not a candidate defect.
- Post-validation recheck: all 211 frozen bindings still match. The axiom inventory has an exact, nonempty 38-name denominator; evidence-log hashes were checked. See `171659562411.log`.

Suggested next proof work is the general depth correspondence and a canonical-encoding lexical invariant. These are remaining program obligations, not repairs required to accept the scoped R28 additions. Preserve AGY authorship and the explicit empty-registry limitation when integrating this recovered contribution.

`commands.json` records verification argv, cwd, UTC start/end, exit status, raw output paths and SHA-256 hashes. Preliminary read-only navigation is not claimed as a verification command. `MANIFEST.json` hashes all review output files except itself and is written only after the final validation command.
