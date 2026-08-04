# Input design for a one-problem / many-independent-solvers exercise
### Evidence from the RPC-Memory case study, the Steam Boiler competition, and the anchoring literature

Scope note: this is about **how the problem statement was written and what that did to the answers**, not about the technical content of the solutions.

---

## 1. Primary target: the RPC-Memory Specification Problem (Dagstuhl 1994 → LNCS 1169, 1996)

### 1.1 Hard facts about the artefact

| Fact | Value | Source |
|---|---|---|
| Problem statement length | **4 pages** (LNCS 1169, pp. 1–4) | Springer/MSR metadata for Broy & Lamport, *The RPC-Memory Specification Problem: Problem Statement* |
| Authors of statement | Manfred Broy + Leslie Lamport | ibid. |
| Solutions published | **15**, after a Dagstuhl workshop (Sept 1994) + revision + cross-refereeing | Broy/Merz/Spies synopsis §1 |
| Editors' synopsis | 16 pp., includes 3 classification tables | synopsis, retrieved in full |

I retrieved and text-extracted two primary sources in full:
- Broy, Merz & Spies, **"The RPC-Memory Case Study: A Synopsis"** — https://members.loria.fr/Stephan.Merz/papers/RPCSynopsis.ps.gz
- Abadi, Lamport & Merz, **"A TLA Solution to the RPC-Memory Specification Problem"** — https://members.loria.fr/SMerz/papers/RPCMemory.ps.gz

All quotes below are from those two documents unless marked otherwise. (Ligature/space artefacts of PostScript extraction silently corrected.)

### 1.2 How the statement was structured

From the synopsis §2 ("The problem"), which reviews the statement clause by clause:

1. **A shared interface layer, fixed for everybody.** "The problem statement begins with a description of the procedure interface employed by all components. Each component is required to accept concurrent calls from different client processes, although there can be at most one outstanding call per process to facilitate identification of return values." This is the single most important structural choice: one **fixed common vocabulary** placed before any of the tasks.
2. **Component descriptions in informal prose**, using deliberate hedges ("as if it consisted of an array of memory cells").
3. **Five numbered problems**, mixing *kinds* of deliverable:
   - P1 specify the memory component (+ two named variants: reliable, ever-failing);
   - P2 specify the RPC component;
   - P3 **prove** that a given three-component configuration implements P1 — with **a figure** fixing that decomposition (Memory Clerk + RPC Component + Reliable Memory);
   - P4 specify a *lossy RPC* with real-time constraints (δ);
   - P5 **prove** RPC is implemented by lossy RPC + a clerk that times out at 2δ+ε.
4. **An explicit justification question, not a formalisation task.** For the two memory variants, "Participants were asked whether these variants are a valid implementation of the original memory component, **and, if so, why this is a reasonable assumption.**"

So: ~4 pages, one fixed interface, five numbered tasks, one architecture figure, at least one "and why?" question. Roughly half the tasks are *specify*, half are *prove*.

### 1.3 What was deliberately left free — and what that cost

> "The contributors were free to solve only those aspects of the problem that they considered particularly important **or omit aspects that could not be adequately represented in the chosen formalism**." (synopsis §1)

They used that freedom aggressively. From Table 1's *Coverage* column: seven solutions cover 1–5; five cover 1–3; one is "1, short discussion of 2,3"; one is "1–3 (incomplete specification)"; one covers 1–5 but with "no proof for 5". **A third of the corpus did not attempt the same questions.** The editors had to invent a Coverage column purely to make the volume legible.

Nothing was fixed about notation, semantics, proof obligation, or level of rigour. Consequently the deliverables ranged from Petri nets to PVS theories to "predicates on streams" to timing diagrams — and the editors had to reconstruct comparability after the fact.

### 1.4 Were the solutions comparable? Only via a post-hoc scheme the *editors* imposed

Comparability was **not** a property of the problem statement. It was manufactured afterwards, from referee reports, along eight fixed dimensions in Tables 1–3:

`Coverage · Means of presentation · Modularity · Properties vs. operational · Hiding · Environment vs. component · Stepwise refinement · Decomposition`

The editors describe their own role as "mostly **redactorial**, trying to ensure a common format and uniform criteria of classification," built from referee overviews with "literal quotes from the referee reports" (anonymised).

They explicitly refused to rank:

> "Although we do not want to and cannot come to a final judgement… Which of the contributions as solutions to the RPC case study a reader may prefer, depends very much on taste and style. **The idea of the whole experiment was never to have Olympic Games in specification, refinement, and verification.**"

And they disclaim neutrality: "because we have contributed solutions ourselves it would have been difficult to ensure a truly impartial assessment"; "our subjective backgrounds and predilections have influenced the presentation."

### 1.5 What the divergence actually revealed — about *people*, not methods

This is the headline retrospective finding, and it is the one most transferable to a nine-mathematician panel:

> "It was very interesting to see how the choice of the individual methods that were used to tackle the problem was **often less important for the quality of the final solutions than the modeling ideas of the specifiers**. Certainly, the creativity and expertise, and of course also the routine of the person applying a method, are more important for the result than the particular notation and model used… even plain predicate logic is a very powerful tool, and if a method comprises first-order predicate logic or at least a sufficient fragment of it, many ideas can be expressed, maybe less explicitly, but nevertheless they can be made to work."

Two corollaries: (a) **expressiveness was almost never the binding constraint** — the differentiator was the modelling *idea*; (b) attributing divergence to "the formalism" was mostly wrong.

They also flag a criterion the exercise **failed** to measure, because the statement never asked for it:

> "An aspect, very important for practical considerations, is the **economy of a method. How long does it take to learn it, how long does it take to use it** for a particular problem. **Here our little experiment does not provide much input.**"

If you want a dimension compared, you must demand it in the statement. Otherwise it is simply absent from fifteen papers.

Finally, they report that the thing that worked best was not the statement at all but the **cross-refereeing round**: "a very fruitful discussion was possible between proponents of quite different methods."

### 1.6 The misreadings — documented, and each one is a trap type

These are the crown jewels for your purposes.

**(a) Hedged prose ("as if") was silently reinterpreted by nearly everyone.**
> "Most contributors understood the wording of the informal description as a description of the **externally visible** memory behavior (as suggested by the phrase 'as if'), not the actual memory operation."

**(b) An asymmetry in the prose became a contradiction with a later task.** Retries were mentioned explicitly only for `Write`. But the P3 implementation "describes an explicit mechanism for retries that allows several atomic reads in response to a Read call." Result: "This issue has nevertheless caused some controversy." Three groups (Best, Romijn, Hooman) responded by *proving observational equivalence* of the single-read and multiple-read behaviours; **Larsen, Steffen & Weise "consider the problem statement to be flawed in this respect."** One accidental asymmetry generated both extra work and an outright rejection of the statement.

**(c) A load-bearing entity was never named.** "The memory clerk component (that is only **implicitly** described in the problem statement)…" — every solution had to invent it, and most independently converged on the same name, which is luck, not design.

**(d) The timed part (P4/P5) was internally inconsistent.** Abadi/Lamport/Merz, §4:
> "The problem statement's informal description of the lossy RPC component is **problematic**… The RPC component of Problem 2 is just as lossy as the 'lossy' one… The additional timing constraints on the lossy RPC component, together with the description of the RPC implementation, suggest that a sender process should be able to issue a new call if a previous one has not returned. However, **issuing a second call without waiting for a return violates the handshake protocol** of the procedure-calling interface."

and later:
> "There is another aspect of the problem statement that is **bizarre**… one would expect the clerk to have to return either a result or an exception within some fixed length of time. However, the problem statement makes no such requirement."

Cuellar/Barnard/Huber patched it by inventing a timeout action that "causes the lossy RPC component to forget a pending call." ALM chose "a literal reading" in one place and "the more sensible requirement" in another — i.e. **they resolved the same document's defects inconsistently within a single paper**, and said so.

**(e) The authors of the statement could not see its ambiguity.** This is the single most important sentence I found:
> "We found no significant ambiguities in the problem statement, **perhaps because we had first-hand knowledge of the authors' intent**." — Abadi, Lamport & Merz (Lamport co-wrote the statement)

The team containing an author rated the document unambiguous; other teams called it flawed and bizarre. **You cannot self-assess your own problem statement for ambiguity.**

**(f) They had to make explicit a rule the statement only implied.** ALM §1: "Our specification makes precise one important detail that is **not quite stated** in the informal specification" — namely that the same process cannot issue another call until the first returns.

**(g) A whole *class* of approach shared one blind spot.** From Lamport's own annotation on the problem statement (via the Microsoft Research record): Reino Kurki-Suonio noticed an error present in **all** the "purely axiomatic" specifications — those that mentioned only the interface, without introducing internal variables. Lamport had expected the high-level spec to be trivial enough to write that way. https://www.microsoft.com/en-us/research/publication/rpc-memory-specification-problem-problem-statement/

Note what (g) means for adjudication: independent divergence did not just show taste; it surfaced a **systematic defect shared by a methodological family**. That only became visible because the group was heterogeneous *and* because the errors were compared against each other in a live workshop.

### 1.7 Where the statement worked

The one place the statement produced a clean, convergent, informative result is exactly where it asked a **yes/no + justify** question with a genuinely available negative answer:

> "The solutions are **unanimous** in their answers: all regard both variants as a valid implementation. The rationale to consider the ever-failing memory an (unavoidable) implementation is that the specification cannot rule out a catastrophic failure of the memory. Several authors remark that probabilistic approaches could be employed to distinguish a memory that never works from one that fails only temporarily."

Fifteen independent groups agreeing, *plus* a spontaneous common recommendation for an extension. That is what a well-posed sub-question buys you.

### 1.8 Did the shared framing cause convergence?

Partly, and visibly. Abadi/Lamport/Merz: "We **benefited from studying the many preliminary solutions presented at a Dagstuhl workshop**… In particular, we **emulated some of these solutions** by writing our specifications as the composition of individual process specifications."

That is direct, self-reported anchoring on peer solutions — by the strongest team in the volume, after exposure. Note the sequencing that made it benign: exposure happened **after** everyone had produced an independent preliminary solution. The published volume is therefore *not* 15 independent samples; it is 15 first-round independent samples, then a shared-exposure revision round.

Also anchoring by construction: the P3 architecture figure fixed the decomposition, and the editors record that this was simply assumed away — "It was assumed that any formalism designed for the specification of reactive systems would support the implementation of a single component by three components as indicated in figure 1."

---

## 2. Steam Boiler (Dagstuhl "Methods for Semantics and Specification", June 1995 → LNCS 1165)

What I could verify:

- Problem statement: **Jean-Raymond Abrial, "Steam-boiler control specification problem", LNCS 1165, pp. 500–509 — 10 pages, placed at the *back* of the volume as an appendix.** (Springer citation metadata, doi 10.1007/BFb0027252.)
- Editors' framing/retrospective chapter: **Abrial, Börger & Langmaack, "The steam boiler case study: Competition of formal program specification and development methods", pp. 1–12.** (doi 10.1007/BFb0027228.) **Paywalled — I could not read it; abstract elided by publisher on Semantic Scholar and absent from Crossref.** Anything about its contents below is inferred from other sources and marked as such.
- The seminar was explicitly framed as a **"competition" between researchers invited as representatives of their particular methods**; **21 papers were selected from 33 candidate solutions**; the volume shipped with a **CD-ROM containing executable code and full specifications**. (Springer/Amazon volume description.)
- Crucially, the acceptance criterion had an **executable, empirical component**. From Börger's annotated ASM bibliography (arXiv cs/9811014, entry BeBoDuGR96): the ASM team's development "leads to a C++ program. **This program has been demonstrated during the Dagstuhl-Meeting on Methods for Semantics and Specification, in June 1995, to control the FZI Steam-Boiler simulator satisfactorily.**"

The contrast with RPC-Memory is the useful part:

| | RPC-Memory | Steam Boiler |
|---|---|---|
| Statement length | 4 pp. | 10 pp. |
| Position | front matter (pp. 1–4) | appendix (pp. 500–509) |
| Deliverable | specifications + proofs | specifications **+ running code** |
| External arbiter | none | **FZI simulator** — a shared executable oracle |
| Selection | 15 published | 21 published **from 33 submitted** (a real filter) |
| Framing | "never Olympic Games" | explicitly a "competition" |

The Steam Boiler bought comparability by adding an artefact nobody could argue with: the simulator either got controlled or it didn't. That is the cheapest known fix for "these answers aren't commensurable."

---

## 2b. Modern equivalents: ABZ case-study track, VerifyThis, SV-COMP

These matter because the ABZ track has run the RPC-Memory experiment roughly annually since 2014 and has converged on a house style. That style is the best available answer to "what does a good problem statement look like."

### The ABZ house format

Every ABZ case study is a **standalone natural-language document, released months ahead, with numbered requirement IDs, and revised in response to participant questions.**

