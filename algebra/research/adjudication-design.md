# Adjudicating nine independent formalisations: what the literature actually supports

Scope: research brief for a nine-mathematician council (3 Claude Opus / 3 GPT / 3 Grok) designing a composable algebra over a 58-mechanism DeFi taxonomy covering 60 protocols, followed by adjudication of nine divergent formalisms.

**Bottom line up front.** Part A (aggregating divergent judgements) has a real literature with real numbers, and it mostly tells you to *not* run an unstructured round 2 and *not* to compute continuous performance weights on nine samples. Part B (adjudicating formal artefacts) has essentially no adjudication literature at all. The two canonical precedents — the RPC-Memory and Steam Boiler LNCS collections — assembled 10–15 competing formalisations of the same problem and then **declined to rank them**. That is the honest state of the art: nobody knows how to adjudicate incomparable formalisms, and the least-bad option is to make as much of the comparison mechanical as possible, publish a Pareto frontier rather than a winner, and preserve the disagreements as executable differential tests.

Evidence strength is flagged throughout. Several key results rest on a *single* database curated by the method's own author, or on a *single* case study, or on 7–8B-parameter models whose relevance to frontier models is unestablished.

---

## Part A — aggregating divergent expert judgement

### A1. Cooke's classical model: mechanics

The classical model (Cooke, *Experts in Uncertainty*, 1991) elicits from each expert a set of quantiles (canonically 5/50/95, sometimes 5/25/50/75/95) for each variable of interest **and** for a set of *seed* / *calibration* variables whose true values are known to the analyst but not the expert. Seeds are drawn from the expert's own field and typically come from measurements, official reports not yet public, or data the analyst holds back ([Research Outreach summary](https://researchoutreach.org/articles/structured-expert-judgment-using-classical-method/); [Colson & Cooke, REEP 2018](https://strathprints.strath.ac.uk/62172/8/Colson_Cooke_REEP_2018_Expert_elicitation_using_the_classical_model_to_validate_experts_judgments.pdf)).

Two scores are computed per expert:

- **Statistical accuracy (calibration)**: treat the expert's quantiles as defining bins with theoretical probabilities (0.05, 0.45, 0.45, 0.05). Compare the empirical hit rates across the seeds against those theoretical probabilities via a relative-information / likelihood-ratio statistic; report it as a *p-value*, i.e. the probability that a perfectly calibrated expert would produce a discrepancy this large. This is a hypothesis test, and it is brutal: it falls off exponentially in the number of seeds.
- **Information**: mean relative information ("Shannon informativeness") of the expert's distribution with respect to a background measure (uniform or log-uniform over the intrinsic range of the answers, with a percentage overshoot). Narrow, confident distributions score high.

The weight is (roughly) *calibration × information*, with calibration thresholded: experts whose statistical accuracy falls below a significance level α get weight zero, and α is itself chosen to maximise the resulting "decision maker's" own combined score. Cooke's claim is that this construction is an *asymptotically strictly proper scoring rule* for the synthetic decision maker.

> Verification note: the two-score structure, seed-question selection, and performance-weighting claim are confirmed by the sources above. The finer mechanics (chi-square asymptotics, the α-optimisation step, the intrinsic-range overshoot) are from background knowledge and I did not re-verify them against a primary text in this session. The α-optimisation step is the one that matters for your design, because **it is the overfitting mechanism** — the weights are tuned on the same seeds used to evaluate them.

### A2. Does performance weighting survive scrutiny? Partly, and less impressively than advertised.

The attack came from Clemen. In *Comment on Cooke's classical method* (Reliability Engineering & System Safety 93(5), 2008, 760–765; [PDF](https://people.duke.edu/~clemen/bio/Published%20Papers/40.Comment-RESS-08.pdf)) he ran the first cross-validation on the TU Delft database: hold out seed variables, fit weights on the rest, score out-of-sample. Result: performance weighting (PW) beat equal weighting (EW) massively **in-sample**, and that advantage largely evaporated **out-of-sample**. Clemen also argued the number of seeds needed for the classical model to behave is probably **more than 10**.

