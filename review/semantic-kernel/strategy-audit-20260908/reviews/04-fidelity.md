# Independent strategy audit 04: financial fidelity and scientific validity

Recommendation: **keep the semantic kernel and verified libraries; simplify the execution agenda around two source-bound reuse demonstrations before further broad implementation.** The approach can support a broadly reusable verification platform. Current evidence does not yet establish that platform's faithful application to real financial software. More generic theorems, corpus imports, or certificate plumbing alone cannot establish it.

The user's clarified priority is a reusable platform and libraries, not a publication-first exercise. The pilot below is a resource gate for that platform, not a replacement objective.

## Scope and evidence identity

Read the primary AGENTS.md, approved 2026-09-06 semantic-kernel design, source proposal, current roadmap/progress ledger and program WORKSTATE. Examined bounded actual artifacts in three candidate worktrees. No source edits, deletions, broad builds, web retrievals, or agents. No excluded assessment/holdout payloads or `/tmp/historical-discovery-r2/discovery.json` were opened. Graph rebuilding was not appropriate to this bounded source audit or its restricted outputs. The repository's defi-footguns skill and gate register informed evidence classification.

Paths below use these explicit roots:

- `P` = `/home/charl/defiformal`
- `C` = `/home/charl/defiformal-wt-corpus-grok-gpt6-20260908`, observed HEAD `ed94e6050d092e67f945df7b9762d3096ab0feda`
- `H` = `/home/charl/defiformal-wt-historical-grok-gpt6-20260908`, same observed HEAD
- `L` = `/home/charl/defiformal-wt-liquidity-grok-gpt6-20260908`, observed HEAD `a12b7cac05a818cc8d35c2ca440b7170a2807e92`

These HEADs are context, not a claim that uncommitted candidate files equal those commits. This audit inspected current file bytes; it does not accept an entire lane. Bounded executions used Python with `-B` and in-memory source loading/mutation, leaving source unchanged. No Solidity execution or new Lean proof checking was performed.

## Findings

**1. Source authenticity is a blocking platform boundary, even when records honestly say factual acceptance is false.** In `C/corpus/adjudicated/v1/inputs/sources.json:12369–12401`, EigenCloud attempt u15-s1:a0 retains 5,474 bytes, HTTP403 and `classification: substantive`, justified as `nonempty_retained_bytes`. I opened the referenced attempt-1.body: it begins with a `Just a moment...` challenge title, not financial documentation. Attempt2 is likewise classified substantive and has the same challenge-page beginning. The import preserves the failure status and remaining gap, which is good; the substantive classification is still false. A hash authenticates these error bytes, not their financial evidentiary value. This is a candidate import defect, not evidence that an accepted factual overlay already relied on it.

**2. Byte-valid citations can be semantically attached to the wrong object.** `C/corpus/adjudicated/v1/inputs/sources.json:1121–1184` attaches `bonding:funded-safe` and `bonding:vouch-and-release` body coordinates to the retained 10,874-byte CoW 404 sibling. The original `C/review/semantic-kernel/corpus-provenance-adjudication/source-research/cow-solver-collateral/retrievals.json:20–49` marks that capture failed, HTTP404 and `support_credit: false`. The locator source, `.../evidence-locators.json:4–26`, explicitly binds funded-safe to a different corrected 31,659-byte capture and to derived `bonding.txt` bytes 648–2391, with coordinate space “Derived UTF-8 text bytes, not HTML response offsets.” The imported record instead calls that span `space: body` on the failed sibling. I inspected the actual 404 body as well as both records. Required invariant: cited span -> exact derived artifact -> extraction record -> exact original successful response; failed attempts remain separate. Merely checking span bounds and SHA fields is insufficient.

**3. Differential arithmetic evidence currently has a concrete source-semantics gap.** `L/review/semantic-kernel/concentrated-liquidity/planning/grok-gpt6-official-r1/cl_oracle.py:172–185` uses unbounded addition for the token0-add denominator. Retained upstream `L/review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-evidence/upstream/contracts/libraries/SqrtPriceMath.sol:36–47` uses a uint256 denominator and tests the wrapped sum, selecting a fallback on sum overflow even when multiplication fits. The oracle's header acknowledges unbounded integers and only multiplication wrap modeling (`:9–10`); that limitation affects its advertised reference algorithm.

I executed this bounded counterexample against the actual Python oracle, separately evaluating the retained source's fallback formula:

```
sqrtP    = 1461446703485210103287273052203988822378723970341
liquidity= 340282366920938463463374607431768211455
amount   = 79231140595944432132633395200
add      = true
product fits uint256: true; numerator1 + product overflows: true
oracle   = 340269576559062238486532777016390125584
fallback = 340269576559062238486532777020684770012
```

sqrtP is MAX_SQRT_RATIO−1; input widths fit. This is executable evidence of disagreement with the source-branch arithmetic, not an EVM result or a deployed exploit. Reachability in a full pool was not established. Both source-correspondence bounds and financial reachability must be stated separately. The difference demonstrates why a second transcription cannot be the sole oracle for a faithful library.

**4. The intended mutant positive control is not unaffected.** `L/openspec/changes/concentrated-liquidity-library/planned-mutations.json:111–120` makes M09 flip the direction predicate but protects F28. F28 has current price 2^96 and target 2^96−1 (`fixtures.json:802–827`), so it uses that predicate. Applying precisely the corresponding predicate flip in an in-memory copy of the Python oracle (`cl_oracle.py:242`) changes F28 amountIn from 2 to 1; its other published amount/fee outputs remain 1. Thus the planned positive assertion fails for the intended mutant. This is a planning-control contradiction, not a claimed compiled Lean mutant run. Repair control selection before crediting mutation counts.

