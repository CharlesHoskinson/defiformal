# Round 2 — Halmos and Gottlieb on the manuscript

# Joint editorial review

Scope: `paper/atlas.tex` at SHA-256 `233132b0…096ed9d`, together with [supplement.tex](/root/defiformal/paper/supplement.tex:1), because the stated totals are obtained only jointly: 72 measurements and 70 remarks in the article, plus 56 measurements and 112 remarks in the supplement. The submission is 42 article pages plus 85 supplement pages. No files were edited.

The manuscript has a real core: the union-closed model class, the definite-fragment convex geometry, the canonical-form calculation, and a substantial empirical audit. It is not yet publishable, however, because several headline claims conflict with the definitions, the data, or one another.

## Must change before publication

1. **Both: the central Horn/dual-Horn classification is wrong as stated, and the conclusion built on it is false.**

   [atlas.tex:444](/root/defiformal/paper/atlas.tex:444) says:

   > “clauses with two or more negative literals together with a positive one; these are neither Horn nor dual-Horn”

   A clause with any number of negative literals and exactly one positive literal is Horn. The actual predicate is heterogeneous: `X19*` and `X18` have multiple negative and multiple positive literals and are indeed neither; `X2` and `X21` are purely negative Horn clauses. The repository’s own audit records this distinction and shows that `X21` and `X2` account for most failures ([VERIFICATION.md:177](/root/defiformal/formal/v3/VERIFICATION.md:177), [VERIFICATION.md:181](/root/defiformal/formal/v3/VERIFICATION.md:181)).

   Consequently these claims must be withdrawn or rewritten:

   - [atlas.tex:132](/root/defiformal/paper/atlas.tex:132): “Every observed composition failure arises from conditional constraints that are neither Horn nor dual-Horn.”
   - [atlas.tex:451](/root/defiformal/paper/atlas.tex:451): the attribution of all failures to one outside class.
   - [atlas.tex:2676](/root/defiformal/paper/atlas.tex:2676): the same false conclusion.

   Reclassify every conditional row individually and replace the headline with the supported statement: requirements, warrants, and grounding cause no observed union failure; failures come from both Horn prohibitions and genuinely mixed-polarity clauses.

2. **Both: three different admissibility objects are repeatedly conflated.**

   The definitions make

   \[
   \Adm=\mathcal R\cap\mathcal W\cap\mathcal H,\qquad
   \Admf\subsetneq\Adm,
   \]

   at [atlas.tex:313](/root/defiformal/paper/atlas.tex:313)–[335](/root/defiformal/paper/atlas.tex:335). But [atlas.tex:338](/root/defiformal/paper/atlas.tex:338) calls the lattice and convex-geometry results “results about \(\Adm\),” although the proved lattice is \(\mathcal R\cap\mathcal W\), without \(\mathcal H\). At [atlas.tex:761](/root/defiformal/paper/atlas.tex:761), “\(\Adm\) a complete lattice” again names the wrong object. The open-problem heading names \(\Admf\) and then asks about \(\Adm\) at [atlas.tex:2577](/root/defiformal/paper/atlas.tex:2577).

   Introduce three unambiguous symbols, for example:

   - \(\mathcal P=\mathcal R\cap\mathcal W\): positive model class;
   - \(\mathcal A_0=\mathcal P\cap\mathcal H\): listed-clause admissibility;
   - \(\mathcal A_{\mathrm{op}}\): full operational predicate.

   Then audit every occurrence of “admissible,” \(\Adm\), \(\Admf\), “prohibition,” and \(\Haz\). In particular, \(\Haz\) must not sometimes mean the listed clutter and sometimes the hand-written conditional predicate.

3. **Both: the warrant relation contradicts itself.**

   [atlas.tex:265](/root/defiformal/paper/atlas.tex:265) says:

   > “It is obtained as the residual (order-theoretic adjoint) of the requirement relation”

   [atlas.tex:731](/root/defiformal/paper/atlas.tex:731) says:

   > “The warrant relation is not the residual of the requirement relation”

   The notation table partly reveals the intended distinction—“\(C\) the fitted assignment, \(C^\ast\) the residual”—but the definitions do not. Define the empirical consumer assignment and order-theoretic residual separately before either is used. Use \(C_e\) for an individual consumer set, \(C\) for the fitted relation, and \(C^\ast\) for its residual. Define the plain \(R\) used at lines 731–738; presently only \(\mathcal R\), a model class, is defined.

4. **Both: \(\Gamma\) is never defined, while the paper first denies that such an operator exists and then bases several sections on it.**

   [atlas.tex:306](/root/defiformal/paper/atlas.tex:306) says that disjunctive requirements determine “no canonical map.” Yet \(\Gamma\) appears as an inflationary operator in the AFT theorem at [atlas.tex:489](/root/defiformal/paper/atlas.tex:489) and throughout “Completion lattices” at [atlas.tex:555](/root/defiformal/paper/atlas.tex:555).

   Either define a particular choice-dependent \(\Gamma\), state its domain and fixed points, and explain why it is legitimate despite Section 3, or delete the \(\Gamma\)-based obstruction and completion sections. At present “admissibility is a diagonal” in the abstract and introduction is not established for the model actually defined.

