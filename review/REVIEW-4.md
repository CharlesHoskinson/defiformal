# Round 4 — Halmos and Gottlieb on the manuscript

The manuscript contains a sound mathematical core, but it is not yet publishable. The blocking faults are not cosmetic: the paper mixes two inequivalent requirement systems, applies structural theorems to a larger admissibility class than they prove anything about, and gives the bilattice/AFT discussion a precision its statements do not currently possess.

## Must change before publication

1. **The central object changes meaning. Both readers agree this is the principal defect.**

   [atlas.tex:47–50](/root/defiformal/paper/atlas.tex:47) says:

   > “Admissibility is the agreement set of an inflationary and a deflationary map.”

   But [atlas.tex:318](/root/defiformal/paper/atlas.tex:318) defines
   \(\Adm=\mathcal R\cap\mathcal W\cap\mathcal H\), and [atlas.tex:328–333](/root/defiformal/paper/atlas.tex:328) adds grounding and conditional clauses to obtain \(\Admf\). Agreement of \(\Gamma\) and \(\Delta\) can describe at most \(\mathcal R\cap\mathcal W\), assuming \(\Gamma\) is strengthened so that its fixed points are exactly \(\mathcal R\). It says nothing about \(\mathcal H\), grounding, or conditional rows.

   The same drift recurs at [atlas.tex:337–340](/root/defiformal/paper/atlas.tex:337), which calls the lattice and convex-geometry results results “about \(\Adm\),” and at [atlas.tex:758](/root/defiformal/paper/atlas.tex:758), which calls “\(\Adm\) a complete lattice.” The actual theorem at [atlas.tex:387–398](/root/defiformal/paper/atlas.tex:387) proves only that \(\mathcal R\cap\mathcal W\) is a complete lattice. Fresh execution of `m2-latticeconf.mjs` confirms that \(\top\in\mathcal R\cap\mathcal W\) but \(\top\notin\Adm\).

   There are two further contradictions inside this definition:

   - [atlas.tex:264–266](/root/defiformal/paper/atlas.tex:264): “\(\War\) … is obtained as the residual.”
   - [atlas.tex:728](/root/defiformal/paper/atlas.tex:728): “The warrant relation is not the residual.”

   And [atlas.tex:330–332](/root/defiformal/paper/atlas.tex:330) says every conditional prohibition has at least two negative literals and a positive one, while [atlas.tex:431–439](/root/defiformal/paper/atlas.tex:431) correctly classifies \(X2,X21\) as purely negative and \(X11a^*\) as dual-Horn.

   **Required revision:** define, separately and permanently:

   \[
   C_{\mathrm{fit}},\quad C_{\mathrm{res}},\quad
   \mathcal P=\mathcal R\cap\mathcal W,\quad
   \Adm_0=\mathcal P\cap\mathcal H,\quad
   \Adm_{\mathrm{op}}.
   \]

   State the diagonal, lattice, and bilattice claims only for \(\mathcal P\). Define the conditional rows neutrally, then classify them in Proposition 3.9. Rewrite the abstract, introduction, notation table, trade-off section, open problems, and conclusion accordingly.

2. **Two inequivalent requirement systems are used, despite the claim that every figure uses one.**

   [atlas.tex:1228–1238](/root/defiformal/paper/atlas.tex:1228) distinguishes a recorded 29-row system from a reduced 11-row system and concludes:

   > “Every figure in this paper is computed under the recorded rows.”

   That is false. The structural harness uses `gammaOpen`, hence the hand-normalised `LSTAR`, at [formal/v3/lib.mjs:9](/root/defiformal/formal/v3/lib.mjs:9). Constructions and canonical forms use `PARSED_NEW` at [formal/v3/construct.mjs:27](/root/defiformal/formal/v3/construct.mjs:27) and [formal/v3/construct.mjs:49](/root/defiformal/formal/v3/construct.mjs:49).

   Fresh computations give:

   | System | distinct definite arcs | compressed protocols | order-book venues drop |
   |---|---:|---:|---|
   | `LSTAR` | 12 | 28/72 | \(Ct\) only |
   | `PARSED_NEW` | 15 | 29/72 | \(Ct,Ex,Li\) |

   This explains the manuscript’s incompatible claims that \(D\) has 15 arcs at [atlas.tex:823–826](/root/defiformal/paper/atlas.tex:823) but the specialization structure has 12 at [atlas.tex:1023–1025](/root/defiformal/paper/atlas.tex:1023).

   The inconsistency reaches the validation denominator. For subsets of size at most three, I obtained:

   - `PARSED_NEW`: 18,570 models, 172,431,735 unordered pairs with diagonal.
   - `LSTAR`: 18,966 models, 179,864,061 pairs.

   The latter is the number printed at [atlas.tex:2530–2534](/root/defiformal/paper/atlas.tex:2530), while the canonical applications use the former system.

   **Required revision:** choose one authoritative \(\Law\), make every predicate and script import it, then regenerate every theorem witness, pair count, canonical form, profile, table, and validation result. Until that is done, the headline canonical and empirical results do not belong to one model.

3. **The bilattice proposition is not presently a mathematical statement, and the AFT conclusion is overstated.**

   [atlas.tex:465–480](/root/defiformal/paper/atlas.tex:465) claims that the diagonal is not “obtained” from a product using bilattice operations and projections. Bilattice operations act on elements; projections change codomain; the proof instead speaks of a *set* “built from” these operations. No term algebra, relational clone, image operation, or permitted set construction is defined. Therefore:

   > “Any set built … is a product \(S\times T\)”

   does not follow from Avron’s representation theorem as stated.

   At [atlas.tex:494–513](/root/defiformal/paper/atlas.tex:494), the inequality
   \(\Gamma(x)\le\Delta(x)\le x\le\Gamma(x)\) is correct under the stipulated diagonal assignment. But a standard exact AFT approximator already requires \(A(x,x)=(O(x),O(x))\); assigning \((\Gamma(x),\Delta(x))\) is non-exact unless the two agree. The claim at [atlas.tex:516–520](/root/defiformal/paper/atlas.tex:516) that exchanging the roles is “admissible” has the same exactness problem.

   **Required revision:** either define the precise closure operations on subsets and prove the bilattice non-definability result, or delete it. Recast the AFT theorem as a narrow consistency observation about the proposed two-map diagonal; do not say that AFT itself cannot represent the problem. In either case, stop calling \(\mathcal R\cap\mathcal W\) “admissibility.”