| Case study | Length | Structure |
|---|---|---|
| Landing Gear (ABZ 2014, Boniol & Wiels) | **19 pp.** | prose + schematics + timing table + ~21 tagged reqs (R11…R82) | [PDF](https://www.irit.fr/ABZ-CS/html_files/files/2014/PDF/Case_Study_LandingGearSystem_2014.pdf) |
| Hemodialysis Machine (ABZ 2016, Mashkoor) | **15 pp.** | architecture prose + 2 figures + parameter tables + 36 tagged safety reqs (R-1…R-36) + explicit out-of-scope statement | [PDF](https://www.irit.fr/ABZ-CS/html_files/files/2016/PDF/Case_Study_The%20Hemodialysis%20Machine_2016.pdf) |
| Adaptive Exterior Light / Speed Control (ABZ 2020, Houdek & Raschke) | **27 pp., version 1.17** | 92 tagged reqs (ELS-1…49, SCS-1…43) + signals appendix + **organiser-supplied validation sequences** | [PDF](https://abz2020.uni-ulm.de/resources/files/casestudyABZ2020v1.17.pdf) |

**The ABZ 2020 document is the single most instructive artefact I found.** It opens with a two-page version history: **17 revisions between 16 Jul and 19 Dec 2019**, each naming the participant whose question triggered it. Sample entries: *"Rephrasing of all statements using the term 'released' due to its ambiguity"*; *"Correction of requirements ELS-8, ELS-12… Deletion of ELS-20"*; *"Adding priority between ELS-16 and ELS-17."* The organisers also *"offered two appointments where questions could be asked to clarify ambiguities, misunderstandings, or inconsistencies"* (Raschke & Méry, STTT 26:327–330, https://doi.org/10.1007/s10009-024-00753-2).

In other words: the modern answer to the RPC-Memory ambiguity problem is **a versioned statement plus a live Q&A window, with every clarification logged and pushed to all participants.** Broy & Lamport did not do this and paid for it.

### How ABZ manufactures comparability: an editorial template, not a metric

ABZ 2018 and 2020 imposed a **mandatory six-section paper structure** on all submissions:
`Introduction / Requirements and modelling strategy / Model details / Validation & verification / Other observations / **Comparison**` — where the Comparison section requires each team to *"outline the main differences between your solution and the other solutions,"* explicitly *"to make it easier for readers to compare the different modelling solutions."*

This is the RPC-Memory classification table moved forward into the submission requirements, plus a peer-differencing step. Note the organisers still never claim commensurability — the strongest verdict in the 2020 retrospective is *"we hope they help readers to get a better appreciation of the strengths and weaknesses of the various formal methods deployed."* The 2014 Landing Gear retrospective (STTT 19(2):133–140, https://doi.org/10.1007/s10009-016-0431-4) is 8 pages and **makes no comparability claim at all** — it lists three challenges, then describes each of six papers in turn.

One organiser conclusion is a deliverable type worth stealing: at ABZ 2020, *"the formalization of the requirements has already helped to identify inconsistencies and ambiguities in the textual requirements, **regardless of the specific modeling (and verification) approach used**."* Same at ABZ 2018 (ERTMS Hybrid Level 3, https://doi.org/10.1007/s10009-020-00562-3): formalisation *"resulted in improvements in the standard through the elimination of ambiguities."* **The most reliable common output of these exercises is not a winning formalism — it is a list of defects in the source document.** Budget for that as a first-class result of your exercise.

### VerifyThis: deliberate under-specification, and the honest admission that follows

Challenges are *"presented in natural language and pseudo code"*; *"no obligatory formal specification is given, neither in logics nor in a particular specification language"* (Ernst, Huisman, Mostowski & Ulbrich, TACAS 2019, https://www.sosy-lab.org/research/pub/2019-TACAS.VerifyThis-Verification_Competition_with_a_Human_Factor.pdf). Three challenges, 90 minutes each. And explicitly: *"The challenge descriptions leave a lot of details open, so that participants can come up with the formalization that best fits the capabilities of their verification tool of choice"* (Dross et al., STTT 2021, https://doi.org/10.1007/s10009-021-00619-x).

Judging is by **20–30 minute interview plus questionnaire** on correctness/completeness/elegance — i.e. a human adjudication protocol, because:
> *"Manually crafted solutions are usually not comparable by pre-definable metrics, and require careful examination."*

and the 2019 abstract names *"the difficulties of comparing the work of teams using wildly different verification approaches."*

Two directly usable empirical findings:
- **Concreteness raises completion.** The 2019 regression analysis: *"When a challenge's main algorithm is only outlined, or is given in pseudo-code but is recursive… participants found it harder to complete a correct solution."* Giving concrete, non-recursive pseudocode measurably improved outcomes. This is the strongest counterweight I found to the fixation literature — concreteness in the *problem* helps, even as concreteness in the *solution* fixates.
- **Post-hoc revisions are not comparable.** *"Comparing the post-competition work of different teams is not very meaningful."* If you run a phase 2, keep and adjudicate phase 1 separately.

### SV-COMP / RERS: the price of mechanical comparability

SV-COMP fixes everything ABZ and VerifyThis leave free — a machine-readable task-definition format, a fixed property/specification language, a published scoring table, fixed resource limits, and all 30,300 verification tasks published in advance. Objective 3 is literally *"establish standards that make it possible to compare different verification tools"* (Beyer, SV-COMP 2024, https://www.sosy-lab.org/research/pub/2024-TACAS.State_of_the_Art_in_Software_Verification_and_Witness_Validation_SV-COMP_2024.pdf). RERS goes further: benchmarks are *synthesised* from temporal constraints so ground truth is correct-by-construction and *"participants only need to submit their 'true'/'false' answers"* (https://doi.org/10.1007/978-3-030-17502-3_7).

**The lesson is a hard trade-off, and it is the central design decision of your exercise.** SV-COMP and RERS buy mechanical comparability by *eliminating the specification-writing step entirely* — the exact step that ABZ, VerifyThis and RPC-Memory treat as the object of study. You are asking nine people to invent a formalism. You therefore **cannot** have SV-COMP-style comparability, and every organiser who has tried to have both has settled for a fixed answer schema plus human adjudication. Plan for that from the start rather than discovering it at adjudication time.

---

## 3. Where the *specification itself* was the deliverable

I found no formally documented multi-team exercise where the task was "design a new formalism" and outputs were judged against stated criteria — the closest documented analogues are all "apply your existing formalism to a fixed problem." Treat that as a genuine gap in the precedent base, not as evidence of anything.

The nearest real analogues are the many-analysts studies (see §4), where the *method* was the free variable and the problem was fixed, and where the organisers explicitly measured dispersion rather than picking a winner.

---

## 4. Anchoring risk: does giving prior art narrow the space?

Yes. Four independent literatures agree, and one is almost exactly your situation.

**Most on-point: framing alone narrows, without any worked solution.** Mohanani, Turhan & Ralph, *Requirements Framing Affects Design Creativity* (2 RCTs, N=42 and N=34): identical desiderata presented as *ideas* vs *requirements* vs *prioritized requirements*. Requirements-framed participants "created designs that are, on average, **less original but more practical**"; the authors conclude "more formal, structured presentations of desiderata are less appropriate where a creative solution is desired." https://arxiv.org/abs/1902.11278

**Design fixation — examples transfer their flaws, and debiasing instructions fail.**
- Jansson & Smith 1991, *Design Studies* 12(1):3–11 — the founding result; example-exposed groups reproduced the example's features **including its flawed ones**. https://www.sciencedirect.com/science/article/abs/pii/0142694X9190003F
- Smith, Ward & Schumacher 1993, *Memory & Cognition* — the "conformity effect" **survived a 23-minute interpolated task** and **survived explicit instructions to avoid the example's features**. https://link.springer.com/article/10.3758/BF03202751
- Chrysikou & Weisberg 2005, *JEP:LMC* 31(5):1134–1148 (N=89, N=60) — even a *defixation* condition (telling participants which elements were problematic and to avoid them) did not eliminate negative transfer. https://eric.ed.gov/?id=EJ734727

**Abstraction level is the lever that actually works.**
- Atilola, Tomko & Linsey, *Design Studies* 42:110–136 — same example content shown as a **sketch** vs a **function tree**: function trees "do not cause fixation to ideas compared to a control group" and "reduce fixation when compared to sketches." https://www.sciencedirect.com/science/article/abs/pii/S0142694X15000939
- Chan et al. 2011, *J. Mech. Design* 133(8):081004 — **far-field, less-common** examples raised novelty and the *variability* of solution quality; near-domain and common examples fixated. https://asmedigitalcollection.asme.org/mechanicaldesign/article-abstract/133/8/081004/478279

**Elicitation practice: independent first pass is the standard control.** The IDEA protocol (Hemming et al. 2018, *MEE* 9:169–180) is Investigate → **private independent estimate + written rationale** → Discuss → **re-Estimate** → Aggregate, precisely to blunt anchoring and dominance effects. https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.12857 In their companion case study (PLOS ONE 13(6):e0198468) experts got deliberately minimal background and the authors *still* report "we suspect that the minimal data provided led to some anchoring" and "participants appeared to strongly anchor on their initial estimates" — while Round1→Round2 improved accuracy for 36 of 44 estimates. https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0198468

**Anchors resist discrediting.** Løhre & Jørgensen, *JSS* 116:49–56: numerical anchors have strong effects on software effort estimates; anchor *precision* did not moderate and **source credibility did not moderate** — telling estimators the anchor came from an incompetent source did not remove it. Recommendation: remove misleading information *before* estimation. https://www.sciencedirect.com/science/article/abs/pii/S0164121215000618

**How wide the space is when framing is withheld.**
- Silberzahn et al. 2018, *AMPPS* 1(3):337–356 — 29 teams / 61 analysts, **no worked example or reference analysis** given (data + codebook only); 21 unique covariate combinations; ORs 0.89–2.93 (median 1.31); 20/29 significant. After a round-robin peer-review round, **effect-size dispersion barely moved (median still 1.31)** while *subjective beliefs* converged (SD 0.84 → 0.70). Discussion converges opinions much faster than it converges methods. https://journals.sagepub.com/doi/10.1177/2515245917747646
- Landy et al. 2020, *Psych. Bulletin* 146(5):451–479 — 15 teams independently *designed materials* (closest to a design task): effects ranged d = −0.37 to +0.26, and "practically none of variability… was attributable to skill of the team." https://doi.org/10.1037/bul0000220
- Anda, Sjøberg & Mockus 2009, *IEEE TSE* 35(3):407–429 — four companies built the *same system* from the same tender specification; **price varied by a factor of six**; reproducibility of price, schedule, reliability and maintainability all "low." https://ieeexplore.ieee.org/document/4693714/
- Botvinik-Nezer et al. 2020, *Nature* 582:84–88 — 70 teams, no two identical pipelines; meta-analysis across teams recovered consensus that individual teams disagreed on. https://www.nature.com/articles/s41586-020-2314-9

Note the convergence between Landy et al.'s "practically none of variability attributable to skill of the team" and the RPC editors' "the modeling ideas of the specifiers… more important than the particular notation." Both say: **the variance you will see is not method variance.** Don't adjudicate as if it were.

---

## Recommendations for my problem statement

### A. Length and shape

**Target 4–8 pages / ~2,500–5,000 words for the statement proper**, plus separately-labelled appendices (corpus, prior art, answer schema).

The evidence band is tight and consistent: RPC-Memory 4 pp. → 15 solutions; Steam Boiler 10 pp. → 33 submissions; ABZ Hemodialysis 15 pp.; ABZ Landing Gear 19 pp.; ABZ 2020 27 pp. **Nobody writes a 60-page problem statement.** Note also where the length goes in the longer ones: ABZ's page count is overwhelmingly *tagged requirement IDs and parameter tables*, not exposition. Your corpus of 58 mechanisms is the analogue of ABZ's 92 tagged requirements and belongs in an appendix with stable IDs — it should not inflate the statement itself.

Longer statements did not produce more comparable answers. Steam Boiler's comparability came from the executable oracle; ABZ's comes from the mandatory paper template. Length bought neither.

Structure, mirroring what demonstrably worked:

1. **§0 Fixed vocabulary (≤1 page).** The RPC statement's single best move was putting the shared procedure interface *before* the tasks. Your analogue: the exact ontology of a "mechanism" — what a mechanism's inputs/outputs/state are, what "composition" means as a *phenomenon* (not as an operator), what two mechanisms being "the same" means. Fix these as **names with definitions**, not as an algebra.
2. **§1 The corpus.** Frozen, numbered, verbatim, identical for all nine. This is the equivalent of "the same dataset" in Silberzahn.
3. **§2 Five to six numbered tasks**, mixing kinds: *construct*, *prove/derive*, *justify*. Do not write one open task.
4. **§3 Acceptance criteria** (see D).
5. **Appendix A: prior art**, clearly marked as non-normative (see C).

### B. What must be FIXED for answers to be comparable

Fix exactly four things. Everything else is where you want variance.

1. **The corpus, frozen and numbered.** All 58 mechanisms, with stable IDs (`M-01`…`M-58`), given in full text identical for all nine. No "e.g." lists, no "such as". The RPC volume's biggest comparability failure — the Coverage column — happened because scope was optional.
2. **A mandatory, uniform answer schema.** This is the RPC editors' Tables 1–3, moved *forward* into the statement instead of reconstructed afterwards. Require every respondent to fill in the same fields, e.g.:
   - carriers/sorts of the algebra, and what each denotes in the corpus;
   - the operators, with arities and laws claimed;
   - which laws are asserted vs proved;
   - **a filled-in table mapping every one of M-01…M-58 to its expression in the algebra, with `NOT EXPRESSIBLE` as an explicit permitted cell value**;
   - the derived count: how many mechanisms are covered, how many require primitives outside the algebra;
   - closure/completeness claim, stated precisely, plus the argument;
   - the counterexample the respondent looked hardest for.
   Nine filled tables over the same 58 rows are comparable *even when the nine algebras are not*. That single artefact does more for your adjudication than anything else on this list.
3. **Coverage is mandatory, not optional.** Explicitly forbid the RPC concession ("free to omit aspects that could not be adequately represented"). Require: every mechanism must be either expressed, or **named as an explicit failure with a stated reason**. Non-expressibility is data; silence is not.
4. **One primitive worked case, fully specified** — see (E).

Three cheap ABZ conventions that cost you nothing and are universal in that track:

- **Stable tagged IDs on everything**, not just the corpus. ABZ tags requirements `R11…R82`, `R-1…R-36`, `ELS-1…ELS-49`. Tag your tasks and your criteria too. Nine answers that all cite `M-31` and `C-4` are far easier to diff than nine answers that paraphrase.
- **An explicit out-of-scope statement.** ABZ 2016 says flatly "single-needle therapy is out of scope." Write the DeFi equivalent — the mechanisms you are *not* asking about, the layer you are *not* modelling — or you will get nine different scopes.
- **A mandatory "Comparison" section in every answer** (ABZ 2018/2020 required exactly this: "outline the main differences between your solution and the other solutions"). You can only run this in a phase 2 with cross-exposure, but it is the cheapest way to get the nine to do your differencing work for you. Caveat: VerifyThis found post-competition revised solutions *"not very meaningful"* to compare, so keep phase-1 answers frozen and adjudicate them separately.

### C. What must be left FREE

1. **The notation.** Do not supply symbols, sort names, or a candidate signature. That is the anchor with the highest cost/benefit ratio.
2. **The number and identity of the operators.** No hints on arity, no "you will probably want a composition operator and a restriction operator."
3. **The mathematical category.** Do not say "algebra" in the sense of a specific structure; do not pre-decide monoid vs lattice vs operad vs institution vs type system. Say what the algebra must *do*, never what it must *be*.
4. **The equivalence relation on mechanisms.** This is very likely where the nine will genuinely diverge and where the divergence is *informative*. Do not fix it — but **require each respondent to state theirs explicitly in §2 of the schema**. Free variable, mandatory disclosure. (In the RPC study, the "as if" hedge left exactly this free and nobody was made to declare their reading — which is why the controversy could not be resolved cleanly.)
5. **Granularity** — whether the 58 are atoms, or themselves composites. Ask them, don't tell them.

### D. Acceptance criteria that make "no useful algebra exists" genuinely available

Rhetorical permission does not work. Anchoring survives explicit instructions to ignore the anchor (Smith/Ward/Schumacher; Chrysikou/Weisberg). You need **structural** permission — a path where the negative answer is *more* work than the positive one, not less, and where it has a defined output format.

Concretely:

1. **Make the null result a named deliverable with its own schema.** "Answer N: no composable algebra exists over this corpus at this granularity." Give it required fields: which subset of M-01…M-58 forms the obstruction; what property fails (associativity? confluence? a non-well-founded dependency? a genuine 2-categorical structure that cannot be flattened?); the minimal counterexample; and what *would* have to be true of the corpus for an algebra to exist. Nobody can produce this by giving up. It is the harder answer, and it is a *result*.
2. **Add a mandatory falsification task.** Task N: "State the strongest claim you can make about what your algebra *cannot* express, and give the witness." The RPC data point: the one sub-question that had a genuinely available negative answer (are the reliable and ever-failing memories valid implementations?) produced the volume's only unanimous, informative convergence — and spontaneous suggestions for extension. Questions that permit "no" get answered honestly.
3. **Do not state a target coverage number.** "Should cover most of the 58" is a numerical anchor, and Løhre & Jørgensen show numerical anchors survive even when the estimator is told the source is incompetent. Ask for the number as an *output*, never supply it as an input.
4. **Ask for cost.** The RPC editors' explicit regret is that they never asked about "the economy of a method… how long does it take to learn it, how long does it take to use it" — and so fifteen papers contained no data on it. If you care how *usable* the algebra is (you should — a complete algebra nobody can compute in is a null result wearing a hat), put a task in: "Express M-17 and M-42 and their composite in full, showing every step." Otherwise you will get nine claims of elegance and zero evidence.

### D2. Version the statement and open a clarification window — the strongest single fix available

This is the one thing the modern exercises do that Broy & Lamport did not, and it directly targets every failure in §1.6.

- **Put a version number and a version history on the statement.** ABZ 2020 shipped **v1.17** with 17 logged revisions over five months, each naming the participant whose question triggered it, including *"Rephrasing of all statements using the term 'released' due to its ambiguity"* and *"Deletion of ELS-20."*
- **Give the nine a question channel and a deadline**, and broadcast every answer to all nine as a numbered clarification appended to the statement. ABZ 2020 ran two scheduled Q&A appointments *"where questions could be asked to clarify ambiguities, misunderstandings, or inconsistencies."*
- Broadcasting is what preserves comparability. A private clarification to one mathematician silently forks the exercise; a published one is just a new version of the statement everyone holds.
- Expect the questions themselves to be a result. In RPC-Memory the "as if", the Write-only retry asymmetry, and the unnamed memory clerk would all have surfaced in a single Q&A round.

Practical adaptation for nine parallel model runs: you cannot hold a meeting, but you can run the statement past one or two cold readers, log their questions as v1.1…v1.n, and only then dispatch. See §G.1.

### E. Worked example: yes, but exactly one, and at the input end

The evidence pulls both ways and resolves cleanly on *what* the example shows.

- **Against:** a worked *solution* fixates hard, transfers its flaws, and resists debiasing (Jansson & Smith; Smith/Ward/Schumacher; Chrysikou/Weisberg). RPC-Memory's Figure 1 fixed the P3 decomposition so thoroughly the editors record it as simply "assumed." ALM openly "emulated" peer solutions after seeing them.
- **For:** the RPC statement's ambiguities (§1.6 a–f) were *all* in undemonstrated prose. Every trap was a sentence nobody had to cash out.
- **The resolving evidence:** Atilola et al. — the same content as a *function tree* does not fixate, while as a *sketch* it does. Chan et al. — far-field and uncommon material raises novelty; near-domain concrete material fixates.
- **And from a real competition:** VerifyThis's 2019 regression analysis found that *"when a challenge's main algorithm is only outlined, or is given in pseudo-code but is recursive… participants found it harder to complete a correct solution."* Vagueness in the *problem* measurably lowers completion. Concreteness about **what must happen** helps; concreteness about **how to do it** fixates.

So: **include one worked example of the *problem*, never of the *solution*.**

- **Do** include: two named mechanisms from the corpus, and a precise natural-language account of what happens when you compose them — including the specific thing that makes it non-trivial (an interaction, a resource conflict, an ordering constraint). Then: "Your algebra must be able to say this. Show it saying this." This is a **test case**, not a template. It disambiguates without supplying structure — which is exactly what the RPC statement failed to do.
- **Do not** include: any candidate operator, symbol, diagram of a decomposition, or "here is how one might start". Kill the Figure-1 equivalent.
- **Do** include a second, deliberately awkward pair chosen because you suspect it *breaks* naive composition. It gives the null answer somewhere to land and stops the example from advertising that everything works.
- **Do** supply **validation sequences** in the ABZ 2020 sense: a handful of composite scenarios with the intended outcome stated, against which every respondent must check their algebra and report pass/fail. This is the closest you can get to the Steam Boiler's FZI simulator without building one — a behavioural oracle expressed as data rather than as structure. It constrains answers on *outcomes* while leaving the mathematics entirely free, which is exactly the split you want.

### F. Prior art: how to supply it without collapsing the space

You said you plan to give interface automata, feature models, FCA, and financial contract algebras. The evidence says supplying them as a bundled reading list is the single riskiest thing in your plan — near-domain concrete prior art is precisely the fixation-maximising configuration, and it will show up as nine variations on "interface automata, but for DeFi."

Mitigations, in order of value:

1. **Two-phase, IDEA-style.** Phase 1: statement + corpus only, no prior art; each mathematician submits a **locked, timestamped** independent construction plus written rationale. Phase 2: release the prior art bundle (and, if you like, the anonymised phase-1 answers) and let them revise. Adjudicate both rounds. This is exactly the structure that actually generated LNCS 1169 — preliminary independent solutions at Dagstuhl, then revision with exposure — and it is what makes those 15 papers meaningful. It also gives you the Silberzahn measurement for free: how much did dispersion move? Their answer was *barely* (median OR stayed 1.31 while beliefs converged) — expect the same, and treat post-exposure agreement as weak evidence.
2. **If you must supply prior art up front, abstract it.** Not "read Alfaro & Henzinger" but "prior work in adjacent fields has found it useful to distinguish an object's *interface* from its *implementation*, and to make composition partial rather than total." Function-tree level, not sketch level (Atilola).
3. **Deliberately include one far-field item** (Chan et al.: far-field, uncommon material raises novelty *and* the variance of solution quality). Given your four are all near-domain, add something structurally distant.
4. **Mark it non-normative, in the document, in a separate appendix**, with: "None of this is required, endorsed, or expected to appear in your answer." This helps less than you'd like — do not rely on it alone.
5. **Ask each respondent to record what they read and when.** Cheap, and it turns anchoring from a confound into a measured variable at adjudication time.

### G. Specific traps you are likely to walk into

Each is a documented failure of the RPC statement, restated for your problem:

1. **You will not be able to see your own ambiguities.** ALM found "no significant ambiguities… perhaps because we had first-hand knowledge of the authors' intent," while another team called the same document flawed. **Mitigation: have one mathematician (or one throwaway model run) read the statement cold and write back only "here is what I think you are asking for and here are the decisions I had to make on your behalf" — before you send it to the nine.** This is the highest-value 30 minutes in the whole exercise.
2. **Hedged prose gets silently reinterpreted.** "as if it consisted of an array of memory cells" → most contributors read external behaviour, not mechanism. Your corpus almost certainly contains "behaves like", "effectively", "roughly", "a kind of". Every one of those is a fork in the solution space that you will never see, because nobody will flag it. Grep the statement and the corpus for them and either cash them out or force disclosure.
3. **Asymmetries in your prose become contradictions with your tasks.** RPC mentioned retries only for `Write`; the P3 implementation then retried reads; controversy, extra equivalence proofs, and one team declaring the statement flawed. If your corpus describes mechanism A with a property and mechanism B without it purely because of how the taxonomy was written up, someone will treat that as semantic.
4. **The entity you never named will be invented nine times.** The memory clerk was "only implicitly described" and every solution had to conjure it. Your analogue is whatever sits *between* mechanisms — the adapter, the wrapper, the context. If your algebra needs it, name it in §0. If you don't know whether it's needed, say so explicitly and make "does this need a mediating construct?" a numbered task.
5. **The timed / dynamic part will be the broken part.** P4/P5 (the only parts with real-time behaviour) drew "problematic" and "bizarre" from Lamport himself. Whatever the DeFi analogue is — sequencing, block-level atomicity, MEV, time-dependent state — that is where your statement will be self-inconsistent. Write it last, then rewrite it, then have someone attack it specifically.
6. **Optional scope destroys comparability.** See §B.3. Do not repeat the "free to omit" concession.
7. **Prepare to be told your statement is wrong.** Larsen/Steffen/Weise's response to a defect was to declare the problem flawed. Build a channel for that: "if you believe the corpus or this statement is internally inconsistent, that is a **reportable result** — file it under Answer N and state the minimal inconsistency." Otherwise a correct objection arrives as a non-answer you can't score.
8. **Don't adjudicate as if the divergence is about the formalism.** Both the RPC editors ("modeling ideas… more important than the particular notation") and Landy et al. ("practically none of variability… attributable to skill of the team") say the variance is not where you'd assume. With three-of-each-vendor you will be very tempted to read vendor structure into the answers. The RPC evidence says the modelling *idea* dominates, and ideas are not vendor-correlated.
9. **Adjudicate structurally, not by preference.** The RPC editors refused to rank and instead published a fixed-dimension classification. Steam Boiler got a genuine competition only because it had a simulator. **You have no simulator — so your only route to a defensible verdict is the mandatory 58-row coverage table** (§B.2), which is a machine-comparable artefact. Decide your adjudication dimensions *before* you send the statement, and make the schema produce them.
10. **Consider a cross-review round.** The single thing the RPC editors say "worked out very convincingly" was cross-refereeing between proponents of different methods; ABZ formalises it as a mandatory "Comparison" section. With nine independent answers you can run a round-robin cheaply. Two caveats: Silberzahn — it converges *opinions* much faster than it converges *methods*; VerifyThis — *"comparing the post-competition work of different teams is not very meaningful."* Use it to surface errors, not to manufacture agreement, and freeze the pre-review answers.
11. **Don't be disappointed if the best result is a defect list.** The most consistently reported outcome across ABZ rounds is that formalisation *"helped to identify inconsistencies and ambiguities in the textual requirements, regardless of the specific modeling approach used"* (2020), and at ABZ 2018 it *"resulted in improvements in the standard through the elimination of ambiguities."* Your realistic modal outcome is not a complete algebra — it is nine people independently showing you where the 58-mechanism taxonomy is inconsistent, overlapping, or wrongly granular. **Make that a scored deliverable** ("list every place the corpus is inconsistent, redundant, or wrongly individuated, with the mechanism IDs"), or you will get it as scattered asides instead of as a comparable artefact.
12. **You cannot have SV-COMP comparability while asking people to invent the formalism.** SV-COMP and RERS achieve mechanical scoring only by deleting the specification-writing step. Every exercise that kept that step — RPC-Memory, Steam Boiler, ABZ, VerifyThis — fell back on a fixed answer schema plus human adjudication (VerifyThis literally judges by a 20–30 minute interview, conceding *"manually crafted solutions are usually not comparable by pre-definable metrics"*). Decide now that you are adjudicating, not scoring, and design the schema to make adjudication tractable.

---

## What I could not verify

- **The full text of the Broy–Lamport problem statement (LNCS 1169 pp. 1–4).** Paywalled at Springer; not on Lamport's or Merz's public file trees. Everything I report about its internal structure comes from Broy/Merz/Spies's §2 review of it and from Abadi/Lamport/Merz's section-by-section parallel treatment — both primary, both by people who wrote or refereed it, but neither is the document itself. In particular I did not see its opening framing paragraph, so I cannot report how it worded the instructions to participants.
- **Abrial's 10-page Steam Boiler statement (LNCS 1165 pp. 500–509).** Paywalled. Mirrors at informatik.uni-kiel.de/~procos/dag9523/ and nlrp.ipd.kit.edu are dead (connection reset / 404); web.archive.org is blocked in this environment. I therefore cannot say what the Steam Boiler statement fixed vs left free, only that it was 10 pages and shipped alongside a simulator.
- **Abrial/Börger/Langmaack's 12-page editors' chapter, "The steam boiler case study: Competition of formal program specification and development methods" (LNCS 1165 pp. 1–12).** Paywalled; abstract explicitly elided by the publisher on Semantic Scholar and absent from Crossref. **This is the single most relevant unread document for your purposes** — it is the Steam Boiler equivalent of the RPC synopsis, and it is the one place a direct organiser retrospective on cross-method comparability under a competition format would appear. Worth an interlibrary or institutional pull before you write your statement.
- **The 33 → 21 selection criteria** for LNCS 1165 — I have the numbers from the volume description but not the rubric.
- **Whether the RPC or Steam Boiler statements were revised mid-exercise** in response to participant questions. No evidence either way; I could not reach any FAQ/clarification artefact. (ABZ 2020 demonstrably was — 17 logged revisions — but that is 25 years later.)
- **ABZ 2023 (AMAN) and ABZ 2024 (Mechanical Lung Ventilator) case-study descriptions** — HAL behind anti-bot protection, Springer chapters paywalled; no page counts or quotes for those rounds. **No organiser retrospective appears to exist for ABZ 2016** (Hemodialysis). The VerifyThis 2012 organisers' report was not retrieved.
- The session web-search budget (200 calls) was exhausted partway through; the later work used direct fetches plus the OpenAlex/Crossref/Semantic Scholar APIs. Some avenues (a direct mirror of Abrial's statement, the Kiel ProCoS archive) died on dead hosts rather than on budget, and web.archive.org is blocked in this environment.
- Exact effect sizes / cell counts for Jansson & Smith 1991 (paywalled, no abstract indexed).

---

## The single most useful thing I learned

**The authors of a problem statement cannot detect its ambiguity.** Abadi, Lamport and Merz — with Lamport a co-author of the statement — wrote "We found no significant ambiguities in the problem statement, perhaps because we had first-hand knowledge of the authors' intent," while a different team in the same volume declared the same document flawed and a third had to invent a mechanism to patch it. The statement felt clear to its author and was not.

The cheapest possible mitigation is one nobody in that 1996 collection used, but which the field has since converged on: the ABZ 2020 case study shipped as **version 1.17**, with seventeen logged revisions driven by participant questions, one of which reads *"Rephrasing of all statements using the term 'released' due to its ambiguity."* Do the same at your scale — send the statement to one cold reader first and ask them **not to solve it**, but to report back **only the decisions they had to make on your behalf**. Every item on that list is either a thing you must fix or a thing you must declare free, and either way you find out before nine people spend their effort on nine different readings of the same sentence.
