# Round 1 — Halmos and Gottlieb on the manuscript

# Joint review

This review refers to the current 4,443-line version of [paper/atlas.tex](/root/defiformal/paper/atlas.tex). It contains 35 sections, 69 subsections, 128 `measurement` environments, and 181 `remark` environments. No files were edited.

Our common diagnosis is that there is a potentially strong paper here, but not yet a publishable one. The opening question is good, the positive algebraic result has a clear shape, and the empirical work is unusually rich. At present, however, the manuscript alternates among three different papers—a constraint-theoretic paper, a computational report, and a sixty-case atlas—without fully securing the definitions or evidence needed by any of them.

## Must change before publication

### 1. `\Adm` changes meaning midway through the paper

**Both readers.** This is the most serious defect because it changes which theorems and measurements concern the same object.

At [paper/atlas.tex:227–235](/root/defiformal/paper/atlas.tex:227):

> “Put … \(\Adm=\mathcal R\cap\mathcal W\cap\mathcal H\).”

But at [paper/atlas.tex:1115–1121](/root/defiformal/paper/atlas.tex:1115):

> “\(\Adm\) below, and throughout, is the model class of the 29 recorded requirement rows under the corrected parser … together with the warrants, the grounding condition and the prohibitions.”

“Below, and throughout” retroactively adds a grounding condition, conditional prohibitions, and a parser choice not present in the definition. At [paper/atlas.tex:1195–1203](/root/defiformal/paper/atlas.tex:1195), the text further distinguishes the listed clutter from a “full prohibition predicate.” Yet [paper/atlas.tex:4082–4087](/root/defiformal/paper/atlas.tex:4082) argues that compatibility depends only on traces of \(H\in\Haz\). That cannot account for the conditional constraints which, according to lines 957–962, cause every observed failure.

**What to do:** define separate objects, for example

\[
\Adm_0=\mathcal R\cap\mathcal W\cap\mathcal H
\]

for the Horn/dual-Horn model, and \(\Adm_{\mathrm{full}}\) for the actual parser, grounding rule, and conditional constraints. State explicitly which results hold for each. Reprove or restrict every theorem using `\Adm`, especially the composition and trace results. Define “grounding condition” and each conditional clause form before first use.

### 2. The warrant relation is asserted both to be and not to be a residual

**Halmos.** One symbol cannot have two incompatible origins.

At [paper/atlas.tex:214–216](/root/defiformal/paper/atlas.tex:214):

> “\(\War\) … is obtained as the residual (order-theoretic adjoint) of the requirement relation.”

At [paper/atlas.tex:620–624](/root/defiformal/paper/atlas.tex:620):

> “The warrant relation is not the residual of the requirement relation…”

The latter passage also suddenly uses plain \(C\) and \(R\), whereas the defined objects are \(C(e)\), \(\Law\), and \(\mathcal R\).

**What to do:** decide which statement is true. If the empirical warrant table is a fitted approximation rather than the residual, say that in the original definition. Give separate notation to the fitted consumer relation and the genuine residual, and use it consistently in the trade-off experiment.

### 3. Several stated mathematical results are not proved as written

**Both readers.**

At [paper/atlas.tex:249–260](/root/defiformal/paper/atlas.tex:249), the closure theorem includes three negative claims:

> “Neither \(\mathcal R\) nor \(\mathcal W\) is closed under intersection, and \(\mathcal H\) is not closed under union.”

The proof establishes only the general Horn/dual-Horn preservation implications and says that the negative halves are “witnessed below.” The manuscript later admits at [paper/atlas.tex:871–880](/root/defiformal/paper/atlas.tex:871) that the formalization contains only generic negative witnesses. Put explicit witnesses for the actual three model classes in the theorem’s proof.

At [paper/atlas.tex:585–590](/root/defiformal/paper/atlas.tex:585):

> “\(\mathcal M(\Law)\) fails \(\cap\)-closure exactly when some requirement has a term of width \(\ge2\), and \(\mathcal M(\Haz)\) fails \(\cup\)-closure exactly when \(\Haz\ne\emptyset\).”

These equivalences are false without further hypotheses. A wide clause may be redundant or implied by singleton clauses; a nonempty prohibition family can still have a union-closed model class. Add irredundancy and nontrivial-edge hypotheses sufficient for the claim, or replace the equivalences with one-way sufficient conditions and prove the actual instance separately.

At [paper/atlas.tex:365–376](/root/defiformal/paper/atlas.tex:365):

> “No interlaced bilattice … has \(\Adm\) as a definable object.”

“Definable object” is undefined. The product representation alone does not establish that no definable diagonal subset exists, and the last sentence invokes “Theorem `lem:polarity`,” which neither is a theorem nor states that \(\Adm\) cannot be a bilattice subobject. Define the logic and signature in which “definable” is meant and supply the missing argument; otherwise reduce this to the narrower, proved observation that the product operations do not preserve the diagonal.

At [paper/atlas.tex:379–394](/root/defiformal/paper/atlas.tex:379), the AFT theorem uses \(\Gamma\) before any definition, and \(\le_p\) is likewise undefined. Define the domain, precision order, approximator axioms, and \(\Gamma\). Then state precisely whether the result excludes one proposed componentwise approximator or all AFT representations.

### 4. The compatibility-graph conclusions overreach their premises

**Both readers.**

At [paper/atlas.tex:4027–4045](/root/defiformal/paper/atlas.tex:4027), \(G_\oplus\) is called a simple graph, followed by:

> “Every vertex is self-compatible…”  
> “self-loops are present for every vertex.”

A simple graph has no loops. Moreover \(A\oplus A=\Gamma(A)\) again uses undefined \(\Gamma\); under the stated definition it should be \(Cn(A)\), equal to \(A\) only under the requisite closedness hypothesis.

At [paper/atlas.tex:4048–4053](/root/defiformal/paper/atlas.tex:4048):

> “Hence there is in general no unique largest … only maximal ones.”

Failure of closure under union does not imply that a unique maximum-cardinality safe family cannot exist. It establishes only that unions of safe families need not be safe.

At [paper/atlas.tex:4056–4063](/root/defiformal/paper/atlas.tex:4056), generic NP-hardness of maximum clique is treated as explaining this instance and ruling out a closed form. It does neither without a reduction showing that the manuscript’s compatibility graphs realize a hard class.

**What to do:** formulate compatibility on distinct vertices; distinguish maximal, maximum-cardinality, and unique maximum; qualify the complexity statement as a reformulation unless a reduction is proved. The trace proposition must use the full conditional-prohibition trace or be restricted to \(\Adm_0\).

### 5. “Linear time” is a headline result without a complexity proof

At [paper/atlas.tex:728–740](/root/defiformal/paper/atlas.tex:728):

> “computable in time linear in \(|\mathrm{ex}(A)|+|\mathrm{ex}(B)|\).”

The proof establishes the set equality but gives no algorithm, representation of the order, preprocessing assumption, or cost for testing maximality. The manuscript itself concedes this at [paper/atlas.tex:871–875](/root/defiformal/paper/atlas.tex:871).

**Halmos:** prove the complexity statement or do not state it.

**What to do:** specify whether the transitive closure or a constant-size \(58\times58\) order table is precomputed, give pseudocode, and prove the bound under a named computational model. Otherwise retain the algebraic identity and delete “linear time” from the theorem, abstract, introduction, and conclusion.