5. **Both: the compatibility-graph arc contains multiple invalid or mutually contradictory claims.**

   - The introduction says the problem “is NP-hard” and there is “no unique largest family” at [atlas.tex:155](/root/defiformal/paper/atlas.tex:155). Later [atlas.tex:2315](/root/defiformal/paper/atlas.tex:2315) correctly admits that no hardness reduction has been shown.
   - [atlas.tex:2301](/root/defiformal/paper/atlas.tex:2301) is titled “No maximum, only maximal,” but its body expressly leaves open uniqueness of a maximum-cardinality family.
   - [atlas.tex:673](/root/defiformal/paper/atlas.tex:673) says no certification rate is claimed for \(F\); [atlas.tex:2334](/root/defiformal/paper/atlas.tex:2334) nevertheless reports \(59\%\).
   - The conjecture `conj:frag` is called a “Measurement” at [atlas.tex:2274](/root/defiformal/paper/atlas.tex:2274) and [atlas.tex:2319](/root/defiformal/paper/atlas.tex:2319).
   - Most seriously, [atlas.tex:2340](/root/defiformal/paper/atlas.tex:2340) claims compatibility on \(\Admf\) is determined by traces of \(\Haz\). But \(\Admf\) includes conditional clauses outside the listed clutter, and those clauses cause most observed failures. The claimed quotient therefore does not determine the graph as defined.

   Retain the valid tautology “safe families are cliques.” Remove the instance-level NP-hardness claim, the “no maximum” claim, the \(59\%\) figure, and the perfection argument until a quotient is constructed for the complete operational predicate and proved to preserve adjacency.

6. **Both: the bilattice theorem is not a theorem in its present form.**

   [atlas.tex:475](/root/defiformal/paper/atlas.tex:475) asserts:

   > “No interlaced bilattice … has \(\Adm\) as a definable object.”

   “Definable object” is not defined. A componentwise product does not by itself make its diagonal undefinable, and a definable subset need not inherit both lattice structures. The proof’s final contradiction cites the polarity lemma, which says nothing of the asserted kind.

   Specify the formal language and permitted definitions, then prove an undefinability statement in it. Otherwise recast this as a failed modelling attempt, not original theorem-level work. The abstract should not lead with it until repaired.

7. **Both: “canonical form” is applied outside the theorem’s domain.**

   [atlas.tex:832](/root/defiformal/paper/atlas.tex:832) proves a unique minimal generator only for a *closed* set. [atlas.tex:1013](/root/defiformal/paper/atlas.tex:1013) then says the corollary assigns “each protocol” a canonical form, including rejected constructions such as Rysk, which omits a definite consequence and is not closed.

   Define, for arbitrary \(X\),

   \[
   \operatorname{can}(X)=\operatorname{ex}(Cn(X)),
   \]

   and distinguish this from \(\operatorname{ex}(A)\) for closed \(A\). Recompute or restate every corpus result accordingly. Replace “every protocol has a unique minimal generator” in the conclusion with the exact closed-set statement.

8. **Both: the empirical totals are stale and mutually inconsistent.**

   The generated table gives 1,259 obligations, 570 discharged, and 689 residue at [atlas.tex:1430](/root/defiformal/paper/atlas.tex:1430). The current scripts reproduce those exact totals and \(570/1259=45.3\%\). But:

   - [atlas.tex:1180](/root/defiformal/paper/atlas.tex:1180) reports \(45.5\%\);
   - [atlas.tex:1186](/root/defiformal/paper/atlas.tex:1186) says 573 rows were assigned;
   - [atlas.tex:2374](/root/defiformal/paper/atlas.tex:2374) says there are 686 residue obligations.

   Regenerate all dependent prose from the same data source as the table. Add a build check that compares every headline total with `cattable.mjs` and `coverage.mjs`; do not repair these numbers manually.

9. **Both: the two empirical layers are not merely two populations; they are often two different encodings.**

   Methods distinguishes 72 decompositions from 60 constructions at [atlas.tex:192](/root/defiformal/paper/atlas.tex:192), which is useful. But many detailed profiles say that the later witness adds or drops elements because the corpus record was wrong or obsolete—for example [supplement.tex:89](/root/defiformal/paper/supplement.tex:89), [supplement.tex:196](/root/defiformal/paper/supplement.tex:196), and [supplement.tex:1478](/root/defiformal/paper/supplement.tex:1478). Thus aggregate composition statistics use one encoding while detailed verdicts and residue use another.

   State this explicitly. Give the two datasets separate names and version identifiers. Never write “the protocol is rejected” without saying by which encoding and predicate. The category table should not mix construction footprints, original-corpus composition counts, and corrected verdicts under one undifferentiated heading.

10. **Both: the submission does not expose the evidence it claims to cite.**

    [atlas.tex:199](/root/defiformal/paper/atlas.tex:199) says every obligation has a cited source and that 639 sources are cited. Yet the 85-page supplement contains no `\cite` command and no bibliography. Its highly specific claims—including addresses, quorums, balances, quoted documentation, and historical events—are not independently checkable from the publication.

    Emit a stable evidence identifier or footnote beside every obligation, with a bibliography or archival URL list. Repository-only JSON is useful supplementary data, but it does not make “639 sources are cited” true in the submitted text.

11. **Both: the current source contains publication-blocking assembly defects.**

    - The proof of Theorem 11.4 appears only after Proposition 11.5 and therefore reads as a second proof of the proposition: [atlas.tex:837](/root/defiformal/paper/atlas.tex:837)–[866](/root/defiformal/paper/atlas.tex:866). Put the theorem proof immediately after the theorem.
    - Two cross-references have been broken into literal text: [atlas.tex:1054](/root/defiformal/paper/atlas.tex:1054) and [atlas.tex:1163](/root/defiformal/paper/atlas.tex:1163).
    - The stablecoin transition paragraph is duplicated verbatim at [atlas.tex:2179](/root/defiformal/paper/atlas.tex:2179) and [atlas.tex:2188](/root/defiformal/paper/atlas.tex:2188).
    - The checker remark ends in a hanging dash and incomplete sentence at [atlas.tex:1382](/root/defiformal/paper/atlas.tex:1382).
    - “evidence reference{,}” at [atlas.tex:206](/root/defiformal/paper/atlas.tex:206) exposes raw assembly text.

    Rebuild from a clean source, inspect the resulting PDF, and make the build fail on malformed `ef{...}`, duplicate paragraphs, incomplete environments, and changelog headings.