4. **The composition theorem has a valid witness, but the paper does not prove it where it is stated and uses one protocol name for two different sets.**

   [atlas.tex:664–667](/root/defiformal/paper/atlas.tex:664) states non-preservation without proof. The witness appears only hundreds of lines later at [atlas.tex:1124–1139](/root/defiformal/paper/atlas.tex:1124). Worse, “Uniswap” in that example means its corpus decomposition, which is admissible, while the retained Uniswap construction at [atlas.tex:1567–1571](/root/defiformal/paper/atlas.tex:1567) is not admissible because it arms \(X21\).

   Here the readers initially differ. Reader Two sees an invalid counterexample because the named endpoint is elsewhere declared inadmissible. Reader One’s computational check resolves the mathematics: the decomposed Uniswap and Aave sets are individually in \(\Admf\), and their union arms \(X2\). The theorem survives; the notation does not.

   **Required revision:** prove Theorem 7.2 immediately with the two full decomposed sets. Introduce distinct notation for a protocol’s decomposition and an application’s exhibited construction, for example \(D(P)\) and \(X_P\). Never write simply “Uniswap” inside a set equation.

   Also reorder the paper: \(\oplus\) is already used at [atlas.tex:421–423](/root/defiformal/paper/atlas.tex:421), defined at line 656, and defined using \(Cn\), which is itself not defined until [atlas.tex:784](/root/defiformal/paper/atlas.tex:784).

5. **The purported 11,026-element composable fragment is missing.**

   [atlas.tex:669–672](/root/defiformal/paper/atlas.tex:669) says:

   > “A witnessed lower bound of \(11{,}026\) admissible sets is exhibited below.”

   It is not exhibited anywhere in either document. At [atlas.tex:2092](/root/defiformal/paper/atlas.tex:2092) and [atlas.tex:2136](/root/defiformal/paper/atlas.tex:2136), the conjecture is incorrectly called a “Measurement” and is said to report a semilattice and an interval that it does not contain.

   **Required revision:** publish the definition of \(F\), prove it is union-closed or \(\oplus\)-closed, state both bounds and their universes, and connect a reproducible script to the statement. Otherwise remove 11,026, the interval, “measured fragment,” and every conclusion based on them.

6. **The residue classification is stale, arithmetically inconsistent, and unavailable where the argument needs it.**

   [atlas.tex:2203–2218](/root/defiformal/paper/atlas.tex:2203) says there are 689 residue obligations, 385 classified, and 301 unclassified. But \(385+301=686\). The seven named categories now contain 404 residue rows, not 385. Phrases such as:

   > “available when it was made,” “first seven categories to complete,” and “categories that arrived later”

   describe workflow history, not a defined sample.

   The statement at [atlas.tex:2220–2222](/root/defiformal/paper/atlas.tex:2220) that the full classification exists “in the development” exiles the load-bearing evidence for the abstract’s three proposed extensions.

   **Required revision:** classify the current 689 rows, publish the row-to-class assignment in the supplement, and regenerate all counts and rankings. If only a subset is retained, define it by an ex ante rule, give its current denominator, and present the repairs as hypotheses from that subset rather than corpus conclusions.

7. **Several current numerical claims no longer match their generators.**

   The clearest example is [atlas.tex:1162–1184](/root/defiformal/paper/atlas.tex:1162). The article gives 205 approximate rows, 36.0%, and 29.0% strict coverage. Fresh execution of `node formal/v3/sensitivity.mjs` gives:

   > 207 rows; 36.3%; strict coverage 28.8%.

   All four retained case studies have a stale off-by-one sentence:

   - Uniswap: 12 residue, then 13 at [atlas.tex:1567–1576](/root/defiformal/paper/atlas.tex:1567).
   - Lido: 8, then 9 at [atlas.tex:1698–1708](/root/defiformal/paper/atlas.tex:1698).
   - WBTC: 15, then 16 at [atlas.tex:1836–1845](/root/defiformal/paper/atlas.tex:1836).
   - Rysk: 12, then 13 at [atlas.tex:1967–1976](/root/defiformal/paper/atlas.tex:1967).

   The supplement’s actual lists agree with 12, 8, 15, and 12 respectively. Its evidence section contains 658 dated entries and 638 distinct URL strings; [atlas.tex:204–206](/root/defiformal/paper/atlas.tex:204) says 639 distinct sources.

   **Required revision:** generate every repeated count from one data source. Delete redundant prose such as “The 13 obligations…” when the measurement has already supplied the count.

8. **The supplement does not expose the claim-to-source relation it says it contains.**

   [supplement.tex:2096–2099](/root/defiformal/paper/supplement.tex:2096) says every obligation carries a source, but the rendered document supplies only a deduplicated list of URLs per application “in the order the obligations appear.” That loses a many-to-many mapping: a reader cannot determine which URLs support which obligation.

   This makes the article/supplement division evidentially unsafe. Specific application claims have been removed from the article’s apparatus but are not locally checkable in the appendix.

   **Required revision:** assign every source an ID and place source IDs beside every obligation, or add an obligation-ID-to-source-ID table. The URL inventory can remain at the end.