### 6. The empirical claims have no publishable evidence trail in the manuscript

At [paper/atlas.tex:92–99](/root/defiformal/paper/atlas.tex:92):

> “selected by capital or volume from live data”

No date, ranking snapshot, inclusion rule, version, or source is supplied. At [paper/atlas.tex:1108–1112](/root/defiformal/paper/atlas.tex:1108), obligations are said to be “checkable against a cited source,” yet the entire category atlas, lines 1280–4002, contains no `\cite` command.

This is especially serious because the atlas makes source-dependent claims about deployed code, governance keys, legal rights, rankings, balances, and documentation. Evidence records do exist elsewhere in the repository—for example [aave-v3.json:27](/root/defiformal/expansion/02-lending/specs/aave-v3.json:27) and [curve.json:22](/root/defiformal/expansion/01-spot-exchange/specs/curve.json:22) contain URLs and access dates—but the paper neither cites nor identifies these ledgers as its data.

**What to do:** add a methods and data-availability section before any empirical result. It must give:

- a frozen list of all 72 observational units;
- the distinction between those 72 units and the 60 detailed constructions;
- category, product scope, ranking variable, snapshot date, and inclusion rule;
- protocol/version, chain, deployment address, repository commit or bytecode identifier;
- one evidence reference for every obligation and decomposition decision;
- analyst assignment, coding instructions, overlap, adjudication, and treatment of uncertainty;
- a permanent supplementary artifact or repository release corresponding to the submitted paper.

The two duplicate decompositions at [paper/atlas.tex:1329–1339](/root/defiformal/paper/atlas.tex:1329)—with agreement of \(11/18\) and \(5/10\)—are not a reliability study because their scopes differ. Do not call the three “lanes” independent evidence. Either perform a genuine blinded overlap sample with fixed scope or state that inter-rater reliability is unknown.

### 7. The abstract and introduction promise results the paper does not deliver

At [paper/atlas.tex:51–58](/root/defiformal/paper/atlas.tex:51), the abstract promises that:

> “every protocol has a unique minimal generator”  
> “we determine what the unnameable residue asks of the formalism”

The theorem applies to \(Cn\)-closed sets in the definite fragment, not to every protocol under full admissibility. More importantly, [paper/atlas.tex:4116–4131](/root/defiformal/paper/atlas.tex:4116) says that only 385 of 686 residue obligations were classified; 301 obligations and five categories remain unclassified. The abstract presents a completed classification of a partial analysis.

The manuscript also alternates between “sixty deployed systems” in the abstract and “72 deployed protocols” in the introduction without explaining the relation.

**What to do:** rewrite the abstract after the mathematics and dataset are repaired. It should distinguish:

1. the proved dual-Horn and definite-fragment results;
2. the empirical results on 72 decompositions;
3. the 60 detailed constructions;
4. the exploratory residue taxonomy over only 385 obligations.

Unless all 686 obligations are classified, say “a partial classification suggests three extensions,” not “we determine.”

### 8. The manuscript’s principal empirical generalization contradicts its own limitation

At [paper/atlas.tex:1085–1094](/root/defiformal/paper/atlas.tex:1085):

> “The second half, the relation to capital, is not measured.”

But the introduction asserts at [paper/atlas.tex:164–172](/root/defiformal/paper/atlas.tex:164) that off-chain fraction is “inversely correlated with capital held”; the cross-category synthesis repeats at [paper/atlas.tex:3815–3819](/root/defiformal/paper/atlas.tex:3815) that footprint is smallest where capital is largest; and the conclusion asserts the correlation again at [paper/atlas.tex:4431–4434](/root/defiformal/paper/atlas.tex:4431).

**What to do:** delete the capital correlation everywhere, or add capital as a dated quantitative variable and perform an analysis that accounts for the capital-based sampling rule. The present observation cannot be called a correlation, still less a monotone one.

## Must change in structure and arc

### 9. The paper defers its announced composability argument for roughly one hundred pages

At [paper/atlas.tex:142–162](/root/defiformal/paper/atlas.tex:142), the introduction announces the compatibility graph and perfect-graph conjecture. The formal section does not appear until [paper/atlas.tex:4003](/root/defiformal/paper/atlas.tex:4003), after all twelve category sections and sixty protocol profiles.

**Gottlieb:** the thread drops at line 162 and resumes at line 4003 as though no hundred-page interruption occurred.

**Halmos:** this violates the spiral plan. The reader is made to retain undefined promises about traces, clique number, and perfection through an entire empirical monograph.

**What to do:** move “The composable fragment problem” directly after “Which protocols compose.” Put the formal graph result, its limitations, and the conjecture there. Only then proceed to empirical cases.

### 10. The twelve-category atlas is the evidence base, but its present form overwhelms the paper

The category atlas occupies lines 1280–4002—most of the manuscript and about one hundred pages in the existing PDF. Its 12 sections and 60 protocol subsections repeatedly contain:

1. a narrative description;
2. a templated measurement listing \(X\), \(\mathrm{ex}(X)\), admissibility, coverage, residue, decomposition, containment, and minimality;
3. a long residue list;
4. a second paragraph comparing the witness with “the corpus record.”

For example, the Azuro measurement at [paper/atlas.tex:3836–3845](/root/defiformal/paper/atlas.tex:3836) is structurally identical to dozens of others. The repeated category preamble at [paper/atlas.tex:3829–3834](/root/defiformal/paper/atlas.tex:3829)—“verification output rather than transcribed”—appears in essentially every category.

**Gottlieb:** move the sixty full profiles out of the article. They are a reference work, not the line of the argument.

**Halmos:** retain enough cases to prove that the definitions can be used, but tables are the natural form for repeated tuples of fields.

**What to do:** in the article, retain:

- one category-level table covering all 12 categories;
- three or four representative protocol case studies;
- the cross-category synthesis;
- the cases on which a theorem, counterexample, or proposed extension directly depends.

Move the 60 full profiles, residue lists, and reconciliation notes to a sourced supplement. Convert the repeated measurements into a table with columns for version, \(X\), \(\mathrm{ex}(X)\), admissibility failure, coverage, residue count, minimality, and decomposability.

### 11. Thirty-five sections make the paper an accumulation rather than an argument

Several adjacent short sections are pieces of the same movement:

- “Model classes,” “Obstructions,” “Collapse,” and “Completion lattices” should become one formal section on model classes and failed operator representations.
- “Composition,” “What the prohibitions cost,” and “Structure and content are in tension” should become one section on the limits of composition.
- “Applying the canonical form” and “Which protocols compose” should become one empirical-results section.
- “Repair” and the later “What the residue asks for” use two meanings of repair and should either be distinguished explicitly—constraint repair versus vocabulary repair—or reorganized together.
- “Machine-checked fragment” belongs in a methods appendix or a short proof-assurance subsection.
- “Related work” at line 4335 arrives after the entire intellectual argument; move it before the empirical atlas or integrate it where each framework is introduced.

A workable order would be: problem and contributions; data and vocabulary; formal model; closure and convex geometry; composition and compatibility graph; corpus-level results; construction and coverage; representative cases; complete residue analysis; limitations and related work; conclusion; appendices.

## Should change

### 12. The formal environments have ceased to distinguish status

There are 128 measurements and 181 remarks. Of 127 labeled measurements, 109 are never referenced. The apparatus is therefore mostly layout, not logical structure.

