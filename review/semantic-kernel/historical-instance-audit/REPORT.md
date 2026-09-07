# Concrete-instance correspondence audit

**The fresh bounded checks pass; concrete all-input correspondence remains unestablished.** All five root observations are confirmed, with the distinction that the composition equation remains a meaningful bounded check even though the identification of `ex` with `maxOf` is built into the script.

The unchanged `formal/v3/m5-convex.mjs` ran at `4d42600082d4213d34ac5ab4b0dfc3eefde23d5e` under Node **v24.18.1**, completed in **14.83 seconds**, and produced empty stderr. [Execution identity](execution.json) records exact UTC times, command, environment, source revision and raw log hashes. [Raw stdout](stdout.log) contains the actual counts. This audit checked every expected result block and its nonempty denominator; exit zero alone was not treated as success.

| Actual current result | LSTAR | PARSED_NEW |
| --- | ---: | ---: |
| Extracted edge occurrences / distinct edges | 13 / 12 | 16 / 15 |
| Vertices / SCCs / nontrivial SCCs | 58 / 58 / 0 | 58 / 58 / 0 |
| Nonempty size 1–3 equality seeds / mismatches | 32,567 / 0 | 32,567 / 0 |
| Fixed singleton/pair union splits / failures | 30,856 / 0 | 30,856 / 0 |
| Distinct closed states in anti-exchange loop | 1,700 | 1,697 |
| Ordered outside-point tests / violations | 5,169,336 / 0 | 5,142,758 / 0 |
| Generator-index composition pairs / failures | 1,464,616 / 0 | 1,464,616 / 0 |
| Singleton closures equal to their seed | 49 / 58 | 48 / 58 |

## What the execution establishes

At `m5:49–60`, both `Cn` and `reach` are defined locally from the same extracted adjacency. They use different traversal algorithms, so disagreement can expose an implementation error. Their agreement does **not** compare a separately shipped closure implementation to graph reachability. No closure export from `lib.mjs` or another implementation is called.

At `m5:93–102`, `ex(A)` is defined as `maxOf(A)`. The experiment therefore does not test the intrinsic definition `a ∉ Cn(A \ {a})` against maximal elements. It does test the resulting composition identity on its selected states. Calling the entire test a tautology would overcorrect the evidence.

The equality loop omits the empty set: its exact denominator is `58 + choose(58,2) + choose(58,3) = 32,567`. Including empty would yield 32,568. The union loop tests only `A={E[i]}`, `B={E[j],E[k]}` for `i<j<k`; it does not test every partition or every pair of small sets.

Anti-exchange deduplicates closures of singleton/pair generators and explicitly adds empty. Its point loop uses ordered, distinct `x,y` outside each closed state, rather than every `58²` pair. It covers only that selected closed-state family.

Composition has **1,711 generator indices**, formed with `i≤j`, and does not deduplicate their closures. The distinct nonempty state counts are therefore 1,699 and 1,696, derived from the anti-exchange state counts minus empty. There are respectively 12 and 15 redundant index entries. The reported 1,464,616 pairs are index pairs with repetition; the corresponding distinct unordered state-pair counts are 1,444,150 and 1,439,056. Empty is absent from this loop.

All violation counters only print. None sets a failing exit code or throws. This wrapper's parsed-counter verdict is separate from the historical script's process status.

An additional scope guard: `definiteArcs` removes self-loops before SCC analysis. Thus the later self-loop count of zero is not an independent test of original rule self-implications. This removal preserves reflexive-transitive reachability and does not itself invalidate an antisymmetry argument.

## Dependencies and theorem boundary

The actual runtime read closure contains **eight repository files**: three JavaScript modules, `viz/src/data.ts`, `algebra/blind-test-set.json`, and all three files in `corpus50/lanes`. The last four files are read eagerly by `tables.mjs`; their corpus classifications do not enter this experiment's numerical loops. Their inclusion gives no holdout-validation credit. The directory listing and every file's Git/hash identity are bound in [before.json](before.json).

Five additional files were inspected as context, not executed. `formal/v2/f8.mjs` contains a separate rule-saturation `Cn`; `viz/src/laws.ts:closureOf` is a different, depth-limited display helper that traverses alternatives and omits the seed. Neither is called by `m5`, and neither should silently stand in for the intended closure.

Lean defines intrinsic `ex`, proves `ex_reachCl`, and proves `ex_reachCl_union_ex` under antisymmetry of reflexive-transitive reachability. `ex_oplus` additionally takes closed-input premises. The JavaScript's “maximal” orientation reverses the reachability order; the generic Lean identification already explains this convention. These are generic statements, not an encoding of this particular extraction.

To justify `cor:ourconvex` for every subset, select the exact vocabulary/table, encode its relation, prove the intended executable closure agrees with `reachCl` for every input, and establish antisymmetry for that encoded relation. Then instantiate the existing extreme-point and composition results with the same representation. A structural correspondence proof suffices; exhaustive `2^58` execution is unnecessary. Algebraic equality remains separate from the paper's word-RAM complexity proposition.

## Historical comparison and preservation

The fresh seed, split, anti-exchange, composition and principal-closure counts match the frozen historical report text. Its graph summaries print **13/16 arcs**, whereas this run prints **12/15 distinct edges** after deduplication. The paper's 15-arc figure corresponds to the raw-table distinct count, not the LSTAR graph. Old executions retain their original identities; matching counters do not reconstruct their source revision or validate an all-input conclusion.

[The audit JSON](audit.json) contains 20 exact source locators and **182 passing counter/provenance checks**. All **116 protected files**, including all **88 frozen Sprint 10 inputs**, remained unchanged. Full snapshots of runtime inputs and comparison context are retained.

Reviewer: nonauthor GPT-6 through the stock Codex harness; provider telemetry unavailable. No Lean build, new model, native review, original generator modification, corpus change or commit occurred. The resolved standalone Node binary resides under an existing `.foreman/tools` directory; no Foreman orchestrator was invoked. This is a source/measurement audit, not formal correspondence or paper acceptance.