9. **Several conclusions do rhetorical work that the study expressly says it did not perform.**

   [atlas.tex:1197–1206](/root/defiformal/paper/atlas.tex:1197) correctly says the relation to capital was not measured. Yet [atlas.tex:2012–2014](/root/defiformal/paper/atlas.tex:2012) declares resolution “inversely correlated with capital,” and [atlas.tex:2508–2510](/root/defiformal/paper/atlas.tex:2508) says coverage degrades with off-chain substance. No off-chain fraction is defined or measured.

   Likewise [atlas.tex:169–171](/root/defiformal/paper/atlas.tex:169) claims none of 72 protocols is fully expressible, while obligation ledgers—the stated expressibility instrument—exist for 60.

   Delete or measure these claims. Replace them with the supported statement: the three least-covered categories are intents, bridges, and reserve-backed issuers.

   Unsupported or self-awarding superlatives should also go unless a metric and source are supplied:

   - “several of the largest losses,” [atlas.tex:79](/root/defiformal/paper/atlas.tex:79);
   - “the coarsest such form that is still faithful,” [atlas.tex:86](/root/defiformal/paper/atlas.tex:86);
   - “largest single asset,” [atlas.tex:110](/root/defiformal/paper/atlas.tex:110);
   - “sharpest statement,” [atlas.tex:1133](/root/defiformal/paper/atlas.tex:1133);
   - “sharpest case,” [atlas.tex:1974](/root/defiformal/paper/atlas.tex:1974);
   - “best-evidenced request,” [atlas.tex:2297](/root/defiformal/paper/atlas.tex:2297).

10. **Several mathematical statements need correction even though their applied instances survive.**

   - [atlas.tex:791–796](/root/defiformal/paper/atlas.tex:791): the empty-premise case is false as stated. The closed sets of \(\emptyset\to B\) are union-stable for every \(B\), not only \(|B|=1\). The manuscript uses singleton nonempty premises, so the application survives.
   - [atlas.tex:803–817](/root/defiformal/paper/atlas.tex:803): add the zero-closed/reachability hypothesis; an arbitrary union-stable closure need not be a down-set geometry of the stated specialization order.
   - [atlas.tex:690–702](/root/defiformal/paper/atlas.tex:690): “both alternatives are attained” is insufficient for failure of intersection closure without exclusive witness models.
   - [atlas.tex:569–571](/root/defiformal/paper/atlas.tex:569): “let \(x_\infty\) be the limit” precedes any convergence or stabilization theorem.
   - [atlas.tex:2524–2527](/root/defiformal/paper/atlas.tex:2524): only 20.4% of the displayed clauses being bijunctive does not prove that the represented relation is not majority-closed; wide clauses may be redundant. Supply a three-model majority counterexample.
   - [atlas.tex:2326–2344](/root/defiformal/paper/atlas.tex:2326): \(T\) was defined as a family of terms, but “\(T\cup V\)” treats it as a set of alternatives. Define voiding term-by-term.

## Should change

11. **The argument arrives too late.**

   Reader Two: the opening problem at [atlas.tex:68–91](/root/defiformal/paper/atlas.tex:68) is excellent and gives a reason to continue by page two. The manuscript then delays the named composition argument behind bilattices, AFT, powerset collapse, completion lattices, carrier limitations, and residual repair.

   Reader One: this also violates the spiral plan—\(\oplus\) and \(Cn\) are used before definition, and the main counterexample appears long after its theorem.

   Order the spine as:

   \[
   \text{predicates}\to\text{polarity}\to Cn\to\oplus
   \to\text{named counterexample}\to\text{pair measurement}
   \to\text{compatibility graph}.
   \]

   Move bilattices/AFT, completion lattices, the Lean inventory, and Validation to appendices unless the corrected abstract still makes them central. Merge “What the prohibitions cost” into “Structure and content are in tension.” The blocker section concedes at [atlas.tex:947–960](/root/defiformal/paper/atlas.tex:947) that the corpus instance is degenerate; reduce it to a paragraph or move it.

12. **The twelve category sections accumulate rather than build.**

   Tables at [atlas.tex:1370–1466](/root/defiformal/paper/atlas.tex:1370) already supply the comparison. The following sections repeat category question, footprint or rejection, residue paragraph, supplement notice, and verification boilerplate. Synthesis arrives only at [atlas.tex:2049](/root/defiformal/paper/atlas.tex:2049).

   Replace twelve parallel article sections with three comparative sections:

   - where composition failures concentrate;
   - what canonical forms distinguish;
   - what the vocabulary cannot express.

   Preserve the twelve headings and all 60 profiles in the supplement. If twelve article sections are retained, group and order them by an explicit argumentative progression rather than aggregator taxonomy.

13. **Only two full retained case studies clearly earn their present space.**

   The article does state its rationale at [atlas.tex:1378–1383](/root/defiformal/paper/atlas.tex:1378), which is good.

   - Rysk earns retention because it motivates voided requirements.
   - WBTC earns retention because it motivates the party sort.
   - Uniswap’s composition witness earns a short worked example, but the long v4 profile does not; retain the proof and move the profile entirely to the supplement.
   - The readers differ on Lido. Reader One would retain a shortened argument showing why \(Vl\) conflates several mechanisms. Reader Two would move the full profile because the category paragraph already makes that point.

   All four profiles are otherwise duplicated nearly verbatim in the supplement. Keep interpretation in the article and the complete empirical record in the supplement.