## Should change

12. **Halmos: the argument needs one spine, not thirty sections. Gottlieb: the article currently reads as an accumulation.**

    A better order is:

    1. Problem, data, and exact objects.
    2. Positive model class and its limits.
    3. Definite closure, convex geometry, and canonical composition.
    4. Operational admissibility and measured composition failures.
    5. Corpus synthesis and four case studies.
    6. Residue-derived extensions.
    7. Limitations and open problems.

    Merge “Obstructions,” “Collapse over the powerset,” “Completion lattices,” and “The positive theory does not bind” into one limits section. Move “Applying the canonical form” directly after the convex-geometry theorem. Move the Lean inventory and classical blocker material to an appendix; the blocker section admits that the instance is trivial and non-degenerate machinery is not exercised ([atlas.tex:956](/root/defiformal/paper/atlas.tex:956)).

13. **They differ on the category material, but agree on the remedy.**

    Halmos would retain the sixty profiles as an audit object. Gottlieb would cut most of their narrative because the same form repeats 60 times. The compromise is sound:

    - Main article: one category table, three cross-category synthesis subsections, and four case studies.
    - Supplement: sixty standardized profile records.
    - Machine-readable archive: full obligation/evidence ledgers and original-versus-corrected deltas.

    The twelve category sections currently repeat “Footprint,” “Composition,” “What the vocabulary cannot see,” and the same verification-output sentence. Collapse the 24 footprint/composition measurements into tables. Keep the interpretive cross-category findings.

14. **Both: 128 “Measurements” and 182 “Remarks” flatten the hierarchy of evidence.**

    Reserve numbered measurement environments for results used later: vacuity, failure attribution, canonical compression, pairwise composition, coverage sensitivity, predicate sensitivity, non-unique constructions, and residue classification.

    Move these out of numbered environments:

    - 60 per-profile construction verdicts: a table/schema in the supplement.
    - 24 category footprint/composition summaries: two tables.
    - method/checker/runtime statements: Methods or reproducibility appendix.
    - the twelve “What the vocabulary cannot see here” remarks: three thematic synthesis subsections.
    - one-sentence qualifications: ordinary prose.

15. **Both: remove the residual scaffolding.**

    These sentences describe how the study happened rather than the result:

    - [atlas.tex:591](/root/defiformal/paper/atlas.tex:591): “Recorded so that it is not re-derived.” Delete.
    - [atlas.tex:685](/root/defiformal/paper/atlas.tex:685): remark titled “Corrected.” State the corrected result directly.
    - [atlas.tex:776](/root/defiformal/paper/atlas.tex:776): “shipped table.” Use “empirical consumer assignment.”
    - [atlas.tex:1316](/root/defiformal/paper/atlas.tex:1316): checker search procedure. Move to computational methods.
    - [atlas.tex:1382](/root/defiformal/paper/atlas.tex:1382): self-test inventory. Move to reproducibility documentation.
    - The repeated “emitted from the verification output rather than transcribed,” beginning at [atlas.tex:1554](/root/defiformal/paper/atlas.tex:1554): say it once in Methods.
    - [atlas.tex:1504](/root/defiformal/paper/atlas.tex:1504): contested-register encoding history. Put in data limitations.
    - [atlas.tex:2179](/root/defiformal/paper/atlas.tex:2179): “A second research pass…” Replace with the final finding.
    - [atlas.tex:2378](/root/defiformal/paper/atlas.tex:2378): “first seven categories to complete” and “categories that arrived later.” Give a result-based reason for the partial classification, not the work order.
    - [atlas.tex:2426](/root/defiformal/paper/atlas.tex:2426): “contract,” “lanes,” and “independent specs.” Move to coding-reliability methods.

    In the supplement, profile-closing paragraphs repeatedly say “the corpus records,” “the witness adds,” or “the witness drops”; representative instances are [supplement.tex:55](/root/defiformal/paper/supplement.tex:55), [supplement.tex:125](/root/defiformal/paper/supplement.tex:125), [supplement.tex:1204](/root/defiformal/paper/supplement.tex:1204), and [supplement.tex:1700](/root/defiformal/paper/supplement.tex:1700). Move these deltas to a compact audit table and let the prose state the final decomposition.

16. **Gottlieb: the opening succeeds, but overpromises what the paper later disclaims.**

    By the end of page two the reader knows the subject and why it matters; [atlas.tex:69](/root/defiformal/paper/atlas.tex:69)–[90](/root/defiformal/paper/atlas.tex:90) is effective. But the abstract omits warrants, grounding, conditional clauses, and the split between structural and operational predicates. It therefore makes the proved algebra appear to govern the empirical failures more directly than it does.

    Rewrite the abstract last. Its center should be the verified positive result and the measured limitation, not the presently unsupported bilattice theorem. Preserve the useful and honest “72 broadly, 60 in detail” distinction and “partial classification” qualification.