Examples:

- [paper/atlas.tex:263–270](/root/defiformal/paper/atlas.tex:263), a citation correction, should be a footnote or proof sentence.
- [paper/atlas.tex:570–574](/root/defiformal/paper/atlas.tex:570), “Width, indicatively,” should be deleted: it is synthetic, non-corpus, and supports no inference.
- [paper/atlas.tex:576–583](/root/defiformal/paper/atlas.tex:576), “Corrected,” is revision history; integrate its valid content into the following proposition.
- [paper/atlas.tex:646–660](/root/defiformal/paper/atlas.tex:646), the warrant trade-off carries the argument and should be ordinary main prose.
- [paper/atlas.tex:772–778](/root/defiformal/paper/atlas.tex:772), the thinness of the positive theory is important and should remain, without the title “Honest scale.”
- [paper/atlas.tex:1040–1048](/root/defiformal/paper/atlas.tex:1040) and [paper/atlas.tex:1269–1277](/root/defiformal/paper/atlas.tex:1269) are essential limitations; promote them from boxed remarks into the methods argument.
- The sixty per-protocol measurements are bookkeeping and belong in the table or supplement.

Reserve `measurement` for a reproducible empirical or computational result with a defined population, denominator, and procedure. Reserve `remark` for a genuine mathematical consequence or limitation, not a paragraph needing visual separation.

There are also status errors: measurements carry `prop:` labels at [paper/atlas.tex:897](/root/defiformal/paper/atlas.tex:897), [paper/atlas.tex:922](/root/defiformal/paper/atlas.tex:922), [paper/atlas.tex:934](/root/defiformal/paper/atlas.tex:934), [paper/atlas.tex:965](/root/defiformal/paper/atlas.tex:965), and [paper/atlas.tex:971](/root/defiformal/paper/atlas.tex:971), and are consequently called propositions in the prose. The conjecture at [paper/atlas.tex:563](/root/defiformal/paper/atlas.tex:563) is labeled `meas:frag`. Correct all environment types and prefixes.

### 13. Residual scaffolding remains throughout

These sentences describe the order or tooling of the study rather than the mathematical object:

- [paper/atlas.tex:323–326](/root/defiformal/paper/atlas.tex:323): “three reruns”
- [paper/atlas.tex:563–567](/root/defiformal/paper/atlas.tex:563): “not reproducible from the stored computation”
- [paper/atlas.tex:637–643](/root/defiformal/paper/atlas.tex:637): “Under the shipped table”
- [paper/atlas.tex:1115–1121](/root/defiformal/paper/atlas.tex:1115): “under the corrected parser”
- [paper/atlas.tex:1255–1266](/root/defiformal/paper/atlas.tex:1255): the checker’s self-test and what changes “break the test”
- [paper/atlas.tex:1329–1338](/root/defiformal/paper/atlas.tex:1329): “lanes that never saw each other’s work”
- [paper/atlas.tex:1392–1397](/root/defiformal/paper/atlas.tex:1392) and its eleven repetitions: “verification output rather than transcribed”
- the recurring profile conclusions beginning “The corpus records…” throughout lines 1410–4000
- [paper/atlas.tex:4120–4127](/root/defiformal/paper/atlas.tex:4120): “first seven categories to complete” and “categories that arrived later”
- [paper/atlas.tex:4133–4135](/root/defiformal/paper/atlas.tex:4133): “recorded in full in the development”
- [paper/atlas.tex:4164–4173](/root/defiformal/paper/atlas.tex:4164): constructions “written to a contract” and “sixty independent specs”

**What to do:** delete revision history and workflow commentary. Preserve reproducibility facts in a conventional methods appendix: software version, code release, deterministic procedure, seeds, and validation tests. Rewrite “lanes” as analysts or coders, with fixed roles and adjudication rules.

### 14. Notation is neither introduced in order nor single-valued

**Halmos.** The principal problems are:

- \(\Delta\) is used at [paper/atlas.tex:297–310](/root/defiformal/paper/atlas.tex:297) before its definition at lines 357–360.
- \(\oplus\) is used at [paper/atlas.tex:318–320](/root/defiformal/paper/atlas.tex:318) before its definition at lines 546–551.
- \(\Gamma\), \(\le_p\), “observational equivalence,” “contexts,” and the grounding condition are never formally defined.
- \(C(e)\) appears at line 358 although the earlier definition speaks of consumer sets locally rather than defining a function \(C:\El\to2^\El\).
- \(D\) is the definite-requirement digraph at [paper/atlas.tex:678–683](/root/defiformal/paper/atlas.tex:678), then the discharge set in an obligation at [paper/atlas.tex:1108–1112](/root/defiformal/paper/atlas.tex:1108).
- \(A\) means a closed set or protocol, then an “application”; \(O\) means an operator at line 415, then an obligation set at line 1147.
- \(X19^{*}\) appears correctly at line 1172 but as raw `\(X19*\)` at [paper/atlas.tex:1955](/root/defiformal/paper/atlas.tex:1955), [paper/atlas.tex:2842](/root/defiformal/paper/atlas.tex:2842), and [paper/atlas.tex:3083](/root/defiformal/paper/atlas.tex:3083).
- The manuscript defines \(|\El|=58\) but gives the reader no complete vocabulary table before symbols such as \(Op,Tp,Ex,L1a,X2,X21\) begin doing work.
- The poset has 15 arcs at line 718 but “12 distinct arcs” at line 893; explain whether the latter is a transitive reduction or deduplication.

**What to do:** insert a notation and data-schema table immediately after the preliminaries. Give different typographic classes to applications, observed protocol decompositions, formal constructions, clauses, and obligation rows. Do not reuse \(D,A,O\) across these types.

### 15. The manuscript retains too many author-protective hedges

No literal “we would defend” occurs. The corresponding softeners are:

- [paper/atlas.tex:136](/root/defiformal/paper/atlas.tex:136): “closure appears to satisfy” immediately before a later theorem—say “we prove.”
- [paper/atlas.tex:563–567](/root/defiformal/paper/atlas.tex:563): “substantial fraction,” followed by an unreproducible number—reproduce it or delete the entire claim.
- [paper/atlas.tex:570–574](/root/defiformal/paper/atlas.tex:570): “indicatively,” “suggest,” and “no inference”—delete.
- [paper/atlas.tex:965–968](/root/defiformal/paper/atlas.tex:965): “essentially always safe”—say exactly 182 cross-category and 3 within-category failures.
- [paper/atlas.tex:1022–1029](/root/defiformal/paper/atlas.tex:1022): “the sharpest statement”—state the proposition without grading it.
- [paper/atlas.tex:1032–1037](/root/defiformal/paper/atlas.tex:1032): “should not be read as reassurance”—state directly that uniform pairs are not a deployment-weighted sample. The production-concentration claim needs evidence.
- [paper/atlas.tex:1181–1192](/root/defiformal/paper/atlas.tex:1181): “an algorithm we could claim to be complete”—state which algorithm is or is not complete.
- [paper/atlas.tex:1337–1339](/root/defiformal/paper/atlas.tex:1337): “should be read against it”—state that reliability is unknown.
- [paper/atlas.tex:4133](/root/defiformal/paper/atlas.tex:4133): “repairs we would act on”—say “we propose,” with a criterion.
- [paper/atlas.tex:4221–4226](/root/defiformal/paper/atlas.tex:4221): “best-evidenced request”—define an evidence metric or say only that 27 classified obligations instantiate it.
- [paper/atlas.tex:4294–4302](/root/defiformal/paper/atlas.tex:4294): “not worth repairing”—replace editorial preference with a stated cost criterion.
- [paper/atlas.tex:4370–4381](/root/defiformal/paper/atlas.tex:4370): “we are not aware,” “appears to be unnamed,” “searches … return nothing,” “apparently unstudied”—document databases, queries, and search date, or narrow the novelty claim.