14. **Reduce the environmental apparatus.**

   Many of the 44 measurements are results: failure attribution at [atlas.tex:442](/root/defiformal/paper/atlas.tex:442), vacuity and ablation at lines 599 and 607, pair composition at line 1090, sensitivity at line 1162, non-unique constructions at line 1295, and residue kinds at line 2234.

   Others are bookkeeping already represented by a table or are one sentence placed in a theorem-like box:

   - the residual count, [atlas.tex:732](/root/defiformal/paper/atlas.tex:732);
   - prohibition-table summary, [atlas.tex:947](/root/defiformal/paper/atlas.tex:947);
   - poset count, [atlas.tex:1023](/root/defiformal/paper/atlas.tex:1023);
   - fibre collisions, [atlas.tex:1066](/root/defiformal/paper/atlas.tex:1066);
   - most category footprints/rejections between lines 1524 and 2040;
   - all five Validation measurements at [atlas.tex:2524–2567](/root/defiformal/paper/atlas.tex:2524).

   Put canonical-form counts in one table, category facts in the existing category tables, and validation counts in one appendix table. Reserve `measurement` for findings used by a later inference. Remarks such as the terminology box at [atlas.tex:916](/root/defiformal/paper/atlas.tex:916) should be ordinary prose or a footnote.

15. **Remove visible workflow scaffolding and stitched boilerplate.**

   Consolidate computation provenance in Methods, then delete repeated language beginning at [atlas.tex:1553–1561](/root/defiformal/paper/atlas.tex:1553) and recurring through nine category sections:

   > “Every figure … is emitted from the verification output rather than transcribed.”

   Replace “lanes,” “arrays,” “parser,” “checker,” “shipped table,” “categories to complete,” “arrived later,” and “the development” at lines 1153, 1228, 1285, 1514, 1806, 2208–2222 with terms describing the published method and data. The sentence at [atlas.tex:1649](/root/defiformal/paper/atlas.tex:1649), “Lido is treated here,” inside the collateralised-stablecoin section is a clear copy remnant and must be deleted.

16. **Fix notation and sentence-level production faults.**

   - [atlas.tex:787–788](/root/defiformal/paper/atlas.tex:787) introduces \(\preceq\) but defines \(a\succeq b\); choose one orientation.
   - The paper introduces \(\mathrm{can}(X)=\mathrm{ex}(Cn(X))\) for arbitrary sets at [atlas.tex:1009–1021](/root/defiformal/paper/atlas.tex:1009), then profiles arbitrary and rejected constructions using \(\mathrm{ex}(X)\). Use `can` consistently.
   - \(X19*\) at [atlas.tex:1839](/root/defiformal/paper/atlas.tex:1839) and several supplement profiles should be \(X19^{*}\).
   - “Measurement~ Measurement” is duplicated at [atlas.tex:1060](/root/defiformal/paper/atlas.tex:1060) and [atlas.tex:1147](/root/defiformal/paper/atlas.tex:1147).
   - The 675-of-65,536 sentence is repeated at [atlas.tex:1227–1238](/root/defiformal/paper/atlas.tex:1227), with an erroneous capital “The” after a semicolon.
   - “Across all seeds, 61 exclusions…” at [atlas.tex:604](/root/defiformal/paper/atlas.tex:604) and “Exhaustively over…” at [atlas.tex:2532](/root/defiformal/paper/atlas.tex:2532) lack finite verbs.
   - Supplement obligation bullets alternate between ledger fragments, prose sentences, code, raw algebra, and emphatic capitals. Define one ledger style and use it throughout.

## Hedges and voice

The author-protective hedges I found are:

- “residue suggests,” [atlas.tex:59](/root/defiformal/paper/atlas.tex:59): replace with “the classified subset motivates,” with its denominator.
- “closure appears to satisfy,” [atlas.tex:139](/root/defiformal/paper/atlas.tex:139): it is later proved; write “satisfies.”
- “Width, indicatively … suggest … indication only,” [atlas.tex:675–678](/root/defiformal/paper/atlas.tex:675): this orphan experiment supports no inference; remove it or specify estimand, sampling, and uncertainty.
- “roughly a factor of four,” [atlas.tex:1812](/root/defiformal/paper/atlas.tex:1812): give the exact count of distinctions.
- “We are not aware,” “appears to be unnamed,” and “apparently unstudied,” [atlas.tex:2443–2468](/root/defiformal/paper/atlas.tex:2443): name the databases, terms, and scope searched, or reduce these to “we found no result in the cited literature.”

The following are informative qualifications and should remain: the warning against interpreting 90% as reassurance at [atlas.tex:1142](/root/defiformal/paper/atlas.tex:1142), the unknown tightness of strict coverage at [atlas.tex:1181–1185](/root/defiformal/paper/atlas.tex:1181), the limitation of the listed-row quotient at [atlas.tex:2166–2173](/root/defiformal/paper/atlas.tex:2166), and the admission that perfection has not been tested at [atlas.tex:2190–2198](/root/defiformal/paper/atlas.tex:2190). Those protect the reader, not the author.

## What is sound

The problem statement is lucid and compelling. The Methods section is unusually candid about sampling and missing inter-rater reliability. The polarity lemma is correct for the defined requirement, warrant, and listed-prohibition clauses. The closure results for \(\mathcal R,\mathcal W,\mathcal H\), and the complete-lattice result for \(\mathcal R\cap\mathcal W\), are sound.

The acyclic reachability closure is a convex geometry under either of the two current law extractions, and the canonical composition identity is sound once one extraction is chosen. Fresh `m5-convex.mjs` runs checked 1,464,616 closed pairs for each extraction with zero failures. The cyclic counterexample correctly shows why acyclicity matters. The clique reformulation is also sound.

The current empirical programs reproduce 109 category claims, 22 self-tests, 1,830 pairs, 185 failures, 184 failures arming a Horn row, and six arming a mixed row. These facts should be retained after the model-system split is repaired; they do not cure that split.

## Verdict

**Not yet.** The reason is specific, not cautious: the paper presently claims one model while its proofs and applications compute with two inequivalent requirement systems; it calls \(\mathcal R\cap\mathcal W\) “admissibility” when admissibility was defined to include additional constraints; and two abstract-level obstruction claims are not proved in the form stated. Publication becomes possible when the authors choose one law system, regenerate all results under it, separate positive feasibility from listed and operational admissibility, formalize or remove the bilattice/AFT claims, publish the missing fragment and residue evidence, and synchronize the empirical counts.
tokens used
255,457
The manuscript contains a sound mathematical core, but it is not yet publishable. The blocking faults are not cosmetic: the paper mixes two inequivalent requirement systems, applies structural theorems to a larger admissibility class than they prove anything about, and gives the bilattice/AFT discussion a precision its statements do not currently possess.

