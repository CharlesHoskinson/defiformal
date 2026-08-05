# Round 3 — Halmos and Gottlieb on the manuscript

# Joint review

The manuscript contains a publishable idea and several strong results, but it is not yet a publishable paper. The obstacle is not length alone. The central objects change meaning, the introduction promises results the body explicitly withdraws, several mathematical statements lack necessary hypotheses, and the empirical paper, mathematical paper, software report, and research diary have not yet been separated.

The first two pages do succeed. “Each component was verified in isolation, if at all. The composite was verified by nobody” and “what, if anything, does composition preserve?” ([atlas.tex:69](/root/defiformal/paper/atlas.tex:69)) are clear, memorable, and sufficient reason to continue. The trouble begins when the opening answers more than the body can support.

## Must change before publication

### 1. Establish one stable set of objects

**Both readers.** The paper presently contradicts itself about its foundational data.

- [atlas.tex:264](/root/defiformal/paper/atlas.tex:264): “\(\War\) is not independent data. It is obtained as the residual (order-theoretic adjoint) of the requirement relation.”

- [atlas.tex:748](/root/defiformal/paper/atlas.tex:748): “The warrant relation is not the residual of the requirement relation.”

One sentence must go. The apparent intended distinction is between a fitted consumer assignment \(C\) and a genuine residual \(C^\ast\). Define both formally before \(\War\), say which generates the warrant clauses used in \(\Adm\) and \(\Admf\), and use “residual” only for \(C^\ast\).

There are two further scope contradictions:

- [atlas.tex:328](/root/defiformal/paper/atlas.tex:328) says every conditional prohibition has at least two negative literals and a positive one; [atlas.tex:443](/root/defiformal/paper/atlas.tex:443) later divides them into purely negative, mixed, and dual-Horn classes.

- The abstract says, without qualification, “prohibitions Horn” ([atlas.tex:45](/root/defiformal/paper/atlas.tex:45)). That is true of the listed clutter \(\Haz\), not of the full operational prohibition predicate used for the empirical results.

Prepare an object ledger containing exactly one definition and scope for
\[
\Law,\War,\Haz,C,C^\ast,\Adm,\Admf,Cn,G^0,G_\oplus.
\]
Then audit every theorem, measurement, abstract sentence, and conclusion against it.

### 2. Repair mathematical statements that are false, undefined, or broader than their proofs

**Halmos.** These are not expository blemishes.

- [atlas.tex:494](/root/defiformal/paper/atlas.tex:494) defines an inflationary selection \(\Gamma\) as producing a model of all requirements whenever a completion exists, then says at [atlas.tex:499](/root/defiformal/paper/atlas.tex:499), “The definite closure \(Cn\) is the selection that makes no choice.” It is not: \(Cn\) closes only singleton-consequent requirements and may leave a disjunctive requirement unsatisfied. Delete this identification or weaken the definition of “selection.”

- [atlas.tex:572](/root/defiformal/paper/atlas.tex:572) asserts that \(\Gamma\) has least fixed point \(\Gamma(S)\) reached in one step. The preceding definition gives neither monotonicity nor idempotence, so this does not follow. State and prove the missing hypotheses or remove the proposition.

- [atlas.tex:711](/root/defiformal/paper/atlas.tex:711) claims intersection closure fails “exactly when some requirement has a term of width \(\ge2\)” and union closure fails “exactly when \(\Haz\ne\emptyset\).” Both biconditionals are false as stated. A wide term containing its own subject is tautological; redundant requirements need not alter the model class; and a singleton prohibition produces a union-closed model class. Replace this with a correctly hypothesised theorem—accounting for tautology, redundancy, and minimal forbidden-set size—and prove it.

- [atlas.tex:681](/root/defiformal/paper/atlas.tex:681) says \(\oplus\) preserves “observational equivalence,” but that relation is defined nowhere in either article or supplement. Define it before the theorem and prove the preservation claim, or delete that half of the theorem.

- [atlas.tex:358](/root/defiformal/paper/atlas.tex:358) asserts that neither \(\mathcal R\) nor \(\mathcal W\) is intersection-closed and that \(\mathcal H\) is not union-closed; “the negative halves are witnessed below.” The manuscript supplies an explicit \(\mathcal R\) witness, but not corresponding \(\mathcal W\) and \(\mathcal H\) witnesses. Supply all three or narrow the theorem.

- [atlas.tex:504](/root/defiformal/paper/atlas.tex:504) claims an AFT obstruction for “any \(A\), product-form or not,” but its proof assumes on the diagonal that \(A(x,x)=(\Gamma(x),\Delta(x))\). Define precisely what it means for a general approximator to “have components \(\Gamma\) and \(\Delta\).” The current proof establishes only the scope encoded by that diagonal identity.

The abstract’s “neither interlaced bilattices nor approximation fixpoint theory can represent a diagonal” ([atlas.tex:48](/root/defiformal/paper/atlas.tex:48)) is much broader than the propositions just described. Replace it with the exact negative statements actually proved.

### 3. Rewrite the clique/perfection story consistently

**Both readers.** The introduction promises one graph and the body conjectures about another.

- [atlas.tex:151](/root/defiformal/paper/atlas.tex:151) says the reformulation makes “the problem” NP-hard. The body correctly concedes that general maximum-clique hardness “bounds nothing about this instance” without a reduction ([atlas.tex:2337](/root/defiformal/paper/atlas.tex:2337)). Put that qualification in the introduction.

- [atlas.tex:156](/root/defiformal/paper/atlas.tex:156) says “there is no unique largest family, only maximal ones.” The later corollary correctly says non-closure under union leaves uniqueness of a maximum-cardinality family open ([atlas.tex:2326](/root/defiformal/paper/atlas.tex:2326)). Use the later, correct statement.

- [atlas.tex:159](/root/defiformal/paper/atlas.tex:159) conjectures that \(G_\oplus\), the operational graph on \(\Admf\), is perfect and says it is a blow-up of a trace quotient. The trace theorem is only for \(G^0\) on \(\Adm\) ([atlas.tex:2365](/root/defiformal/paper/atlas.tex:2365)); the manuscript expressly says it does not extend to \(G_\oplus\) ([atlas.tex:2374](/root/defiformal/paper/atlas.tex:2374)); and the formal conjecture is about \(G^0\) ([atlas.tex:2394](/root/defiformal/paper/atlas.tex:2394)). The open-problems section then switches back to \(G_\oplus\) ([atlas.tex:2618](/root/defiformal/paper/atlas.tex:2618)).

Choose one conjecture. If it is about \(G^0\), say explicitly that it does not solve operational composition. If it is about \(G_\oplus\), supply a quotient for the full predicate or present the conjecture without the unsupported trace reduction.

### 4. Reconcile empirical populations and contradictory claims

**Both readers.** The distinction between 72 decompositions and 60 obligation ledgers is stated well at [atlas.tex:191](/root/defiformal/paper/atlas.tex:191), but later tables obscure it.

Table 1 counts elements used by five constructions ([atlas.tex:1455](/root/defiformal/paper/atlas.tex:1455)), whereas category “Footprint” measurements count all decomposed members. The resulting numbers appear contradictory:

- Spot: 18 in the table, 16 at [atlas.tex:1542](/root/defiformal/paper/atlas.tex:1542).
- Lending: 20 versus 24 at [atlas.tex:1627](/root/defiformal/paper/atlas.tex:1627).
- Bridges: 11 versus 17 at [atlas.tex:1903](/root/defiformal/paper/atlas.tex:1903).
- Intents: 10 versus 8 at [atlas.tex:1993](/root/defiformal/paper/atlas.tex:1993).

Use separate columns headed “all decompositions” and “top-five constructions,” or use one population consistently.

Several prose claims also conflict with the measurements:

- The introduction gives coverage as \(25\%\)–\(73\%\) ([atlas.tex:167](/root/defiformal/paper/atlas.tex:167)); the defined statistic later runs from \(26.5\%\) to \(59.1\%\) ([atlas.tex:1229](/root/defiformal/paper/atlas.tex:1229)). Name the two instruments and denominators, or remove the stale range.

- [atlas.tex:1237](/root/defiformal/paper/atlas.tex:1237) says the relation between coverage and capital “is not measured.” [atlas.tex:2192](/root/defiformal/paper/atlas.tex:2192) nevertheless declares resolution “inversely correlated with capital.” Delete the latter claim.

- “Coverage degrades systematically as more … lies off-chain” appears in the introduction and conclusion ([atlas.tex:171](/root/defiformal/paper/atlas.tex:171), [atlas.tex:2730](/root/defiformal/paper/atlas.tex:2730)), but no off-chain fraction is defined or analysed. Either add a preregistered variable and analysis or recast this as a qualitative observation with named cases.