Across the atlas, “honest,” “correct,” “right,” “under protest,” “deliberately,” and “sharpest” repeatedly certify the author’s decisions rather than expose their rule. Replace them with evidence status: exact, approximate, disputed, source-conflicting, or unverified.

### 16. Superlatives and exclusivity claims need dated comparators

The unsupported or under-specified cases include:

- [paper/atlas.tex:74–78](/root/defiformal/paper/atlas.tex:74): “several of the largest losses”—name and cite them or remove “largest.”
- [paper/atlas.tex:82–84](/root/defiformal/paper/atlas.tex:82): “the coarsest such form that is still faithful”—no order or fidelity criterion is supplied.
- [paper/atlas.tex:107–108](/root/defiformal/paper/atlas.tex:107): “the largest single asset”—identify the ranking variable and snapshot.
- [paper/atlas.tex:929–932](/root/defiformal/paper/atlas.tex:929): “the most derived mechanism”—give the complete comparison or say only that \(Ct\) is always derived when present.
- [paper/atlas.tex:1023–1027](/root/defiformal/paper/atlas.tex:1023): “sharpest” and “two largest protocols”—the former is rhetoric; the latter needs dated ranking evidence.
- category claims such as “three largest bridges” at [paper/atlas.tex:2657](/root/defiformal/paper/atlas.tex:2657), “largest protocol … by capital” at [paper/atlas.tex:2445](/root/defiformal/paper/atlas.tex:2445), and “largest asset” at [paper/atlas.tex:3703](/root/defiformal/paper/atlas.tex:3703) need the same frozen selection table.
- [paper/atlas.tex:4294–4302](/root/defiformal/paper/atlas.tex:4294) says 82 proposed additions would make a 58-element vocabulary “grow by half”; explain how many *distinct* new elements are proposed, because 82 obligations are not 29 elements.

Dataset-internal “only” claims can remain once the complete data table makes them auditable and they are consistently qualified with “in this corpus.”

### 17. The category boundaries are not what the methods paragraph says they are

At [paper/atlas.tex:1282–1288](/root/defiformal/paper/atlas.tex:1282), categories are said to be external DefiLlama/rwa.xyz tags. But the prediction section begins at [paper/atlas.tex:3780–3782](/root/defiformal/paper/atlas.tex:3780):

> “The category is the residual of the sampling frame … together with two large protocols its lane could not file elsewhere.”

That is an analyst-created residual bin, not an external category. Because the paper’s principal \(182/185\) result is explicitly cross-category, classification decisions affect the result.

**What to do:** reclassify Grove and Steakhouse under a declared external taxonomy or report a sensitivity analysis under plausible classifications. Do not call the resulting category boundaries exogenous.

### 18. The failure counts need their overlap stated

At [paper/atlas.tex:1317–1323](/root/defiformal/paper/atlas.tex:1317), the paper gives 147 failures arming \(X21\), 37 arming \(X2\), and 6 arming \(X19^*\), against 185 total failures. The counts sum to 190.

**What to do:** state the overlap explicitly, preferably as a small contingency table, and keep the denominators consistent with the earlier 9,883 set-level failures and later 185 corpus-pair failures. At lines 341–348, percentages \(27.8+57+23\) also exceed 100%; say whether conditions overlap and what population each percentage uses.

## What would improve the paper

### 19. Keep the opening, but make the contribution statement more exact

**Gottlieb:** [paper/atlas.tex:67–80](/root/defiformal/paper/atlas.tex:67) succeeds. By the end of the first page the reader knows the subject and the motivating question:

> “what, if anything, does composition preserve?”

That is a reason to continue.

**Halmos:** lines 111–162 then announce conclusions before their objects are defined and include claims later shown to be weaker or false. Keep the motivating opening, but replace “The shape of the answer” with a concise contribution list separating theorems, measurements, and conjectures. Do not introduce the clique conjecture until compatibility is prepared.

### 20. Several sections are sound and should survive the reconstruction

- [paper/atlas.tex:484–522](/root/defiformal/paper/atlas.tex:484), “The positive theory does not bind,” contains an important negative empirical result and candidly limits the formal theory. Keep it, with reproducibility information.
- [paper/atlas.tex:673–778](/root/defiformal/paper/atlas.tex:673), the convex-geometry section, has the manuscript’s cleanest theorem sequence. Keep the identity and the “thinness” observation; repair the complexity claim.
- [paper/atlas.tex:1040–1098](/root/defiformal/paper/atlas.tex:1040), the coverage limitations, are unusually clear. Move them into methods and obey them elsewhere.
- [paper/atlas.tex:1100–1112](/root/defiformal/paper/atlas.tex:1100) and [paper/atlas.tex:1269–1277](/root/defiformal/paper/atlas.tex:1269) give a sound account of what a construction does and does not establish, once the predicate and evidence are fixed.
- [paper/atlas.tex:853–880](/root/defiformal/paper/atlas.tex:853), the machine-checked scope statement, is responsible and precise. Gottlieb would shorten or append it; Halmos would retain the exact “formalised/not formalised” division.
- The twelve category-opening questions and “What the vocabulary cannot see here” syntheses generally carry argument. Preserve those; remove the repeated procedural paragraphs around them.
- [paper/atlas.tex:4335–4400](/root/defiformal/paper/atlas.tex:4335), the related-work section, is mostly modest and useful. Move it earlier and document the novelty search.

### 21. Repair local report-writing and sentence defects

At [paper/atlas.tex:953–956](/root/defiformal/paper/atlas.tex:953):

> “The composability question, asked of the corpus rather than of abstract sets.”

This is a fragment. Write a complete introductory sentence stating what the section measures.

At [paper/atlas.tex:318–320](/root/defiformal/paper/atlas.tex:318), an empirical verification is placed inside a corollary:

> “closed under \(\oplus\): verified on 96,720 pairs”

A corollary is proved; a finite check is measured. Separate the theorem from corroboration.

The very long single-paragraph profile conclusions—many exceeding a page—regularly contain four or five independent findings joined by dashes. Break the retained case studies into evidence, decomposition decision, residue, and consequence. In the supplement, use structured fields rather than prose.

## Verdict

**Not yet.** The manuscript has an arresting question, a credible mathematical core in the definite fragment, and a large empirical study worth preserving. But publication presently depends on a formal object whose definition changes, several theorems stronger than their proofs, a compatibility argument with elementary graph-theoretic errors, and an empirical atlas whose sources and sampling frame are not exposed in the paper. These are not matters of polishing. The formal predicates must be stabilized and the claims reproved under them; the 60/72-unit corpus must be made reproducible; the incomplete residue classification must be described honestly or completed; and the hundred-page atlas must become a supplement supporting a much shorter argument. Once those changes are made, the work could merit a fresh publication review.
tokens used
373,631
# Joint review