## Must change before publication

1. **The central object changes meaning. Both readers agree this is the principal defect.**

   [atlas.tex:47–50](/root/defiformal/paper/atlas.tex:47) says:

   > “Admissibility is the agreement set of an inflationary and a deflationary map.”

   But [atlas.tex:318](/root/defiformal/paper/atlas.tex:318) defines
   \(\Adm=\mathcal R\cap\mathcal W\cap\mathcal H\), and [atlas.tex:328–333](/root/defiformal/paper/atlas.tex:328) adds grounding and conditional clauses to obtain \(\Admf\). Agreement of \(\Gamma\) and \(\Delta\) can describe at most \(\mathcal R\cap\mathcal W\), assuming \(\Gamma\) is strengthened so that its fixed points are exactly \(\mathcal R\). It says nothing about \(\mathcal H\), grounding, or conditional rows.

   The same drift recurs at [atlas.tex:337–340](/root/defiformal/paper/atlas.tex:337), which calls the lattice and convex-geometry results results “about \(\Adm\),” and at [atlas.tex:758](/root/defiformal/paper/atlas.tex:758), which calls “\(\Adm\) a complete lattice.” The actual theorem at [atlas.tex:387–398](/root/defiformal/paper/atlas.tex:387) proves only that \(\mathcal R\cap\mathcal W\) is a complete lattice. Fresh execution of `m2-latticeconf.mjs` confirms that \(\top\in\mathcal R\cap\mathcal W\) but \(\top\notin\Adm\).

   There are two further contradictions inside this definition:

   - [atlas.tex:264–266](/root/defiformal/paper/atlas.tex:264): “\(\War\) … is obtained as the residual.”
   - [atlas.tex:728](/root/defiformal/paper/atlas.tex:728): “The warrant relation is not the residual.”

   And [atlas.tex:330–332](/root/defiformal/paper/atlas.tex:330) says every conditional prohibition has at least two negative literals and a positive one, while [atlas.tex:431–439](/root/defiformal/paper/atlas.tex:431) correctly classifies \(X2,X21\) as purely negative and \(X11a^*\) as dual-Horn.

   **Required revision:** define, separately and permanently:

   \[
   C_{\mathrm{fit}},\quad C_{\mathrm{res}},\quad
   \mathcal P=\mathcal R\cap\mathcal W,\quad
   \Adm_0=\mathcal P\cap\mathcal H,\quad
   \Adm_{\mathrm{op}}.
   \]

   State the diagonal, lattice, and bilattice claims only for \(\mathcal P\). Define the conditional rows neutrally, then classify them in Proposition 3.9. Rewrite the abstract, introduction, notation table, trade-off section, open problems, and conclusion accordingly.

2. **Two inequivalent requirement systems are used, despite the claim that every figure uses one.**

   [atlas.tex:1228–1238](/root/defiformal/paper/atlas.tex:1228) distinguishes a recorded 29-row system from a reduced 11-row system and concludes:

   > “Every figure in this paper is computed under the recorded rows.”

   That is false. The structural harness uses `gammaOpen`, hence the hand-normalised `LSTAR`, at [formal/v3/lib.mjs:9](/root/defiformal/formal/v3/lib.mjs:9). Constructions and canonical forms use `PARSED_NEW` at [formal/v3/construct.mjs:27](/root/defiformal/formal/v3/construct.mjs:27) and [formal/v3/construct.mjs:49](/root/defiformal/formal/v3/construct.mjs:49).

   Fresh computations give:

   | System | distinct definite arcs | compressed protocols | order-book venues drop |
   |---|---:|---:|---|
   | `LSTAR` | 12 | 28/72 | \(Ct\) only |
   | `PARSED_NEW` | 15 | 29/72 | \(Ct,Ex,Li\) |

   This explains the manuscript’s incompatible claims that \(D\) has 15 arcs at [atlas.tex:823–826](/root/defiformal/paper/atlas.tex:823) but the specialization structure has 12 at [atlas.tex:1023–1025](/root/defiformal/paper/atlas.tex:1023).

   The inconsistency reaches the validation denominator. For subsets of size at most three, I obtained:

   - `PARSED_NEW`: 18,570 models, 172,431,735 unordered pairs with diagonal.
   - `LSTAR`: 18,966 models, 179,864,061 pairs.

   The latter is the number printed at [atlas.tex:2530–2534](/root/defiformal/paper/atlas.tex:2530), while the canonical applications use the former system.

   **Required revision:** choose one authoritative \(\Law\), make every predicate and script import it, then regenerate every theorem witness, pair count, canonical form, profile, table, and validation result. Until that is done, the headline canonical and empirical results do not belong to one model.

3. **The bilattice proposition is not presently a mathematical statement, and the AFT conclusion is overstated.**

   [atlas.tex:465–480](/root/defiformal/paper/atlas.tex:465) claims that the diagonal is not “obtained” from a product using bilattice operations and projections. Bilattice operations act on elements; projections change codomain; the proof instead speaks of a *set* “built from” these operations. No term algebra, relational clone, image operation, or permitted set construction is defined. Therefore:

   > “Any set built … is a product \(S\times T\)”

   does not follow from Avron’s representation theorem as stated.

   At [atlas.tex:494–513](/root/defiformal/paper/atlas.tex:494), the inequality
   \(\Gamma(x)\le\Delta(x)\le x\le\Gamma(x)\) is correct under the stipulated diagonal assignment. But a standard exact AFT approximator already requires \(A(x,x)=(O(x),O(x))\); assigning \((\Gamma(x),\Delta(x))\) is non-exact unless the two agree. The claim at [atlas.tex:516–520](/root/defiformal/paper/atlas.tex:516) that exchanging the roles is “admissible” has the same exactness problem.

   **Required revision:** either define the precise closure operations on subsets and prove the bilattice non-definability result, or delete it. Recast the AFT theorem as a narrow consistency observation about the proposed two-map diagonal; do not say that AFT itself cannot represent the problem. In either case, stop calling \(\mathcal R\cap\mathcal W\) “admissibility.”