The defence: [Colson & Cooke, "Cross validation for the classical model of structured expert judgment", RESS 2017](https://www.sciencedirect.com/science/article/pii/S0951832017302090) ([author PDF](https://rogermcooke.net/rogermcooke_files/Cross%20Validation%20SEJ%20RESS.pdf)) extended the database to 33 professionally contracted studies (2006–March 2015) and reports:

- PW beats EW **in-sample in 32 of 33** studies.
- PW beats EW **out-of-sample in 26 of 33** studies; under a null of no difference the probability of ≥26/33 is **0.001**.
- PW nonetheless pays a real **out-of-sample penalty**: its absolute statistical accuracy out of sample is lower than in sample, and by some accounts lower than EW's.
- Out-of-sample performance was **not** correlated with the number of experts or the number of calibration questions.

Be blunt about what this does and does not establish. The result is genuine and statistically significant, but (i) it comes from a single database assembled and curated by the method's author, (ii) the "decision maker" being scored is itself an optimised object, so the comparison is not obviously apples-to-apples, and (iii) the effect is a win-rate over studies, not a large effect size within a study. The [Bolger & Rowe critique and Cooke's reply](https://ideas.repec.org/a/wly/riskan/v35y2015i1p12-15.html) (Risk Analysis 35(1), 2015) is the visible surface of a genuine, unresolved methodological dispute — Cooke's rejoinder is essentially "you ignored the public performance data", which is an argument about evidence admissibility, not about mechanism.

Two further findings are directly relevant to you:

- **The dominant criticism is seed representativeness** — whether performance on the seeds transfers to the questions of interest. That is exactly your risk if you use "which of 12 protocols close under the laws" as a seed for "is your algebra good".
- **Peer weighting does not work.** Experts rating each other's expertise produces rankings that correlate with conventional hallmarks of expertise but *not* with measured performance ([Colson & Cooke 2018](https://strathprints.strath.ac.uk/62172/8/Colson_Cooke_REEP_2018_Expert_elicitation_using_the_classical_model_to_validate_experts_judgments.pdf)). Do not let the nine rank each other and treat that as signal.

### A3. IDEA and modified Delphi: does a second round help, or just induce conformity?

The IDEA protocol (Investigate, Discuss, Estimate, Aggregate) is a modified Delphi: private round-1 estimates, then a facilitated discussion that surfaces reasoning, resolves ambiguous question wording, and cross-examines evidence, then a **second private, anonymous estimate**, then mathematical aggregation ([Hanea et al., IJF 2017](https://www.sciencedirect.com/science/article/abs/pii/S0169207016300450); [Hemming et al., practical guide, MEE 2018](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.12857)).

Evidence for round 2: [Hemming et al., PLOS ONE 2018](https://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0198468) — 76 participants, 8 groups, 14 questions about future Great Barrier Reef events — found **average per-participant Brier scores lower (more accurate) in Round 2 than Round 1**, and that pooled group judgements almost always beat individuals.

The important caveat is the *attributed mechanism*. The IDEA authors repeatedly attribute the gain to **removing linguistic ambiguity** — participants discovering they were answering different questions — and to **sharing evidence**, not to opinion convergence per se. Round 2 estimates are kept strictly private and anonymous *precisely to suppress* group-dynamic effects. So the literature does not say "let experts see each other's answers and re-answer"; it says "let experts see each other's *evidence and interpretations*, then re-answer alone, unaware of who said what."

Evidence against, from the older Delphi literature ([Rowe & Wright 2001](https://gwern.net/doc/statistics/prediction/2001-rowe.pdf); [Rowe & Wright, IJF 1999](https://bpb-us-e1.wpmucdn.com/sites.psu.edu/dist/7/144284/files/2021/12/The_Delphi_technique_as_a_forecasting_to-2.pdf)):

- Accuracy *tends* to increase across Delphi rounds, and Delphi panels tend to beat unstructured interacting groups.
- But Gustafson et al. (1973) found Delphi groups **less accurate than their own first-round aggregate on 7 of 8 items**, and less accurate than independent statistical groups on 6 of 8.
- The mechanism when it works is asymmetric change: more accurate (more expert) panellists change their estimates *less*, so the group mean drifts toward them. This mechanism requires that expertise be correlated with stability — a property you cannot assume in your setting.
- **No evidence was found** that Delphi consensus arises from information dissemination rather than conformity pressure. Documented failure modes: consensus achieved by group pressure mediated through the statistical feedback; feedback rounds amplifying shared priors over contrarian analyses; facilitator control of feedback shaping outcomes; heterogeneous panels being the main protection against premature uniformity.

> Verification note: I could not extract the Rowe & Wright PDF body (binary PDF defeated the fetcher). The counts above come from search-surfaced summaries of that literature and should be treated as one-remove citations, not verified quotations.

**The LLM-specific evidence is considerably more hostile to round 2.** This matters more than the human literature because your panellists are language models:

- [Can LLM Agents Really Debate? A Controlled Study (arXiv 2511.07784)](https://arxiv.org/pdf/2511.07784): debate does not consistently beat independent sampling once you control for the aggregation strategy and compute budget; belief in the correct answer behaves like a **martingale** across debate rounds — no expected gain over independent voting. Debate helps only when agent diversity is high, the task has clear logical structure, and agents can actually recognise a superior argument. It hurts when agents share biases.
- [The Cost of Consensus (arXiv 2605.00914)](https://arxiv.org/html/2605.00914v1): 10-agent, 3-round peer debate vs isolated self-correction. Self-correction matched or beat debate nearly everywhere (Qwen2.5-7B: 61.0% vs 58.8% on GSM-Hard; Ministral-3-8B: 48.3% vs 20.7% — a catastrophic debate collapse) at 2.1–3.4× lower token cost. Modal sycophancy rate **>85.5%**; contextual fragility (abandoning correct reasoning on peer exposure) **up to 70%**; **oracle gaps up to 32.3 percentage points** — i.e. the team generated the correct answer and then voted it away. The authors explicitly warn that heterogeneous systems built on homogeneous sub-panels inherit these pathologies.
- Related work documents that standard LLMs default to the majority view even when the minority is better supported, and that weak models correct only ~3.6% of stance biases during debate.

> Evidence strength: these are recent preprints using 7–8B open models. External validity to frontier Opus/GPT/Grok is **unestablished** and plausibly better at the top end. But the direction is consistent across several independent groups, and the failure mode (sycophantic convergence destroying a correct minority) is precisely the one your house rule exists to prevent. Treat as a strong prior, not a proof.

### A4. Wisdom of crowds when independence is fictional

The standard decomposition (crowd error = average individual error − diversity of individual predictions) makes the failure mode obvious: correlated errors zero out the diversity term, and the crowd inherits the shared bias with spurious confidence. Judgements correlated through overlapping information produce a **miscalibrated (over-confident, under-dispersed) simple average**, and the standard advice — collect judgements without communication, and when adding a member choose the one *maximally different* from the existing crowd — follows directly ([BISE 2020 simulation study](https://link.springer.com/article/10.1007/s12599-020-00664-x); [Mannes/Soll-adjacent work on identifying expertise, Management Science](https://pubsonline.informs.org/doi/10.1287/mnsc.2014.1909)).

There *is* a literature on aggregating judgements known to be correlated. The relevant families are: Bayesian aggregation with an explicit correlation/copula structure over expert errors; **extremizing** the average (shifting the pooled probability away from 0.5) on the grounds that shared information makes the naive average systematically under-confident; and **shared-information correction** methods that ask each judge both for their own answer *and* for their prediction of what the others will say, then treat the deviation between the two as the private signal. Prelec's Bayesian Truth Serum and the "surprisingly popular" algorithm are the sharpest version: the answer that is *more popular than the crowd predicted it would be* is the one carrying private information.

> Verification note: I exhausted the session's web-search budget before verifying the Prelec / Palley-Soll / Palley-Satopää citations directly. I am confident these methods exist and are correctly characterised, but treat the specific attributions as unverified in this document. The *design idea* — ask each mathematician to predict the modal answer of the other eight, and weight deviations — is the actionable part and does not depend on getting the citation right.

Directly on your case: [Wisdom of LLM Crowds (arXiv 2607.18269)](https://arxiv.org/html/2607.18269v2) aggregated 15 LLMs on forecasting questions. Findings:

- A learned linear aggregator reached Brier ≈ 0.24 vs 0.313 for the arithmetic mean (≈23% improvement); a nonlinear MLP added nothing over logistic regression, i.e. the gain is from *weighting diverse outputs*, not from interaction effects.
- Aggregator weights correlated with **error-independence from the crowd** (Spearman +0.482) and essentially **not with individual accuracy** (−0.075). **Nine of fifteen models received negative weights** — weak models contributed contrastively by having different error structure.
- Effective ensembles paired top cloud models with several weak local models in a "U-shaped selection pattern" inconsistent with picking experts.
- Training-data contamination was decisive: the cloud/local performance gap collapsed from 35.8% to 8.9% once contaminated items were excluded; rank stability between full and clean sets was only ρ = 0.532.
- Human prediction markets still beat the LLM aggregate by 1.6–2.6×.

> Evidence strength: single preprint, forecasting task (not design), n=15 models. But it is the closest available analogue to your setup and its central message is robust to the details: **the value of a council member is their error-independence, not their individual quality**, and contamination is the dominant confound.

Separately, panel-of-judges practice: LLM judges exhibit **family-level favouritism** — Claude judges score Claude outputs higher, GPT judges score GPT outputs higher — and "three correlated judges are one judge with 3× the requests." The mitigation in the field is a multi-family jury. This constrains your *adjudication* step as much as your council composition.

---

## Part B — judging formal artefacts

### B1. The precedent collections, and what they actually did

Two LNCS volumes are the closest thing to prior art for "N teams formalise the same problem, now compare":

- **RPC-Memory** — Broy & Lamport's problem statement, solved by 15 groups in different formalisms, published as [LNCS 1169, *Formal Systems Specification: The RPC-Memory Specification Case Study*](https://link.springer.com/book/10.1007/BFb0024423) (Broy, Merz, Spies, eds., 1996), after a Dagstuhl workshop in Sept 1994 and an extended referee–author dialogue. It includes a [synopsis by Merz](https://members.loria.fr/Stephan.Merz/papers/RPCSynopsis.html) that "attempts to classify the solutions."
- **Steam Boiler** — [LNCS 1165, *Formal Methods for Industrial Applications: Specifying and Programming the Steam Boiler Control*](https://link.springer.com/book/10.1007/BFb0027227) (Abrial, Börger, Langmaack, eds., 1996), from the June 1995 Dagstuhl seminar, explicitly motivated by the belief that "thorough comparison between various design formalisms would be crucial both to industrial takeover and scientific progress."

**What they concluded: nothing.** The RPC synopsis states it "does not attempt to provide an in-depth analysis of the solutions to the case study" and the authors flag that "our subjective backgrounds and predilections have influenced the presentation." No ranking, no winner, no scoring rubric. The Steam Boiler volume likewise presents solutions side by side with descriptive commentary rather than a verdict.

This is the single most important finding in Part B and you should internalise it before designing anything. Two of the best-organised comparison exercises in the history of formal methods — with named editors, a referee process, and multi-year lead times — produced *a corpus and a taxonomy of approaches*, not an adjudication. The deliverable that survived was the **problem statement plus the collection**, which became a reusable benchmark. If you set out to crown one of nine algebras, you are attempting something the field has tried twice and abandoned.

> Verification note: I could not retrieve the full text of the Merz synopsis (the source is a gzipped PostScript file). The quoted disclaimers come from the HTML abstract page. I therefore cannot rule out that the full synopsis contains a comparison scheme richer than the abstract implies — but the abstract's explicit disclaimer of in-depth analysis is hard to reconcile with a hidden ranking.

### B2. Ontology and DSL criteria: mostly not operational

[Gruber's criteria](https://pdfs.semanticscholar.org/8889/ab615e9e8ddb89295148a3a244be6fa3b61a.pdf) (1993/95) — clarity, coherence, extendibility, minimal encoding bias, minimal ontological commitment — are design *heuristics*. Only **coherence** is decidable as stated (consistency of the defining axioms; does the theory sanction inferences consistent with the definitions). "Clarity", "minimal encoding bias" and "extendibility" have no decision procedure and, when used as a scoring rubric, degenerate into taste laundered through a checklist. Later work (Fox & Lynnes and others) piles on *more* subjective criteria — contextual relevance, maturity, fitness for use — which makes things worse, not better.

The one genuinely operational thread is **competency questions** (Grüninger & Fox lineage): a set of natural-language questions with known intended answers that an ontology-based system must answer correctly; they are simultaneously the requirements and the evaluation criteria ([overview](https://ieeexplore.ieee.org/document/6690745/); [retrofitting CQs, arXiv 2311.05662](https://arxiv.org/pdf/2311.05662)). Crucially, the CQ framing yields a **decidable preference relation**: *an ontology is preferred if it omits the fewest intended models and admits no superfluous models.* That is the operationalisation of "minimal ontological commitment", and it is a real comparison, not a checklist — it requires both a positive set (things that must be derivable) and a negative set (things that must *not* be).

Take that structure and forget the rest of the ontology-evaluation literature. Your 58 mechanisms and 60 protocol decompositions are already competency questions; you just have to also write down what each algebra must **refuse** to express.

For the qualitative residue, the [Cognitive Dimensions of Notations framework](https://www.cl.cam.ac.uk/~afb21/publications/BlackwellGreen-CDsChapter.pdf) (Green & Petre; Blackwell & Green) is the honest option — but note its own self-description: it is **not an analytic method**, its dimensions are explicitly **tradeoffs rather than metrics to be maximised**, and improving one dimension typically degrades another. It offers "yardsticks" and "straw tests" cast in operational terms ("how much work does this cost the user?"). Use it to *structure a profile*, never to compute a score. Known limitation: whoever selects the dimensions determines the outcome — the facilitator-bias problem again, in notation-design clothing.

### B3. Held-out corpus as an adjudication device: yes, with precedent, and with two traps

There *is* precedent for holding out cases when evaluating a **formalism** rather than a model. Grammar engineering does exactly this: broad-coverage precision grammars (the English Resource Grammar; the LinGO Grammar Matrix) are evaluated by **coverage and overgeneration on held-out corpora** — e.g. a grammar-inference system developed against 27 genealogically diverse languages and tested on **5 held-out languages**, reporting figures like **88.4% coverage with 1.5% overgeneration** ([Grammar Matrix / HPSG inference, NEJLT 2022](https://aclanthology.org/2022.nejlt-1.3.pdf)). The design goal is stated as "accept as many grammatical strings as possible while correctly rejecting ungrammatical strings."

That is your template, and the paired metric is the whole point:

- **Coverage on held-out protocols** measures whether the algebra generalises — whether it is a genuine abstraction or a disguised enumeration of the 50 protocols the designer saw. This is the thing you most need to detect, because a 58-mechanism taxonomy invites an algebra that is really a lookup table with an `Other` constructor.
- **Overgeneration / rejection rate on a negative corpus** measures whether the algebra says anything at all. An algebra that types every conceivable composition has 100% coverage and zero content. **Held-out coverage without a negative set is worse than useless — it actively rewards the degenerate answer.** You must construct impossible or incoherent protocol compositions (violated invariants, mechanisms in contradictory order, hazards that cannot co-occur) and score whether each algebra rejects them.

What held-out testing **misses**: expressive *adequacy* of the derivation (an algebra can express a protocol via a path that bears no relation to the human decomposition — so score the derivation against the reference decomposition, not just yes/no); compositionality (does the same mechanism denote the same thing in every protocol, or is it re-interpreted per case); ergonomics and extendibility (cost of adding the 59th mechanism); and everything about proof burden.

The **contamination trap** is severe and specific to your setting. Sixty real DeFi protocols are extensively documented on the public web and are certainly in the pretraining corpora of all nine models. Withholding ten from the *brief* does not withhold them from the *models*. The Common Task Framework literature is explicit that "a held-out test set that has been public for three years is not held out — nobody has to decide to cheat, the pipeline cheats by default" ([CACM on Goodhart and benchmarks](https://cacm.acm.org/blogcacm/goodharts-law-comes-for-every-benchmark-you-trust/); [CTF for scientific ML, arXiv 2510.23166](https://arxiv.org/pdf/2510.23166); the LLM-crowd contamination result above). Mitigation: include **synthetic held-out items** — hybrids and perturbations of real mechanisms that have never existed as deployed protocols — alongside the real ten, and compare each algebra's performance on real vs synthetic held-out items. A large gap is a contamination signature.

Second trap: the held-out set is a **one-shot instrument**. The moment you feed results back for a round 2, it is burned. Split it now: a *validation* subset you may reveal, and a *final* subset nobody sees until adjudication is closed.

### B4. Relative expressiveness as a tie-break: formalisable, and it does not collapse

This is the strongest genuinely-formal tie-break available, and the "everything is Turing-adequate" objection is exactly what the existing apparatus was built to defeat.

- [Felleisen, *On the Expressive Power of Programming Languages* (1990/1991)](https://www.cs.tufts.edu/comp/150FP/archive/matthias-felleisen/expressive-as-published.pdf) defines **macro-expressibility**: language A expresses a construct of B if there is a *local, syntax-directed (macro) translation* that eliminates the construct without changing observable behaviour, and does not restructure the surrounding program. Two languages are equally expressive when each translates into the other this way. The restriction to *local* translations is what stops the collapse — a global, whole-program encoding (which Turing-completeness always provides) does not count.
- [Gorla, *Towards a Unified Approach to Encodability and Separation Results for Process Calculi* (CONCUR 2008)](https://link.springer.com/chapter/10.1007/978-3-540-85361-9_38) gives the now-standard five criteria for a **valid encoding**: compositionality, name invariance, operational correspondence, divergence reflection, and success sensitiveness. These are validated by the fact that known good encodings satisfy them, known separation results can be *restated and proved* in terms of them, and non-trivially, some encodings fail them.

So: yes, "A can encode B but not conversely" is a formalisable tie-break, with a mature apparatus for both directions (encodability *and* separation/impossibility). But be realistic about cost. Each pairwise encodability result is a small research contribution; nine algebras give **72 ordered pairs**, and separation proofs are strictly harder than encodings. You cannot compute the full order in an adjudication window.

The practical version: (i) fix a small **reference kernel** — say 8–10 mechanisms plus the composition operators — and ask each entrant, in the brief, to supply a compositional translation of the kernel into their algebra and to state which of Gorla's criteria their translation satisfies; (ii) at adjudication, demand encodings only between the small number of algebras that survive the gates; (iii) accept a **partial order with incomparable pairs** as the output. Incomparability is information, not failure — it tells you the two algebras have genuinely different expressive commitments and both belong in the record.

---

## Recommended council design

**1. Round 2: yes, but as an evidence round, never a consensus round.**

Run it in the IDEA shape stripped of everything social. Concretely:

- Freeze and hash all nine round-1 artefacts before anything is shared. Score them independently; the round-1 scores are archived and never overwritten.
- Do **not** distribute the rival algebras. Distribute a single anonymised, deduplicated **challenge set**: every counterexample, every protocol someone found inexpressible, every law someone showed unsound, every question-wording ambiguity anyone flagged — stripped of authorship, stripped of which algebra produced it, and stripped of any tally or frequency count.
- Each mathematician revises **privately and alone**. No visibility of who raised what, no "current consensus", no vote distribution. Publishing a tally is the single change that converts round 2 from evidence-sharing into conformity pressure, and it is the mechanism the Delphi literature blames for consensus-by-group-pressure and the LLM literature measures at >85% sycophancy.
- Score round 2 against round 1 on the held-out validation subset. If aggregate held-out coverage *falls* or the nine algebras become more similar without becoming more accurate, you have induced conformity and should discard round 2 and adjudicate on round 1.

Rationale: the IDEA gain is attributed to linguistic disambiguation and evidence-sharing, both of which the challenge set delivers; the documented harms come from social feedback, which the challenge set removes. The LLM debate literature (martingale result, oracle gaps up to 32.3pp, sycophancy >85%) says unstructured mutual exposure has no expected gain and a large downside. Do the half that works.

**2. Calibration questions: yes — as gates and diagnostics, not as weights.**

Include seeds, but choose them so their truth value is **independent of the entrant's own design**. "Which of 12 protocols close under the laws" is design-relative and therefore a bad seed — each entrant would be graded against their own laws. Good seeds are corpus facts with quantified confidence:

- "Does protocol X exhibit mechanism m? (probability)" — with your ground-truth decomposition as the answer key.
- "Is hazard H realisable in protocol Y? Supply a witness trace." — decidable against your existing hazard analysis.
- "Protocols P and Q differ in exactly one mechanism. Which?" 
- "Is checking property Φ decidable for the class of protocols in the corpus? (probability, plus a one-line justification)" — your existing decidability ground truth.

Elicit these as 5/50/95 intervals or explicit probabilities so Cooke-style statistical accuracy is computable. Then:

- Use them as a **gate**: any entrant whose statistical accuracy is below a pre-registered threshold (i.e. is confidently wrong about the corpus) has their algebra flagged as built on a mis-read of the domain, and the flag travels with the artefact.
- Do **not** compute continuous performance weights. With ~9 experts and realistically 12–25 seeds you are right at the edge where Clemen says the model misbehaves, the out-of-sample penalty is documented and real, and — decisively — **you cannot multiply an algebra by 0.31**. Performance weighting presupposes a quantity you can average. You do not have one.
- Do use the calibration scores as a **tie-break** among Pareto-incomparable finalists, and report them alongside the final artefact.

**3. Scoring rubric: three tiers, mechanically computed where possible, deliberately refusing to produce a single number.**

*Tier 0 — gates (binary, disqualifying).* Internal consistency (the laws do not derive a contradiction); every one of the 58 mechanisms has a denotation; every stated law is accompanied by a proof or is marked conjectural; the algebra is well-formed under its own typing rules. An entry failing Tier 0 is recorded but not ranked.

*Tier 1 — measured by you, by script, blind to authorship.* Held-in coverage (50 protocols expressible); held-out coverage (10 real + N synthetic, reported separately — the gap is the contamination signal); **negative-corpus rejection rate**; derivation fidelity (does the algebra's decomposition of a held-out protocol match the reference decomposition, or merely produce *some* derivation); number of primitives; number of laws; number of mechanisms requiring an escape hatch or `Other` constructor; encoded size of a fixed reference protocol; whether each claimed hazard check comes with a decision procedure, a complexity bound, or an undecidability proof.

*Tier 2 — profile, never summed.* Cognitive-dimensions-style entries with worked examples: viscosity (cost of adding a 59th mechanism — make every entrant actually do this, with a specific new mechanism you hold back), minimal ontological commitment (what does the algebra force you to assert that the domain does not require), encoding bias, proof burden per new protocol.

Output: a **vector per algebra plus a Pareto frontier**, published as such. The rubric names a winner only where one algebra Pareto-dominates on Tier 1 with no Tier 0 failures. Otherwise the rubric's honest output is the frontier, and the final selection is a human decision recorded with its reasons and its dissent. Blind the artefacts (strip vendor identity) before any human or model scoring — cheap, standard programme-committee practice, and directly mitigates the documented family-favouritism effect.

**4. Composition: cross the two splits — 3 vendors × 3 schools, one per cell.**

Vendor diversity and school diversity buy different things and you can have both for free.

Vendor diversity buys **error decorrelation**, which is the property the aggregation evidence says actually matters (weights correlate with error-independence at +0.482 and with individual accuracy at −0.075; 9 of 15 models earned *negative* weights for being usefully wrong in different directions). It also buys protection at the judging step, where same-family judges are documented to inflate same-family outputs.

But vendor diversity does **not** buy diversity of mathematical commitment. Left unconstrained, all nine will likely converge on the modal training-data answer — a symmetric-monoidal-category or typed-lambda framing — because that is what the corpus contains. For a *design* task, the diversity that matters is coverage of the design space, not decorrelation of noise. Three vendors sampling the same modal design is a worse council than three schools sampled once each.

So: assign a 3×3 Latin square. Schools: **categorical** (monoidal categories / PROPs / operads, string-diagram composition), **order-theoretic / algebraic** (semirings, residuated lattices, refinement and abstract-interpretation orderings, Galois connections), **logical / type-theoretic** (linear logic, session types, separation logic, effect systems). One (vendor, school) per cell. Every entrant is told the school is a **starting lens they may abandon if they argue why** — an abandonment, with reasons, is itself a finding, and this framing limits the facilitator-bias risk of the brief becoming the answer.

Honest caveat: with n=1 per cell you lose the ability to attribute any outcome to vendor or to school. You are not running an experiment, you are harvesting designs; coverage beats identifiability here. If you later want the vendor effect, re-run one school across all three vendors.

**5. Dissent preservation: convert it into an executable artefact, or it will evaporate.**

The governing lesson from the IPCC: formal minority reports are **permitted and almost never used** ([Cambridge, *Minority Reports: Registering Dissent in Science*](https://www.cambridge.org/core/journals/philosophy-of-science/article/minority-reports-registering-dissent-in-science/3750E24DFB4D34CED8E36507767B4D27); [JCOM survey of researchers on IPCC consensus policy](https://jcom.sissa.it/article/pubid/JCOM_1803_2019_A04/)). An optional, effortful dissent channel dies. Make it mandatory, cheap, and machine-checkable:

- **Differential test suite as the primary dissent artefact.** For every pair of surviving algebras, find at least one corpus item on which they disagree — different typing, different closure verdict, different hazard decidability. Record each as a test case with both verdicts and the reasoning. This turns "minority findings must survive" from a documentation promise into a file that *fails loudly* if a future revision silently resolves the disagreement. This is the single highest-value recommendation in this document, because it is the only dissent mechanism that has teeth.
- **Mandatory irreducible-disagreement entry.** Every non-selected entrant must contribute at least one entry naming a concrete protocol or mechanism where its algebra makes a different prediction from the selected one, with a witness. No entry, no sign-off.
- **Never resolve by majority vote.** The oracle-gap finding (up to 32.3pp of correct answers generated and then voted away) is the empirical case: majority voting among correlated agents systematically destroys correct minority positions. Resolve only by counterexample, proof, or explicit recorded human judgement.
- **Seal round 1.** Hash the nine round-1 artefacts before any sharing, so a round-2 convergence cannot be retconned as an original consensus.
- **Cross-family adjudication.** Do not let a single Claude model adjudicate a pool containing three Claude entries. Make Tier 1 mechanical (scripts, not judgement) so vendor bias cannot reach it, and use a multi-family jury for the Tier 2 profile.

---

## What I could not verify

- **Fine mechanics of Cooke's scoring.** The chi-square asymptotics of the calibration statistic, the α-optimisation of the significance cutoff, and the intrinsic-range-with-overshoot background measure come from background knowledge; I confirmed the two-score structure and performance-weighting claim from sources but did not re-derive the formulae from a primary text this session. The α-optimisation point is load-bearing for my "this is where overfitting enters" claim.
- **The Colson & Cooke 2017 internals.** The ScienceDirect page returned HTTP 403 and the author-hosted PDF defeated the fetcher (binary). The headline numbers (33 studies, 32/33 in-sample, 26/33 out-of-sample, p = 0.001, no correlation with expert or seed count) come from search-surfaced summaries of that paper, not from the paper's own text. I regard them as reliable but one-remove.
- **The apparent conflict in the Cooke literature.** One source says performance weighting's out-of-sample statistical accuracy is *lower than equal weighting's*; Colson & Cooke report PW *beating* EW out-of-sample in 26/33 studies. Both can be true (degraded absolute accuracy, still a higher win rate, possibly on a combined calibration×information score rather than calibration alone), but I could not confirm the reconciliation from a primary text. If this distinction matters to you, read the 2017 paper directly.
- **Rowe & Wright 2001.** PDF extraction failed. The Gustafson 7-of-8 / 6-of-8 counts and the differential-change mechanism are from search summaries of that literature.
- **The Merz RPC synopsis full text.** Only the abstract page was retrievable; the full synopsis is a gzipped PostScript file. I cannot exclude a richer comparison scheme inside it than the abstract's explicit "does not attempt an in-depth analysis" disclaimer suggests. Worth 20 minutes with a PostScript reader if the classification dimensions would be useful to you — that is the closest thing to a rubric for exactly your problem that exists.
- **Correlated-judgement correction methods.** I ran out of web-search budget before verifying Prelec's Bayesian Truth Serum / surprisingly-popular algorithm and the Palley–Soll / Palley–Satopää shared-information corrections against primary sources. The methods exist and I have characterised them correctly to the best of my knowledge, but treat the attributions as unverified here. The design idea (elicit each member's prediction of the others' modal answer; treat the deviation as the private signal) stands on its own.
- **External validity of the LLM debate/conformity results.** Every quantitative figure I cite there (85.5% sycophancy, 70% contextual fragility, 32.3pp oracle gap, the martingale claim) comes from recent preprints using 7–8B open models. Whether frontier Opus/GPT/Grok exhibit conformity at these rates is **unknown**, and there is a plausible argument they do not. My round-2 recommendation is deliberately structured to be robust either way: the evidence-sharing half is supported by the human IDEA literature regardless, and withholding the tally costs nothing if the conformity risk turns out to be small.
- **Whether anyone has ever adjudicated N competing formalisations with a rubric.** I found no such precedent. The two organised attempts declined to rank. I searched the obvious places; absence of evidence here is moderately strong evidence of absence, but I would not stake much on exhaustiveness.