This review refers to the current 4,443-line version of [paper/atlas.tex](/root/defiformal/paper/atlas.tex). It contains 35 sections, 69 subsections, 128 `measurement` environments, and 181 `remark` environments. No files were edited.

Our common diagnosis is that there is a potentially strong paper here, but not yet a publishable one. The opening question is good, the positive algebraic result has a clear shape, and the empirical work is unusually rich. At present, however, the manuscript alternates among three different papers—a constraint-theoretic paper, a computational report, and a sixty-case atlas—without fully securing the definitions or evidence needed by any of them.

## Must change before publication

### 1. `\Adm` changes meaning midway through the paper

**Both readers.** This is the most serious defect because it changes which theorems and measurements concern the same object.

At [paper/atlas.tex:227–235](/root/defiformal/paper/atlas.tex:227):

> “Put … \(\Adm=\mathcal R\cap\mathcal W\cap\mathcal H\).”

But at [paper/atlas.tex:1115–1121](/root/defiformal/paper/atlas.tex:1115):

> “\(\Adm\) below, and throughout, is the model class of the 29 recorded requirement rows under the corrected parser … together with the warrants, the grounding condition and the prohibitions.”

“Below, and throughout” retroactively adds a grounding condition, conditional prohibitions, and a parser choice not present in the definition. At [paper/atlas.tex:1195–1203](/root/defiformal/paper/atlas.tex:1195), the text further distinguishes the listed clutter from a “full prohibition predicate.” Yet [paper/atlas.tex:4082–4087](/root/defiformal/paper/atlas.tex:4082) argues that compatibility depends only on traces of \(H\in\Haz\). That cannot account for the conditional constraints which, according to lines 957–962, cause every observed failure.

**What to do:** define separate objects, for example

\[
\Adm_0=\mathcal R\cap\mathcal W\cap\mathcal H
\]

for the Horn/dual-Horn model, and \(\Adm_{\mathrm{full}}\) for the actual parser, grounding rule, and conditional constraints. State explicitly which results hold for each. Reprove or restrict every theorem using `\Adm`, especially the composition and trace results. Define “grounding condition” and each conditional clause form before first use.

### 2. The warrant relation is asserted both to be and not to be a residual

**Halmos.** One symbol cannot have two incompatible origins.

At [paper/atlas.tex:214–216](/root/defiformal/paper/atlas.tex:214):

> “\(\War\) … is obtained as the residual (order-theoretic adjoint) of the requirement relation.”

At [paper/atlas.tex:620–624](/root/defiformal/paper/atlas.tex:620):

> “The warrant relation is not the residual of the requirement relation…”

The latter passage also suddenly uses plain \(C\) and \(R\), whereas the defined objects are \(C(e)\), \(\Law\), and \(\mathcal R\).

**What to do:** decide which statement is true. If the empirical warrant table is a fitted approximation rather than the residual, say that in the original definition. Give separate notation to the fitted consumer relation and the genuine residual, and use it consistently in the trade-off experiment.

### 3. Several stated mathematical results are not proved as written

**Both readers.**

At [paper/atlas.tex:249–260](/root/defiformal/paper/atlas.tex:249), the closure theorem includes three negative claims:

> “Neither \(\mathcal R\) nor \(\mathcal W\) is closed under intersection, and \(\mathcal H\) is not closed under union.”

The proof establishes only the general Horn/dual-Horn preservation implications and says that the negative halves are “witnessed below.” The manuscript later admits at [paper/atlas.tex:871–880](/root/defiformal/paper/atlas.tex:871) that the formalization contains only generic negative witnesses. Put explicit witnesses for the actual three model classes in the theorem’s proof.

At [paper/atlas.tex:585–590](/root/defiformal/paper/atlas.tex:585):

> “\(\mathcal M(\Law)\) fails \(\cap\)-closure exactly when some requirement has a term of width \(\ge2\), and \(\mathcal M(\Haz)\) fails \(\cup\)-closure exactly when \(\Haz\ne\emptyset\).”

These equivalences are false without further hypotheses. A wide clause may be redundant or implied by singleton clauses; a nonempty prohibition family can still have a union-closed model class. Add irredundancy and nontrivial-edge hypotheses sufficient for the claim, or replace the equivalences with one-way sufficient conditions and prove the actual instance separately.

At [paper/atlas.tex:365–376](/root/defiformal/paper/atlas.tex:365):

> “No interlaced bilattice … has \(\Adm\) as a definable object.”

“Definable object” is undefined. The product representation alone does not establish that no definable diagonal subset exists, and the last sentence invokes “Theorem `lem:polarity`,” which neither is a theorem nor states that \(\Adm\) cannot be a bilattice subobject. Define the logic and signature in which “definable” is meant and supply the missing argument; otherwise reduce this to the narrower, proved observation that the product operations do not preserve the diagonal.

At [paper/atlas.tex:379–394](/root/defiformal/paper/atlas.tex:379), the AFT theorem uses \(\Gamma\) before any definition, and \(\le_p\) is likewise undefined. Define the domain, precision order, approximator axioms, and \(\Gamma\). Then state precisely whether the result excludes one proposed componentwise approximator or all AFT representations.

### 4. The compatibility-graph conclusions overreach their premises

**Both readers.**

At [paper/atlas.tex:4027–4045](/root/defiformal/paper/atlas.tex:4027), \(G_\oplus\) is called a simple graph, followed by:

> “Every vertex is self-compatible…”  
> “self-loops are present for every vertex.”

A simple graph has no loops. Moreover \(A\oplus A=\Gamma(A)\) again uses undefined \(\Gamma\); under the stated definition it should be \(Cn(A)\), equal to \(A\) only under the requisite closedness hypothesis.

At [paper/atlas.tex:4048–4053](/root/defiformal/paper/atlas.tex:4048):

> “Hence there is in general no unique largest … only maximal ones.”

Failure of closure under union does not imply that a unique maximum-cardinality safe family cannot exist. It establishes only that unions of safe families need not be safe.

At [paper/atlas.tex:4056–4063](/root/defiformal/paper/atlas.tex:4056), generic NP-hardness of maximum clique is treated as explaining this instance and ruling out a closed form. It does neither without a reduction showing that the manuscript’s compatibility graphs realize a hard class.

**What to do:** formulate compatibility on distinct vertices; distinguish maximal, maximum-cardinality, and unique maximum; qualify the complexity statement as a reformulation unless a reduction is proved. The trace proposition must use the full conditional-prohibition trace or be restricted to \(\Adm_0\).

### 5. “Linear time” is a headline result without a complexity proof

At [paper/atlas.tex:728–740](/root/defiformal/paper/atlas.tex:728):

> “computable in time linear in \(|\mathrm{ex}(A)|+|\mathrm{ex}(B)|\).”

The proof establishes the set equality but gives no algorithm, representation of the order, preprocessing assumption, or cost for testing maximality. The manuscript itself concedes this at [paper/atlas.tex:871–875](/root/defiformal/paper/atlas.tex:871).

**Halmos:** prove the complexity statement or do not state it.

**What to do:** specify whether the transitive closure or a constant-size \(58\times58\) order table is precomputed, give pseudocode, and prove the bound under a named computational model. Otherwise retain the algebraic identity and delete “linear time” from the theorem, abstract, introduction, and conclusion.