4. **The composition theorem has a valid witness, but the paper does not prove it where it is stated and uses one protocol name for two different sets.**

   [atlas.tex:664–667](/root/defiformal/paper/atlas.tex:664) states non-preservation without proof. The witness appears only hundreds of lines later at [atlas.tex:1124–1139](/root/defiformal/paper/atlas.tex:1124). Worse, “Uniswap” in that example means its corpus decomposition, which is admissible, while the retained Uniswap construction at [atlas.tex:1567–1571](/root/defiformal/paper/atlas.tex:1567) is not admissible because it arms \(X21\).

   Here the readers initially differ. Reader Two sees an invalid counterexample because the named endpoint is elsewhere declared inadmissible. Reader One’s computational check resolves the mathematics: the decomposed Uniswap and Aave sets are individually in \(\Admf\), and their union arms \(X2\). The theorem survives; the notation does not.

   **Required revision:** prove Theorem 7.2 immediately with the two full decomposed sets. Introduce distinct notation for a protocol’s decomposition and an application’s exhibited construction, for example \(D(P)\) and \(X_P\). Never write simply “Uniswap” inside a set equation.

   Also reorder the paper: \(\oplus\) is already used at [atlas.tex:421–423](/root/defiformal/paper/atlas.tex:421), defined at line 656, and defined using \(Cn\), which is itself not defined until [atlas.tex:784](/root/defiformal/paper/atlas.tex:784).

5. **The purported 11,026-element composable fragment is missing.**

   [atlas.tex:669–672](/root/defiformal/paper/atlas.tex:669) says:

   > “A witnessed lower bound of \(11{,}026\) admissible sets is exhibited below.”

   It is not exhibited anywhere in either document. At [atlas.tex:2092](/root/defiformal/paper/atlas.tex:2092) and [atlas.tex:2136](/root/defiformal/paper/atlas.tex:2136), the conjecture is incorrectly called a “Measurement” and is said to report a semilattice and an interval that it does not contain.

   **Required revision:** publish the definition of \(F\), prove it is union-closed or \(\oplus\)-closed, state both bounds and their universes, and connect a reproducible script to the statement. Otherwise remove 11,026, the interval, “measured fragment,” and every conclusion based on them.

6. **The residue classification is stale, arithmetically inconsistent, and unavailable where the argument needs it.**

   [atlas.tex:2203–2218](/root/defiformal/paper/atlas.tex:2203) says there are 689 residue obligations, 385 classified, and 301 unclassified. But \(385+301=686\). The seven named categories now contain 404 residue rows, not 385. Phrases such as:

   > “available when it was made,” “first seven categories to complete,” and “categories that arrived later”

   describe workflow history, not a defined sample.

   The statement at [atlas.tex:2220–2222](/root/defiformal/paper/atlas.tex:2220) that the full classification exists “in the development” exiles the load-bearing evidence for the abstract’s three proposed extensions.

   **Required revision:** classify the current 689 rows, publish the row-to-class assignment in the supplement, and regenerate all counts and rankings. If only a subset is retained, define it by an ex ante rule, give its current denominator, and present the repairs as hypotheses from that subset rather than corpus conclusions.

7. **Several current numerical claims no longer match their generators.**

   The clearest example is [atlas.tex:1162–1184](/root/defiformal/paper/atlas.tex:1162). The article gives 205 approximate rows, 36.0%, and 29.0% strict coverage. Fresh execution of `node formal/v3/sensitivity.mjs` gives:

   > 207 rows; 36.3%; strict coverage 28.8%.

   All four retained case studies have a stale off-by-one sentence:

   - Uniswap: 12 residue, then 13 at [atlas.tex:1567–1576](/root/defiformal/paper/atlas.tex:1567).
   - Lido: 8, then 9 at [atlas.tex:1698–1708](/root/defiformal/paper/atlas.tex:1698).
   - WBTC: 15, then 16 at [atlas.tex:1836–1845](/root/defiformal/paper/atlas.tex:1836).
   - Rysk: 12, then 13 at [atlas.tex:1967–1976](/root/defiformal/paper/atlas.tex:1967).

   The supplement’s actual lists agree with 12, 8, 15, and 12 respectively. Its evidence section contains 658 dated entries and 638 distinct URL strings; [atlas.tex:204–206](/root/defiformal/paper/atlas.tex:204) says 639 distinct sources.

   **Required revision:** generate every repeated count from one data source. Delete redundant prose such as “The 13 obligations…” when the measurement has already supplied the count.

8. **The supplement does not expose the claim-to-source relation it says it contains.**

   [supplement.tex:2096–2099](/root/defiformal/paper/supplement.tex:2096) says every obligation carries a source, but the rendered document supplies only a deduplicated list of URLs per application “in the order the obligations appear.” That loses a many-to-many mapping: a reader cannot determine which URLs support which obligation.

   This makes the article/supplement division evidentially unsafe. Specific application claims have been removed from the article’s apparatus but are not locally checkable in the appendix.

   **Required revision:** assign every source an ID and place source IDs beside every obligation, or add an obligation-ID-to-source-ID table. The URL inventory can remain at the end.