17. **Halmos: notation still changes type.**

    Besides \(\Adm\), \(\Haz\), and \(C\):

    - “protocol” means both deployed system and subset of \(\El\). Say “deployed application \(P\)” and “decomposition \(X_P\).”
    - \(X\) is a protocol variable while identifiers such as `X2` and `X21` are clauses. Rename clause identifiers typographically, e.g. \(\mathsf{X2}\).
    - \(S\) means a clause set, seed, local bitset, and obligation alternative. Use distinct letters.
    - “footprint” means all 72 decompositions in category measurements but the five detailed constructions in Table 2. Name these “corpus footprint” and “detailed-sample footprint.”
    - \(\oplus\) and \(Cn\) are used at [atlas.tex:428](/root/defiformal/paper/atlas.tex:428), hundreds of lines before their definitions. Move the definitions earlier.

18. **Both: the hedging alternates between necessary caution and author-protection.**

    Keep genuine epistemic limits such as “not measured,” “inter-rater reliability is unknown,” and formally labelled conjectures. Remove or recast:

    - [atlas.tex:138](/root/defiformal/paper/atlas.tex:138): “appears to satisfy” precedes a theorem proving it.
    - [atlas.tex:674](/root/defiformal/paper/atlas.tex:674): “substantial fraction” is unquantified.
    - [atlas.tex:679](/root/defiformal/paper/atlas.tex:679): the synthetic-width indication does no work; delete the remark and its “Corrected” sequel.
    - [atlas.tex:767](/root/defiformal/paper/atlas.tex:767): “so we take the second.” State the criterion and consequence.
    - [atlas.tex:779](/root/defiformal/paper/atlas.tex:779): “recover the structure theorem honestly.” “Preserve invariance while fitting the corpus” is enough.
    - [atlas.tex:2391](/root/defiformal/paper/atlas.tex:2391): “three repairs we would act on.” State the inclusion criteria.
    - [atlas.tex:2552](/root/defiformal/paper/atlas.tex:2552): “not worth repairing” and “we recommend.” State cost and benefit, then leave the design decision explicit.
    - “sharpest,” “honest,” “worth,” and “false comfort” at lines 1149, 2136, 2542, and 2473 are editorial flourishes, not evidence.

    No occurrence of “we would defend” appears, but the listed phrases perform the same protective or evaluative work.

19. **Both: superlatives require scope or evidence.**

    Unsupported or internally contradicted instances include:

    - [atlas.tex:78](/root/defiformal/paper/atlas.tex:78): “several of the largest losses” has no citation.
    - [atlas.tex:85](/root/defiformal/paper/atlas.tex:85): “coarsest … still faithful” has no faithfulness test.
    - [atlas.tex:109](/root/defiformal/paper/atlas.tex:109): “largest single asset” is unnamed and capital is not stored as a measured quantity.
    - [atlas.tex:1149](/root/defiformal/paper/atlas.tex:1149): “sharpest statement.”
    - [atlas.tex:1152](/root/defiformal/paper/atlas.tex:1152): “two largest protocols” needs the ranking source and date.
    - [atlas.tex:2174](/root/defiformal/paper/atlas.tex:2174): “resolution is inversely correlated with capital” directly contradicts [atlas.tex:1218](/root/defiformal/paper/atlas.tex:1218), which says that relation was not measured.
    - [atlas.tex:2436](/root/defiformal/paper/atlas.tex:2436): “largest request” must say “within the 385 classified obligations.”
    - [atlas.tex:2552](/root/defiformal/paper/atlas.tex:2552): “largest group” conflicts with the preceding 95-item party group unless the grouping levels are distinguished.
    - [atlas.tex:2632](/root/defiformal/paper/atlas.tex:2632): “unnamed” and “apparently unstudied” require a documented search protocol or narrower wording.
    - [atlas.tex:2689](/root/defiformal/paper/atlas.tex:2689): “Coverage degrades with the fraction … off-chain” is not measured anywhere.

    Add a ranking/source table for empirical “largest” claims. Define the metric for mathematical “most” claims. Delete aesthetic superlatives.

## Would improve it

- Normalize the supplement’s report register: remove all-caps emphasis such as “MONOTONE,” “NO,” and “WHICH”; use mathematical or typographic emphasis sparingly. Its current raw-audit style also causes numerous serious overfull boxes.

- Replace long contract identifiers and addresses in prose with evidence notes or a data table. The supplement should be readable as a publication, not as terminal output.

- Give the partial residue classification a preregistered or substantive inclusion rule. Chronological availability is not a defensible basis for ranking proposed extensions.

- Add a short limitations table collecting: one coding per application, unknown inter-rater reliability, approximate assignments, dated live-state reads, original-versus-corrected encodings, and the partial residue classification.

## Material that is sound and should be preserved

Both readers would retain the opening problem statement; the requirement, prohibition, and warrant definitions once the residual contradiction is fixed; the proof that \(\mathcal R\cap\mathcal W\) is union-closed and therefore a complete lattice; the definite-requirement digraph and convex-geometry core; the careful coverage warning at [atlas.tex:1167](/root/defiformal/paper/atlas.tex:1167)–[1202](/root/defiformal/paper/atlas.tex:1202); the construction definitions; and the four extended case studies, after evidence citations and audit-history prose are separated. The Related Work section is broadly well pitched, subject to qualifying its novelty searches.

## Verdict: not yet

The manuscript contains publishable mathematics and an unusually rich empirical record, but its present claims do not form one reliable object. The operational clauses are misclassified, the principal predicates and warrant relations change meaning, undefined operators support theorem-level claims, the clique/perfection arc contradicts both the data and itself, and the generated totals no longer agree with the prose. The source also contains visible assembly failures and the supplement withholds the citations needed to audit its strongest empirical statements. This requires a structural and mathematical revision, not copy-editing; after that revision, the convex-geometry result, corpus synthesis, and carefully scoped residue analysis could support a publishable paper.
tokens used
255,611
# Joint editorial review