### 6. The empirical claims have no publishable evidence trail in the manuscript

At [paper/atlas.tex:92–99](/root/defiformal/paper/atlas.tex:92):

> “selected by capital or volume from live data”

No date, ranking snapshot, inclusion rule, version, or source is supplied. At [paper/atlas.tex:1108–1112](/root/defiformal/paper/atlas.tex:1108), obligations are said to be “checkable against a cited source,” yet the entire category atlas, lines 1280–4002, contains no `\cite` command.

This is especially serious because the atlas makes source-dependent claims about deployed code, governance keys, legal rights, rankings, balances, and documentation. Evidence records do exist elsewhere in the repository—for example [aave-v3.json:27](/root/defiformal/expansion/02-lending/specs/aave-v3.json:27) and [curve.json:22](/root/defiformal/expansion/01-spot-exchange/specs/curve.json:22) contain URLs and access dates—but the paper neither cites nor identifies these ledgers as its data.

**What to do:** add a methods and data-availability section before any empirical result. It must give:

- a frozen list of all 72 observational units;
- the distinction between those 72 units and the 60 detailed constructions;
- category, product scope, ranking variable, snapshot date, and inclusion rule;
- protocol/version, chain, deployment address, repository commit or bytecode identifier;
- one evidence reference for every obligation and decomposition decision;
- analyst assignment, coding instructions, overlap, adjudication, and treatment of uncertainty;
- a permanent supplementary artifact or repository release corresponding to the submitted paper.

The two duplicate decompositions at [paper/atlas.tex:1329–1339](/root/defiformal/paper/atlas.tex:1329)—with agreement of \(11/18\) and \(5/10\)—are not a reliability study because their scopes differ. Do not call the three “lanes” independent evidence. Either perform a genuine blinded overlap sample with fixed scope or state that inter-rater reliability is unknown.

### 7. The abstract and introduction promise results the paper does not deliver

At [paper/atlas.tex:51–58](/root/defiformal/paper/atlas.tex:51), the abstract promises that:

> “every protocol has a unique minimal generator”  
> “we determine what the unnameable residue asks of the formalism”

The theorem applies to \(Cn\)-closed sets in the definite fragment, not to every protocol under full admissibility. More importantly, [paper/atlas.tex:4116–4131](/root/defiformal/paper/atlas.tex:4116) says that only 385 of 686 residue obligations were classified; 301 obligations and five categories remain unclassified. The abstract presents a completed classification of a partial analysis.

The manuscript also alternates between “sixty deployed systems” in the abstract and “72 deployed protocols” in the introduction without explaining the relation.

**What to do:** rewrite the abstract after the mathematics and dataset are repaired. It should distinguish:

1. the proved dual-Horn and definite-fragment results;
2. the empirical results on 72 decompositions;
3. the 60 detailed constructions;
4. the exploratory residue taxonomy over only 385 obligations.

Unless all 686 obligations are classified, say “a partial classification suggests three extensions,” not “we determine.”

### 8. The manuscript’s principal empirical generalization contradicts its own limitation

At [paper/atlas.tex:1085–1094](/root/defiformal/paper/atlas.tex:1085):

> “The second half, the relation to capital, is not measured.”

But the introduction asserts at [paper/atlas.tex:164–172](/root/defiformal/paper/atlas.tex:164) that off-chain fraction is “inversely correlated with capital held”; the cross-category synthesis repeats at [paper/atlas.tex:3815–3819](/root/defiformal/paper/atlas.tex:3815) that footprint is smallest where capital is largest; and the conclusion asserts the correlation again at [paper/atlas.tex:4431–4434](/root/defiformal/paper/atlas.tex:4431).

**What to do:** delete the capital correlation everywhere, or add capital as a dated quantitative variable and perform an analysis that accounts for the capital-based sampling rule. The present observation cannot be called a correlation, still less a monotone one.

## Must change in structure and arc

### 9. The paper defers its announced composability argument for roughly one hundred pages

At [paper/atlas.tex:142–162](/root/defiformal/paper/atlas.tex:142), the introduction announces the compatibility graph and perfect-graph conjecture. The formal section does not appear until [paper/atlas.tex:4003](/root/defiformal/paper/atlas.tex:4003), after all twelve category sections and sixty protocol profiles.

**Gottlieb:** the thread drops at line 162 and resumes at line 4003 as though no hundred-page interruption occurred.

**Halmos:** this violates the spiral plan. The reader is made to retain undefined promises about traces, clique number, and perfection through an entire empirical monograph.

**What to do:** move “The composable fragment problem” directly after “Which protocols compose.” Put the formal graph result, its limitations, and the conjecture there. Only then proceed to empirical cases.

### 10. The twelve-category atlas is the evidence base, but its present form overwhelms the paper

The category atlas occupies lines 1280–4002—most of the manuscript and about one hundred pages in the existing PDF. Its 12 sections and 60 protocol subsections repeatedly contain:

1. a narrative description;
2. a templated measurement listing \(X\), \(\mathrm{ex}(X)\), admissibility, coverage, residue, decomposition, containment, and minimality;
3. a long residue list;
4. a second paragraph comparing the witness with “the corpus record.”

For example, the Azuro measurement at [paper/atlas.tex:3836–3845](/root/defiformal/paper/atlas.tex:3836) is structurally identical to dozens of others. The repeated category preamble at [paper/atlas.tex:3829–3834](/root/defiformal/paper/atlas.tex:3829)—“verification output rather than transcribed”—appears in essentially every category.

**Gottlieb:** move the sixty full profiles out of the article. They are a reference work, not the line of the argument.

**Halmos:** retain enough cases to prove that the definitions can be used, but tables are the natural form for repeated tuples of fields.

**What to do:** in the article, retain:

- one category-level table covering all 12 categories;
- three or four representative protocol case studies;
- the cross-category synthesis;
- the cases on which a theorem, counterexample, or proposed extension directly depends.

Move the 60 full profiles, residue lists, and reconciliation notes to a sourced supplement. Convert the repeated measurements into a table with columns for version, \(X\), \(\mathrm{ex}(X)\), admissibility failure, coverage, residue count, minimality, and decomposability.

### 11. Thirty-five sections make the paper an accumulation rather than an argument

Several adjacent short sections are pieces of the same movement:

- “Model classes,” “Obstructions,” “Collapse,” and “Completion lattices” should become one formal section on model classes and failed operator representations.
- “Composition,” “What the prohibitions cost,” and “Structure and content are in tension” should become one section on the limits of composition.
- “Applying the canonical form” and “Which protocols compose” should become one empirical-results section.
- “Repair” and the later “What the residue asks for” use two meanings of repair and should either be distinguished explicitly—constraint repair versus vocabulary repair—or reorganized together.
- “Machine-checked fragment” belongs in a methods appendix or a short proof-assurance subsection.
- “Related work” at line 4335 arrives after the entire intellectual argument; move it before the empirical atlas or integrate it where each framework is introduced.

A workable order would be: problem and contributions; data and vocabulary; formal model; closure and convex geometry; composition and compatibility graph; corpus-level results; construction and coverage; representative cases; complete residue analysis; limitations and related work; conclusion; appendices.

## Should change

### 12. The formal environments have ceased to distinguish status

There are 128 measurements and 181 remarks. Of 127 labeled measurements, 109 are never referenced. The apparatus is therefore mostly layout, not logical structure.