9. **Several conclusions do rhetorical work that the study expressly says it did not perform.**

   [atlas.tex:1197–1206](/root/defiformal/paper/atlas.tex:1197) correctly says the relation to capital was not measured. Yet [atlas.tex:2012–2014](/root/defiformal/paper/atlas.tex:2012) declares resolution “inversely correlated with capital,” and [atlas.tex:2508–2510](/root/defiformal/paper/atlas.tex:2508) says coverage degrades with off-chain substance. No off-chain fraction is defined or measured.

   Likewise [atlas.tex:169–171](/root/defiformal/paper/atlas.tex:169) claims none of 72 protocols is fully expressible, while obligation ledgers—the stated expressibility instrument—exist for 60.

   Delete or measure these claims. Replace them with the supported statement: the three least-covered categories are intents, bridges, and reserve-backed issuers.

   Unsupported or self-awarding superlatives should also go unless a metric and source are supplied:

   - “several of the largest losses,” [atlas.tex:79](/root/defiformal/paper/atlas.tex:79);
   - “the coarsest such form that is still faithful,” [atlas.tex:86](/root/defiformal/paper/atlas.tex:86);
   - “largest single asset,” [atlas.tex:110](/root/defiformal/paper/atlas.tex:110);
   - “sharpest statement,” [atlas.tex:1133](/root/defiformal/paper/atlas.tex:1133);
   - “sharpest case,” [atlas.tex:1974](/root/defiformal/paper/atlas.tex:1974);
   - “best-evidenced request,” [atlas.tex:2297](/root/defiformal/paper/atlas.tex:2297).

10. **Several mathematical statements need correction even though their applied instances survive.**

   - [atlas.tex:791–796](/root/defiformal/paper/atlas.tex:791): the empty-premise case is false as stated. The closed sets of \(\emptyset\to B\) are union-stable for every \(B\), not only \(|B|=1\). The manuscript uses singleton nonempty premises, so the application survives.
   - [atlas.tex:803–817](/root/defiformal/paper/atlas.tex:803): add the zero-closed/reachability hypothesis; an arbitrary union-stable closure need not be a down-set geometry of the stated specialization order.
   - [atlas.tex:690–702](/root/defiformal/paper/atlas.tex:690): “both alternatives are attained” is insufficient for failure of intersection closure without exclusive witness models.
   - [atlas.tex:569–571](/root/defiformal/paper/atlas.tex:569): “let \(x_\infty\) be the limit” precedes any convergence or stabilization theorem.
   - [atlas.tex:2524–2527](/root/defiformal/paper/atlas.tex:2524): only 20.4% of the displayed clauses being bijunctive does not prove that the represented relation is not majority-closed; wide clauses may be redundant. Supply a three-model majority counterexample.
   - [atlas.tex:2326–2344](/root/defiformal/paper/atlas.tex:2326): \(T\) was defined as a family of terms, but “\(T\cup V\)” treats it as a set of alternatives. Define voiding term-by-term.

## Should change

11. **The argument arrives too late.**

   Reader Two: the opening problem at [atlas.tex:68–91](/root/defiformal/paper/atlas.tex:68) is excellent and gives a reason to continue by page two. The manuscript then delays the named composition argument behind bilattices, AFT, powerset collapse, completion lattices, carrier limitations, and residual repair.

   Reader One: this also violates the spiral plan—\(\oplus\) and \(Cn\) are used before definition, and the main counterexample appears long after its theorem.

   Order the spine as:

   \[
   \text{predicates}\to\text{polarity}\to Cn\to\oplus
   \to\text{named counterexample}\to\text{pair measurement}
   \to\text{compatibility graph}.
   \]

   Move bilattices/AFT, completion lattices, the Lean inventory, and Validation to appendices unless the corrected abstract still makes them central. Merge “What the prohibitions cost” into “Structure and content are in tension.” The blocker section concedes at [atlas.tex:947–960](/root/defiformal/paper/atlas.tex:947) that the corpus instance is degenerate; reduce it to a paragraph or move it.

12. **The twelve category sections accumulate rather than build.**

   Tables at [atlas.tex:1370–1466](/root/defiformal/paper/atlas.tex:1370) already supply the comparison. The following sections repeat category question, footprint or rejection, residue paragraph, supplement notice, and verification boilerplate. Synthesis arrives only at [atlas.tex:2049](/root/defiformal/paper/atlas.tex:2049).

   Replace twelve parallel article sections with three comparative sections:

   - where composition failures concentrate;
   - what canonical forms distinguish;
   - what the vocabulary cannot express.

   Preserve the twelve headings and all 60 profiles in the supplement. If twelve article sections are retained, group and order them by an explicit argumentative progression rather than aggregator taxonomy.

13. **Only two full retained case studies clearly earn their present space.**

   The article does state its rationale at [atlas.tex:1378–1383](/root/defiformal/paper/atlas.tex:1378), which is good.

   - Rysk earns retention because it motivates voided requirements.
   - WBTC earns retention because it motivates the party sort.
   - Uniswap’s composition witness earns a short worked example, but the long v4 profile does not; retain the proof and move the profile entirely to the supplement.
   - The readers differ on Lido. Reader One would retain a shortened argument showing why \(Vl\) conflates several mechanisms. Reader Two would move the full profile because the category paragraph already makes that point.

   All four profiles are otherwise duplicated nearly verbatim in the supplement. Keep interpretation in the article and the complete empirical record in the supplement.

14. **Reduce the environmental apparatus.**

   Many of the 44 measurements are results: failure attribution at [atlas.tex:442](/root/defiformal/paper/atlas.tex:442), vacuity and ablation at lines 599 and 607, pair composition at line 1090, sensitivity at line 1162, non-unique constructions at line 1295, and residue kinds at line 2234.

   Others are bookkeeping already represented by a table or are one sentence placed in a theorem-like box:

   - the residual count, [atlas.tex:732](/root/defiformal/paper/atlas.tex:732);
   - prohibition-table summary, [atlas.tex:947](/root/defiformal/paper/atlas.tex:947);
   - poset count, [atlas.tex:1023](/root/defiformal/paper/atlas.tex:1023);
   - fibre collisions, [atlas.tex:1066](/root/defiformal/paper/atlas.tex:1066);
   - most category footprints/rejections between lines 1524 and 2040;
   - all five Validation measurements at [atlas.tex:2524–2567](/root/defiformal/paper/atlas.tex:2524).

   Put canonical-form counts in one table, category facts in the existing category tables, and validation counts in one appendix table. Reserve `measurement` for findings used by a later inference. Remarks such as the terminology box at [atlas.tex:916](/root/defiformal/paper/atlas.tex:916) should be ordinary prose or a footnote.