- The conclusion says the polarity classification “predicts” the failures ([atlas.tex:2715](/root/defiformal/paper/atlas.tex:2715), while the atlas says their concentration is “a property of the prohibition table and not a discovery about the protocols” ([atlas.tex:1505](/root/defiformal/paper/atlas.tex:1505)). Unless the table was fixed before an out-of-sample test, use “classifies” or “explains within the encoding,” not “predicts.”

### 5. Rebuild the article/supplement boundary

**Both readers.** The main article has 12 category sections but only four protocol subsections: Uniswap, Lido, WBTC, and Rysk. The other 56 profiles are in [supplement.tex](/root/defiformal/paper/supplement.tex:22).

The article correctly says “Profiles of all sixty … are in the supplement” ([atlas.tex:1447](/root/defiformal/paper/atlas.tex:1447), then repeatedly promises that five profiles “are treated below”: for example [atlas.tex:1579](/root/defiformal/paper/atlas.tex:1579), [atlas.tex:1666](/root/defiformal/paper/atlas.tex:1666), [atlas.tex:1712](/root/defiformal/paper/atlas.tex:1712), and [atlas.tex:2273](/root/defiformal/paper/atlas.tex:2273). In the last case, the next heading is not a profile but “The composable fragment problem.”

Make the separation absolute:

- Main article: one comparative twelve-category table, a synthesis organized around the claims, and at most two to four abbreviated worked cases.
- Supplement: twelve category headings containing all sixty profiles uniformly.
- Replace every “treated below” paragraph with an exact supplement reference.

Here the readers differ slightly. Gottlieb would retain four short cases because they give the paper human and empirical weight. Halmos would retain only examples needed by a theorem or counterexample. They agree that the long forensic lists—such as Uniswap at [atlas.tex:1599](/root/defiformal/paper/atlas.tex:1599) and WBTC at [atlas.tex:1963](/root/defiformal/paper/atlas.tex:1963)—do not belong in the mathematical article.

### 6. The evidence apparatus does not yet support the dossier-level claims

[atlas.tex:198](/root/defiformal/paper/atlas.tex:198) says every obligation carries an evidence reference. The supplement instead provides unnumbered URL lists by application beginning at [supplement.tex:1931](/root/defiformal/paper/supplement.tex:1931). Because reused sources are listed once, a reader cannot reliably map a particular technical assertion to its supporting source.

Assign every obligation a stable identifier and explicit source identifiers; include access date, version or commit, contract address where relevant, and an archive or content hash for mutable webpages. The hard-coded addresses, exact quorums, live balances, quotations, and claims about deployed code must cite evidence at the sentence or obligation level.

Also revise [atlas.tex:208](/root/defiformal/paper/atlas.tex:208), “Admissibility, canonical forms, coverage, minimality … were computed, not judged.” Those outputs were computed only after authored decompositions and obligation assignments had been judged. Write: “Conditional on the recorded decompositions and ledgers, these quantities were computed.”

### 7. The environment system must be dismantled

The user’s count is submission-wide: the article has 72 measurements and 71 remarks; the supplement has 56 measurements and 112 remarks—128 measurements and 183 remarks altogether. The article alone contains 205 theorem-style environments.

The sixty profiles follow a mechanical pattern: one measurement and two remarks. A representative instance is Curve: boxed verdict at [supplement.tex:26](/root/defiformal/paper/supplement.tex:26), substantive residue analysis at [supplement.tex:32](/root/defiformal/paper/supplement.tex:32), and coding/reconciliation log at [supplement.tex:54](/root/defiformal/paper/supplement.tex:54).

Classify them as follows:

- **Keep as principal results, though usually in tables:** failure attribution at [atlas.tex:454](/root/defiformal/paper/atlas.tex:454); vacuity and ablation at [atlas.tex:616](/root/defiformal/paper/atlas.tex:616); fitted/residual trade-off at [atlas.tex:763](/root/defiformal/paper/atlas.tex:763); canonical-form application at [atlas.tex:1047](/root/defiformal/paper/atlas.tex:1047); corpus composition at [atlas.tex:1108](/root/defiformal/paper/atlas.tex:1108); coverage sensitivity at [atlas.tex:1203](/root/defiformal/paper/atlas.tex:1203); residue classification at [atlas.tex:2442](/root/defiformal/paper/atlas.tex:2442).

- **Move to validation appendix or repository report:** clause-width and exhaustive confirmation at [atlas.tex:381](/root/defiformal/paper/atlas.tex:381); repeated lattice confirmation at [atlas.tex:432](/root/defiformal/paper/atlas.tex:432); synthetic iteration at [atlas.tex:595](/root/defiformal/paper/atlas.tex:595); invariance enumeration at [atlas.tex:735](/root/defiformal/paper/atlas.tex:735); downward-closure enumeration at [atlas.tex:1347](/root/defiformal/paper/atlas.tex:1347); checker self-test at [atlas.tex:1407](/root/defiformal/paper/atlas.tex:1407).

- **Convert to one table:** the five pair-composition measurements at [atlas.tex:1108](/root/defiformal/paper/atlas.tex:1108)–[atlas.tex:1153](/root/defiformal/paper/atlas.tex:1153), and the repeated Footprint/Rejection/Composition triplets across the twelve category sections.

- **Delete as a result:** [atlas.tex:2451](/root/defiformal/paper/atlas.tex:2451), whose following remark concedes that it measures compliance with the coding contract rather than the subject.

Remarks that genuinely carry argument include the \(\Adm/\Admf\) separation ([atlas.tex:337](/root/defiformal/paper/atlas.tex:337)), the consequence of vacuity ([atlas.tex:632](/root/defiformal/paper/atlas.tex:632)), the fitted/residual trade-off ([atlas.tex:772](/root/defiformal/paper/atlas.tex:772)), the thinness of the convex geometry ([atlas.tex:914](/root/defiformal/paper/atlas.tex:914)), the coverage definition and sensitivity interpretation ([atlas.tex:1192](/root/defiformal/paper/atlas.tex:1192), [atlas.tex:1217](/root/defiformal/paper/atlas.tex:1217)), and the limit of constructions ([atlas.tex:1420](/root/defiformal/paper/atlas.tex:1420)). Make these ordinary argumentative prose.

### 8. Remove the research diary and production scaffolding

**Both readers.** The following passages would differ if the same results had been obtained through another workflow:

- “three independent lanes” and “every lane reporting” ([atlas.tex:167](/root/defiformal/paper/atlas.tex:167));
- “generated … rather than transcribed” ([atlas.tex:208](/root/defiformal/paper/atlas.tex:208)), repeated category by category;
- “Recorded so that it is not re-derived” ([atlas.tex:603](/root/defiformal/paper/atlas.tex:603));
- the remark title “Corrected” ([atlas.tex:702](/root/defiformal/paper/atlas.tex:702));
- “the shipped table” ([atlas.tex:790](/root/defiformal/paper/atlas.tex:790));
- the parser/reduced-predicate fork report ([atlas.tex:1268](/root/defiformal/paper/atlas.tex:1268));
- “Its self-test reproduces the numbers published above” ([atlas.tex:1407](/root/defiformal/paper/atlas.tex:1407));
- “this stage exists to catch” and “after the record was written” ([atlas.tex:1793](/root/defiformal/paper/atlas.tex:1793));
- “The lane recorded…” and “Against the arrays…” ([atlas.tex:1918](/root/defiformal/paper/atlas.tex:1918));
- “The original decomposition recorded…” ([atlas.tex:2063](/root/defiformal/paper/atlas.tex:2063));
- “artefacts of the corpus decomposition” ([atlas.tex:2121](/root/defiformal/paper/atlas.tex:2121));
- “A second research pass closed every gap the first left open” ([atlas.tex:2204](/root/defiformal/paper/atlas.tex:2204));
- “the first seven categories to complete” and “categories that arrived later” ([atlas.tex:2415](/root/defiformal/paper/atlas.tex:2415));
- “recorded in full in the development” ([atlas.tex:2428](/root/defiformal/paper/atlas.tex:2428));
- “written to a contract” and “the lanes’ compliance” ([atlas.tex:2459](/root/defiformal/paper/atlas.tex:2459));
- “no published verdict is reversed” ([atlas.tex:2569](/root/defiformal/paper/atlas.tex:2569)).

Retain only methodologically necessary facts: sampling, coding instructions, lack of blinded overlap, adjudication rules, computation, and availability. Put predicate-version sensitivity and coding changes in a reproducibility appendix or machine-readable changelog.

### 9. Make the notation single-valued and introduce it before use

**Halmos.** Specific defects:

- \(\Delta\) is used at [atlas.tex:406](/root/defiformal/paper/atlas.tex:406)–[atlas.tex:425](/root/defiformal/paper/atlas.tex:425) but defined only at [atlas.tex:469](/root/defiformal/paper/atlas.tex:469).

- \(\oplus\) is used in a corollary at [atlas.tex:427](/root/defiformal/paper/atlas.tex:427) but defined at [atlas.tex:673](/root/defiformal/paper/atlas.tex:673).

- That definition depends on \(Cn\), formally defined only at [atlas.tex:804](/root/defiformal/paper/atlas.tex:804).

Move the composition and \(Cn\) definitions before their first theorem-level use.

The letter \(C\) is both the consumer set in a warrant \((e,C)\) ([atlas.tex:256](/root/defiformal/paper/atlas.tex:256)) and the global fitted consumer assignment later compared with a residual ([atlas.tex:748](/root/defiformal/paper/atlas.tex:748)). Use \(C_e\) for a local consumer set and \(c:\El\to2^\El\) for the assignment.

Other collisions:

- \(X\) means a protocol set while \(X2,X9,X21\) are clause identifiers. Set identifiers as \(\mathsf X_2\) or `X2`, never as ordinary mathematical \(X2\).

- “Protocol” formally means \(X\subseteq\El\), but throughout the corpus it also means the deployed application \(P\). Reserve “application” for the deployed system and “representation” or “element set” for \(X\).

- “Sound” is ordinary English at [atlas.tex:73](/root/defiformal/paper/atlas.tex:73), a formally defined construction property at [atlas.tex:1297](/root/defiformal/paper/atlas.tex:1297), and informal operational compatibility at [atlas.tex:2296](/root/defiformal/paper/atlas.tex:2296). Use “admissible” for \(\Admf\) and reserve “sound” for a separately defined semantic property, if any.

- [atlas.tex:2549](/root/defiformal/paper/atlas.tex:2549) takes a requirement \((s,T)\) and forms the head \(T\cup V\), although [atlas.tex:236](/root/defiformal/paper/atlas.tex:236) defined \(T\) as a family of terms \(T_j\), not a set of elements. Define voiding term-by-term as \(T_j\cup V\).

- [atlas.tex:2614](/root/defiformal/paper/atlas.tex:2614) calls the structure of \(\Admf\) the central gap but asks “Is \(\Adm\) a lattice?” Ask about the object named in the heading.

### 10. Remove hedges that protect the author rather than delimit a result

The literal phrase “we would defend” does not occur. Its equivalents do.

Delete or replace:

- “closure appears to satisfy” ([atlas.tex:137](/root/defiformal/paper/atlas.tex:137)); the paper later proves it.
- “Width, indicatively” and “We report this as an indication only” ([atlas.tex:696](/root/defiformal/paper/atlas.tex:696)); the synthetic aside contributes no later inference.
- “so we take the second” and “would recover the structure theorem honestly” ([atlas.tex:784](/root/defiformal/paper/atlas.tex:784), [atlas.tex:790](/root/defiformal/paper/atlas.tex:790)); state the criterion and the unresolved question without self-certification.
- “should not be read as reassurance,” “should not be read as,” and “should be read as such” ([atlas.tex:1183](/root/defiformal/paper/atlas.tex:1183), [atlas.tex:1559](/root/defiformal/paper/atlas.tex:1559), [atlas.tex:2101](/root/defiformal/paper/atlas.tex:2101)); put the limitation directly in the measurement.
- “the three repairs we would act on” ([atlas.tex:2428](/root/defiformal/paper/atlas.tex:2428)) and “we recommend against acting on it” ([atlas.tex:2589](/root/defiformal/paper/atlas.tex:2589)); mathematical consequences, not authorial preference, should decide the prose.
- Repeated “honest,” “honestly,” “correct about the tables and wrong about the protocols,” and “not a defect in the witness.” These phrases argue character. State the mismatch and its formal cause.

Retain genuine uncertainty: unknown inter-rater reliability ([atlas.tex:213](/root/defiformal/paper/atlas.tex:213)), an unperformed quotient proof ([atlas.tex:2374](/root/defiformal/paper/atlas.tex:2374)), an untested conjecture ([atlas.tex:2398](/root/defiformal/paper/atlas.tex:2398)), and carefully scoped literature awareness ([atlas.tex:2665](/root/defiformal/paper/atlas.tex:2665)). For the literature claims, cite the documented search protocol rather than saying merely that searches “return nothing.”

### 11. Delete or substantiate superlatives

The following do rhetorical work without adequate evidence in the paper:

- “several of the largest losses” ([atlas.tex:78](/root/defiformal/paper/atlas.tex:78)): name and cite them or delete.
- “the coarsest such form that is still faithful to practice” ([atlas.tex:84](/root/defiformal/paper/atlas.tex:84)): no comparison establishes either “coarsest” or “faithful.”
- “the sharpest statement the framework produces” ([atlas.tex:1173](/root/defiformal/paper/atlas.tex:1173)) and “the sharpest case in the paper” ([atlas.tex:2140](/root/defiformal/paper/atlas.tex:2140)): delete “sharpest.”
- “best-evidenced request” ([atlas.tex:2516](/root/defiformal/paper/atlas.tex:2516)): the classification covers only 385 of 689 obligations.
- “The largest group is not worth repairing” ([atlas.tex:2589](/root/defiformal/paper/atlas.tex:2589)): the same section reports 135 party-sort obligations at [atlas.tex:2442](/root/defiformal/paper/atlas.tex:2442), more than the 82 named here. State the grouping criterion or remove “largest.”
- “appears to be unnamed” and “apparently unstudied” ([atlas.tex:2669](/root/defiformal/paper/atlas.tex:2669)): present these as a dated literature-search result, not evidence of originality.
- “the two largest protocols” ([atlas.tex:2722](/root/defiformal/paper/atlas.tex:2722)) and “the largest asset” ([atlas.tex:2730](/root/defiformal/paper/atlas.tex:2730)): attach the sampling date, ranking variable, and source.

Exact corpus extrema such as “most composition-hostile” are acceptable when the denominator and ranking appear in the same result.

## Should change

### 12. Replace accumulation with an argument

There are 35 numbered sections, one unnumbered section, and 13 subsections in the article. Composition is posed at line 69, defined at line 673, measured at line 1104, and converted to a clique problem at line 2280. That is not a spiral; it is four starts.

A coherent main-paper order would be:

1. Problem, data, and objects.
2. Clause polarity; \(\Adm/\Admf\) distinction.
3. Definite fragment, convex geometry, canonical forms, and thinness.
4. Composition, named counterexample, corpus pair table, compatibility graph, precise conjecture.
5. Constructions, coverage sensitivity, and carrier limits.
6. Comparative category synthesis and abbreviated worked cases.
7. Residue classification and costed repairs.
8. Limitations, related work, conclusion.

Gottlieb would move the bilattice/AFT discussion ([atlas.tex:475](/root/defiformal/paper/atlas.tex:475)), completion-iteration investigation ([atlas.tex:539](/root/defiformal/paper/atlas.tex:539)), degenerate blocker application ([atlas.tex:923](/root/defiformal/paper/atlas.tex:923)), and Lean status report ([atlas.tex:995](/root/defiformal/paper/atlas.tex:995)) to appendices. Halmos’s qualification is that a correct, central theorem may remain—but only after its objects are defined and its proof is complete. An appendix must not become a cemetery for unresolved claims.

### 13. Fix elementary editorial failures

- The proof of Theorem 13.4 occurs after Proposition 13.5 ([atlas.tex:854](/root/defiformal/paper/atlas.tex:854)–[atlas.tex:883](/root/defiformal/paper/atlas.tex:883)). Move it immediately after its theorem.

- “Together with Measurement~ Measurement…” is duplicated at [atlas.tex:1079](/root/defiformal/paper/atlas.tex:1079); the same defect recurs at [atlas.tex:1188](/root/defiformal/paper/atlas.tex:1188).

- “The composability question, asked of the corpus rather than of abstract sets” is a sentence fragment ([atlas.tex:1104](/root/defiformal/paper/atlas.tex:1104)).

- The checker remark ends with a dangling dash and no completed sentence ([atlas.tex:1407](/root/defiformal/paper/atlas.tex:1407)).

- “The last” after Table 1 is ambiguous and appears to refer to residue although residue is not the last column ([atlas.tex:1484](/root/defiformal/paper/atlas.tex:1484)).

- The reserve-backed-stablecoin paragraph is duplicated verbatim ([atlas.tex:2204](/root/defiformal/paper/atlas.tex:2204)–[atlas.tex:2220](/root/defiformal/paper/atlas.tex:2220)).

- The introduction’s “appears” at line 138, the “[Corrected]” heading at line 702, and phrases such as “published measurement stops being true” at [atlas.tex:2504](/root/defiformal/paper/atlas.tex:2504) reveal unreconciled draft layers.

## Would improve the paper

The following portions are fundamentally sound and should survive with light revision:

- the opening problem statement ([atlas.tex:69](/root/defiformal/paper/atlas.tex:69));
- the two-population and reliability disclosures in Methods ([atlas.tex:177](/root/defiformal/paper/atlas.tex:177));
- the explicit \(\Adm/\Admf\) separation ([atlas.tex:323](/root/defiformal/paper/atlas.tex:323));
- the convex-geometry and canonical-form sequence, especially its “thinness” qualification ([atlas.tex:799](/root/defiformal/paper/atlas.tex:799));
- the corpus application of canonical forms ([atlas.tex:1028](/root/defiformal/paper/atlas.tex:1028));
- the Uniswap/Aave counterexample, without “sharpest” or “largest” rhetoric ([atlas.tex:1165](/root/defiformal/paper/atlas.tex:1165));
- the construction definitions ([atlas.tex:1260](/root/defiformal/paper/atlas.tex:1260));
- the repair taxonomy and void-term idea, after notation and denominator repairs ([atlas.tex:2432](/root/defiformal/paper/atlas.tex:2432));
- the interface-theory and CSP related-work discussion ([atlas.tex:2632](/root/defiformal/paper/atlas.tex:2632)).

The abstract should be rewritten last. It should say that the positive model class is union-closed, the operational predicate is not; the definite fragment is a sparse convex geometry; the positive constraints are empirically nonbinding on the sampled seeds; observed failures are concentrated in encoded prohibitions; and the obligation corpus exposes substantial, partly classified residue. Those are narrower claims than the present abstract, but they are more interesting because they expose the exact limits of the formalism.

## Verdict

**Not yet.** The manuscript is not publishable after ordinary copy-editing: it requires a mathematical scope audit, correction of at least two false general propositions, reconciliation of \(\Adm\), \(\Admf\), \(G^0\), \(G_\oplus\), \(C\), and \(C^\ast\), and a reconstruction of the article/supplement boundary. The opening, the polarity result, the thin convex geometry, the named composition counterexample, and the empirical residue together could make a strong original paper. In the present version, however, the strongest promises are contradicted by later qualifications, the apparatus hides rather than clarifies the hierarchy of evidence, and the manuscript still shows the order in which the study was assembled rather than the order in which its argument must be read.
tokens used
362,837
# Joint review

The manuscript contains a publishable idea and several strong results, but it is not yet a publishable paper. The obstacle is not length alone. The central objects change meaning, the introduction promises results the body explicitly withdraws, several mathematical statements lack necessary hypotheses, and the empirical paper, mathematical paper, software report, and research diary have not yet been separated.

The first two pages do succeed. “Each component was verified in isolation, if at all. The composite was verified by nobody” and “what, if anything, does composition preserve?” ([atlas.tex:69](/root/defiformal/paper/atlas.tex:69)) are clear, memorable, and sufficient reason to continue. The trouble begins when the opening answers more than the body can support.

## Must change before publication

### 1. Establish one stable set of objects

**Both readers.** The paper presently contradicts itself about its foundational data.

- [atlas.tex:264](/root/defiformal/paper/atlas.tex:264): “\(\War\) is not independent data. It is obtained as the residual (order-theoretic adjoint) of the requirement relation.”

- [atlas.tex:748](/root/defiformal/paper/atlas.tex:748): “The warrant relation is not the residual of the requirement relation.”

One sentence must go. The apparent intended distinction is between a fitted consumer assignment \(C\) and a genuine residual \(C^\ast\). Define both formally before \(\War\), say which generates the warrant clauses used in \(\Adm\) and \(\Admf\), and use “residual” only for \(C^\ast\).

There are two further scope contradictions:

- [atlas.tex:328](/root/defiformal/paper/atlas.tex:328) says every conditional prohibition has at least two negative literals and a positive one; [atlas.tex:443](/root/defiformal/paper/atlas.tex:443) later divides them into purely negative, mixed, and dual-Horn classes.

- The abstract says, without qualification, “prohibitions Horn” ([atlas.tex:45](/root/defiformal/paper/atlas.tex:45)). That is true of the listed clutter \(\Haz\), not of the full operational prohibition predicate used for the empirical results.

Prepare an object ledger containing exactly one definition and scope for
\[
\Law,\War,\Haz,C,C^\ast,\Adm,\Admf,Cn,G^0,G_\oplus.
\]
Then audit every theorem, measurement, abstract sentence, and conclusion against it.

### 2. Repair mathematical statements that are false, undefined, or broader than their proofs

**Halmos.** These are not expository blemishes.

- [atlas.tex:494](/root/defiformal/paper/atlas.tex:494) defines an inflationary selection \(\Gamma\) as producing a model of all requirements whenever a completion exists, then says at [atlas.tex:499](/root/defiformal/paper/atlas.tex:499), “The definite closure \(Cn\) is the selection that makes no choice.” It is not: \(Cn\) closes only singleton-consequent requirements and may leave a disjunctive requirement unsatisfied. Delete this identification or weaken the definition of “selection.”

- [atlas.tex:572](/root/defiformal/paper/atlas.tex:572) asserts that \(\Gamma\) has least fixed point \(\Gamma(S)\) reached in one step. The preceding definition gives neither monotonicity nor idempotence, so this does not follow. State and prove the missing hypotheses or remove the proposition.

- [atlas.tex:711](/root/defiformal/paper/atlas.tex:711) claims intersection closure fails “exactly when some requirement has a term of width \(\ge2\)” and union closure fails “exactly when \(\Haz\ne\emptyset\).” Both biconditionals are false as stated. A wide term containing its own subject is tautological; redundant requirements need not alter the model class; and a singleton prohibition produces a union-closed model class. Replace this with a correctly hypothesised theorem—accounting for tautology, redundancy, and minimal forbidden-set size—and prove it.

- [atlas.tex:681](/root/defiformal/paper/atlas.tex:681) says \(\oplus\) preserves “observational equivalence,” but that relation is defined nowhere in either article or supplement. Define it before the theorem and prove the preservation claim, or delete that half of the theorem.

- [atlas.tex:358](/root/defiformal/paper/atlas.tex:358) asserts that neither \(\mathcal R\) nor \(\mathcal W\) is intersection-closed and that \(\mathcal H\) is not union-closed; “the negative halves are witnessed below.” The manuscript supplies an explicit \(\mathcal R\) witness, but not corresponding \(\mathcal W\) and \(\mathcal H\) witnesses. Supply all three or narrow the theorem.

- [atlas.tex:504](/root/defiformal/paper/atlas.tex:504) claims an AFT obstruction for “any \(A\), product-form or not,” but its proof assumes on the diagonal that \(A(x,x)=(\Gamma(x),\Delta(x))\). Define precisely what it means for a general approximator to “have components \(\Gamma\) and \(\Delta\).” The current proof establishes only the scope encoded by that diagonal identity.

The abstract’s “neither interlaced bilattices nor approximation fixpoint theory can represent a diagonal” ([atlas.tex:48](/root/defiformal/paper/atlas.tex:48)) is much broader than the propositions just described. Replace it with the exact negative statements actually proved.

### 3. Rewrite the clique/perfection story consistently

**Both readers.** The introduction promises one graph and the body conjectures about another.

- [atlas.tex:151](/root/defiformal/paper/atlas.tex:151) says the reformulation makes “the problem” NP-hard. The body correctly concedes that general maximum-clique hardness “bounds nothing about this instance” without a reduction ([atlas.tex:2337](/root/defiformal/paper/atlas.tex:2337)). Put that qualification in the introduction.

- [atlas.tex:156](/root/defiformal/paper/atlas.tex:156) says “there is no unique largest family, only maximal ones.” The later corollary correctly says non-closure under union leaves uniqueness of a maximum-cardinality family open ([atlas.tex:2326](/root/defiformal/paper/atlas.tex:2326)). Use the later, correct statement.

- [atlas.tex:159](/root/defiformal/paper/atlas.tex:159) conjectures that \(G_\oplus\), the operational graph on \(\Admf\), is perfect and says it is a blow-up of a trace quotient. The trace theorem is only for \(G^0\) on \(\Adm\) ([atlas.tex:2365](/root/defiformal/paper/atlas.tex:2365)); the manuscript expressly says it does not extend to \(G_\oplus\) ([atlas.tex:2374](/root/defiformal/paper/atlas.tex:2374)); and the formal conjecture is about \(G^0\) ([atlas.tex:2394](/root/defiformal/paper/atlas.tex:2394)). The open-problems section then switches back to \(G_\oplus\) ([atlas.tex:2618](/root/defiformal/paper/atlas.tex:2618)).

Choose one conjecture. If it is about \(G^0\), say explicitly that it does not solve operational composition. If it is about \(G_\oplus\), supply a quotient for the full predicate or present the conjecture without the unsupported trace reduction.

### 4. Reconcile empirical populations and contradictory claims

**Both readers.** The distinction between 72 decompositions and 60 obligation ledgers is stated well at [atlas.tex:191](/root/defiformal/paper/atlas.tex:191), but later tables obscure it.

Table 1 counts elements used by five constructions ([atlas.tex:1455](/root/defiformal/paper/atlas.tex:1455)), whereas category “Footprint” measurements count all decomposed members. The resulting numbers appear contradictory:

- Spot: 18 in the table, 16 at [atlas.tex:1542](/root/defiformal/paper/atlas.tex:1542).
- Lending: 20 versus 24 at [atlas.tex:1627](/root/defiformal/paper/atlas.tex:1627).
- Bridges: 11 versus 17 at [atlas.tex:1903](/root/defiformal/paper/atlas.tex:1903).
- Intents: 10 versus 8 at [atlas.tex:1993](/root/defiformal/paper/atlas.tex:1993).

Use separate columns headed “all decompositions” and “top-five constructions,” or use one population consistently.

Several prose claims also conflict with the measurements:

- The introduction gives coverage as \(25\%\)–\(73\%\) ([atlas.tex:167](/root/defiformal/paper/atlas.tex:167)); the defined statistic later runs from \(26.5\%\) to \(59.1\%\) ([atlas.tex:1229](/root/defiformal/paper/atlas.tex:1229)). Name the two instruments and denominators, or remove the stale range.

- [atlas.tex:1237](/root/defiformal/paper/atlas.tex:1237) says the relation between coverage and capital “is not measured.” [atlas.tex:2192](/root/defiformal/paper/atlas.tex:2192) nevertheless declares resolution “inversely correlated with capital.” Delete the latter claim.

- “Coverage degrades systematically as more … lies off-chain” appears in the introduction and conclusion ([atlas.tex:171](/root/defiformal/paper/atlas.tex:171), [atlas.tex:2730](/root/defiformal/paper/atlas.tex:2730)), but no off-chain fraction is defined or analysed. Either add a preregistered variable and analysis or recast this as a qualitative observation with named cases.

- The conclusion says the polarity classification “predicts” the failures ([atlas.tex:2715](/root/defiformal/paper/atlas.tex:2715), while the atlas says their concentration is “a property of the prohibition table and not a discovery about the protocols” ([atlas.tex:1505](/root/defiformal/paper/atlas.tex:1505)). Unless the table was fixed before an out-of-sample test, use “classifies” or “explains within the encoding,” not “predicts.”

### 5. Rebuild the article/supplement boundary

**Both readers.** The main article has 12 category sections but only four protocol subsections: Uniswap, Lido, WBTC, and Rysk. The other 56 profiles are in [supplement.tex](/root/defiformal/paper/supplement.tex:22).

The article correctly says “Profiles of all sixty … are in the supplement” ([atlas.tex:1447](/root/defiformal/paper/atlas.tex:1447), then repeatedly promises that five profiles “are treated below”: for example [atlas.tex:1579](/root/defiformal/paper/atlas.tex:1579), [atlas.tex:1666](/root/defiformal/paper/atlas.tex:1666), [atlas.tex:1712](/root/defiformal/paper/atlas.tex:1712), and [atlas.tex:2273](/root/defiformal/paper/atlas.tex:2273). In the last case, the next heading is not a profile but “The composable fragment problem.”

Make the separation absolute:

- Main article: one comparative twelve-category table, a synthesis organized around the claims, and at most two to four abbreviated worked cases.
- Supplement: twelve category headings containing all sixty profiles uniformly.
- Replace every “treated below” paragraph with an exact supplement reference.

Here the readers differ slightly. Gottlieb would retain four short cases because they give the paper human and empirical weight. Halmos would retain only examples needed by a theorem or counterexample. They agree that the long forensic lists—such as Uniswap at [atlas.tex:1599](/root/defiformal/paper/atlas.tex:1599) and WBTC at [atlas.tex:1963](/root/defiformal/paper/atlas.tex:1963)—do not belong in the mathematical article.

### 6. The evidence apparatus does not yet support the dossier-level claims

[atlas.tex:198](/root/defiformal/paper/atlas.tex:198) says every obligation carries an evidence reference. The supplement instead provides unnumbered URL lists by application beginning at [supplement.tex:1931](/root/defiformal/paper/supplement.tex:1931). Because reused sources are listed once, a reader cannot reliably map a particular technical assertion to its supporting source.

Assign every obligation a stable identifier and explicit source identifiers; include access date, version or commit, contract address where relevant, and an archive or content hash for mutable webpages. The hard-coded addresses, exact quorums, live balances, quotations, and claims about deployed code must cite evidence at the sentence or obligation level.

Also revise [atlas.tex:208](/root/defiformal/paper/atlas.tex:208), “Admissibility, canonical forms, coverage, minimality … were computed, not judged.” Those outputs were computed only after authored decompositions and obligation assignments had been judged. Write: “Conditional on the recorded decompositions and ledgers, these quantities were computed.”

### 7. The environment system must be dismantled

The user’s count is submission-wide: the article has 72 measurements and 71 remarks; the supplement has 56 measurements and 112 remarks—128 measurements and 183 remarks altogether. The article alone contains 205 theorem-style environments.

The sixty profiles follow a mechanical pattern: one measurement and two remarks. A representative instance is Curve: boxed verdict at [supplement.tex:26](/root/defiformal/paper/supplement.tex:26), substantive residue analysis at [supplement.tex:32](/root/defiformal/paper/supplement.tex:32), and coding/reconciliation log at [supplement.tex:54](/root/defiformal/paper/supplement.tex:54).

Classify them as follows:

- **Keep as principal results, though usually in tables:** failure attribution at [atlas.tex:454](/root/defiformal/paper/atlas.tex:454); vacuity and ablation at [atlas.tex:616](/root/defiformal/paper/atlas.tex:616); fitted/residual trade-off at [atlas.tex:763](/root/defiformal/paper/atlas.tex:763); canonical-form application at [atlas.tex:1047](/root/defiformal/paper/atlas.tex:1047); corpus composition at [atlas.tex:1108](/root/defiformal/paper/atlas.tex:1108); coverage sensitivity at [atlas.tex:1203](/root/defiformal/paper/atlas.tex:1203); residue classification at [atlas.tex:2442](/root/defiformal/paper/atlas.tex:2442).

- **Move to validation appendix or repository report:** clause-width and exhaustive confirmation at [atlas.tex:381](/root/defiformal/paper/atlas.tex:381); repeated lattice confirmation at [atlas.tex:432](/root/defiformal/paper/atlas.tex:432); synthetic iteration at [atlas.tex:595](/root/defiformal/paper/atlas.tex:595); invariance enumeration at [atlas.tex:735](/root/defiformal/paper/atlas.tex:735); downward-closure enumeration at [atlas.tex:1347](/root/defiformal/paper/atlas.tex:1347); checker self-test at [atlas.tex:1407](/root/defiformal/paper/atlas.tex:1407).

- **Convert to one table:** the five pair-composition measurements at [atlas.tex:1108](/root/defiformal/paper/atlas.tex:1108)–[atlas.tex:1153](/root/defiformal/paper/atlas.tex:1153), and the repeated Footprint/Rejection/Composition triplets across the twelve category sections.

- **Delete as a result:** [atlas.tex:2451](/root/defiformal/paper/atlas.tex:2451), whose following remark concedes that it measures compliance with the coding contract rather than the subject.

Remarks that genuinely carry argument include the \(\Adm/\Admf\) separation ([atlas.tex:337](/root/defiformal/paper/atlas.tex:337)), the consequence of vacuity ([atlas.tex:632](/root/defiformal/paper/atlas.tex:632)), the fitted/residual trade-off ([atlas.tex:772](/root/defiformal/paper/atlas.tex:772)), the thinness of the convex geometry ([atlas.tex:914](/root/defiformal/paper/atlas.tex:914)), the coverage definition and sensitivity interpretation ([atlas.tex:1192](/root/defiformal/paper/atlas.tex:1192), [atlas.tex:1217](/root/defiformal/paper/atlas.tex:1217)), and the limit of constructions ([atlas.tex:1420](/root/defiformal/paper/atlas.tex:1420)). Make these ordinary argumentative prose.

### 8. Remove the research diary and production scaffolding

**Both readers.** The following passages would differ if the same results had been obtained through another workflow:

- “three independent lanes” and “every lane reporting” ([atlas.tex:167](/root/defiformal/paper/atlas.tex:167));
- “generated … rather than transcribed” ([atlas.tex:208](/root/defiformal/paper/atlas.tex:208)), repeated category by category;
- “Recorded so that it is not re-derived” ([atlas.tex:603](/root/defiformal/paper/atlas.tex:603));
- the remark title “Corrected” ([atlas.tex:702](/root/defiformal/paper/atlas.tex:702));
- “the shipped table” ([atlas.tex:790](/root/defiformal/paper/atlas.tex:790));
- the parser/reduced-predicate fork report ([atlas.tex:1268](/root/defiformal/paper/atlas.tex:1268));
- “Its self-test reproduces the numbers published above” ([atlas.tex:1407](/root/defiformal/paper/atlas.tex:1407));
- “this stage exists to catch” and “after the record was written” ([atlas.tex:1793](/root/defiformal/paper/atlas.tex:1793));
- “The lane recorded…” and “Against the arrays…” ([atlas.tex:1918](/root/defiformal/paper/atlas.tex:1918));
- “The original decomposition recorded…” ([atlas.tex:2063](/root/defiformal/paper/atlas.tex:2063));
- “artefacts of the corpus decomposition” ([atlas.tex:2121](/root/defiformal/paper/atlas.tex:2121));
- “A second research pass closed every gap the first left open” ([atlas.tex:2204](/root/defiformal/paper/atlas.tex:2204));
- “the first seven categories to complete” and “categories that arrived later” ([atlas.tex:2415](/root/defiformal/paper/atlas.tex:2415));
- “recorded in full in the development” ([atlas.tex:2428](/root/defiformal/paper/atlas.tex:2428));
- “written to a contract” and “the lanes’ compliance” ([atlas.tex:2459](/root/defiformal/paper/atlas.tex:2459));
- “no published verdict is reversed” ([atlas.tex:2569](/root/defiformal/paper/atlas.tex:2569)).

Retain only methodologically necessary facts: sampling, coding instructions, lack of blinded overlap, adjudication rules, computation, and availability. Put predicate-version sensitivity and coding changes in a reproducibility appendix or machine-readable changelog.

### 9. Make the notation single-valued and introduce it before use

**Halmos.** Specific defects:

- \(\Delta\) is used at [atlas.tex:406](/root/defiformal/paper/atlas.tex:406)–[atlas.tex:425](/root/defiformal/paper/atlas.tex:425) but defined only at [atlas.tex:469](/root/defiformal/paper/atlas.tex:469).

- \(\oplus\) is used in a corollary at [atlas.tex:427](/root/defiformal/paper/atlas.tex:427) but defined at [atlas.tex:673](/root/defiformal/paper/atlas.tex:673).

- That definition depends on \(Cn\), formally defined only at [atlas.tex:804](/root/defiformal/paper/atlas.tex:804).

Move the composition and \(Cn\) definitions before their first theorem-level use.

The letter \(C\) is both the consumer set in a warrant \((e,C)\) ([atlas.tex:256](/root/defiformal/paper/atlas.tex:256)) and the global fitted consumer assignment later compared with a residual ([atlas.tex:748](/root/defiformal/paper/atlas.tex:748)). Use \(C_e\) for a local consumer set and \(c:\El\to2^\El\) for the assignment.

Other collisions:

- \(X\) means a protocol set while \(X2,X9,X21\) are clause identifiers. Set identifiers as \(\mathsf X_2\) or `X2`, never as ordinary mathematical \(X2\).

- “Protocol” formally means \(X\subseteq\El\), but throughout the corpus it also means the deployed application \(P\). Reserve “application” for the deployed system and “representation” or “element set” for \(X\).

- “Sound” is ordinary English at [atlas.tex:73](/root/defiformal/paper/atlas.tex:73), a formally defined construction property at [atlas.tex:1297](/root/defiformal/paper/atlas.tex:1297), and informal operational compatibility at [atlas.tex:2296](/root/defiformal/paper/atlas.tex:2296). Use “admissible” for \(\Admf\) and reserve “sound” for a separately defined semantic property, if any.

- [atlas.tex:2549](/root/defiformal/paper/atlas.tex:2549) takes a requirement \((s,T)\) and forms the head \(T\cup V\), although [atlas.tex:236](/root/defiformal/paper/atlas.tex:236) defined \(T\) as a family of terms \(T_j\), not a set of elements. Define voiding term-by-term as \(T_j\cup V\).

- [atlas.tex:2614](/root/defiformal/paper/atlas.tex:2614) calls the structure of \(\Admf\) the central gap but asks “Is \(\Adm\) a lattice?” Ask about the object named in the heading.

### 10. Remove hedges that protect the author rather than delimit a result

The literal phrase “we would defend” does not occur. Its equivalents do.

Delete or replace:

- “closure appears to satisfy” ([atlas.tex:137](/root/defiformal/paper/atlas.tex:137)); the paper later proves it.
- “Width, indicatively” and “We report this as an indication only” ([atlas.tex:696](/root/defiformal/paper/atlas.tex:696)); the synthetic aside contributes no later inference.
- “so we take the second” and “would recover the structure theorem honestly” ([atlas.tex:784](/root/defiformal/paper/atlas.tex:784), [atlas.tex:790](/root/defiformal/paper/atlas.tex:790)); state the criterion and the unresolved question without self-certification.
- “should not be read as reassurance,” “should not be read as,” and “should be read as such” ([atlas.tex:1183](/root/defiformal/paper/atlas.tex:1183), [atlas.tex:1559](/root/defiformal/paper/atlas.tex:1559), [atlas.tex:2101](/root/defiformal/paper/atlas.tex:2101)); put the limitation directly in the measurement.
- “the three repairs we would act on” ([atlas.tex:2428](/root/defiformal/paper/atlas.tex:2428)) and “we recommend against acting on it” ([atlas.tex:2589](/root/defiformal/paper/atlas.tex:2589)); mathematical consequences, not authorial preference, should decide the prose.
- Repeated “honest,” “honestly,” “correct about the tables and wrong about the protocols,” and “not a defect in the witness.” These phrases argue character. State the mismatch and its formal cause.

Retain genuine uncertainty: unknown inter-rater reliability ([atlas.tex:213](/root/defiformal/paper/atlas.tex:213)), an unperformed quotient proof ([atlas.tex:2374](/root/defiformal/paper/atlas.tex:2374)), an untested conjecture ([atlas.tex:2398](/root/defiformal/paper/atlas.tex:2398)), and carefully scoped literature awareness ([atlas.tex:2665](/root/defiformal/paper/atlas.tex:2665)). For the literature claims, cite the documented search protocol rather than saying merely that searches “return nothing.”

### 11. Delete or substantiate superlatives

The following do rhetorical work without adequate evidence in the paper:

- “several of the largest losses” ([atlas.tex:78](/root/defiformal/paper/atlas.tex:78)): name and cite them or delete.
- “the coarsest such form that is still faithful to practice” ([atlas.tex:84](/root/defiformal/paper/atlas.tex:84)): no comparison establishes either “coarsest” or “faithful.”
- “the sharpest statement the framework produces” ([atlas.tex:1173](/root/defiformal/paper/atlas.tex:1173)) and “the sharpest case in the paper” ([atlas.tex:2140](/root/defiformal/paper/atlas.tex:2140)): delete “sharpest.”
- “best-evidenced request” ([atlas.tex:2516](/root/defiformal/paper/atlas.tex:2516)): the classification covers only 385 of 689 obligations.
- “The largest group is not worth repairing” ([atlas.tex:2589](/root/defiformal/paper/atlas.tex:2589)): the same section reports 135 party-sort obligations at [atlas.tex:2442](/root/defiformal/paper/atlas.tex:2442), more than the 82 named here. State the grouping criterion or remove “largest.”
- “appears to be unnamed” and “apparently unstudied” ([atlas.tex:2669](/root/defiformal/paper/atlas.tex:2669)): present these as a dated literature-search result, not evidence of originality.
- “the two largest protocols” ([atlas.tex:2722](/root/defiformal/paper/atlas.tex:2722)) and “the largest asset” ([atlas.tex:2730](/root/defiformal/paper/atlas.tex:2730)): attach the sampling date, ranking variable, and source.

Exact corpus extrema such as “most composition-hostile” are acceptable when the denominator and ranking appear in the same result.

## Should change

### 12. Replace accumulation with an argument

There are 35 numbered sections, one unnumbered section, and 13 subsections in the article. Composition is posed at line 69, defined at line 673, measured at line 1104, and converted to a clique problem at line 2280. That is not a spiral; it is four starts.

A coherent main-paper order would be:

1. Problem, data, and objects.
2. Clause polarity; \(\Adm/\Admf\) distinction.
3. Definite fragment, convex geometry, canonical forms, and thinness.
4. Composition, named counterexample, corpus pair table, compatibility graph, precise conjecture.
5. Constructions, coverage sensitivity, and carrier limits.
6. Comparative category synthesis and abbreviated worked cases.
7. Residue classification and costed repairs.
8. Limitations, related work, conclusion.

Gottlieb would move the bilattice/AFT discussion ([atlas.tex:475](/root/defiformal/paper/atlas.tex:475)), completion-iteration investigation ([atlas.tex:539](/root/defiformal/paper/atlas.tex:539)), degenerate blocker application ([atlas.tex:923](/root/defiformal/paper/atlas.tex:923)), and Lean status report ([atlas.tex:995](/root/defiformal/paper/atlas.tex:995)) to appendices. Halmos’s qualification is that a correct, central theorem may remain—but only after its objects are defined and its proof is complete. An appendix must not become a cemetery for unresolved claims.

### 13. Fix elementary editorial failures

- The proof of Theorem 13.4 occurs after Proposition 13.5 ([atlas.tex:854](/root/defiformal/paper/atlas.tex:854)–[atlas.tex:883](/root/defiformal/paper/atlas.tex:883)). Move it immediately after its theorem.

- “Together with Measurement~ Measurement…” is duplicated at [atlas.tex:1079](/root/defiformal/paper/atlas.tex:1079); the same defect recurs at [atlas.tex:1188](/root/defiformal/paper/atlas.tex:1188).

- “The composability question, asked of the corpus rather than of abstract sets” is a sentence fragment ([atlas.tex:1104](/root/defiformal/paper/atlas.tex:1104)).

- The checker remark ends with a dangling dash and no completed sentence ([atlas.tex:1407](/root/defiformal/paper/atlas.tex:1407)).

- “The last” after Table 1 is ambiguous and appears to refer to residue although residue is not the last column ([atlas.tex:1484](/root/defiformal/paper/atlas.tex:1484)).

- The reserve-backed-stablecoin paragraph is duplicated verbatim ([atlas.tex:2204](/root/defiformal/paper/atlas.tex:2204)–[atlas.tex:2220](/root/defiformal/paper/atlas.tex:2220)).

- The introduction’s “appears” at line 138, the “[Corrected]” heading at line 702, and phrases such as “published measurement stops being true” at [atlas.tex:2504](/root/defiformal/paper/atlas.tex:2504) reveal unreconciled draft layers.

## Would improve the paper

The following portions are fundamentally sound and should survive with light revision:

- the opening problem statement ([atlas.tex:69](/root/defiformal/paper/atlas.tex:69));
- the two-population and reliability disclosures in Methods ([atlas.tex:177](/root/defiformal/paper/atlas.tex:177));
- the explicit \(\Adm/\Admf\) separation ([atlas.tex:323](/root/defiformal/paper/atlas.tex:323));
- the convex-geometry and canonical-form sequence, especially its “thinness” qualification ([atlas.tex:799](/root/defiformal/paper/atlas.tex:799));
- the corpus application of canonical forms ([atlas.tex:1028](/root/defiformal/paper/atlas.tex:1028));
- the Uniswap/Aave counterexample, without “sharpest” or “largest” rhetoric ([atlas.tex:1165](/root/defiformal/paper/atlas.tex:1165));
- the construction definitions ([atlas.tex:1260](/root/defiformal/paper/atlas.tex:1260));
- the repair taxonomy and void-term idea, after notation and denominator repairs ([atlas.tex:2432](/root/defiformal/paper/atlas.tex:2432));
- the interface-theory and CSP related-work discussion ([atlas.tex:2632](/root/defiformal/paper/atlas.tex:2632)).

The abstract should be rewritten last. It should say that the positive model class is union-closed, the operational predicate is not; the definite fragment is a sparse convex geometry; the positive constraints are empirically nonbinding on the sampled seeds; observed failures are concentrated in encoded prohibitions; and the obligation corpus exposes substantial, partly classified residue. Those are narrower claims than the present abstract, but they are more interesting because they expose the exact limits of the formalism.

## Verdict

**Not yet.** The manuscript is not publishable after ordinary copy-editing: it requires a mathematical scope audit, correction of at least two false general propositions, reconciliation of \(\Adm\), \(\Admf\), \(G^0\), \(G_\oplus\), \(C\), and \(C^\ast\), and a reconstruction of the article/supplement boundary. The opening, the polarity result, the thin convex geometry, the named composition counterexample, and the empirical residue together could make a strong original paper. In the present version, however, the strongest promises are contradicted by later qualifications, the apparatus hides rather than clarifies the hierarchy of evidence, and the manuscript still shows the order in which the study was assembled rather than the order in which its argument must be read.