Examples:

- [paper/atlas.tex:263–270](/root/defiformal/paper/atlas.tex:263), a citation correction, should be a footnote or proof sentence.
- [paper/atlas.tex:570–574](/root/defiformal/paper/atlas.tex:570), “Width, indicatively,” should be deleted: it is synthetic, non-corpus, and supports no inference.
- [paper/atlas.tex:576–583](/root/defiformal/paper/atlas.tex:576), “Corrected,” is revision history; integrate its valid content into the following proposition.
- [paper/atlas.tex:646–660](/root/defiformal/paper/atlas.tex:646), the warrant trade-off carries the argument and should be ordinary main prose.
- [paper/atlas.tex:772–778](/root/defiformal/paper/atlas.tex:772), the thinness of the positive theory is important and should remain, without the title “Honest scale.”
- [paper/atlas.tex:1040–1048](/root/defiformal/paper/atlas.tex:1040) and [paper/atlas.tex:1269–1277](/root/defiformal/paper/atlas.tex:1269) are essential limitations; promote them from boxed remarks into the methods argument.
- The sixty per-protocol measurements are bookkeeping and belong in the table or supplement.

Reserve `measurement` for a reproducible empirical or computational result with a defined population, denominator, and procedure. Reserve `remark` for a genuine mathematical consequence or limitation, not a paragraph needing visual separation.

There are also status errors: measurements carry `prop:` labels at [paper/atlas.tex:897](/root/defiformal/paper/atlas.tex:897), [paper/atlas.tex:922](/root/defiformal/paper/atlas.tex:922), [paper/atlas.tex:934](/root/defiformal/paper/atlas.tex:934), [paper/atlas.tex:965](/root/defiformal/paper/atlas.tex:965), and [paper/atlas.tex:971](/root/defiformal/paper/atlas.tex:971), and are consequently called propositions in the prose. The conjecture at [paper/atlas.tex:563](/root/defiformal/paper/atlas.tex:563) is labeled `meas:frag`. Correct all environment types and prefixes.

### 13. Residual scaffolding remains throughout

These sentences describe the order or tooling of the study rather than the mathematical object:

- [paper/atlas.tex:323–326](/root/defiformal/paper/atlas.tex:323): “three reruns”
- [paper/atlas.tex:563–567](/root/defiformal/paper/atlas.tex:563): “not reproducible from the stored computation”
- [paper/atlas.tex:637–643](/root/defiformal/paper/atlas.tex:637): “Under the shipped table”
- [paper/atlas.tex:1115–1121](/root/defiformal/paper/atlas.tex:1115): “under the corrected parser”
- [paper/atlas.tex:1255–1266](/root/defiformal/paper/atlas.tex:1255): the checker’s self-test and what changes “break the test”
- [paper/atlas.tex:1329–1338](/root/defiformal/paper/atlas.tex:1329): “lanes that never saw each other’s work”
- [paper/atlas.tex:1392–1397](/root/defiformal/paper/atlas.tex:1392) and its eleven repetitions: “verification output rather than transcribed”
- the recurring profile conclusions beginning “The corpus records…” throughout lines 1410–4000
- [paper/atlas.tex:4120–4127](/root/defiformal/paper/atlas.tex:4120): “first seven categories to complete” and “categories that arrived later”
- [paper/atlas.tex:4133–4135](/root/defiformal/paper/atlas.tex:4133): “recorded in full in the development”
- [paper/atlas.tex:4164–4173](/root/defiformal/paper/atlas.tex:4164): constructions “written to a contract” and “sixty independent specs”

**What to do:** delete revision history and workflow commentary. Preserve reproducibility facts in a conventional methods appendix: software version, code release, deterministic procedure, seeds, and validation tests. Rewrite “lanes” as analysts or coders, with fixed roles and adjudication rules.

### 14. Notation is neither introduced in order nor single-valued

**Halmos.** The principal problems are:

- \(\Delta\) is used at [paper/atlas.tex:297–310](/root/defiformal/paper/atlas.tex:297) before its definition at lines 357–360.
- \(\oplus\) is used at [paper/atlas.tex:318–320](/root/defiformal/paper/atlas.tex:318) before its definition at lines 546–551.
- \(\Gamma\), \(\le_p\), “observational equivalence,” “contexts,” and the grounding condition are never formally defined.
- \(C(e)\) appears at line 358 although the earlier definition speaks of consumer sets locally rather than defining a function \(C:\El\to2^\El\).
- \(D\) is the definite-requirement digraph at [paper/atlas.tex:678–683](/root/defiformal/paper/atlas.tex:678), then the discharge set in an obligation at [paper/atlas.tex:1108–1112](/root/defiformal/paper/atlas.tex:1108).
- \(A\) means a closed set or protocol, then an “application”; \(O\) means an operator at line 415, then an obligation set at line 1147.
- \(X19^{*}\) appears correctly at line 1172 but as raw `\(X19*\)` at [paper/atlas.tex:1955](/root/defiformal/paper/atlas.tex:1955), [paper/atlas.tex:2842](/root/defiformal/paper/atlas.tex:2842), and [paper/atlas.tex:3083](/root/defiformal/paper/atlas.tex:3083).
- The manuscript defines \(|\El|=58\) but gives the reader no complete vocabulary table before symbols such as \(Op,Tp,Ex,L1a,X2,X21\) begin doing work.
- The poset has 15 arcs at line 718 but “12 distinct arcs” at line 893; explain whether the latter is a transitive reduction or deduplication.

**What to do:** insert a notation and data-schema table immediately after the preliminaries. Give different typographic classes to applications, observed protocol decompositions, formal constructions, clauses, and obligation rows. Do not reuse \(D,A,O\) across these types.

### 15. The manuscript retains too many author-protective hedges

No literal “we would defend” occurs. The corresponding softeners are:

- [paper/atlas.tex:136](/root/defiformal/paper/atlas.tex:136): “closure appears to satisfy” immediately before a later theorem—say “we prove.”
- [paper/atlas.tex:563–567](/root/defiformal/paper/atlas.tex:563): “substantial fraction,” followed by an unreproducible number—reproduce it or delete the entire claim.
- [paper/atlas.tex:570–574](/root/defiformal/paper/atlas.tex:570): “indicatively,” “suggest,” and “no inference”—delete.
- [paper/atlas.tex:965–968](/root/defiformal/paper/atlas.tex:965): “essentially always safe”—say exactly 182 cross-category and 3 within-category failures.
- [paper/atlas.tex:1022–1029](/root/defiformal/paper/atlas.tex:1022): “the sharpest statement”—state the proposition without grading it.
- [paper/atlas.tex:1032–1037](/root/defiformal/paper/atlas.tex:1032): “should not be read as reassurance”—state directly that uniform pairs are not a deployment-weighted sample. The production-concentration claim needs evidence.
- [paper/atlas.tex:1181–1192](/root/defiformal/paper/atlas.tex:1181): “an algorithm we could claim to be complete”—state which algorithm is or is not complete.
- [paper/atlas.tex:1337–1339](/root/defiformal/paper/atlas.tex:1337): “should be read against it”—state that reliability is unknown.
- [paper/atlas.tex:4133](/root/defiformal/paper/atlas.tex:4133): “repairs we would act on”—say “we propose,” with a criterion.
- [paper/atlas.tex:4221–4226](/root/defiformal/paper/atlas.tex:4221): “best-evidenced request”—define an evidence metric or say only that 27 classified obligations instantiate it.
- [paper/atlas.tex:4294–4302](/root/defiformal/paper/atlas.tex:4294): “not worth repairing”—replace editorial preference with a stated cost criterion.
- [paper/atlas.tex:4370–4381](/root/defiformal/paper/atlas.tex:4370): “we are not aware,” “appears to be unnamed,” “searches … return nothing,” “apparently unstudied”—document databases, queries, and search date, or narrow the novelty claim.