**5. Historical evidence is reusable only within its reviewed mathematical object.** `H/review/semantic-kernel/claim-reconciliation/implementation/grok-gpt6-claim-closure-r2/scenario-evidence.json:68–71,411–414` attaches the historical Lean review to H02 Independence and H12 Interface. The actual cited `H/review/semantic-kernel/program-loop-20260908/historical-lean-ed94-gpt6-review.md:3–11` accepts the Convex/Saturation/Instances/Counterexamples bridge and explicitly excludes claim overlays. That report does not establish the mapped Independence/Interface scope assertions. The candidate marks independent review pending; preserve that honesty and replace the unsupported links with exact source inspection or scoped review. Do not discard the historical Interface counterexample or change its theorem.

The same r2 `measurement-table.json:39–79` records the latticeconf R∩W headline but follows it with seeded R-only intersection measurements. Actual retained R∩W comparison numbers are in `H/formal/v3/VERIFICATION.md:78–101`: seeded intersection failures 50,223 / 50,611 / 50,276 and the size≤3 exhaustive 32,188,276 pairs / 396,437 failures. The table's 3,342 / 2,955 / 2,809 values belong to a different predicate/universe. I verified the mismatch by reading both, without rerunning the historical experiment. Reconciliation must compare like predicates and universes; an attractive common pair count is not equivalence.

**6. Development coverage cannot estimate generalization.** All existing 75 units remain development. Prior twelve REPORT labels are exposure records, not recovered original assessment IDs. `C/corpus/adjudicated/v1/metadata/prior-exposure-ledger.json:5–34` explicitly preserves development status, original ID unknown, unresolved aliases and no opened assessment payload. Those distinctions are correct. Do not compute an untouched score from them, infer a 75+12 disjoint denominator, or treat additional pages from the same publisher as independent corroboration. Reusable interfaces can be tested on development examples now; untouched generalization requires a later frozen selection and evaluator workflow.

## Smallest useful platform validation

First freeze a source-to-result vertical slice for the retained Uniswap v3 token0 next-price operation. Compile/run the pinned Solidity source with its compiler settings through a minimal harness, then compare the same inputs with the Lean library executable. Include product-overflow, sum-overflow, non-overflow, both add/remove directions, zero input and refusal cases. Require exact returned values and refusal classification. Bind inputs, compiler/source, model, theorem identities, assumptions and observations in one minimal evidence record. Prove a scoped arithmetic/library property and instantiate an existing kernel accounting/authority or framing result in a small operation wrapper; keep the external source correspondence evidence distinct from the Lean theorem.

Then use one contrasting already-development financial operation: a pinned vault deposit/withdrawal with share rounding and an asset-transfer refusal is preferable to another AMM formula. Select an already-retained implementation with adequate source and revision evidence; if none is ready, record that source prerequisite instead of inventing fidelity. Compose the operations through the existing sequential interface where financially meaningful, exposing dimensions, holdings and refusal behavior. This second case tests reuse, not untouched generalization.

Exact success criteria:

1. Every credited source span resolves to the correct artifact and coordinate space; challenge/404 captures receive zero semantic support.
2. Zero unexplained source/model differences on the declared nonempty boundary matrix and a predeclared deterministic bounded input set. Each omitted source behavior has an explicit scope exclusion before scoring.
3. Each characteristic production mutant is applied singly, reaches the intended branch, changes its designated observation and preserves a genuinely unaffected control. Neither compile failure nor oracle-only mutation earns production detection credit.
4. Both examples use the same evidence schema, refusal vocabulary and interface checker. The second adds adapter/library code and proof instantiations, with no edits to generic theorem statements or checker exemptions. Record person/agent effort and changed module classes, including new assumptions.
5. At least one two-operation preservation result is instantiated, and a financial negative (wrong asset, insufficient transfer, invalid rounding/direction) is rejected at its intended boundary. Runtime reference agreement remains bounded evidence; universal claims require the corresponding proof.

Stop broad library/corpus expansion if any criterion fails. One source mismatch stops fidelity credit for that scope until explained. If the second case needs a new kernel concept or changes global proofs, stop the reuse claim, record the counterexample to the interface design, and revise only that boundary before widening. This does not prove the platform impossible; it falsifies the present claim that the interface is already reusable unchanged.

## Prerequisites and deferrals

Prerequisites are exact arithmetic/rounding/refusal semantics, trustworthy source identity and spans, a minimal executable adapter, existing typed interfaces/composition results, and evidence binding that refuses unknown support. They are directly exercised by the two cases. A certificate checker can initially support only their shared evidence format; a certificate proves its decoded formal obligation, not the authenticity of its protocol model.

Full 169-item source closure, all historical paper reconciliations, Curve/redemption/loss-allocation/async/margin library breadth, universal adapter ambitions, atlas polish and publication are deferrable. Preserve unfinished and negative evidence; isolate inaccurate historical headlines rather than purging counterexamples. Avoid using completion of those inventories as the platform's success metric.

The existing architecture has the right separation in `P/docs/superpowers/specs/2026-09-06-semantic-kernel-design.md:9–13,35–54,64–77`: conditional composition, source correspondence and explicit limits. The efficient strategic change is to make that separation executable across two real source-bound cases before purchasing further breadth. This audit sampled a few consequential boundaries, not the entire corpus, Lean development or deployed state.