Scope: `paper/atlas.tex` at SHA-256 `233132b0…096ed9d`, together with [supplement.tex](/root/defiformal/paper/supplement.tex:1), because the stated totals are obtained only jointly: 72 measurements and 70 remarks in the article, plus 56 measurements and 112 remarks in the supplement. The submission is 42 article pages plus 85 supplement pages. No files were edited.

The manuscript has a real core: the union-closed model class, the definite-fragment convex geometry, the canonical-form calculation, and a substantial empirical audit. It is not yet publishable, however, because several headline claims conflict with the definitions, the data, or one another.

## Must change before publication

1. **Both: the central Horn/dual-Horn classification is wrong as stated, and the conclusion built on it is false.**

   [atlas.tex:444](/root/defiformal/paper/atlas.tex:444) says:

   > “clauses with two or more negative literals together with a positive one; these are neither Horn nor dual-Horn”

   A clause with any number of negative literals and exactly one positive literal is Horn. The actual predicate is heterogeneous: `X19*` and `X18` have multiple negative and multiple positive literals and are indeed neither; `X2` and `X21` are purely negative Horn clauses. The repository’s own audit records this distinction and shows that `X21` and `X2` account for most failures ([VERIFICATION.md:177](/root/defiformal/formal/v3/VERIFICATION.md:177), [VERIFICATION.md:181](/root/defiformal/formal/v3/VERIFICATION.md:181)).

   Consequently these claims must be withdrawn or rewritten:

   - [atlas.tex:132](/root/defiformal/paper/atlas.tex:132): “Every observed composition failure arises from conditional constraints that are neither Horn nor dual-Horn.”
   - [atlas.tex:451](/root/defiformal/paper/atlas.tex:451): the attribution of all failures to one outside class.
   - [atlas.tex:2676](/root/defiformal/paper/atlas.tex:2676): the same false conclusion.

   Reclassify every conditional row individually and replace the headline with the supported statement: requirements, warrants, and grounding cause no observed union failure; failures come from both Horn prohibitions and genuinely mixed-polarity clauses.

2. **Both: three different admissibility objects are repeatedly conflated.**

   The definitions make

   \[
   \Adm=\mathcal R\cap\mathcal W\cap\mathcal H,\qquad
   \Admf\subsetneq\Adm,
   \]

   at [atlas.tex:313](/root/defiformal/paper/atlas.tex:313)–[335](/root/defiformal/paper/atlas.tex:335). But [atlas.tex:338](/root/defiformal/paper/atlas.tex:338) calls the lattice and convex-geometry results “results about \(\Adm\),” although the proved lattice is \(\mathcal R\cap\mathcal W\), without \(\mathcal H\). At [atlas.tex:761](/root/defiformal/paper/atlas.tex:761), “\(\Adm\) a complete lattice” again names the wrong object. The open-problem heading names \(\Admf\) and then asks about \(\Adm\) at [atlas.tex:2577](/root/defiformal/paper/atlas.tex:2577).

   Introduce three unambiguous symbols, for example:

   - \(\mathcal P=\mathcal R\cap\mathcal W\): positive model class;
   - \(\mathcal A_0=\mathcal P\cap\mathcal H\): listed-clause admissibility;
   - \(\mathcal A_{\mathrm{op}}\): full operational predicate.

   Then audit every occurrence of “admissible,” \(\Adm\), \(\Admf\), “prohibition,” and \(\Haz\). In particular, \(\Haz\) must not sometimes mean the listed clutter and sometimes the hand-written conditional predicate.

3. **Both: the warrant relation contradicts itself.**

   [atlas.tex:265](/root/defiformal/paper/atlas.tex:265) says:

   > “It is obtained as the residual (order-theoretic adjoint) of the requirement relation”

   [atlas.tex:731](/root/defiformal/paper/atlas.tex:731) says:

   > “The warrant relation is not the residual of the requirement relation”

   The notation table partly reveals the intended distinction—“\(C\) the fitted assignment, \(C^\ast\) the residual”—but the definitions do not. Define the empirical consumer assignment and order-theoretic residual separately before either is used. Use \(C_e\) for an individual consumer set, \(C\) for the fitted relation, and \(C^\ast\) for its residual. Define the plain \(R\) used at lines 731–738; presently only \(\mathcal R\), a model class, is defined.

4. **Both: \(\Gamma\) is never defined, while the paper first denies that such an operator exists and then bases several sections on it.**

   [atlas.tex:306](/root/defiformal/paper/atlas.tex:306) says that disjunctive requirements determine “no canonical map.” Yet \(\Gamma\) appears as an inflationary operator in the AFT theorem at [atlas.tex:489](/root/defiformal/paper/atlas.tex:489) and throughout “Completion lattices” at [atlas.tex:555](/root/defiformal/paper/atlas.tex:555).

   Either define a particular choice-dependent \(\Gamma\), state its domain and fixed points, and explain why it is legitimate despite Section 3, or delete the \(\Gamma\)-based obstruction and completion sections. At present “admissibility is a diagonal” in the abstract and introduction is not established for the model actually defined.

