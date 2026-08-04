# Defensible notions of completeness / expressiveness for a mechanism algebra

Research note. Target: replacing "completeness = corpus coverage (ACTUS/Marlowe style)" with something falsifiable.

Status legend: **[VERBATIM]** = quoted from the primary source I extracted; **[PARAPHRASE]** = my restatement, source read; **[UNVERIFIED]** = could not obtain primary text.

---

## 1. Felleisen, "On the Expressive Power of Programming Languages"

Source obtained and text-extracted: Felleisen, *Science of Computer Programming* 17 (1991) 35–75, PDF at
`https://www2.ccs.neu.edu/racket/pubs/scp91-felleisen.pdf` (also `https://www.cs.tufts.edu/comp/150FP/archive/matthias-felleisen/expressive-as-published.pdf`).
ESOP 1990 version: `https://link.springer.com/chapter/10.1007/3-540-52592-0_60`.
All quotations below are from the extracted text of the SCP version (OCR-clean; some math symbols lost in extraction, noted inline).

### 1.1 The logical ancestor (Kleene / definitional extension) **[VERBATIM]**

> "A conservative extension L of a formal system L0 is a formal system whose expressions are a superset of the expressions over L0, generated from a richer set of operators, and whose formulae and theorems restricted to the expressions of L0 are the formulae and theorems of L0:
> Fm(L) ∩ Exp(L0) = Fm(L0); Thm(L) ∩ Exp(L0) = Thm(L0)."

> "A conservative extension L is a **definitional extension** of L0 if there is a mapping φ : Exp(L) → Exp(L0) that satisfies the following conditions:
> **F1** φ(f) ∈ Fm(L0) for each f ∈ Fm(L);
> **F2** φ(f) = f for all f ∈ Fm(L0);
> **F3** φ is homomorphic in all logical operators;
> **F4** L ⊢ t if and only if L0 ⊢ φ(t); and
> **F5** L ⊢ t ↔ φ(t).
> Kleene referred to those symbols that generate the additional expressions of the extended formal system as **eliminable**."

Note F5 — provable equivalence of a term and its translation — is exactly the condition that *has no programming-language counterpart* (see below), and it is exactly the condition you would most want in a DeFi setting.

### 1.2 Programming language **[VERBATIM, Definition 3.1]**

> "A programming language L consists of
> - a set of L-phrases, which is a set of freely generated abstract syntax trees (or terms), based on a possibly infinite number of function symbols F, F1, . . . with arities a, a1, . . .;
> - a set of L-programs, which is a non-empty, recursive subset of the set of phrases; and
> - a semantics, eval_L, which is a recursively enumerable predicate on the set of L-programs. If eval_L holds for a program P, the program terminates."

Two things matter here and are usually forgotten when people cite this paper:

1. The semantics is *only* a termination predicate. Felleisen deliberately observes almost nothing. **[VERBATIM]** "To avoid restrictive assumptions about the set of programming languages, the definition only requires that the semantics observe the termination behavior of programs." That minimal observable is what makes the whole apparatus work: it is the coarsest possible non-trivial observation, so equivalences are as *large* as possible, so distinguishing two phrases is as *hard* as possible, so a non-expressibility proof is as *strong* as possible.
2. The phrase set is a **free term algebra** over the constructors. **[VERBATIM]** "In the terminology of universal algebra, the set of expressions is the universe of a free term algebra." Your 58-mechanism vocabulary would have to be the signature of exactly such a free algebra.

### 1.3 Conservative restriction / extension for languages **[VERBATIM, Definition 3.2 in effect]**

L0 is a conservative restriction of L when:
> "- the constructors of L0 are a subset of the constructors of L with the difference being {F1, . . . , Fn, . . .}, which are not constructors of L0;
> - the set of L0-phrases is the full subset of L-phrases that do not contain any constructs in {F1, . . . , Fn, . . .};
> - the set of L0-programs is the full subset of L-programs that do not contain any constructs in {F1, . . . , Fn, . . .}; and
> - the semantics of L0, eval_L0, is a restriction of L's semantics, i.e., for all L0-programs P, eval_L0(P) holds if and only if eval_L(P) holds."

Notation: `L0 = L \ {F1,...}` and `L = L0 + {F1,...}`.

### 1.4 Eliminability / expressibility **[VERBATIM, Definition 3.3]**

> "Let L be a programming language and let {F1, . . . , Fn, . . .} be a subset of its constructors such that L0 = L \ {F1, . . . , Fn, . . .} is a conservative restriction. The programming facilities F1, . . . , Fn, . . . are **eliminable** if there is a recursive mapping φ from L-phrases to L0-phrases that satisfies the following conditions:
> **E1** φ(e) is an L0-program for all L-programs e;
> **E2** φ(F(e1, . . . , ea)) = F(φ(e1), . . . , φ(ea)) for all facilities F of L0, i.e., φ is homomorphic in all constructs of L0; and
> **E3** eval_L(e) holds if and only if eval_L0(φ(e)) holds for all L-programs e.
> We also say that **L0 can express the facilities F1, . . . , Fn, . . . with respect to L**."

Felleisen's own gloss: **[VERBATIM]** "Condition E2 in this definition implies that the mapping φ is the identity on the language L0." And: **[VERBATIM]** "the last condition of the logical notion of eliminability, F5, has no counterpart in a programming language context because of the lack of a ubiquitous programming construct." (i.e. there is no `↔` in a programming language.)

**Weak expressibility** replaces E3's "iff" with a one-way implication (Remark 2), matching Kleene's F4′.

### 1.5 Where observational equivalence enters **[VERBATIM, Definitions 3.4, 3.5]**

Felleisen states plainly that the definition means translation into *observationally indistinguishable* phrases:

> "An alternative understanding of the above definition is that the translation maps phrases constructed from eliminated symbols to observationally indistinguishable phrases in the smaller language. In other words, replacing the original phrase with its translation does not affect the termination behavior of the surrounding programs."

*Contexts* (Def. 3.4): "An n-ary context over L, C(□1,...,□n), is a freely generated tree based on L's constructors and the additional, 0-ary constructors □1,...,□n, called meta-variables." "An L-program context for a phrase e is a unary context, C(□), such that C(e) is a program."

*Operational equivalence* (Def. 3.5) **[VERBATIM]**:
> "Let L be a programming language and let eval_L be its operational semantics. The L-phrases e1 and e2 are **operationally equivalent**, e1 ≃_L e2, if there are contexts that are program contexts for both e1 and e2, and if for all such contexts, C(□), eval_L(C(e1)) holds if and only if eval_L(C(e2)) holds."

So: **the observational equivalence is not an extra ingredient — it is *derived* from `eval` plus the context set.** Fix the observable and the syntax, and the equivalence is determined. This is the single most important structural fact for your purposes (see §1.8).

### 1.6 Sufficient condition for expressibility **[VERBATIM, Theorem 3.6]**

> "Let L = L0 + {F1, . . . , Fn, . . .} be a conservative extension of L0. If φ : L → L0 is homomorphic in all facilities of L0 and preserves program-ness, and if F_i(e1, . . . , e_ai) ≃_L φ(F_i(e1, . . . , e_ai)) for all F_i and all L-expressions e1, . . . , e_ai, then L0 can express the facilities F1, . . . , Fn, . . ."

### 1.7 Macro expressibility and the killer non-expressibility theorem

**[VERBATIM, Definition 3.11]**
> "The programming facilities F1, . . . , Fn, . . . are **macro eliminable** if they are eliminable and if the eliminating mapping φ from L to L0 satisfies the following, additional condition:
> **E4** For each a-ary construct F ∈ {F1, . . . , Fn, . . .} there exists an a-ary syntactic abstraction, A, over L0 such that φ(F(e1, . . . , ea)) = A(φ(e1), . . . , φ(ea))."

Felleisen's own footnote is directly relevant to you: **[VERBATIM]** "In Lisp-like languages, syntactic abstractions are realized as macros; logical frameworks know them as notational abbreviations. **The terminology of equational algebraic specifications refers to syntactic abstractions as derived operators.**" — i.e. macro-expressibility *is* "definable as a derived operator" in algebraic-specification language. That is the bridge you want.

**[VERBATIM, Corollary 3.13]** (the practical positive test — no reference to the translation map at all)
> "Let L = L0 + {F1, . . . , Fn, . . .} be a conservative extension of L0. If there is a syntactic abstraction A_i for each F_i in F1, . . . , Fn, . . . so that F_i(e1, . . . , e_ai) ≃_L A_i(e1, . . . , e_ai) for all L-expressions e1, . . . , e_ai, then L0 can macro-express the facilities F1, . . . , Fn, . . ."

**[VERBATIM, Theorem 3.14]** (the negative test — this is *the* theorem)
> "Let L1 = L0 + {F1, . . . , Fn, . . .} be a conservative extension of L0. Let ≃0 and ≃1 be the operational equivalence relations of L0 and L1, respectively.
> (i) If the operational equivalence relation of L1 restricted to L0 expressions is not equal to the operational equivalence relation of L0, i.e., ≃0 ≠ (≃1 |L0), then L0 **cannot** macro-express the facilities F1, . . . , Fn, . . .
> (ii) The converse of (i) does not hold. That is, there are cases where L0 cannot express some facilities F1, . . . , Fn, . . ., even though the operational equivalence relation of L1 restricted to L0 is identical to the operational equivalence relation of L0."

