# Independent frozen Grok R2 review

Verdict: **ACCEPT WITH LIMITATIONS** for the new depth transport proofs and partial scanner continuation library. No proof repair is required. This is not P19, P20, or P37 acceptance and does not prove EncodeDecodeRoundtripStatement.

Reviewer: independent nonauthor gpt-6-astra, medium reasoning, agent /root/astra_grok_r2_review. Author identity is the frozen root record: requested grok-4.6, reported grok-4.6-build. Reviewed only the frozen astra-grok-r2 sandbox; no live author source/cache was accessed. Production sources were not changed.

## Mathematical scope

CompositionDepth proves representation-metric equality at every fuel for input sources, invocations, steps, output observations, step payloads, run payloads, and all DecodedIR constructors. Step handling includes invoke, issue, revoke, and unsupported. Invocation handling includes literal/prior-output inputs and both claimedActor branches. Step payloads cover actual config, boundary, index, history, step, and pre-state. Run payloads cover config, boundaries, world, and all steps. Configuration equality uses the inherited component theorem for every catalog entry, without an empty-registry or empty-catalog restriction.

The general depth bound follows from unchanged StructurallyAdmissibleIR, whose SupportedIR conjunct already contains WholeDocumentDepthBounded. Equality at fuel 100 transfers the old semantic JSON bound to TreeJson.toJson; the inherited valid-tree min-depth theorem then yields actual syntactic depth at most 64. This closes the representation gap rather than adding syntactic depth to admission. WholeDocumentDepthBounded and structural admission are byte-identical to R1.

The strongest production theorem is decodeBytes_encodeModule_of_lex: structural admission plus scanLexical(encodeModule ir)=ok implies decodeBytes(encodeModule ir)=ok ir. Beyond admission, only lexical success remains. The names resolve to the unchanged production Encode/Decode implementation, including UTF-8, canonical parsing, decoding and byte equality checks. This is a useful conditional theorem, not an unconditional roundtrip proof; the remaining premise is explicitly a desired scanner-success obligation and has not been disguised as admission.

Lexical contributes 58 theorems and 5 definitions, including the three mutual scan-cost definitions. It establishes scanner continuations for null, booleans, strings, integer buffers, and empty containers; string keys require freshness, and delimiters require valid numeric buffers where appropriate. scanLexicalCheckNum_numBuf discharges the buffer condition for encoded scalar numbers. The combined scalar theorem explicitly excludes nonempty arrays and objects. Nonempty list/object induction, visited-key disjointness, comma counts, sufficient fuel, the outer scanLexical wrapper theorem, universal h_lex, and EncodeDecodeRoundtripStatement remain open. No narrowing of historical statements or alternative codec was found.

## Inventory and verification

- Source-authored inventory: 78 declarations, consisting of 15 CompositionDepth theorems and 63 Lexical declarations (58 theorems, 5 definitions). No new source-declared instances or private declarations.
- Full elaborated inventory: 132 constants, 22 owned by CompositionDepth and 110 by Lexical; 98 theorem constants and 34 definitions. The additional 54 are compiler-generated helpers/equations, including 6 private constants. Exact names and transitive axiom sets are in compiled-inventory.json.
- Explicit #print axioms ran on all 78 source-authored names, then all 132 compiled names. Private numeric Name components required exact Name construction and elaboration of #print axioms syntax. All 132 resolved; only propext, Classical.choice and Quot.sound occur, with no sorryAx, native or custom axioms.
- Fresh private lake build of CompositionDepth, Lexical and Verify passed, 943 jobs. The log confirms all three targets were Built, not replayed; pinned inherited dependencies were reused. Lean 4.33.0-rc2 and all 9 package commits matched the frozen manifest. .lake, build and package directories are not symlinks.
- All 422 frozen file hashes and the archive hash/content matched before and after review. All inherited Lean sources match R1 except Verify, whose only diff adds the two imports. Roundtrip remains byte-identical, preserving 246 theorems **and 45 definitions**. DepthBridge and IRDepth also match frozen R1 copies.
- Author MANIFEST's 86 bindings pass, including root-relative lean paths and evidence-relative other paths. All 14 command records match their individual receipts, raw stream hashes, unchanged command-time source hashes, and local recorder hash. All commands ended before the author seal timestamp.
- Unchanged 54/21/7 campaigns were not rerun or credited as new tests.

## Findings

R2-E01, low, report accuracy: REPORT's “Lexical compile iterations v1–v7 | failed attempts preserved” incorrectly includes v3, whose receipt records exit 0. Actual failed build iterations are v1, v2, v4, v5, v6 and v7; v3 and v8 passed. Root should record this correction alongside acceptance without rewriting frozen author evidence.

R2-E02, informational, audit coverage resolved by this review: the author's generic Lexical helper resolved only 4/60 top-level matches and the author probe printed only selected names. Neither is a complete audit. This review independently covers all 78 authored and all 132 compiled constants.

R2-E03, informational, recorder routing: the root recorder still targets historical agy-r27-proof; the author's local copy differs only by EVIDENCE=grok-20260919-r2. Receipt recorder hashes match that local copy. This is a traceable evidence destination correction, not evidence contamination. Preserve the diff and use the intended destination in future dispatches.

## Review evidence limitations and failures

commands/ contains actual argv, cwd, start/end UTC, exit, raw stdout/stderr and SHA-256 for substantive verification runs. Initial instruction/path discovery, a few read-only inspections, recorder setup and final artifact writing were tool calls but were not wrapped; no retroactive timing/stream telemetry is invented for them. The initial context read failed because two design files are absent from the frozen bundle; their main-repository instruction copies were subsequently read, without consulting live author source.

Reviewer failures are preserved: validate-author first rejected an overbroad multiline regex; its script is saved as evidence-failed-v1.py. The prematurely launched all-compiled-axioms then failed because generation had stopped. all-compiled-axioms-v2 printed accessible names but failed on textual private numeric names. ExactAxioms.lean fixes query construction without modifying candidate source, and its successful receipt plus full name-set reconciliation supplies the complete audit. These failures are not candidate proof defects.

The self-excluding MANIFEST is written only after all command receipts and final artifacts exist. Its seal script revalidates every raw stream and all frozen inputs. Review is advisory scoped evidence; root retains integration and full-program adjudication responsibility.