5. **Both: the compatibility-graph arc contains multiple invalid or mutually contradictory claims.**

   - The introduction says the problem “is NP-hard” and there is “no unique largest family” at [atlas.tex:155](/root/defiformal/paper/atlas.tex:155). Later [atlas.tex:2315](/root/defiformal/paper/atlas.tex:2315) correctly admits that no hardness reduction has been shown.
   - [atlas.tex:2301](/root/defiformal/paper/atlas.tex:2301) is titled “No maximum, only maximal,” but its body expressly leaves open uniqueness of a maximum-cardinality family.
   - [atlas.tex:673](/root/defiformal/paper/atlas.tex:673) says no certification rate is claimed for \(F\); [atlas.tex:2334](/root/defiformal/paper/atlas.tex:2334) nevertheless reports \(59\%\).
   - The conjecture `conj:frag` is called a “Measurement” at [atlas.tex:2274](/root/defiformal/paper/atlas.tex:2274) and [atlas.tex:2319](/root/defiformal/paper/atlas.tex:2319).
   - Most seriously, [atlas.tex:2340](/root/defiformal/paper/atlas.tex:2340) claims compatibility on \(\Admf\) is determined by traces of \(\Haz\). But \(\Admf\) includes conditional clauses outside the listed clutter, and those clauses cause most observed failures. The claimed quotient therefore does not determine the graph as defined.

   Retain the valid tautology “safe families are cliques.” Remove the instance-level NP-hardness claim, the “no maximum” claim, the \(59\%\) figure, and the perfection argument until a quotient is constructed for the complete operational predicate and proved to preserve adjacency.

6. **Both: the bilattice theorem is not a theorem in its present form.**

   [atlas.tex:475](/root/defiformal/paper/atlas.tex:475) asserts:

   > “No interlaced bilattice … has \(\Adm\) as a definable object.”

   “Definable object” is not defined. A componentwise product does not by itself make its diagonal undefinable, and a definable subset need not inherit both lattice structures. The proof’s final contradiction cites the polarity lemma, which says nothing of the asserted kind.

   Specify the formal language and permitted definitions, then prove an undefinability statement in it. Otherwise recast this as a failed modelling attempt, not original theorem-level work. The abstract should not lead with it until repaired.

7. **Both: “canonical form” is applied outside the theorem’s domain.**

   [atlas.tex:832](/root/defiformal/paper/atlas.tex:832) proves a unique minimal generator only for a *closed* set. [atlas.tex:1013](/root/defiformal/paper/atlas.tex:1013) then says the corollary assigns “each protocol” a canonical form, including rejected constructions such as Rysk, which omits a definite consequence and is not closed.

   Define, for arbitrary \(X\),

   \[
   \operatorname{can}(X)=\operatorname{ex}(Cn(X)),
   \]

   and distinguish this from \(\operatorname{ex}(A)\) for closed \(A\). Recompute or restate every corpus result accordingly. Replace “every protocol has a unique minimal generator” in the conclusion with the exact closed-set statement.

8. **Both: the empirical totals are stale and mutually inconsistent.**

   The generated table gives 1,259 obligations, 570 discharged, and 689 residue at [atlas.tex:1430](/root/defiformal/paper/atlas.tex:1430). The current scripts reproduce those exact totals and \(570/1259=45.3\%\). But:

   - [atlas.tex:1180](/root/defiformal/paper/atlas.tex:1180) reports \(45.5\%\);
   - [atlas.tex:1186](/root/defiformal/paper/atlas.tex:1186) says 573 rows were assigned;
   - [atlas.tex:2374](/root/defiformal/paper/atlas.tex:2374) says there are 686 residue obligations.

   Regenerate all dependent prose from the same data source as the table. Add a build check that compares every headline total with `cattable.mjs` and `coverage.mjs`; do not repair these numbers manually.

9. **Both: the two empirical layers are not merely two populations; they are often two different encodings.**

   Methods distinguishes 72 decompositions from 60 constructions at [atlas.tex:192](/root/defiformal/paper/atlas.tex:192), which is useful. But many detailed profiles say that the later witness adds or drops elements because the corpus record was wrong or obsolete—for example [supplement.tex:89](/root/defiformal/paper/supplement.tex:89), [supplement.tex:196](/root/defiformal/paper/supplement.tex:196), and [supplement.tex:1478](/root/defiformal/paper/supplement.tex:1478). Thus aggregate composition statistics use one encoding while detailed verdicts and residue use another.

   State this explicitly. Give the two datasets separate names and version identifiers. Never write “the protocol is rejected” without saying by which encoding and predicate. The category table should not mix construction footprints, original-corpus composition counts, and corrected verdicts under one undifferentiated heading.

10. **Both: the submission does not expose the evidence it claims to cite.**

    [atlas.tex:199](/root/defiformal/paper/atlas.tex:199) says every obligation has a cited source and that 639 sources are cited. Yet the 85-page supplement contains no `\cite` command and no bibliography. Its highly specific claims—including addresses, quorums, balances, quoted documentation, and historical events—are not independently checkable from the publication.

    Emit a stable evidence identifier or footnote beside every obligation, with a bibliography or archival URL list. Repository-only JSON is useful supplementary data, but it does not make “639 sources are cited” true in the submitted text.

11. **Both: the current source contains publication-blocking assembly defects.**

    - The proof of Theorem 11.4 appears only after Proposition 11.5 and therefore reads as a second proof of the proposition: [atlas.tex:837](/root/defiformal/paper/atlas.tex:837)–[866](/root/defiformal/paper/atlas.tex:866). Put the theorem proof immediately after the theorem.
    - Two cross-references have been broken into literal text: [atlas.tex:1054](/root/defiformal/paper/atlas.tex:1054) and [atlas.tex:1163](/root/defiformal/paper/atlas.tex:1163).
    - The stablecoin transition paragraph is duplicated verbatim at [atlas.tex:2179](/root/defiformal/paper/atlas.tex:2179) and [atlas.tex:2188](/root/defiformal/paper/atlas.tex:2188).
    - The checker remark ends in a hanging dash and incomplete sentence at [atlas.tex:1382](/root/defiformal/paper/atlas.tex:1382).
    - “evidence reference{,}” at [atlas.tex:206](/root/defiformal/paper/atlas.tex:206) exposes raw assembly text.

    Rebuild from a clean source, inspect the resulting PDF, and make the build fail on malformed `ef{...}`, duplicate paragraphs, incomplete environments, and changelog headings.