15. **Remove visible workflow scaffolding and stitched boilerplate.**

   Consolidate computation provenance in Methods, then delete repeated language beginning at [atlas.tex:1553–1561](/root/defiformal/paper/atlas.tex:1553) and recurring through nine category sections:

   > “Every figure … is emitted from the verification output rather than transcribed.”

   Replace “lanes,” “arrays,” “parser,” “checker,” “shipped table,” “categories to complete,” “arrived later,” and “the development” at lines 1153, 1228, 1285, 1514, 1806, 2208–2222 with terms describing the published method and data. The sentence at [atlas.tex:1649](/root/defiformal/paper/atlas.tex:1649), “Lido is treated here,” inside the collateralised-stablecoin section is a clear copy remnant and must be deleted.

16. **Fix notation and sentence-level production faults.**

   - [atlas.tex:787–788](/root/defiformal/paper/atlas.tex:787) introduces \(\preceq\) but defines \(a\succeq b\); choose one orientation.
   - The paper introduces \(\mathrm{can}(X)=\mathrm{ex}(Cn(X))\) for arbitrary sets at [atlas.tex:1009–1021](/root/defiformal/paper/atlas.tex:1009), then profiles arbitrary and rejected constructions using \(\mathrm{ex}(X)\). Use `can` consistently.
   - \(X19*\) at [atlas.tex:1839](/root/defiformal/paper/atlas.tex:1839) and several supplement profiles should be \(X19^{*}\).
   - “Measurement~ Measurement” is duplicated at [atlas.tex:1060](/root/defiformal/paper/atlas.tex:1060) and [atlas.tex:1147](/root/defiformal/paper/atlas.tex:1147).
   - The 675-of-65,536 sentence is repeated at [atlas.tex:1227–1238](/root/defiformal/paper/atlas.tex:1227), with an erroneous capital “The” after a semicolon.
   - “Across all seeds, 61 exclusions…” at [atlas.tex:604](/root/defiformal/paper/atlas.tex:604) and “Exhaustively over…” at [atlas.tex:2532](/root/defiformal/paper/atlas.tex:2532) lack finite verbs.
   - Supplement obligation bullets alternate between ledger fragments, prose sentences, code, raw algebra, and emphatic capitals. Define one ledger style and use it throughout.

## Hedges and voice

The author-protective hedges I found are:

- “residue suggests,” [atlas.tex:59](/root/defiformal/paper/atlas.tex:59): replace with “the classified subset motivates,” with its denominator.
- “closure appears to satisfy,” [atlas.tex:139](/root/defiformal/paper/atlas.tex:139): it is later proved; write “satisfies.”
- “Width, indicatively … suggest … indication only,” [atlas.tex:675–678](/root/defiformal/paper/atlas.tex:675): this orphan experiment supports no inference; remove it or specify estimand, sampling, and uncertainty.
- “roughly a factor of four,” [atlas.tex:1812](/root/defiformal/paper/atlas.tex:1812): give the exact count of distinctions.
- “We are not aware,” “appears to be unnamed,” and “apparently unstudied,” [atlas.tex:2443–2468](/root/defiformal/paper/atlas.tex:2443): name the databases, terms, and scope searched, or reduce these to “we found no result in the cited literature.”

The following are informative qualifications and should remain: the warning against interpreting 90% as reassurance at [atlas.tex:1142](/root/defiformal/paper/atlas.tex:1142), the unknown tightness of strict coverage at [atlas.tex:1181–1185](/root/defiformal/paper/atlas.tex:1181), the limitation of the listed-row quotient at [atlas.tex:2166–2173](/root/defiformal/paper/atlas.tex:2166), and the admission that perfection has not been tested at [atlas.tex:2190–2198](/root/defiformal/paper/atlas.tex:2190). Those protect the reader, not the author.

## What is sound

The problem statement is lucid and compelling. The Methods section is unusually candid about sampling and missing inter-rater reliability. The polarity lemma is correct for the defined requirement, warrant, and listed-prohibition clauses. The closure results for \(\mathcal R,\mathcal W,\mathcal H\), and the complete-lattice result for \(\mathcal R\cap\mathcal W\), are sound.

The acyclic reachability closure is a convex geometry under either of the two current law extractions, and the canonical composition identity is sound once one extraction is chosen. Fresh `m5-convex.mjs` runs checked 1,464,616 closed pairs for each extraction with zero failures. The cyclic counterexample correctly shows why acyclicity matters. The clique reformulation is also sound.

The current empirical programs reproduce 109 category claims, 22 self-tests, 1,830 pairs, 185 failures, 184 failures arming a Horn row, and six arming a mixed row. These facts should be retained after the model-system split is repaired; they do not cure that split.

## Verdict

**Not yet.** The reason is specific, not cautious: the paper presently claims one model while its proofs and applications compute with two inequivalent requirement systems; it calls \(\mathcal R\cap\mathcal W\) “admissibility” when admissibility was defined to include additional constraints; and two abstract-level obstruction claims are not proved in the form stated. Publication becomes possible when the authors choose one law system, regenerate all results under it, separate positive feasibility from listed and operational admissibility, formalize or remove the bilattice/AFT claims, publish the missing fragment and residue evidence, and synchronize the empirical counts.