Slogan (Felleisen's own): **[VERBATIM]** "new programming constructs add to the expressive power of a language if their addition affects existing operational equivalences."

Also **[VERBATIM, Corollary 3.10]**: "If for some F_i(e1,...,e_ai) there is a program context C over L0 but there is no e in L0 such that F_i(e1,...,e_ai) ≃_L e, then L0 cannot express the facilities F1, . . . , Fn, . . ."

### 1.8 Two caveats that you must put in the brief

**(a) Everything is relative to a fixed language universe L.** **[VERBATIM, Definition 3.17]** "Let L0 and L1 be conservative language restrictions of L. L1 is at least as (macro-) expressive as L0 with respect to L if L1 contains or can (macro-) express a set of L-constructs whenever L0 contains or can (macro-) express the additional facilities." There is no absolute expressiveness. A mathematician who proposes a new generator must be made to name the universe L.

**(b) The order is NOT stable under enlarging the universe.** **[VERBATIM, Theorem 3.19]** "Expressiveness relationships are not invariant under uniform extensions of the languages." (Proof: λv and λn are incomparable; adding `begin` uniformly makes λn+begin strictly more expressive than λv+begin.) This is a genuine hazard for you: a mechanism that is *not* expressible in your 58 today can become expressible tomorrow when someone adds an unrelated 59th generator, and vice versa. Any expressiveness claim you make is a claim about a *frozen* signature.

### 1.9 Does it transfer to a taxonomy-to-algebra setting? — skeptical verdict

**It transfers only if you can supply three things, and two of them you do not currently have.**

What transfers cleanly:
- The *free term algebra over a signature* framing. Your 58 mechanisms as constructors with arities, protocols as terms: that is Definition 3.1's phrase set, exactly.
- **Conservative restriction/extension** as the hygiene condition on adding a 59th generator. This is the cheapest, most defensible thing in the whole note and you should take it regardless (§2).
- **Macro-expressibility = derived operator**. "Mechanism M is macro-expressible over the other 57" is a precise redundancy claim, and Corollary 3.13 gives you the positive proof obligation in one line: exhibit a term (syntactic abstraction) A over the other generators and prove `M(e1..ea) ≃ A(e1..ea)`.
- **Theorem 3.14 as the independence test.** To show a generator is *not* redundant, exhibit two protocol terms in the 57-subset that are observationally equivalent without M and distinguishable with M. This is a genuinely falsifiable obligation and it is the strongest single import.

What does NOT transfer without work you have not done:
1. **You have no `eval`.** Felleisen's whole apparatus is downstream of a semantics — a recursively enumerable predicate on programs. You have a *taxonomy*, i.e. a signature with no interpretation. Until you fix a semantics for protocol terms, "≃" is undefined and every theorem above is vacuous. This is not a technicality; it is the entire content of the method. **Corpus coverage is exactly what people reach for when they have a signature and no semantics.**
2. **You have no notion of "program".** Felleisen needs a recursive subset of phrases that are complete/runnable. What is a *closed* protocol term? A deployed protocol with all parameters instantiated and all external dependencies (oracle, collateral asset, governance) bound? You need to say.
3. **You have no contexts.** The power of the method is that a phrase is judged by *all* the ways it can be embedded. In DeFi the analogue of a context is a *composition environment*: the rest of the on-chain system into which a mechanism is plugged — other protocols, arbitrageurs, flash-loan availability, the mempool. "Composable" in your title is doing exactly this work, and it is a genuine fit: DeFi's characteristic pathology (a mechanism that is safe standalone and unsafe when composed) is literally "these two mechanisms are equivalent in the empty context and distinguishable in context C".

**What "observation" would have to be for DeFi.** Candidates, from coarsest to finest:

| Observable | Equivalence induced | Assessment |
|---|---|---|
| Termination / liveness of the composed system | Very coarse | Nearly useless — almost nothing in DeFi fails to "terminate" |
| **Terminal net cash-flow vector per agent** (final token balances of each participating address, over all price paths / adversary schedules) | Coarse but non-trivial | **Best candidate.** This is the ACTUS/Peyton-Jones observable (a contract *is* its cash flows) and it is the one the finance literature already agrees on |
| Full trace of cash flows with timestamps | Finer | Distinguishes too much — two economically identical AMMs with different fee-accrual timing become inequivalent. Probably too fine |
| State-transition bisimulation on the protocol LTS | Finest | Distinguishes everything; equivalence collapses to near-identity; expressiveness results become trivial and uninformative |
| Value/pricing functional (risk-neutral value at time 0) | Coarse, quantitative | Attractive (matches Peyton Jones & Eber's denotational semantics) but requires fixing a measure/model, which imports enormous economic commitment |

**Recommendation:** the observable should be *net cash-flow vector per agent, quantified over an adversarial environment* (price paths and transaction orderings). Coarse enough that equivalences are large; fine enough that MEV, oracle manipulation and liquidation cascades show up as distinguishing contexts. Note that with this observable, "atomicity" and "ordering" mechanisms are automatically *not* macro-expressible from the others — which is the right answer and a good sanity check on the choice.

**Honest counter-argument you should include.** Felleisen's method is a *comparison* method, not a *completeness* method. It tells you whether L0 can express L1's extra features. It never tells you that L1 is complete for anything. So it cannot, by itself, replace corpus coverage as a definition of completeness. What it *can* replace is the far weaker and far more common claim "our vocabulary is minimal/orthogonal", turning that into a theorem. **Use Felleisen for minimality and independence; you still need §5 for completeness.**

---

## 2. Conservative extension as hygiene for adding generators

The logic definition is in §1.1 above (Fm and Thm restricted to the old language are unchanged). Two operational restatements you can hand a mathematician:

- **Logic form:** T′ ⊇ T is conservative iff for every sentence φ in the language of T, T′ ⊢ φ ⟹ T ⊢ φ. (Nothing new is provable about the old vocabulary.)
- **Algebraic-specification form ("no junk, no confusion"):** an extension SP′ of SP is *protecting* / persistent iff the reduct of every SP′-model to the SP signature is an SP-model and the unit map is an isomorphism — concretely, adding new operations must add **no new elements** to the carriers of the old sorts (*no junk*) and must **not identify** any previously distinct old terms (*no confusion*). This is the initial-algebra-semantics formulation (ADJ / Goguen–Thatcher–Wagner; realised as Maude's `protecting` vs `extending` vs `including` imports and CASL's conservative/definitional extension notions).

**Why this is the right hygiene condition for you.** A mathematician who wants a 59th generator is proposing an extension of your signature. Demand:
1. **No junk:** the new generator does not create protocol terms that are *in the old sorts* but were not previously denotable — otherwise it is not an addition, it is a change of scope.
2. **No confusion:** no two protocol terms that your algebra previously distinguished become equal.
3. **Not macro-expressible:** by Corollary 3.13's contrapositive plus Theorem 3.14 — exhibit the distinguishing context. Otherwise the "new" generator is a derived operator and belongs in a library, not the vocabulary.

Conditions 1–2 are conservativity; condition 3 is non-redundancy. Together they are a complete, checkable admission test for new vocabulary, and neither requires any completeness theorem.

**Caveat to state:** conservativity is undecidable in general for first-order theories; for equational specifications it is typically established by *exhibiting a model expansion* (show every old model extends to a new one) or by a confluence/critical-pair argument on the rewrite system. Either is a real proof obligation, not a checkbox.

### 2.1 The precise algebraic statement — use this wording

Maude's manual gives the cleanest mathematical statement of "no junk, no confusion" I found, and it is the one to hand the mathematicians. **[VERBATIM, Maude 3.2.1 manual §6.1, https://maude.lcc.uma.es/maude321-manual-html/maude-manualch6.html]**

> "…for each sort s′ in Σ′ there is a well-defined function mapping the equivalence class [t]_{E′∪A′} of a ground term t to the equivalence class [t]_{E∪A}. By definition, the submodule inclusion M′ ⊆ M is protecting if and only if for each sort s′ in Σ′ the above function is **bijective**. This captures mathematically the 'no junk' (**surjectivity**) and 'no confusion' (**injectivity**) ideas."

So, precisely:
- **no junk** = *surjectivity*: every element of an old sort in the extended initial algebra is still denoted by an *old* ground term;
- **no confusion** = *injectivity*: two old ground terms are equal in the extension only if they were already provably equal.

The weaker "extending" mode (junk allowed, confusion forbidden) is what Maude itself calls the conservative-extension condition **[VERBATIM]**: "the extending (Σ′,E′∪A′) ⊆ (Σ,E∪A) requirement is a form of **conservative extension** requirement, in the sense that it implies that for any Σ′ ground terms t and t′ that have a sort in (Σ′,E′∪A′), E′∪A′ proves t = t′ if and only if E∪A proves t = t′."

Also note the honest warning, which applies verbatim to your situation **[VERBATIM]**: "the Maude system does not check that these constraints are satisfied, that is, the different modes of importation can be understood as **promises by the user**, which would need to be proved by him/herself." If you write conservativity into the brief, you are writing a proof obligation, and you should say so.

Origin: initial-algebra semantics from the ADJ group (Goguen, Thatcher, Wagner, Wright, *Initial Algebra Semantics and Continuous Algebras*, JACM 24(1):68–95, 1977); the "no junk, no confusion" slogan is standardly credited to Burstall & Goguen (early 1980s) — **[UNVERIFIED]** exact 1982 paper and wording not confirmed.

### 2.2 The CASL / institution version

**[VERBATIM, Mossakowski, Haxthausen, Sannella & Tarlecki, *CASL — the Common Algebraic Specification Language*, https://homepages.inf.ed.ac.uk/dts/pub/cai.pdf]**

> "A specification morphism σ: SP1 → SP2 is conservative iff each SP1-model is the σ-reduct of some SP2-model."

This is the *model-theoretic* form, and it is the one you should prefer, because it is language-independent. CASL's own proof calculus treats conservativity as an **external oracle** — it is a side condition, not something the calculus derives. Also worth quoting to the mathematicians as a general caution about completeness in this setting **[VERBATIM, same source]**: "**Theorem 2.** If sort generation constraints are used, the CASL logic is not complete. Moreover, there cannot be a recursively axiomatized sound and complete entailment system for many-sorted CASL basic specifications."

### 2.3 The logic form and the eliminability upgrade

Standard proof-theoretic definition (Wikipedia, matching Shoenfield/Mendelson) **[VERBATIM]**: "A theory T2 is a (proof theoretic) conservative extension of a theory T1 if every theorem of T1 is a theorem of T2, and any theorem of T2 in the language of T1 is already a theorem of T1."

**Extension by definitions** is the stronger, better thing to demand where possible **[VERBATIM, https://en.wikipedia.org/wiki/Extension_by_definitions]**: "Then T′ is a conservative extension of T, and for any formula ψ of T′ we can form a formula ψ* of T, called a *translation* of ψ into T, such that ψ ↔ ψ* is provable in T′." That second clause is Kleene's F5 — the condition Felleisen had to drop for programming languages. If your algebra has an equality/equivalence in the object language, you can demand it back, and you should: it converts "conservative" into "definitionally eliminable".

### 2.4 How to check conservativity, concretely

1. **Model expansion** (model-theoretic; matches CASL's definition): take an arbitrary model of the old theory and construct an expansion satisfying the new axioms.
2. **Rewriting / normal-form argument** (equational): prove the new rules terminating and ground-confluent, then show the canonical form of every old ground term is unchanged. Sufficient-completeness checking is the "no junk" half. Maude's manual points at exactly this toolchain (inductive theorem prover + Church–Rosser checker + sufficient-completeness checker) and notes it "requires inductive theorem proving".
3. **Refutation is much cheaper than proof.** Hunt for the counterexample first: one old-language sentence provable in T′ but not T, or one old model with no expansion.

Undecidable in general — state it that way and do not attach a complexity class.

---

## 3. Ontology evaluation: Gruber and the encoding-bias problem

**Headline:** exactly one thing in this literature is falsifiable in the artifact itself (OntoClean's subsumption constraints — and only *conditionally*, on a human labelling); one is falsifiable relative to a chosen test set (formal competency questions); one is falsifiable relative to an external task (task-based evaluation, with a documented sensitivity defect). Everything else is advisory prose or objectively-computable counts wrapped in an unvalidated normative layer. **On your key question: no, there is no published method that measures encoding/source bias in a vocabulary.**

### 3.1 Gruber's five criteria — and why "encoding bias" is NOT your bias

Source: https://tomgruber.org/writing/onto-design.pdf (KSL-93-04; IJHCS 43(5–6):907–928, 1995). **[VERBATIM]** for all five:

**Clarity** — "An ontology should effectively communicate the intended meaning of defined terms. Definitions should be objective. While the motivation for defining a concept might arise from social situations or computational requirements, the definition should be independent of social or computational context. Formalism is a means to this end. When a definition can be stated in logical axioms, it should be. Where possible, a complete definition (a predicate defined by necessary and sufficient conditions) is preferred over a partial definition (defined by only necessary or sufficient conditions). All definitions should be documented with natural language."

**Coherence** — "An ontology should be coherent: that is, it should sanction inferences that are consistent with the definitions. At the least, the defining axioms should be logically consistent. Coherence should also apply to the concepts that are defined informally… If a sentence that can be inferred from the axioms contradicts a definition or example given informally, then the ontology is incoherent."

**Extendibility** — "An ontology should be designed to anticipate the uses of the shared vocabulary… the representation should be crafted so that one can extend and specialize the ontology **monotonically**. In other words, one should be able to define new terms for special uses based on the existing vocabulary, in a way that does not require the revision of the existing definitions." *(Note: this is Gruber's informal version of conservative extension — §2 is the rigorous form of the same idea, and you should cite §2, not this.)*

**Minimal encoding bias** — "The conceptualization should be specified at the knowledge level without depending on a particular symbol-level encoding. **An encoding bias results when a representation choices are made purely for the convenience of notation or implementation.** Encoding bias should be minimized, because knowledge-sharing agents may be implemented in different representation systems and styles of representation." *(typo "a representation choices" is Gruber's)*

**Minimal ontological commitment** — "An ontology should require the minimal ontological commitment sufficient to support the intended knowledge sharing activities… ontological commitment can be minimized by specifying the weakest theory (allowing the most models) and defining only those terms that are essential to the communication of knowledge consistent with that theory."

**Two findings that matter for your draft:**

1. **Gruber's "encoding bias" is not your bias.** His is *symbol-level leakage*: modelling choices made for notational/implementation convenience. Yours is *sampling* bias: granularity tracking how many Ethereum codebases exist. Gruber never addresses sampling bias. **Do not cite Gruber's criterion as covering your problem — a reviewer who reads the original will catch it.** (You could argue the AMM over-granularity *is* implementation-convenience bias, since the five variants are distinguished by implementation. That argument is available and defensible; make it explicitly rather than by citation.)
2. **The definition is unmeasurable by construction.** It is defined by the *designer's motive* — bias exists when choices "are made purely for the convenience of notation or implementation." Two structurally identical ontologies differ in bias according to why the modeller did it. There is no observable that separates them. Of the five criteria, only *coherence* is even partly mechanical. Gruber himself frames the whole set as purposive: design criteria should be "founded on the purpose of the resulting artifact, rather than based on a priori notions of naturalness or Truth."

### 3.2 OntoClean — the only genuinely formal method, and it is a consistency checker

Sources: Guarino & Welty, "An Overview of OntoClean", *Handbook on Ontologies* ch. 8 — https://www.loa.istc.cnr.it/old/Papers/GuarinoWeltyOntoCleanv3.pdf; WordNet analysis https://arxiv.org/abs/cs/0109013.

**Meta-properties [VERBATIM]:** *Rigidity* — "A property is rigid if it is essential to all its possible instances; an instance of a rigid property cannot stop being an instance of that property in a different world"; anti-rigid = "properties that are not essential to all their instances". *Identity* — "+I" for properties carrying an identity criterion, "+O" for those that "supply (rather just carrying) their 'own' identity criteria". *Unity* — "A property P is said to carry unity (+U) if there is a common unifying relation R such that all instances of P are essential wholes under R." *Dependence* — "+D iff, for all its instances, there exists something they are constantly dependent on"; the chapter concedes dependence "is rather difficult to formalize".

**The constraints [VERBATIM, ch. 8]:** "Given two properties, p and q, when q subsumes p the following constraints hold: 1. If q is anti-rigid, then p must be anti-rigid. 2. If q carries an identity criterion, then p must carry the same criterion. 3. If q carries a unity criterion, then p must carry the same criterion. 4. If q has anti-unity, then p must also have anti-unity." Implementations add "Dependent class cannot subsume non-dependent class" and "A role cannot subsume a type."

**Verdict: real and falsifiable, but conditionally.** Violations are mechanically derivable by forward chaining and a violation is an objective failure — the canonical worked example being WordNet subsuming `Person` (rigid type) under `Causal_Agent` (anti-rigid role). But the authors are explicit about the escape hatch **[VERBATIM]**: "the point of OntoClean is not to help people decide about the ontological nature of a certain property, but rather to help them explore the logical consequences of making certain choices," and the meta-property assignments "are not meant to be definitive at all." A modeller who dislikes a violation can relabel rather than restructure. Labelling is manual and expert-dependent (a 2024 study, arXiv:2403.15864, notes "lack of consensus among ontologists" and uses GPT-4 to reach ~4% error).

**Worth running on your 58 anyway** — it will catch genuine category errors (e.g. treating a *role* a token plays inside a mechanism as a *type* of mechanism), which is a distinct failure from the bias problem and cheap to check.

### 3.3 The quantitative metrics: real tooling, unearned scores

- **OQuaRE** (Duque-Ramos, Fernández-Breis, Stevens, Aussenac-Gilles, JRPIT 43(2), 2011; ESWA 2013; code at https://github.com/tecnomod-um/oquare). Real, maintained, used in published studies. Metrics are graph counts with OO-metric *names* but not OO-metric *definitions* — e.g. "LCOMOnto: Length of the path from the leaf class to Thing, divided by the total number of paths", "DITOnto: Length of the largest path from Thing to a leaf class". **The 1–5 quality mapping ("1 – Not Acceptable … 5 – Exceeds Requirements") is hand-assigned**, and the authors state the thresholds are "scaled based on the **best practices for object oriented programming**". They concede "An open question is whether the ranges can be universally set". Their alternative — k-means (k=5) over one ontology's own version history — makes scores corpus-relative and cross-ontology meaningless. Independent critique exists: https://link.springer.com/chapter/10.1007/978-3-031-39386-0_13. **Verdict: reproducible ritual, not measurement. No criterion validity anywhere.**
- **OntoQA** (Tartir et al. 2005). `RR = |P|/(|SC|+|P|)`, `AR = |AT|/|C|`, `IR = |SC|/|C|`. **The most honest of the family** — descriptive statistics with no thresholds and no targets, correctly labelled. High inheritance richness means a shallow taxonomy; neither direction is "better" absent a task. The pathology is downstream citation treating "richness" as good.
- **Gangemi, Catenacci, Ciaramita, Lehmann, oQual/O²** (ESWC 2006, https://ceur-ws.org/Vol-166/9.pdf) — **the most honest source in the field.** Three dimensions **[VERBATIM]**: "structural measures, that are typical of ontologies represented as graphs; functional measures, that are related to the intended use of an ontology…; usability-related measures". They state the limit outright **[VERBATIM]**: "This seems to imply that no automatized method will ever suffice to the task and that intellectual judgement will always be needed," and on aggregation, "different trade-offs denote good/bad quality according to which criterion is preferred." **They explicitly refuse to define a task-free aggregate score.** Cite this one if you want a defensible statement that structural metrics are normatively empty.
- **ONTOMETRIC** (Lozano-Tello & Gómez-Pérez, JDM 2004, https://oa.upm.es/6467/1/ONTOMETRIC_A_Method.pdf). 160 characteristics over five dimensions, combined by **AHP with user-supplied pairwise weights** and fuzzy linguistic values (very_low…very_high), aggregated as Σwᵢvᵢ. The paper admits its worked example's numbers "have been assigned for a hypothetical evaluation project"; validation was face validity by ten developers; users reported assessment "is quite subjective". **Verdict: not a measurement instrument. Change the evaluator, the output changes, the ontology unchanged — the textbook signature of non-measurement.**
- Field-level critique that is safe to cite: ACM Computing Surveys, *Evaluating Domain Ontologies: Clarification, Classification, and Challenges* (https://dl.acm.org/doi/fullHtml/10.1145/3329124) — "no consensus on which attributes of an ontology correlate to a high level of quality." And *Briefings in Bioinformatics* 21(2):473, which clustered 19 structural metrics over 197 ontologies, found 63% stable groupings, and still framed it as "still a challenge to provide insights about whether the evaluation and classification of ontologies using structural quality metrics is a valid measuring instrument" — **reliability demonstrated without validity.**

### 3.4 KEY QUESTION: can encoding/source bias be measured? — No, and here is exactly why

Everything falls into three buckets; only the third could in principle work.

**(i) Artifact-internal metrics cannot detect it by construction.** An ontology built from a skewed corpus and one built from a balanced corpus can have identical internal entropy. This covers all entropy-based ontology metrics (Calmet & Daemi; EAPB; path-based entropy), OntoQA richness, OQuaRE's structural set, and Keet's granularity theory (not even a number). Two sharp findings:
- **Information content went the wrong way.** Seco, Veale & Hayes (2004) introduced *intrinsic* IC computed from hyponym counts in the hierarchy alone, discarding corpus grounding, and reported *better* human correlation than Resnik's corpus-based IC. Dominant practice now reads probability off the taxonomy's own branching — i.e. it **assumes the granularity is correct**. Using intrinsic IC to assess granularity is circular.
- The one paper that computes a granularity number — *Class Granularity: How richly does your knowledge graph represent the real world?* (https://arxiv.org/abs/2411.06385) — is internal-only, and **its own limitations section admits it cannot distinguish poor schema design from appropriate simplicity for the domain.** That is an explicit admission it does not do what you need.

**(ii) MDL is principled and used for the wrong thing.** MDL appears as a learning/summarization objective scored against the data the model came from: Li & Abe's tree-cut models (https://aclanthology.org/J98-2002/) — the closest thing in print to "MDL picks the right granularity level"; KGist (https://arxiv.org/abs/2003.10412), "a summary of inductive rules that best compress the KG according to the Minimum Description Length principle". **Nobody uses description length as a standalone ontology quality criterion**, and the naive form is circular for your question: `L(taxonomy) + L(data|taxonomy)` scored on the corpus the taxonomy came from *rewards* source bias, because fine granularity where the corpus is dense genuinely compresses that corpus better.

**(iii) Artifact-vs-external-reference — the only class that works, and there is essentially one good example, from outside ontology engineering.** *Gene annotation bias impedes biomedical research* (Sci Rep 2018, https://www.nature.com/articles/s41598-018-19333-x) applies eight inequality metrics (Gini, Ricci-Schutz, Atkinson, Kolm, Theil, CV, squared CV, generalized entropy) to GO annotation density **with the full gene set as an external denominator**: Gini rose 0.25 (2001) → 0.47 (2017) despite ~6× annotation growth; ~58% of annotations cover ~16% of human genes; and they name the mechanism — researchers annotate what was already annotated, so density tracks *research attention*, not biology. **This is exactly your argument form, and it is your template.** It works because the domain has an independent enumerable denominator (the genome). Weaker relative: Brewster et al., *Data Driven Ontology Evaluation* (LREC 2004, https://aclanthology.org/L04-1476/) — right shape, 20 years old, never standard, and never argues the corpus is independent of the ontology's sources.

**The bias literature's own state of the art is a checklist.** C. Maria Keet, *Bias in ontologies — a preliminary assessment* (https://arxiv.org/abs/2101.08035) — the only paper titled on this — enumerates eight bias types (including granularity) and assesses three ontologies with **a presence/absence matrix**. No scoring, no severity, no magnitude, manual expert review, and future work is "a systematic way assessing and annotating explicit choices in the ontology."

**Guarino's "ontological level"** (1994; revisited https://link.springer.com/chapter/10.1007/978-3-642-02463-4_4) is a five-level stratification of KR primitives — logical / epistemological / **ontological** / conceptual / linguistic — giving a **criterion of kind** (are the primitives ontologically constrained or merely structurally convenient?), not of degree. Zero quantitative content; its operational descendant is OntoClean. **[Sourcing caveat: LOA PDF and Springer pages resisted extraction; wording is secondary.]**

**The identification problem, stated.** Fine granularity in region R is *supposed* to correlate with the domain's density in R. So "disproportionate" is only meaningful against a density estimate of the domain that is **causally independent of the sources the vocabulary was built from**. Every published method either has no domain estimate at all, or uses a corpus without arguing independence. **The measure is the easy part** — a two-part code with per-region excess code length on a disjoint-provenance sample, or KL between granularity mass and a reference mass, or Gini/Theil over region-level counts, will all serve. **The independent reference is the hard part, and it does not exist in the literature.**

*(If you want to build it for DeFi: the analogue of the genome is a value-weighted denominator — TVL, notional volume, or user count per economic function, sourced independently of which codebases you read. That is a genuinely novel and defensible measurement, and it is a good task to hand one of the nine.)*

### 3.5 Competency questions — the "completeness theorem" is real and weaker than its name

Grüninger & Fox, *Methodology for the Design and Evaluation of Ontologies* (IJCAI-95 workshop); restated in Uschold & Grüninger, *Ontologies: Principles, Methods and Applications*, KER 1996 (http://www.aiai.ed.ac.uk/publications/documents/1996/96-ker-intro-ontologies.pdf).

Pipeline: Motivating Scenario → Informal CQs → FOL Terminology → Formal CQs → FOL Axioms → **Completeness Theorems**.

**[VERBATIM, IJCAI-95]** "These are the informal competency questions, since they are not yet expressed in the formal language of the ontology." And critically: "**These competency questions do not generate ontological commitments; rather, they are used to evaluate the ontological commitments that have been made.**"

**[VERBATIM, KER 1996]** "Once the competency questions have been posed informally and the terminology of the ontology has been defined, the competency questions are defined formally as an **entailment or consistency problem** with respect to the axioms in the ontology" — as `T_ontology ∪ T_ground ⊨ Q`. *(The symbolic form is in the 1996 paper, not IJCAI-95 — attribute correctly.)*

**[VERBATIM, IJCAI-95]** "Lastly, we test the competency of the ontology by proving **completeness theorems** with respect to the competency questions." **[VERBATIM, KER 1996]** "Once the competency questions have been formally stated we must define the conditions under which the solutions to the questions are complete. **This forms the basis for completeness theorems for the ontology.**" Example forms: "`T_ontology ∪ T_ground ⊨ Φ` if and only if `T_ontology ∪ T_ground ⊨ Q`" and "All models of `T_ontology ∪ T_ground` agree on the extension of some predicate P." Plus, directly relevant to §2: "**Any extension to the ontology must be able to preserve the completeness theorems.**"

**[VERBATIM]** "**The axioms in the ontology must be necessary and sufficient to express the competency questions and to characterize their solutions.**" Note the asymmetry: **sufficiency gets an operational repair rule** ("If the proposed axioms are insufficient… then additional objects or axioms must be added"); **necessity gets no test at all.**

**Blunt verdict.** This is not a completeness result in the logician's sense — no proof-system-vs-semantics theorem, no general schema, and no worked proof in the methodology paper. It is a **per-ontology proof obligation**: hand-written, for a hand-chosen CQ set, proved by hand. "Complete" means "complete for the questions we thought to ask", and the questions are chosen by the same people who built the ontology. The word *theorem* does rhetorical work the method does not cash.

**But it is the most falsifiable thing in the field, and it is the closest published precedent for Candidate A below.** Given a fixed formalized CQ set, "is Q entailed?" is refutable with a mechanical answer; Grüninger's group later mechanized it with ATPs (https://arxiv.org/abs/1510.04826), splitting CQs into truth-tests and falsity-tests.

**The formalization attrition rate is a hard number you should know:** Wiśniewski, Potoniec, Ławrynowicz & Keet (https://arxiv.org/abs/1811.09529) took 234 CQs across 5 ontologies and **only 131 (56%) could be translated into SPARQL-OWL**; no CQ pattern was shared across all five ontologies. Failures: "lacking vocabulary in the ontology to construct expected query or expressing the CQ in a too vague way." **If you adopt a CQ-style adequacy clause, budget for roughly half your questions being unformalizable.**

**Task-based evaluation** (Porzel & Malaka, ECAI-2004 OLP; survey: Brank, Grobelnik & Mladenić, http://ailab.ijs.si/dunja/sikdd2005/Papers/BrankEvaluationSiKDD2005.pdf) is the strongest external falsifier — a number on a benchmark you did not choose. Brank's three stated drawbacks **[VERBATIM]**: "an ontology is good or bad when used in a particular way for a particular task, but it's difficult to generalize this observation"; "the ontology could be only a small component of the application and its effect on the outcome may be relatively small and indirect"; "comparing different ontologies is only possible if they can all be plugged into the same application." The second is a **sensitivity** defect — a null result is uninformative. *(Also worth noting: Brank's 2005 survey never mentions Grüninger, Fox, or competency questions. The logical-adequacy and empirical-evaluation literatures barely talk to each other.)*

### 3.6 What to do about your encoding bias instead

Since the ontology literature will not give you a measure, **measure it with the algebra instead.** The independence test (§7, Candidate B) is a *direct* test for over-granularity: if five AMM pricing generators exist because five codebases exist rather than because five mechanisms exist, then for most of them you will fail to produce a distinguishing context, and they collapse into one parameterised generator. That is a measurement, it is falsifiable, and it does not require anyone to agree on a bias metric. Conversely, if the single options generator turns out to macro-express three genuinely independent things, the independence test forces you to *split* it.

**This is the honest reframing: encoding bias is not something to measure directly; it is what independence testing detects.**

---

## 4. Adequacy / representational adequacy

### 4.1 The one that is actually a theorem: LF adequacy (Harper–Honsell–Plotkin)

This is the single most directly adaptable formal notion in this whole note, and it is the thing your brief should probably ask for by name.

**[VERBATIM, Harper, Honsell & Plotkin, *A Framework for Defining Logics*, JACM 40(1):143–184, 1993 — preprint https://homepages.inf.ed.ac.uk/gdp/publications/Framework_Def_Log.pdf, Theorem 4.2]**

> "Let A be an assignment and let Δ be a labeled set of hypotheses with free variables declared in A. There is a **compositional bijection** ε_{A,Δ} mapping valid proofs of a formula ϕ with respect to (A, Δ) to **canonical LF terms** of type ε_{A,o}(ϕ) in Σ_HOL and Γ_{A,Δ}."

(Theorem 4.1 is the longer first-order version, which spells out compositionality as commutation with substitution.)

**The shape is exactly three conjuncts, and all three are falsifiable:**
1. **Bijection** between object-language entities of a category and the representation's terms — surjectivity = coverage, injectivity = no two distinct real things collapse to one term;
2. at the **right type**, and only over **canonical** terms — adequacy fails if you quantify over all well-formed terms;
3. **Compositional**: ε(t[u/x]) = [ε(u)/x] ε(t). This is what rules out an ad-hoc Gödel-numbering bijection that is technically a bijection but destroys structure.

The proof method is worth copying too: HHP prove surjectivity by exhibiting a **left inverse** — a decoding function δ defined by induction on canonical forms, with δ(ε(Π)) = Π. A constructive round-trip, not an existence claim.

Two caveats they state themselves **[VERBATIM]**: "It is important to stress that the way in which we have defined the set of free variables in a proof is crucial to the correctness of the adequacy theorem." — adequacy is only statable against a *fully formalised* object language. And: "The adequacy theorem is a minimal correctness criterion, and does not delineate the extent to which the type structure of LF may be exploited in representing forms of inference that are not characteristic of the logical system being represented." — adequacy is a **floor, not a ceiling**.

**Transfer to your setting.** Pre-register a frozen set of protocol mechanisms — descriptions written *before* the vocabulary — and demand a **compositional bijection** between those mechanisms (up to your chosen observational equivalence) and the well-formed terms over 𝒢 (up to the same). Three distinct, nameable failure modes fall out:
- **under-coverage** (surjectivity fails): a real mechanism has no term;
- **confusion** (injectivity fails): two economically distinct mechanisms get the same term;
- **junk**: a well-formed term denotes no realizable mechanism.

The third is the one nobody in the ACTUS/Marlowe tradition ever checks, and it is where a 58-generator algebra will hurt most: with 58 free generators you can write astronomically many terms that correspond to nothing. Requiring a junk bound is a real, novel demand.

### 4.2 McCarthy & Hayes: three adequacies (a rubric, not a theorem)

**[VERBATIM, *Some Philosophical Problems from the Standpoint of Artificial Intelligence*, Machine Intelligence 4, 1969 — https://www-formal.stanford.edu/jmc/mcchay69/node5.html]**

> "A representation is called **metaphysically adequate** if the world could have that form without contradicting the facts of the aspect of reality that interests us."
> "A representation is called **epistemologically adequate** for a person or machine if it can be used practically to express the facts that one actually has about the aspect of the world."
> "A representation is called **heuristically adequate** if the reasoning processes actually gone through in solving a problem are expressible in the language."

The three are distinct and not nested; McCarthy & Hayes' own point is that particle physics is metaphysically adequate and epistemologically useless. For you: metaphysical ≈ no deployed protocol contradicts the ontology; epistemological ≈ the facts analysts actually have can be stated; **heuristic ≈ the reasoning analysts actually do (deriving a risk or solvency conclusion) is expressible.** Hand-built taxonomies almost always fail the third, and that is the one worth explicitly testing. But note: none of the three is a theorem, and citing them is a rubric move, not a formalisation move.

### 4.3 Levesque & Brachman: expressiveness is not free

Levesque & Brachman, *Expressiveness and tractability in knowledge representation and reasoning*, Computational Intelligence 3(2):78–93, 1987. Thesis: reasoning difficulty grows sharply with expressive power, so representation design is a *tradeoff*, not a maximisation. **[UNVERIFIED verbatim — paywalled; cite for the thesis, not for a quote.]**

Relevance to your brief: a mathematician's instinct will be to make the algebra maximally expressive. That is the wrong target. If the vocabulary is expressive enough that two competent analysts classify the same protocol differently, it has failed regardless of coverage. "Expressive enough and no more" is a defensible design constraint and you should state it.

### 4.4 Codd's theorem — the shape to imitate

**[VERBATIM, https://en.wikipedia.org/wiki/Codd%27s_theorem]** relational algebra and the domain-independent relational calculus queries "are precisely equivalent in expressive power." Original: E. F. Codd, *Relational Completeness of Data Base Sublanguages*, Courant Computer Science Symposium 6, 1972, pp. 65–98.

What makes it a genuine theorem and not a slogan: it equates two *syntactically dissimilar* languages (variable-free algebra vs. a logic with quantifiers), and it comes with a matching **negative** result — relationally complete languages cannot express aggregation or transitive closure.

**Imitable move for you:** define the vocabulary twice — once as a compositional grammar of generators, once as a flat enumerated taxonomy — and prove they induce the same classification of the corpus. The valuable half is the negative one: name what *neither* can express. Do not confuse this with normalization (BCNF); normalization is a non-redundancy condition on how a schema is factored, not a statement about expressive power.

---

## 5. Expressive completeness against a semantic class — the key question

### 5.1 What makes the gold-standard theorems possible

Kamp, Post, Büchi–Elgot–Trakhtenbrot all have the same shape:

> Logic L is **expressively complete** for semantic class C iff for every property P ∈ C there is a formula φ ∈ L such that for all structures 𝔐, 𝔐 ⊨ φ ⟺ 𝔐 ∈ P.

The load-bearing precondition is that **C is defined independently of L, and prior to it.** Kamp works because "first-order monadic logic of order over Dedekind-complete linear orders" was already a defined mathematical object; the theorem then says Until/Since suffice. Post works because "all Boolean functions {0,1}ⁿ → {0,1}" is a completed totality. MSO=regular works because regular languages were defined by automata, not by MSO.

**Corpus coverage fails exactly here.** A corpus is not a semantic class; it is a finite sample. "We cover 60 protocols" is the analogue of "our temporal logic can express all 60 formulas we tried". No theorem is available because there is nothing quantified over.

So the question for your brief is: **is there a prior, independently-defined semantic class of DeFi mechanisms?**

### 5.2 There is one, and it is real — but it cuts both ways

**Roger Lee, "All AMMs are CFMMs. All DeFi markets have invariants. A DeFi market is arbitrage-free if and only if it has an increasing invariant"** (arXiv:2310.09782). Text extracted and read. This gives a genuine, prior, model-independent semantic class for DeFi. **[VERBATIM]**

> **Definition 2.1.** "A market system on a state space X is a function M : X → 2^X, where 2^X denotes the set of subsets of X."

with M(x) = the states reachable by one admissible transaction. Reachability M^∞(x) (Def 2.4), induced preorder ≼_M (Def 2.7: `x ≼_M y if and only if y ∈ M^∞(x)`), invariant (Def 2.8: K with `K(x) < K(y)` for x ≺ y and `K(x) = K(y)` for x ∼ y), completeness (Def 2.9: **"A market system on X is said to be complete if for all x, y ∈ X, we have x ≼ y or y ≼ x"** — i.e. the induced preorder is total), recovery (Def 2.10).

Real theorems, quoted:
- **Proposition 2.11** — "Let M be a market system with an invariant K. Then M is complete if and only if K recovers M."
- **Theorem 3.1** — "Every D-CFMM is D-arbitrage-free."
- **Definition 3.5** — "An AMM is an order-continuous market system, or a restriction thereof."
- **Theorem 3.6 (Zeroth fundamental theorem)** — "All AMMs are CFMMs." (Proof via Sondermann's order-representation theorem — Debreu-style representability of a preorder by a real-valued function.)
- **Corollary 3.7** — "Every market system on a countable space is continuous and is therefore a CFMM."
- **Definition 3.10** — "A DeFi market system (or DeFi market or DeFi system) is a giftable market system…" (giftable, Def 3.9: `x ≼ y` whenever `y ⊴_D x` — you may always donate).
- **Theorem 3.11** — "If M is a D-arbitrage-free DeFi system, then M is a D-CFMM."
- **Theorem 3.12** — "A DeFi system is arbitrage-free if and only if it has an increasing invariant."

This is the closest thing in the literature to an FTAP for DeFi and it is a genuine characterization theorem over a semantic class.

**But read the author's own scope note** **[VERBATIM]**:
> "Indeed Definition 2.1 is universal, in that it encompasses every conceivably implementable combination of DeFi primitives, because on a coding level, any protocol (or network of protocols) operates by transforming state variables."

That universality is what makes it a legitimate semantic class *and* what makes it dangerous as a completeness target. **A completeness theorem of the form "every DeFi market system M : X → 2^X is denoted by some term over our 58 generators" is either false or trivial.** Trivial if your generators include anything Turing-expressive (you then prove Turing-completeness dressed up as domain completeness, which is worthless — Solidity already has it). False if they do not. Either way you learn nothing.

### 5.3 What a *non-trivial* completeness theorem would have to look like

The move is to **shrink the semantic class by imposing structure that is economically meaningful, then prove your generators generate exactly that.** Candidate restrictions, in increasing order of how much a theorem would be worth:

| Restricted class C | Plausibility of a completeness theorem | What it would buy you |
|---|---|---|
| Market systems on X ⊆ ℝⁿ that are **order-continuous, giftable, and admit a differentiable increasing invariant** | Plausible. Lee already characterizes membership. | "Our AMM/pricing fragment is complete for arbitrage-free continuous exchange." Real but covers ~5 of your 58 |
| **Path-independent** market systems (M^∞ determined by a potential) | Plausible | Excludes lending, options, governance. Narrow |
| Systems whose cash-flow observable factors through a **finite-state controller over a fixed set of oracle predicates** | Plausible; this is a regular-language-style theorem, à la Büchi | Would give you a real Kamp-analogue: "term-definable = definable in [some monadic logic] over event traces" |
| **All** DeFi market systems (Lee's Def 2.1/3.10) | Trivial or false, per §5.2 | Nothing |
| The class of **ACTUS-style deterministic cash-flow contracts** | Actually provable, and someone should | Would cover the fixed-income half; irrelevant to AMMs |

**The honest line for your brief:** a single completeness theorem covering all 58 mechanisms against one semantic class is *not currently available and probably not achievable*, because DeFi mechanisms are not one kind of object. AMM pricing is a preorder-representation problem; lending is a solvency-invariant problem; options are a stopping-time/payoff problem; governance and oracles are distributed-agreement problems. The right target is **a family of fragment-wise completeness theorems plus one global adequacy statement**, not one theorem.

State that explicitly. It is a stronger intellectual position than a completeness claim you cannot cash.

### 5.4 Other DeFi semantic frameworks worth naming to the mathematicians

- Bartoletti, Chiang, Lluch-Lafuente, *A theory of Automated Market Makers in DeFi* (arXiv:2102.11350) — abstract operational (LTS) model of user/AMM interaction, instantiable by economic mechanism; proves structural + economic properties and a general solution to the arbitrage problem. Confirmed via abstract; **[UNVERIFIED]** whether it contains any expressiveness result (I did not extract the full text; I saw no such claim).
- Bartoletti et al., *A theory of Lending Protocols in DeFi* (arXiv:2506.15295) — LTS with Deposit/Borrow/Repay/Redeem/Liquidate rules. Same shape.
- *Formal Analysis of Composable DeFi Protocols* (arXiv:2103.00540) — composition-focused; relevant to the "context" notion in §1.9.

These give you the **contexts** for a Felleisen-style argument: an LTS semantics plus a composition operator is exactly what you need to define ≃ and to exhibit distinguishing contexts.

### 5.5 A modern alternative to Felleisen worth naming: Gorla's encodability criteria **[UNVERIFIED — shape only]**

Daniele Gorla, *Towards a unified approach to encodability and separation results for process calculi* (CONCUR 2008 / Information and Computation 208(9), 2010). This is the framework the concurrency community actually uses now for "calculus A cannot be encoded in calculus B", and it is a better fit than Felleisen for a *stateful, concurrent, adversarial* domain like DeFi, because it does not require a common language universe.

I could **not** retrieve the paper text (ScienceDirect returned 403 and my web-search budget was exhausted), so I will not state the criteria as quotations. **The shape**, which you should verify before putting it in the brief: Gorla proposes a small set of criteria a translation ⟦·⟧ must satisfy to count as a *valid encoding* — roughly, (1) **compositionality** (the translation of an operator is a fixed context parameterised by the translations of its arguments, plus a renaming policy — this is precisely Felleisen's E4/macro condition generalised), (2) **name invariance** (translation commutes with renaming), (3) **operational correspondence** (completeness: source reductions are matched by target reductions up to ≍; soundness: target reductions come back to translations of source terms), (4) **divergence reflection** (the encoding does not introduce non-termination), and (5) **success sensitiveness** (a designated observable "success" is preserved and reflected). Separation results are then proved by showing no translation can satisfy all five. Treat every one of those five names as needing confirmation against the paper.

Why it matters for you: criterion (5) is *exactly* the "you must fix an observable" demand, and criterion (3) splits into completeness and soundness halves that map neatly onto "the algebra can build the protocol" and "the algebra builds nothing spurious". If you want one citation that a modern mathematician will accept as the standard for this kind of claim, it is probably Gorla rather than Felleisen — Felleisen is the origin and the cleaner statement, Gorla is the working tool.

---

## 6. Prior expressiveness results for financial contract DSLs

### VERDICT: No. Your suspicion is correct, and it is a strong line for the brief.

No paper in the financial-contract-DSL literature states or proves a result of the form "language L expresses exactly the class C". What exists is (i) denotational semantics without metatheory, (ii) **safety** theorems about execution (money preservation, termination) or **soundness** theorems about analyses, and (iii) corpus coverage. The proof budget in this field has gone entirely to safety, never to expressiveness.

| Work | What is actually proved | Expressiveness/completeness theorem? |
|---|---|---|
| Peyton Jones & Eber, ICFP 2000 / "How to write a financial contract" 2003 | Nothing. Denotational semantics ("value processes") + algebraic laws stated as observations | **No** |
| Vandenbroucke & Schrijvers, *Rigged Contracts*, FLOPS 2024 | **Nothing.** The paper contains 3 Definitions (semiring, group, ring/field) and **zero** Theorems/Lemmas/Propositions | **No** — see below |
| Marlowe (WTSC 2020 + Isabelle/HOL) | termination of `reductionLoop`; valid-state and positive-account preservation; quiescence; **money preservation**; timeout-closes-contract; bounded transaction count (`lemma playTrace_only_accepts_maxTransactionsInitialState`) | **No** |
| ACTUS | Nothing formal | **No** — expert consensus |
| Findel (FC 2017) | Solidity implementation + gas benchmarks | **No** ([UNVERIFIED] — paper not retrievable) |
| DAML / Digital Asset | Ledger-model safety: integrity, conformance, authorization, privacy | **No** |
| Hvitved (PhD 2012) survey | 16-criterion feature matrix | **No** — criterion 13 "isomorphic encoding" is an informal desideratum |
| CSL — Henglein, Larsen & Murawska, FC 2020 | Coq-mechanised `Theorem 1 (Soundness of approximation)`, `Theorem 2 (Soundness of widening)`, `Theorem csl_analysis_sound` | **No** — analysis soundness, not expressiveness |

### 6.1 Rigged Contracts is the near-miss, and it is worth naming precisely

This is the most useful single fact for your brief. The introduction claims an initiality result **[VERBATIM]**:

> "we can take inspiration from mathematics, by reimagining the semantics as a universal semiring homomorphism, i.e. a structure-preserving function from contracts to any semiring (equipped with inverses). In other words, **the contract semiring is the initial object with respect to such semirings.**"

**That claim is never stated as a theorem and never proved.** The semiring laws themselves are asserted informally **[VERBATIM]**: "From their informal descriptions, **it is quite easy to see** that both operators are associative and commutative, and that both distributes over or. **These properties can be proved formally using the semantics defined in Section 4.**" — explicit future tense; it is not done in the paper.

Also, the initiality claim as stated cannot literally hold: `Contract` carries seven non-semiring primitives (`Give`, `Truncate`, `Thereafter`, `One`, `Scale`, `Get`, `Anytime`) whose interpretation is supplied externally by the `Financial r obs` record. At best it would be initiality in a category of semirings-with-extra-structure, which the paper does not define.

And their own expressiveness remark is a *negative* one **[VERBATIM]**: `both` "seems **slightly more powerful** than the and combinator of Peyton Jones et al., in the sense that it allows more contracts to be expressed in the language directly" — immediately weakened by "it is always possible to define a contract that behaves like (both c1 c2) by using features from the host language (Haskell)." In Felleisen's terms they are conceding macro-eliminability into the host language.

**Use this in the brief:** *the strongest structural claim anyone has made about a financial contract algebra is an unproved one-sentence initiality claim in an introduction. Proving it — or proving the analogous statement for your 58 generators — would be the first such theorem in the field.* That is a much better motivating sentence than "we cover 60 protocols."

### 6.2 Marlowe vs ACTUS: the coverage claim is weaker than you think

The WTSC 2020 Marlowe paper mentions ACTUS **once**, in Related Work **[VERBATIM]**: "In providing such specificity this bears comparison with **our implementation of contracts from the ACTUS standard**." There is no "we can express all 32 ACTUS contract types" theorem, or even claim, in that paper. The dedicated Marlowe/ACTUS work (Kondratiuk, Lamela Seijas, Nemish, Thompson) is an implementation report. If your draft cites Marlowe-extended-when-benchmarked-against-ACTUS as precedent, cite it accurately: it is an engineering exercise, not a coverage proof.

### 6.3 ACTUS's own claim is explicitly not completeness

**[VERBATIM, ACTUS Financial Research Foundation]**: "The vast majority of the relevant financial contracts are built on a manageable number of underlying mechanisms. Financial contracts follow a limited number of patterns." Note *"vast majority"*. ACTUS does not claim completeness, and no methodology or census derivation is published. If ACTUS is your model for corpus coverage, you are inheriting a claim its own authors declined to make.

### 6.4 Nothing Felleisen-style exists here

No "X cannot be macro-expressed in Y" result for any contract language. Adjacent algebraic work — Incer, *The Algebra of Contracts* (Berkeley 2022) — is about **assume/guarantee design contracts**, a lattice/quotient structure on specifications, not financial contracts and not expressive power. Flood & Goodenough, "Contract as Automaton" (OFR working paper) argues automaton-representability by construction and example, not by theorem.

**This is the gap.** A minimality/independence result over a DeFi mechanism vocabulary would, as far as I can establish, be the first expressiveness result in the financial-contract-language literature.

---

## 7. Completeness vs adequacy vs minimality — the three-way split

Use these as three separate, separately-provable requirements. Conflating them is what makes "complete and composable algebra" sound like a slogan.

| | Statement form | Quantifies over | Provable? |
|---|---|---|---|
| **Completeness** | ⟦Term(𝒢)⟧ = C for a class C defined without reference to 𝒢 | an infinite, prior semantic class | Only if C exists (§5) |
| **Adequacy** | for every p in corpus P, ∃ t with ⟦t⟧ = ⟦p⟧ | a finite corpus | Always, by construction — hence weak |
| **Minimality / independence** | for each g ∈ 𝒢, 𝒢∖{g} cannot macro-express g | the generators themselves | Yes, one proof per generator |

**Independence is the one you can actually get, and it is the one that attacks your encoding-bias problem directly.** If five AMM pricing generators are present because five codebases exist rather than because five economically distinct mechanisms exist, then *most of them will fail the independence test* — you will find no context distinguishing constant-product from constant-sum from the concentrated-liquidity variant once they are all parameterised over an invariant function K. That is a proof, not an assertion, that your vocabulary has encoding bias. Conversely if all five survive, you have a defence.

**Concretely: the standard method for proving independence.** For each generator g, exhibit a *model* (an interpretation of the signature) that validates all your axioms, is closed under every generator except g, and is not closed under g. This is the classical independence-of-axioms technique (Padoa's method / Beth definability in the logical setting; the same construction that proves the Post clones are the only maximal ones in Boolean algebra). Felleisen's Theorem 3.14 is the operational version of the same move: the "model" is the observational equivalence relation, and the witness is a pair of terms whose equivalence status changes.

---

## The completeness clause I should actually write

Three candidates. They are not alternatives so much as increasing levels of ambition; **A is the floor and you should take it unconditionally; B is the one I would actually put in the statement; C is the stretch goal you name as an open problem rather than a requirement.**

### Candidate A — Adequacy + hygiene (cheap, unfalsifiable-by-cheating, no theorem required)

> **Adequacy.** Fix an observation map ⟦·⟧ sending each protocol term to its *net cash-flow vector per agent*, quantified over an adversarial environment (price paths, transaction orderings, and composition with other deployed terms). The vocabulary 𝒢 is **adequate for a corpus P** iff for every protocol p ∈ P there is a term t over 𝒢 with ⟦t⟧ = ⟦p⟧ under that observation. Adequacy is relative to ⟦·⟧ and to P, and both must be stated.
>
> **Extension hygiene.** Any proposed generator g ∉ 𝒢 is admissible only if (i) 𝒢 ∪ {g} is a *conservative extension* of 𝒢 — no new inhabitants of existing sorts (*no junk*) and no new identifications of previously distinct terms (*no confusion*); and (ii) g is not macro-expressible over 𝒢, witnessed by two terms t₁, t₂ over 𝒢 with t₁ ≃_𝒢 t₂ but t₁ ≄_{𝒢∪{g}} t₂ (Felleisen 1991, Thm 3.14(i)).

*Precedent:* this is structurally Grüninger & Fox's competency-question "completeness theorem" (§3.5) — completeness relative to an explicitly declared, pre-registered question set — with an observation map in place of the CQ set. Cite them; it is honest and it is the closest published thing.
*Cost:* you must fix ⟦·⟧ before the mathematicians start, and you can never again say "complete" unqualified. Budget for attrition: the SPARQL-OWL study found only 56% of real competency questions could be formalized at all (§3.5).
*What a mathematician can get away with:* choosing an ⟦·⟧ so coarse that everything is equivalent. **Mitigation: fix ⟦·⟧ yourself, in the statement, and forbid changing it.** Also: adequacy is still corpus-relative — this is honest ACTUS-with-teeth, not a completeness theorem.

### Candidate B — Independence + relative expressiveness theorem (my recommendation)

> Let 𝒢 = {g₁,…,g₅₈} be the generator signature and let Term(𝒢) be the free 𝒢-algebra of protocol terms. Fix a semantics ⟦·⟧ : Term(𝒢) → 𝔻 into Lee-style market systems (M : X → 2^X, arXiv:2310.09782 Def. 2.1), and let ≃ be the induced observational equivalence: t₁ ≃ t₂ iff for every composition context C[·] over 𝒢, ⟦C[t₁]⟧ and ⟦C[t₂]⟧ have the same net cash-flow observable.
>
> The algebra is required to satisfy:
>
> **(I) Independence.** For each i, the sub-signature 𝒢∖{gᵢ} cannot macro-express gᵢ with respect to 𝒢. Proof obligation per generator: exhibit t₁, t₂ ∈ Term(𝒢∖{gᵢ}) with t₁ ≃_{𝒢∖{gᵢ}} t₂ and t₁ ≄_𝒢 t₂. (Felleisen 1991, Thm 3.14(i).) Any gᵢ for which this fails must be **demoted to a derived operator** and given as a definition A(x₁,…,x_a) over the remaining generators, with the proof gᵢ(ē) ≃ A(ē) (Felleisen 1991, Cor. 3.13).
>
> **(II) Fragment completeness.** For each of the named fragments F ⊆ 𝒢 (exchange/pricing, credit, derivative payoff, …) and its independently specified semantic class C_F, prove ⟦Term(F)⟧ = C_F, or exhibit the exact gap. Coverage of the 60-protocol corpus is *evidence for* the specification of C_F, not a substitute for it.
>
> **(III) Conservativity.** Every extension of 𝒢 during the work must be conservative in the algebraic-specification sense (no junk, no confusion) and must come with an (I)-style independence witness.

*Cost:* 58 independence proofs is real work, and some will fail — which is the point; failures shrink the vocabulary and directly attack the AMM-vs-options encoding bias. Requires you to specify C_F for each fragment, which is the hardest intellectual demand in the whole brief.
*What a mathematician can get away with:* (a) picking a distinguishing context so exotic it is not physically realizable on-chain — so **constrain contexts to terms over 𝒢 itself**, which is exactly what Felleisen's Def 3.4 does and why it is the right formulation; (b) gerrymandering C_F to be the image of Term(F), making (II) a tautology — so **require C_F to be defined without reference to 𝒢**, in the language of the underlying economics.

### Candidate C — Full expressive completeness (name it as an open problem, do not require it)

> **Conjecture (expressive completeness).** There is a semantic class C of DeFi market systems, defined independently of 𝒢 — e.g. the giftable, order-continuous market systems on ℝⁿ whose reachability preorder is representable by a piecewise-smooth invariant and whose event-triggering is definable in monadic first-order logic over the oracle-predicate trace — such that ⟦Term(𝒢)⟧ = C, up to ≃. That is: 𝒢 is expressively complete for C in the sense of Kamp's theorem for Until/Since over FOMLO.
>
> We do not claim this. We ask whether such a C exists and, if it does not, we ask for the obstruction.

*Cost:* essentially none to state, high credibility gain, and it invites a negative result (a proof that no such C exists, or that any such C is either trivial or equals "all computable state transformers") which would itself be a publishable finding.
*What a mathematician can get away with:* nothing — it is a conjecture, explicitly not a requirement. The risk is the opposite: someone "proves" it by taking C := ⟦Term(𝒢)⟧. Pre-empt with the independence clause: **C must be specified before 𝒢 is consulted.**

### Sentence you can paste as the framing paragraph

> We do not define completeness as corpus coverage. Coverage of the 60-protocol corpus is *evidence* about the vocabulary, not a definition of its adequacy, and it is evidence of a known-biased kind: the corpus over-samples Ethereum AMM implementations relative to their economic significance, which is why the draft vocabulary carries five pricing-curve generators and one option generator. We therefore ask for three separable things — **adequacy** relative to an explicitly fixed observation map, **independence** of the generating set in the sense of Felleisen's macro-expressibility (a generator is admissible only if removing it collapses an observational distinction), and, where a semantic class can be specified independently of the vocabulary, **fragment-wise expressive completeness** against that class. We regard a proof that no such class exists for a given fragment as an equally valuable outcome.

---

## What I could not verify

1. **Gorla's five encodability criteria** — could not obtain the paper text (ScienceDirect 403; alternative hosts not reachable within budget). The five names and their shape in §5.5 are from memory and must be checked against *Information and Computation* 208(9):1031–1053 (2010) before they go in the brief. Do not quote them.
2. **Gruber's verbatim definitions** of the five criteria, in particular "minimal encoding bias" — tomgruber.org serves only the abstract page; the PDF link 404'd for me. See §3 for what the parallel lane recovered.
3. **Bartoletti/Chiang/Lluch-Lafuente AMM theory** — I read only the abstract. I did not extract the full text, so I cannot state which theorems they prove or confirm the absence of an expressiveness result there. Treat "no expressiveness result in Bartoletti et al." as *unchecked*, not established.
4. **Kamp's theorem exact statement** — I have the standard formulation (Until/Since expressively complete for FOMLO over Dedekind-complete linear orders; fails over the rationals; over ℕ, Until alone suffices for the future fragment; over ℝ no finite basis of future modalities suffices) from secondary sources (Rabinovich, Hirshfeld). I did not read Kamp's 1968 thesis. The formulation above is standard and safe to cite, but cite a modern proof paper (e.g. Rabinovich, "A Proof of Kamp's theorem", LMCS 2014) rather than the thesis.
5. **Sondermann's order-representation theorem**, which Lee's Theorem 3.6 relies on — I did not check it. If a mathematician leans on "All AMMs are CFMMs" they should check that dependency, since it is where the continuity hypothesis does its work.
6. **The web-search budget for this session was exhausted mid-task** (200/200). Several intended follow-ups — quantitative ontology-metric papers beyond what the parallel lane found, Hvitved's contract-language survey, and confirmation of the Marlowe–ACTUS benchmarking claim's exact wording — may be incomplete for that reason. Anything marked [UNVERIFIED] below should be re-run with fresh budget before it enters the problem statement.
7. **Financial-DSL lane could not directly read**: Peyton Jones & Eber ICFP 2000 (bitmap Type3 PDF, mirrors 404 — the "no theorems" finding rests on convergent secondary evidence, including Vandenbroucke & Schrijvers' own characterisation of it); Findel (uni.lu link 404); Hvitved's thesis and survey (DIKU links dead); Andersen, Elsborg, Henglein, Simonsen & Stefansen, *Compositional specification of commercial contracts* (STTT 2006, paywalled); Brammertz & Mendelowitz. **The one worth re-checking before publishing a strong "nobody has ever proved this" claim is Andersen et al. 2006** — a residuation semantics plausibly carries a soundness/completeness pair, though even that would be *semantics adequacy*, not expressiveness.
8. **Padoa's method and Beth's theorem** — the Padoa formulation given is a paraphrase assembled from secondary sources; Beth's statement is quoted from Wikipedia, not from Beth (1953). Verify before quoting.
9. **"Semantic relativism"** in semantic data modelling — not verified at all. Check Hammer & McLeod (SDM) and Kent, *Data and Reality*.
10. **Levesque & Brachman 1987** — thesis confirmed, no verbatim quote obtained (paywalled).
11. **nLab's "conservative extension" page is a stub** with an empty Idea section. Do not cite it.
12. **§3 gaps (ontology lane, now returned and verified — these specific items remain open):** Vrandečić's *Ontology Evaluation* chapter (Handbook on Ontologies, 2009) — **no verified quotations at all**; Springer auth gate, author's site dead. The two-axis grid (approaches × levels) attributed to him is secondary-source only. OntoQA's knowledgebase-level formulas (host bot-blocked) — only the schema-level three are confirmed. Guarino's 1994 "Ontological Level" wording — secondary only. **OQuaRE's LCOMOnto threshold direction — two published sources contradict each other; do not cite any OQuaRE threshold table without checking the tool source.** Ren et al. ESWC 2014 and the Sci Rep 2025 biomedical-granularity paper — paywalled, unread.
13. **No theorem statement in this document has been invented.** Where I could not obtain an exact statement I have said so and given only the shape.

---

## Primary sources actually read

- Felleisen, *On the Expressive Power of Programming Languages*, Science of Computer Programming 17 (1991) 35–75 — https://www2.ccs.neu.edu/racket/pubs/scp91-felleisen.pdf (text extracted; Defs 3.1–3.5, 3.11, 3.17, Thms 3.6, 3.8, 3.12, 3.14, 3.18, 3.19, Cors 3.10, 3.13 quoted above). ESOP 1990: https://link.springer.com/chapter/10.1007/3-540-52592-0_60
- Roger Lee, *All AMMs are CFMMs. All DeFi markets have invariants. A DeFi market is arbitrage-free if and only if it has an increasing invariant* — https://arxiv.org/abs/2310.09782 (text extracted; Defs 2.1, 2.4, 2.7–2.10, 3.5, 3.9, 3.10, Props 2.11, Thms 3.1, 3.6, 3.11, 3.12 quoted)
- Harper, Honsell & Plotkin, *A Framework for Defining Logics*, JACM 40(1):143–184, 1993 — https://homepages.inf.ed.ac.uk/gdp/publications/Framework_Def_Log.pdf (Thms 4.1, 4.2)
- Maude 3.2.1 Manual, Ch. 6 §6.1 — https://maude.lcc.uma.es/maude321-manual-html/maude-manualch6.html (protecting/extending/including; "no junk, no confusion" = surjectivity/injectivity)
- Mossakowski, Haxthausen, Sannella & Tarlecki, *CASL — the Common Algebraic Specification Language* — https://homepages.inf.ed.ac.uk/dts/pub/cai.pdf
- Bidoit & Mosses, *A Gentle Introduction to CASL* — https://lsv.ens-paris-saclay.fr/~bidoit/GENTLE.pdf
- Goguen, Thatcher, Wagner, Wright, *Initial Algebra Semantics and Continuous Algebras*, JACM 24(1):68–95, 1977 — http://users.csc.calpoly.edu/~gfisher/work/specl/documentation/related-work/formal-semantics/algebraic/p68-goguen.pdf
- McCarthy & Hayes, *Some Philosophical Problems from the Standpoint of Artificial Intelligence*, Machine Intelligence 4, 1969 — https://www-formal.stanford.edu/jmc/mcchay69/node5.html
- Vandenbroucke & Schrijvers, *Declarative Pearl: Rigged Contracts*, FLOPS 2024 — https://lirias.kuleuven.be/retrieve/cdcd0444-8325-4b38-90f2-800a6d0a7019 (full text; **0 theorems**)
- Marlowe, WTSC 2020 + Isabelle formalisation (full text read by the DSL lane)
- Henglein, Larsen & Murawska, *A Formally Verified Static Analysis Framework for Compositional Contracts*, FC 2020 (Coq; analysis soundness only)
- Pelletier & Martin, *Post's Functional Completeness Theorem* — https://www.sfu.ca/~jeffpell/papers/PostPellMartin.pdf
- Bartoletti, Chiang, Lluch-Lafuente, *A theory of Automated Market Makers in DeFi* — https://arxiv.org/abs/2102.11350 (abstract only)
- Bartoletti et al., *A theory of Lending Protocols in DeFi* — https://arxiv.org/abs/2506.15295 (abstract only)
- Codd, *Relational Completeness of Data Base Sublanguages*, Courant Symposium 6, 1972 (via https://en.wikipedia.org/wiki/Codd%27s_theorem)
- Gruber, *Toward Principles for the Design of Ontologies Used for Knowledge Sharing*, IJHCS 43(5–6):907–928, 1995 — https://tomgruber.org/writing/onto-design.pdf (all five criteria quoted)
- Guarino & Welty, *An Overview of OntoClean*, Handbook on Ontologies ch. 8 — https://www.loa.istc.cnr.it/old/Papers/GuarinoWeltyOntoCleanv3.pdf
- Grüninger & Fox, *Methodology for the Design and Evaluation of Ontologies*, IJCAI-95 workshop; Uschold & Grüninger, KER 1996 — http://www.aiai.ed.ac.uk/publications/documents/1996/96-ker-intro-ontologies.pdf
- Gangemi, Catenacci, Ciaramita & Lehmann, *Modelling Ontology Evaluation and Validation*, ESWC 2006 — https://ceur-ws.org/Vol-166/9.pdf
- Lozano-Tello & Gómez-Pérez, *ONTOMETRIC*, JDM 2004 — https://oa.upm.es/6467/1/ONTOMETRIC_A_Method.pdf
- Brank, Grobelnik & Mladenić, *A Survey of Ontology Evaluation Techniques*, SiKDD 2005 — http://ailab.ijs.si/dunja/sikdd2005/Papers/BrankEvaluationSiKDD2005.pdf
- Wiśniewski, Potoniec, Ławrynowicz & Keet, *Analysis of Ontology Competency Questions and their Formalisations in SPARQL-OWL* — https://arxiv.org/abs/1811.09529 (56% formalization rate)
- Keet, *Bias in ontologies — a preliminary assessment* — https://arxiv.org/abs/2101.08035
- Haynes, Rovito et al., *Gene annotation bias impedes biomedical research*, Sci Rep 8:1362, 2018 — https://www.nature.com/articles/s41598-018-19333-x (**the template for measuring source bias against an external denominator**)

---