## Should change

12. **Halmos: the argument needs one spine, not thirty sections. Gottlieb: the article currently reads as an accumulation.**

    A better order is:

    1. Problem, data, and exact objects.
    2. Positive model class and its limits.
    3. Definite closure, convex geometry, and canonical composition.
    4. Operational admissibility and measured composition failures.
    5. Corpus synthesis and four case studies.
    6. Residue-derived extensions.
    7. Limitations and open problems.

    Merge “Obstructions,” “Collapse over the powerset,” “Completion lattices,” and “The positive theory does not bind” into one limits section. Move “Applying the canonical form” directly after the convex-geometry theorem. Move the Lean inventory and classical blocker material to an appendix; the blocker section admits that the instance is trivial and non-degenerate machinery is not exercised ([atlas.tex:956](/root/defiformal/paper/atlas.tex:956)).

13. **They differ on the category material, but agree on the remedy.**

    Halmos would retain the sixty profiles as an audit object. Gottlieb would cut most of their narrative because the same form repeats 60 times. The compromise is sound:

    - Main article: one category table, three cross-category synthesis subsections, and four case studies.
    - Supplement: sixty standardized profile records.
    - Machine-readable archive: full obligation/evidence ledgers and original-versus-corrected deltas.

    The twelve category sections currently repeat “Footprint,” “Composition,” “What the vocabulary cannot see,” and the same verification-output sentence. Collapse the 24 footprint/composition measurements into tables. Keep the interpretive cross-category findings.

14. **Both: 128 “Measurements” and 182 “Remarks” flatten the hierarchy of evidence.**

    Reserve numbered measurement environments for results used later: vacuity, failure attribution, canonical compression, pairwise composition, coverage sensitivity, predicate sensitivity, non-unique constructions, and residue classification.

    Move these out of numbered environments:

    - 60 per-profile construction verdicts: a table/schema in the supplement.
    - 24 category footprint/composition summaries: two tables.
    - method/checker/runtime statements: Methods or reproducibility appendix.
    - the twelve “What the vocabulary cannot see here” remarks: three thematic synthesis subsections.
    - one-sentence qualifications: ordinary prose.

15. **Both: remove the residual scaffolding.**

    These sentences describe how the study happened rather than the result:

    - [atlas.tex:591](/root/defiformal/paper/atlas.tex:591): “Recorded so that it is not re-derived.” Delete.
    - [atlas.tex:685](/root/defiformal/paper/atlas.tex:685): remark titled “Corrected.” State the corrected result directly.
    - [atlas.tex:776](/root/defiformal/paper/atlas.tex:776): “shipped table.” Use “empirical consumer assignment.”
    - [atlas.tex:1316](/root/defiformal/paper/atlas.tex:1316): checker search procedure. Move to computational methods.
    - [atlas.tex:1382](/root/defiformal/paper/atlas.tex:1382): self-test inventory. Move to reproducibility documentation.
    - The repeated “emitted from the verification output rather than transcribed,” beginning at [atlas.tex:1554](/root/defiformal/paper/atlas.tex:1554): say it once in Methods.
    - [atlas.tex:1504](/root/defiformal/paper/atlas.tex:1504): contested-register encoding history. Put in data limitations.
    - [atlas.tex:2179](/root/defiformal/paper/atlas.tex:2179): “A second research pass…” Replace with the final finding.
    - [atlas.tex:2378](/root/defiformal/paper/atlas.tex:2378): “first seven categories to complete” and “categories that arrived later.” Give a result-based reason for the partial classification, not the work order.
    - [atlas.tex:2426](/root/defiformal/paper/atlas.tex:2426): “contract,” “lanes,” and “independent specs.” Move to coding-reliability methods.

    In the supplement, profile-closing paragraphs repeatedly say “the corpus records,” “the witness adds,” or “the witness drops”; representative instances are [supplement.tex:55](/root/defiformal/paper/supplement.tex:55), [supplement.tex:125](/root/defiformal/paper/supplement.tex:125), [supplement.tex:1204](/root/defiformal/paper/supplement.tex:1204), and [supplement.tex:1700](/root/defiformal/paper/supplement.tex:1700). Move these deltas to a compact audit table and let the prose state the final decomposition.

16. **Gottlieb: the opening succeeds, but overpromises what the paper later disclaims.**

    By the end of page two the reader knows the subject and why it matters; [atlas.tex:69](/root/defiformal/paper/atlas.tex:69)–[90](/root/defiformal/paper/atlas.tex:90) is effective. But the abstract omits warrants, grounding, conditional clauses, and the split between structural and operational predicates. It therefore makes the proved algebra appear to govern the empirical failures more directly than it does.

    Rewrite the abstract last. Its center should be the verified positive result and the measured limitation, not the presently unsupported bilattice theorem. Preserve the useful and honest “72 broadly, 60 in detail” distinction and “partial classification” qualification.