Across the atlas, “honest,” “correct,” “right,” “under protest,” “deliberately,” and “sharpest” repeatedly certify the author’s decisions rather than expose their rule. Replace them with evidence status: exact, approximate, disputed, source-conflicting, or unverified.

### 16. Superlatives and exclusivity claims need dated comparators

The unsupported or under-specified cases include:

- [paper/atlas.tex:74–78](/root/defiformal/paper/atlas.tex:74): “several of the largest losses”—name and cite them or remove “largest.”
- [paper/atlas.tex:82–84](/root/defiformal/paper/atlas.tex:82): “the coarsest such form that is still faithful”—no order or fidelity criterion is supplied.
- [paper/atlas.tex:107–108](/root/defiformal/paper/atlas.tex:107): “the largest single asset”—identify the ranking variable and snapshot.
- [paper/atlas.tex:929–932](/root/defiformal/paper/atlas.tex:929): “the most derived mechanism”—give the complete comparison or say only that \(Ct\) is always derived when present.
- [paper/atlas.tex:1023–1027](/root/defiformal/paper/atlas.tex:1023): “sharpest” and “two largest protocols”—the former is rhetoric; the latter needs dated ranking evidence.
- category claims such as “three largest bridges” at [paper/atlas.tex:2657](/root/defiformal/paper/atlas.tex:2657), “largest protocol … by capital” at [paper/atlas.tex:2445](/root/defiformal/paper/atlas.tex:2445), and “largest asset” at [paper/atlas.tex:3703](/root/defiformal/paper/atlas.tex:3703) need the same frozen selection table.
- [paper/atlas.tex:4294–4302](/root/defiformal/paper/atlas.tex:4294) says 82 proposed additions would make a 58-element vocabulary “grow by half”; explain how many *distinct* new elements are proposed, because 82 obligations are not 29 elements.

Dataset-internal “only” claims can remain once the complete data table makes them auditable and they are consistently qualified with “in this corpus.”

### 17. The category boundaries are not what the methods paragraph says they are

At [paper/atlas.tex:1282–1288](/root/defiformal/paper/atlas.tex:1282), categories are said to be external DefiLlama/rwa.xyz tags. But the prediction section begins at [paper/atlas.tex:3780–3782](/root/defiformal/paper/atlas.tex:3780):

> “The category is the residual of the sampling frame … together with two large protocols its lane could not file elsewhere.”

That is an analyst-created residual bin, not an external category. Because the paper’s principal \(182/185\) result is explicitly cross-category, classification decisions affect the result.

**What to do:** reclassify Grove and Steakhouse under a declared external taxonomy or report a sensitivity analysis under plausible classifications. Do not call the resulting category boundaries exogenous.

### 18. The failure counts need their overlap stated

At [paper/atlas.tex:1317–1323](/root/defiformal/paper/atlas.tex:1317), the paper gives 147 failures arming \(X21\), 37 arming \(X2\), and 6 arming \(X19^*\), against 185 total failures. The counts sum to 190.

**What to do:** state the overlap explicitly, preferably as a small contingency table, and keep the denominators consistent with the earlier 9,883 set-level failures and later 185 corpus-pair failures. At lines 341–348, percentages \(27.8+57+23\) also exceed 100%; say whether conditions overlap and what population each percentage uses.

## What would improve the paper

### 19. Keep the opening, but make the contribution statement more exact

**Gottlieb:** [paper/atlas.tex:67–80](/root/defiformal/paper/atlas.tex:67) succeeds. By the end of the first page the reader knows the subject and the motivating question:

> “what, if anything, does composition preserve?”

That is a reason to continue.

**Halmos:** lines 111–162 then announce conclusions before their objects are defined and include claims later shown to be weaker or false. Keep the motivating opening, but replace “The shape of the answer” with a concise contribution list separating theorems, measurements, and conjectures. Do not introduce the clique conjecture until compatibility is prepared.

### 20. Several sections are sound and should survive the reconstruction

- [paper/atlas.tex:484–522](/root/defiformal/paper/atlas.tex:484), “The positive theory does not bind,” contains an important negative empirical result and candidly limits the formal theory. Keep it, with reproducibility information.
- [paper/atlas.tex:673–778](/root/defiformal/paper/atlas.tex:673), the convex-geometry section, has the manuscript’s cleanest theorem sequence. Keep the identity and the “thinness” observation; repair the complexity claim.
- [paper/atlas.tex:1040–1098](/root/defiformal/paper/atlas.tex:1040), the coverage limitations, are unusually clear. Move them into methods and obey them elsewhere.
- [paper/atlas.tex:1100–1112](/root/defiformal/paper/atlas.tex:1100) and [paper/atlas.tex:1269–1277](/root/defiformal/paper/atlas.tex:1269) give a sound account of what a construction does and does not establish, once the predicate and evidence are fixed.
- [paper/atlas.tex:853–880](/root/defiformal/paper/atlas.tex:853), the machine-checked scope statement, is responsible and precise. Gottlieb would shorten or append it; Halmos would retain the exact “formalised/not formalised” division.
- The twelve category-opening questions and “What the vocabulary cannot see here” syntheses generally carry argument. Preserve those; remove the repeated procedural paragraphs around them.
- [paper/atlas.tex:4335–4400](/root/defiformal/paper/atlas.tex:4335), the related-work section, is mostly modest and useful. Move it earlier and document the novelty search.

### 21. Repair local report-writing and sentence defects

At [paper/atlas.tex:953–956](/root/defiformal/paper/atlas.tex:953):

> “The composability question, asked of the corpus rather than of abstract sets.”

This is a fragment. Write a complete introductory sentence stating what the section measures.

At [paper/atlas.tex:318–320](/root/defiformal/paper/atlas.tex:318), an empirical verification is placed inside a corollary:

> “closed under \(\oplus\): verified on 96,720 pairs”

A corollary is proved; a finite check is measured. Separate the theorem from corroboration.

The very long single-paragraph profile conclusions—many exceeding a page—regularly contain four or five independent findings joined by dashes. Break the retained case studies into evidence, decomposition decision, residue, and consequence. In the supplement, use structured fields rather than prose.

## Verdict

**Not yet.** The manuscript has an arresting question, a credible mathematical core in the definite fragment, and a large empirical study worth preserving. But publication presently depends on a formal object whose definition changes, several theorems stronger than their proofs, a compatibility argument with elementary graph-theoretic errors, and an empirical atlas whose sources and sampling frame are not exposed in the paper. These are not matters of polishing. The formal predicates must be stabilized and the claims reproved under them; the 60/72-unit corpus must be made reproducible; the incomplete residue classification must be described honestly or completed; and the hundred-page atlas must become a supplement supporting a much shorter argument. Once those changes are made, the work could merit a fresh publication review.