17. **Halmos: notation still changes type.**

    Besides \(\Adm\), \(\Haz\), and \(C\):

    - “protocol” means both deployed system and subset of \(\El\). Say “deployed application \(P\)” and “decomposition \(X_P\).”
    - \(X\) is a protocol variable while identifiers such as `X2` and `X21` are clauses. Rename clause identifiers typographically, e.g. \(\mathsf{X2}\).
    - \(S\) means a clause set, seed, local bitset, and obligation alternative. Use distinct letters.
    - “footprint” means all 72 decompositions in category measurements but the five detailed constructions in Table 2. Name these “corpus footprint” and “detailed-sample footprint.”
    - \(\oplus\) and \(Cn\) are used at [atlas.tex:428](/root/defiformal/paper/atlas.tex:428), hundreds of lines before their definitions. Move the definitions earlier.

18. **Both: the hedging alternates between necessary caution and author-protection.**

    Keep genuine epistemic limits such as “not measured,” “inter-rater reliability is unknown,” and formally labelled conjectures. Remove or recast:

    - [atlas.tex:138](/root/defiformal/paper/atlas.tex:138): “appears to satisfy” precedes a theorem proving it.
    - [atlas.tex:674](/root/defiformal/paper/atlas.tex:674): “substantial fraction” is unquantified.
    - [atlas.tex:679](/root/defiformal/paper/atlas.tex:679): the synthetic-width indication does no work; delete the remark and its “Corrected” sequel.
    - [atlas.tex:767](/root/defiformal/paper/atlas.tex:767): “so we take the second.” State the criterion and consequence.
    - [atlas.tex:779](/root/defiformal/paper/atlas.tex:779): “recover the structure theorem honestly.” “Preserve invariance while fitting the corpus” is enough.
    - [atlas.tex:2391](/root/defiformal/paper/atlas.tex:2391): “three repairs we would act on.” State the inclusion criteria.
    - [atlas.tex:2552](/root/defiformal/paper/atlas.tex:2552): “not worth repairing” and “we recommend.” State cost and benefit, then leave the design decision explicit.
    - “sharpest,” “honest,” “worth,” and “false comfort” at lines 1149, 2136, 2542, and 2473 are editorial flourishes, not evidence.

    No occurrence of “we would defend” appears, but the listed phrases perform the same protective or evaluative work.

19. **Both: superlatives require scope or evidence.**

    Unsupported or internally contradicted instances include:

    - [atlas.tex:78](/root/defiformal/paper/atlas.tex:78): “several of the largest losses” has no citation.
    - [atlas.tex:85](/root/defiformal/paper/atlas.tex:85): “coarsest … still faithful” has no faithfulness test.
    - [atlas.tex:109](/root/defiformal/paper/atlas.tex:109): “largest single asset” is unnamed and capital is not stored as a measured quantity.
    - [atlas.tex:1149](/root/defiformal/paper/atlas.tex:1149): “sharpest statement.”
    - [atlas.tex:1152](/root/defiformal/paper/atlas.tex:1152): “two largest protocols” needs the ranking source and date.
    - [atlas.tex:2174](/root/defiformal/paper/atlas.tex:2174): “resolution is inversely correlated with capital” directly contradicts [atlas.tex:1218](/root/defiformal/paper/atlas.tex:1218), which says that relation was not measured.
    - [atlas.tex:2436](/root/defiformal/paper/atlas.tex:2436): “largest request” must say “within the 385 classified obligations.”
    - [atlas.tex:2552](/root/defiformal/paper/atlas.tex:2552): “largest group” conflicts with the preceding 95-item party group unless the grouping levels are distinguished.
    - [atlas.tex:2632](/root/defiformal/paper/atlas.tex:2632): “unnamed” and “apparently unstudied” require a documented search protocol or narrower wording.
    - [atlas.tex:2689](/root/defiformal/paper/atlas.tex:2689): “Coverage degrades with the fraction … off-chain” is not measured anywhere.

    Add a ranking/source table for empirical “largest” claims. Define the metric for mathematical “most” claims. Delete aesthetic superlatives.

## Would improve it

- Normalize the supplement’s report register: remove all-caps emphasis such as “MONOTONE,” “NO,” and “WHICH”; use mathematical or typographic emphasis sparingly. Its current raw-audit style also causes numerous serious overfull boxes.

- Replace long contract identifiers and addresses in prose with evidence notes or a data table. The supplement should be readable as a publication, not as terminal output.

- Give the partial residue classification a preregistered or substantive inclusion rule. Chronological availability is not a defensible basis for ranking proposed extensions.

- Add a short limitations table collecting: one coding per application, unknown inter-rater reliability, approximate assignments, dated live-state reads, original-versus-corrected encodings, and the partial residue classification.

## Material that is sound and should be preserved

Both readers would retain the opening problem statement; the requirement, prohibition, and warrant definitions once the residual contradiction is fixed; the proof that \(\mathcal R\cap\mathcal W\) is union-closed and therefore a complete lattice; the definite-requirement digraph and convex-geometry core; the careful coverage warning at [atlas.tex:1167](/root/defiformal/paper/atlas.tex:1167)–[1202](/root/defiformal/paper/atlas.tex:1202); the construction definitions; and the four extended case studies, after evidence citations and audit-history prose are separated. The Related Work section is broadly well pitched, subject to qualifying its novelty searches.

## Verdict: not yet

The manuscript contains publishable mathematics and an unusually rich empirical record, but its present claims do not form one reliable object. The operational clauses are misclassified, the principal predicates and warrant relations change meaning, undefined operators support theorem-level claims, the clique/perfection arc contradicts both the data and itself, and the generated totals no longer agree with the prose. The source also contains visible assembly failures and the supplement withholds the citations needed to audit its strongest empirical statements. This requires a structural and mathematical revision, not copy-editing; after that revision, the convex-geometry result, corpus synthesis, and carefully scoped residue analysis could support a publishable paper.
