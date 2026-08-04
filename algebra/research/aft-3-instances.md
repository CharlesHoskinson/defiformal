# AFT Lane 3 — Instantiations and Runnable Tooling

**Scope:** what Approximation Fixpoint Theory has actually been instantiated as, and what we can execute today.
**Retrieval date:** 2026-08-04. **Method:** arXiv API, Unpaywall, GitHub/Bitbucket REST APIs, direct URL probing, scrapling `stealthy-fetch --solve-cloudflare` for ScienceDirect. General WebSearch was unavailable (session budget exhausted before this lane started), so discovery was API- and citation-driven rather than search-driven. See "What I could not retrieve".

**A note on fidelity.** The two items the caller flagged as unforgiving — the ADF semantics definitions and the complexity table — were retrieved as HTML/markdown with Unicode math (Σ, Π, ⊑, ≤ᵢ, ⊨) preserved intact, not as PDF text extraction. They are quoted verbatim below. No image fallback was needed for them. The one source that *did* extract badly (a two-column PDF) is flagged as such and is not paraphrased in detail.

---

## 1. Abstract Dialectical Frameworks (ADFs)

### 1.1 Definition

Verbatim, from Pastva & Trinh 2026 (arXiv:2604.27576v2, Definition 1), attributed there to Brewka & Woltran, KR 2010:

> An ADF is a tuple `D := (S, C)` where `S` is a finite set of arguments and `C := {φₛ}_{s∈S}` consists of acceptance conditions (one for each argument in `S`), corresponding to propositional formulas `φₛ := s ∈ S | 0 | 1 | ¬φ | (φ ⊙ ψ)`, such that `⊙` can be one of the binary operators `∧, ∨, →, ↔`.

And the note that matters for us:

> The original definition of [Brewka & Woltran 2010] also assumes a link relation of dependencies between arguments to mirror the attack relation of AFs. However, this relation can be inferred from the acceptance conditions and is therefore commonly omitted in recent literature.

So: **an ADF is exactly a set of atoms, each with an arbitrary propositional acceptance formula over the other atoms.** Support and attack are not primitives; they are patterns in the formulas (`φₛ = ... ∧ t` is support from `t`, `φₛ = ... ∧ ¬t` is attack from `t`). This is why ADFs handle a requirements-vs-prohibitions split natively — but see §6 for the important caveat about *global* constraints.

**Interpretations.** Three-valued: `I : S → {0, 1, u}`. Information ordering `≤ᵢ` is the reflexive-transitive closure of `u <ᵢ 0`, `u <ᵢ 1`, lifted pointwise. `φ[I]` is partial evaluation (substitute every atom with a known Boolean value).

**Characteristic operator** (verbatim, same source):

> `Γ_D(I) = I'` where `I'(s) = 1` iff `⊨ φₛ[I]` (a 2-valued tautology), `I'(s) = 0` iff `⊨ ¬φₛ[I]` (a 2-valued contradiction), and `I'(s) = u` otherwise.

### 1.2 The link to AFT

This is the core of Strass & Wallner, *Analyzing the computational complexity of abstract dialectical frameworks via approximation fixpoint theory*, Artif. Intell. 226:34–74, 2015 (DOI 10.1016/j.artint.2015.05.003, **open access at the publisher**). Two distinct approximating operators exist and they are *not* interchangeable:

**(a) The "approximate" operator `G_Ξ`** (Strass, AIJ 205:39–70, 2013), verbatim:

> `G_Ξ(X,Y) = (G'_Ξ(X,Y), G'_Ξ(Y,X))`
> `G'_Ξ(X,Y) = {s ∈ S | ∃B ⊆ par(s), C_s(B) = t, B ⊆ X, (par(s) \ B) ∩ Y = ∅}`

**(b) The "ultimate" operator `U_Ξ`**, which is Denecker/Marek/Truszczyński's *ultimate approximation* (their Theorem 5.6) applied to the two-valued consequence operator `G_Ξ(X) = {s ∈ S | X ⊨ φₛ}`. Verbatim:

> `U'_Ξ(X,Y) = {s ∈ S | for all Z ⊆ S with X ⊆ Z ⊆ Y we have Z ⊨ φₛ}`
> `U''_Ξ(X,Y) = {s ∈ S | for some Z ⊆ S with X ⊆ Z ⊆ Y we have Z ⊨ φₛ}`

Strass & Wallner note that Brewka & Woltran had already defined `U_Ξ` independently in the 2010 KR paper; it is what generates the "ultimate" family of ADF semantics used by Brewka et al. (IJCAI 2013).

Operationally: `s` is in the **lower bound** iff `φₛ` partially evaluated against `(X,Y)` is *irrefutable* (a tautology → coNP check); `s` is in the **upper bound** iff it is *satisfiable* (→ NP check). That is the whole computational story of ADFs in one line.

### 1.3 Semantics as AFT fixpoint notions

This is the table the caller wants. Verbatim from Strass & Wallner Table 1 — "Operator-based semantical notions (and their argumentation names on the right) for a complete lattice `(L,⊑)` and an approximating operator `O : Lc → Lc` on the consistent CPO `(Lc, ≤ᵢ)`":

| AFT notion | Fixpoint condition | ADF/argumentation name |
| --- | --- | --- |
| Kripke–Kleene semantics | `lfp(O)` | grounded pair |
| conflict-free pair `(x,y)` | `x ⊑ O''(x,y)` and `O'(x,y) ⊑ y` | conflict-free pair |
| M-conflict-free pair `(x,y)` | `(x,y)` is `≤ᵢ`-maximal conflict-free | naive pair |
| admissible/reliable pair `(x,y)` | `(x,y) ≤ᵢ O(x,y)` | admissible pair |
| three-valued supported model `(x,y)` | `(x,y) = O(x,y)` | complete pair |
| M-supported model `(x,y)` | `(x,y)` is `≤ᵢ`-maximal admissible | preferred pair |
| two-valued supported model `(x,x)` | `(x,x) = O(x,x)` | model |
| two-valued stable model `(x,x)` | `x = lfp(O'(·, x))` | stable model |

Also verbatim from that table caption: *"any two-valued stable model is a two-valued supported model is a preferred pair is a complete pair is an admissible pair; furthermore the grounded pair is a complete pair."*

Note the **stable** row: `x = lfp(O'(·,x))`. That single line is the general AFT stable-fixpoint construction, and it is *literally the same line* that produces Gelfond–Lifschitz stable models in ASP (§2). This is the strongest single piece of evidence that ADFs and ASP are two instances of one machine.

Strass & Wallner also prove (Proposition 2.4) that **Brewka et al.'s tailor-made ADF stable-model definition coincides with Denecker et al.'s ultimate two-valued stable models.** So the argumentation-flavoured reduct definition and the AFT-flavoured `lfp` definition are the same thing.

**Dung AFs as a special case** — confirmed, verbatim: for an AF `F = (A,R)`, *"The associated ADF of F is given by `Ξ = (A, R, C)` with `φ_a = ⋀_{(b,a)∈R} ¬b` for `a ∈ A`."* Strass & Wallner's Proposition 2.2 then shows conflict-free sets of `F` and conflict-free pairs of `O ∈ {G_Ξ, U_Ξ}` correspond. So **Dung AF ⊂ ADF ⊂ AFT** is a confirmed chain, and an AF is just an ADF whose every acceptance condition is a conjunction of negative literals.

### 1.4 Complexity — verbatim tables

Notation: `Ver` = verify a given pair has semantics σ; `Exists` = a non-trivial σ-pair exists; `Cred`/`Skept` = credulous/skeptical reasoning. `-c` = complete. `D^P` = intersection of a language in NP and one in coNP (canonical problem SAT-UNSAT).

**Table 2 — general ADFs, approximate operator `G`:**

| Approximate (G), σ | Conflict-free | Naive | Admissible | Complete | Preferred | Grounded | Model | Stable model |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Ver | NP-c | D^P-c | coNP-c | D^P-c | Π₂^P-c | D^P-c | in P | in P |
| Exists | in P | in P | Σ₂^P-c | Σ₂^P-c | Σ₂^P-c | coNP-c | NP-c | NP-c |
| Cred | NP-c | NP-c | Σ₂^P-c | Σ₂^P-c | Σ₂^P-c | coNP-c | NP-c | NP-c |
| Skept | trivial | Π₂^P-c | trivial | coNP-c | Π₃^P-c | coNP-c | coNP-c | coNP-c |

**Table 2 (cont.) — general ADFs, ultimate operator `U`:**

| Ultimate (U), σ | Conflict-free | Naive | Admissible | Complete | Preferred | Grounded | Model | Stable model |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Ver | NP-c | D^P-c | coNP-c | D^P-c | Π₂^P-c | D^P-c | in P | coNP-c |
| Exists | NP-c | NP-c | Σ₂^P-c | Σ₂^P-c | Σ₂^P-c | coNP-c | NP-c | Σ₂^P-c |
| Cred | NP-c | NP-c | Σ₂^P-c | Σ₂^P-c | Σ₂^P-c | coNP-c | NP-c | Σ₂^P-c |
| Skept | trivial | Π₂^P-c | trivial | coNP-c | Π₃^P-c | coNP-c | coNP-c | Π₂^P-c |

**The approximate/ultimate distinction is not cosmetic.** For stable models, approximate `Ver` is *in P* and `Exists` is *NP-complete*, while ultimate `Ver` is *coNP-complete* and `Exists` is *Σ₂^P-complete*. Strass & Wallner say so explicitly: *"the complexity difference between the lower bound operators for approximate (in P) and ultimate (coNP-hard) semantics comes to bear."* If a source quotes "ADF stable models are Σ₂^P-complete" without saying which operator, it means the *ultimate* one (which is Brewka et al.'s, and is the one solvers implement).

**Table 3 — bipolar ADFs (BADFs), where every link is known to be supporting or attacking.** `I ∈ {BG, BU}`:

| I ∈ {BG,BU}, σ | Conflict-free | Naive | Admissible | Complete | Preferred | Grounded | Model | Stable model |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Ver | in P | in P | in P | in P | coNP-c | in P | in P | in P |
| Exists | in P | in P | NP-c | NP-c | NP-c | in P | NP-c | NP-c |
| Cred | in P | in P | NP-c | NP-c | NP-c | in P | NP-c | NP-c |
| Skept | trivial | coNP-c | trivial | in P | Π₂^P-c | in P | coNP-c | coNP-c |

**This is the most actionable result in the whole lane for us.** A requirements-vs-prohibitions model is *bipolar by construction* (a requirement is a support link, a prohibition is an attack link, and we know which is which). Bipolarity drops an entire level of the polynomial hierarchy off almost everything: grounded goes from coNP-c to **in P**, complete/admissible/preferred existence goes Σ₂^P → **NP**, stable-model verification goes coNP-c → **in P**. Strass & Wallner's own summary: *"for the corresponding reasoning tasks AFs and BADFs have (almost) the same complexity, with the single exception of skeptical reasoning among naive pairs. This suggests that many types of relations between arguments can be introduced without increasing the worst-time complexity."*

**Conversely**, their discussion states plainly: *"arbitrary (non-bipolar) ADFs cannot be compiled into equivalent Dung AFs in deterministic polynomial time, unless the polynomial hierarchy collapses to the first level. Under the same assumption, ADFs cannot be implemented directly with methods that are typically applied to AFs, for example answer-set programming."* Read carefully: general ADFs need a *disjunctive/saturation* ASP encoding or a SAT-with-oracle-calls approach, not a plain normal-program encoding. That is exactly what YADF and goDIAMOND do and why they are slower than the SAT-based k++adf.

### 1.5 What this means at our scale (58 atoms, 156 test cases)

**Everything in these tables is tractable for us.** Concretely:

- The BAss 2026 benchmark set is 1,237 ADF instances averaging **135 arguments** (median 80, max 1,076), with up to 923,346 links. Our 58 atoms is *below the median* of a standard benchmark suite that modern solvers clear in seconds.
- Σ₂^P-completeness at 58 atoms means, in the worst case, a search over 2^58 with an NP oracle. In practice SAT/ASP solvers on 58 Boolean variables with a two-level structure are effectively instantaneous. In the BAss results table, the 2-valued-model category was solved on 1,142/1,165 instances in a PAR2 score of **52 seconds**, and stable models on 1,149 in **36 seconds** — those averages are dominated by instances an order of magnitude larger than ours.
- The one thing that can still blow up at small atom counts is **enumeration**, not decision. BAss's contribution is precisely this: the number of complete/preferred interpretations can be astronomically larger than the atom count suggests (their Table 3 shows a 144-argument network with ~9.4×10²⁴ complete interpretations). If we plan to *enumerate* all complete or preferred interpretations of our 58-atom model rather than decide/check specific ones, we should expect solution-set explosion and should either (i) restrict to grounded + stable, or (ii) use a BDD-based tool that represents the solution set symbolically instead of enumerating it.
- **Recommendation at our scale: keep everything bipolar if we can, and prefer grounded + stable + 2-valued models over preferred.** Grounded is `in P` for BADFs and is the unique least-committed fixpoint — it is the natural "what is forced" answer. Preferred is the expensive one (Π₂^P-c skeptical even for BADFs, Π₃^P-c in general).

---

## 2. ASP as an AFT instance

### 2.1 The mapping

Confirmed as a canonical instantiation. Heyninck, Arieli & Bogaerts (arXiv:2211.17262v2) list the established instantiations verbatim: *"propositional logic programming, default logic, autoepistemic logic, abstract argumentation and abstract dialectical frameworks, hybrid MKNF, the graph description language SHACL, and active integrity constraints, each one of which was shown to be an instantiation of this abstract theory of approximation."*

The mapping for a normal logic program `P` over atoms `At`:

- The lattice is `L = 2^At` under `⊆`; the bilattice is `L² = 2^At × 2^At` under the precision order `≤ᵢ`.
- The two-valued operator is the immediate-consequence operator `T_P`.
- The approximator is Fitting's four-valued/three-valued operator `Ψ_P` (positive body literals read against the lower bound, negated body literals against the upper bound).
- Then, from Strass & Wallner's Table 1, *the same generic definitions* give: `lfp(Ψ_P)` = **Kripke–Kleene / Fitting model**; the `≤ᵢ`-least stable fixpoint = **well-founded model**; the exact (two-valued) stable fixpoints `x = lfp(Ψ'_P(·,x))` = **Gelfond–Lifschitz stable models / answer sets**; the exact fixpoints of `Ψ_P` = **supported models**.

The reduct-free characterisation `x = lfp(O'(·,x))` *is* the stable-model semantics; the GL reduct is one way of computing it. Vanbesien, Bruynooghe & Denecker (TPLP 2022, arXiv:2104.14789v5) make this explicit in their abstract: *"We introduce an AFT formalisation equivalent with the Gelfond-Lifschitz reduct for basic ASP programs and we extend it to handle aggregates."* That paper is the cleanest published statement of the ASP↔AFT correspondence *and* the extension past plain normal rules.

### 2.2 Is the caller's framing about choice rules right?

**The Horn half: yes, confirmed and uncontroversial.** `a :- b` is a definite rule. A definite (negation-free) program has a monotone `T_P`, hence a unique least model `lfp(T_P)`, hence exactly one answer set. There is no family of models and therefore nothing to be union-closed over. If we want alternatives, definite rules alone cannot produce them. That part of the framing is correct.

**The choice-rule half: right in spirit, but the union-closure claim needs a correction.** Two things I want to separate, because one is retrieved and one is my reasoning:

*Retrieved:* I found **no paper giving a dedicated AFT account of choice rules `{a} :- b.`** The two nearest published things are:
1. **Non-deterministic AFT** — Heyninck, Arieli & Bogaerts, arXiv:2211.17262v2, and Heyninck & Bogaerts, TPLP 2023, arXiv:2305.10846v1. This generalises AFT to operators *"whose ranges are sets of elements rather than single elements"*, motivated by disjunction. Verbatim from the 2022 paper: *"a non-deterministic operator assigns to every element x of L a (nonempty) set of choices."* The vocabulary is literally "choices". This is the right algebraic home for `{a} :- b.`, but the papers apply it to **disjunctive** logic programs (`a ∨ b :- c`), not to choice rules per se. The 2023 follow-up adds ultimate non-deterministic operators and aggregates.
2. **AFT for aggregate ASP** — Vanbesien/Bruynooghe/Denecker, TPLP 2022. A choice rule is a head-cardinality-aggregate special case, so this is the closest thing to a formal AFT treatment we have; but the paper is framed around body aggregates and does not single out choice rules.

*My reasoning, not retrieved — flagging it as such:* in practice `{a} :- b.` is semantically equivalent to the normal-program pair `a :- b, not a'. a' :- b, not a.` (an even negative loop), which is a *plain normal program*, so **ordinary two-valued AFT already covers choice rules**; you do not need non-deterministic AFT for them. Non-deterministic AFT is needed for genuine *disjunction*, which is strictly stronger (Σ₂^P vs NP). I am fairly confident of this equivalence but did not retrieve a source stating it in this session, so treat it as a claim to verify before we rely on it.

*A correction the caller should have:* **"choice rules give union-closed behaviour" is not automatic, and constraints actively break it.** A program of bare choice rules `{a}.` for every atom has as its answer sets the *entire* powerset, which is trivially union-closed. But an integrity constraint `:- a, b.` removes exactly the sets containing both — so `{a}` and `{b}` survive while `{a,b}` does not, and the family is no longer closed under union. That is the whole point of a prohibition: it is a *non*-union-closed cut. So the accurate framing is: **choice rules generate a union-closed candidate family; constraints are precisely the device that breaks union-closure.** If our design genuinely needs the answer-set family to stay union-closed, hard prohibitions expressed as constraints are the thing that will violate it, and we need to decide which property we actually want.

### 2.3 Complexity of ASP with choice rules + constraints

A normal program with choice rules and integrity constraints is, semantically, a **normal (non-disjunctive) program**. Standard results: deciding whether an answer set exists is **NP-complete**; brave/credulous consequence is **NP-complete**; cautious/skeptical consequence is **coNP-complete**. Adding integrity constraints does not change this (a constraint is a normal rule with a fresh atom). Adding *disjunction* would raise it to Σ₂^P/Π₂^P.

Cross-check against §1.4: normal ASP sits at NP/coNP — i.e. exactly where **bipolar ADFs** sit for the model/stable tasks, and **one level below general ADFs**. This is consistent with Strass & Wallner's remark that general ADFs cannot be encoded into plain ASP without a PH collapse.

At 58 atoms, NP-complete and coNP-complete are not meaningful obstacles. Clingo will solve these in milliseconds. **The complexity discussion should not drive our tool choice at this scale; maintenance status and modelling ergonomics should.**

---

## 3. Default logic and autoepistemic logic as AFT instances

Both are original instantiations, and historically they came *before* the ADF work — they are what AFT was built to unify.

Primary source: Denecker, Marek & Truszczyński, *Uniform semantic treatment of default and autoepistemic logics* (arXiv:cs/0002002, KR 2000; journal version Artif. Intell. 143(1):79–122, 2003). Companion: *Fixpoint 3-valued semantics for autoepistemic logic* (arXiv:cs/9901003, AAAI 1998).

**Honest limitation:** this PDF is two-column and `pdftotext -layout` interleaved the columns, mangling the formulas. I read it only at the level of section structure and theorem statements, and I am **not** going to reproduce its definitions. What I can state from the structure with confidence:

- The paper builds an operator `D_T` for a modal theory `T` (autoepistemic logic) and an operator `E_Δ` for a default theory `Δ`, on a lattice of possible-world structures / belief pairs ordered by knowledge.
- The same AFT fixpoint family is then read off each: a Kripke–Kleene fixpoint `KK(T)` / `KK(Δ)`, a well-founded fixpoint `WF(T)` / `WF(Δ)`, and the exact/stable fixpoints. Theorem 4.2 identifies fixpoints of `E_Δ` with **weak extensions**; Theorem 4.4 identifies fixpoints of the *stable* operator `E^st_Δ` with **Reiter extensions**; Theorem 4.6 establishes that `E^st_Δ` has a least fixpoint (the well-founded semantics of default logic).
- The AE side mirrors this: fixpoints of `D_T` give **expansions**, stable fixpoints give **extensions**, and the least stable fixpoint gives the well-founded semantics of AE logic.

**Why this matters for our generality question:** default logic's `(α : β / γ)` and AE logic's `Lφ` are *far* less structured than either ADF acceptance conditions or ASP rules, and AFT still handles them by the same three lines (Kripke–Kleene = lfp of the approximator; extensions = exact fixpoints; well-founded = least stable fixpoint). The framework is genuinely general. The price of that generality is that AFT itself gives you **no algorithms** — it gives you a semantics-generating recipe. Every runnable thing in this lane comes from *instantiating* AFT into a formalism that has solvers, not from AFT.

---

## 4. Dung argumentation frameworks via AFT

Covered above (§1.3). Confirmed, verbatim, from Strass & Wallner: an AF `F = (A,R)` maps to the ADF `Ξ = (A, R, C)` with `φ_a = ⋀_{(b,a)∈R} ¬b`, and their Proposition 2.2 proves the conflict-free correspondence in both directions. The AFT reading of AF semantics via the characteristic function `F_AF` (Dung's own) predates this and is the historical bridge; Strass (AIJ 2013) is the paper that puts AFs, ADFs and AFT into one picture.

For us this is mostly a sanity check rather than a target: **AFs are strictly weaker than what we need** (attack only, no support, no arbitrary formulas), so there is no reason to model in an AF when ADFs cost the same at bipolar restriction.

---

## 5. Tooling: what exists, and does it still build in 2026?

I checked repository liveness directly via the GitHub and Bitbucket REST APIs. **I distinguish *confirmed* (I read a commit/release date from an API) from *inferred* (I am reasoning from indirect evidence).** No tool below was actually built or run by me — repo liveness is not the same as "compiles on our machine".

### ASP

| Tool | Status | Evidence |
| --- | --- | --- |
| **clingo** (Potassco) | **CONFIRMED LIVE.** Last push **2026-08-04** (today). Latest release **v5.8.0, 2025-04-03**. 815 stars, not archived, C++. | GitHub API `potassco/clingo` |
| **clasp** (the solver clingo wraps) | **CONFIRMED LIVE.** Last push **2026-07-31**. 148 stars, not archived, C++. | GitHub API `potassco/clasp` |

Clingo is the only tool in this entire lane with a *this-week* commit. It has native choice rules, integrity constraints, aggregates, optimisation, incremental/multi-shot solving, and a first-class Python API (`clingo` on PyPI) for embedding.

### ADF solvers

| Tool | Backend | Status | Evidence |
| --- | --- | --- | --- |
| **BAss** (`sybila/biodivine-bass`) | BDD (Rust, `ruddy` BDD lib) | **CONFIRMED ALIVE BUT UNRELEASED.** Repo created 2025-11-07, last push **2026-02-16**, Rust, **0 stars, no releases at all**. | GitHub API |
| **adf-bdd** (`ellmau/adf-obdd`) | BDD (Rust) | **CONFIRMED semi-maintained.** Last push **2025-06-30**, 8 stars, not archived. BAss paper tested v0.3.1. | GitHub API |
| **k++adf** (`bitbucket.org/andreasniskanen/k-adf`) | SAT (C++) | **CONFIRMED STALE.** Last commit **2022-01-26**, message *"fix issues with newer gcc"*. Repo created 2018-07-06, still reachable (HTTP 200). BAss paper used "version 2021-03-31". | Bitbucket API |
| **YADF** (dbai.tuwien.ac.at) | ASP encodings → clingo | **CONFIRMED UNMAINTAINED.** Project page states version **0.1.1, released 2018-12-07**, Scala/JAR, *"tested using the rule decomposition tool lpopt and clingo (4.4.0)"*. Page went online Nov 2016. | direct page fetch |
| **goDIAMOND** | ASP encodings | **STATUS UNRESOLVED.** BAss tested "version 2.0.2". `dbai.tuwien.ac.at/proj/adf/godiamond/` → **404**. No canonical repo or project page found. | URL probing |
| **DIAMOND** (`diamond-adf.sourceforge.net`) | ASP → clingo (Python) | **PAGE LIVE, CLAIM STALE.** Page describes v2.0.0, Python ≥3.3.0, **clingo ≥4.3.0**, and asserts it is *"actively developed and maintained by the Intelligent Systems Group of Leipzig University"* — but that copy is undated and clingo 4.3.0 is from ~2014 while current clingo is 5.8.0. **I regard the maintenance claim as unreliable.** | direct page fetch |
| **QADF** | QBF encodings | Mentioned in Strass & Wallner's discussion; **not investigated**, no status checked. | — |

**Discrepancy I could not resolve:** the BAss 2026 paper reports testing "yadf (version 2.2)" and "goDiamond (version 2.0.2)", but the YADF project page advertises **0.1.1 (2018)**. Either there is a newer distribution I did not find, or the paper's version strings refer to something else. I flag this rather than guess.

### Performance, from the BAss 2026 evaluation

1,165 instances, 1,200s timeout, AMD EPYC 7713. Cells are (instances solved) / PAR2 score:

- **admissible:** BAss 695 / 991s · k++adf 298 / 1796s · yadf 201 / 1992s · goDiamond 170 / 2063s · adf-bdd N/A
- **complete:** BAss 974 / 404s · k++adf 883 / 602s · yadf 342 / 1732s · goDiamond 190 / 2023s
- **preferred:** k++adf 1081 / 181s · BAss 982 / 389s · goDiamond 215 / 1958s · yadf 65 / 2269s
- **2-valued:** BAss 1142 / 52s · k++adf 1116 / 102s · goDiamond 1130 / 74s
- **stable:** BAss 1149 / 36s · k++adf 1115 / 105s · goDiamond 202 / 2002s

Reading: **k++adf and BAss are the only two competitive ADF solvers.** YADF and goDIAMOND — the ASP-encoding-based ones — are an order of magnitude behind and, per §1.4, this is *structural*, not an implementation accident: general ADFs cannot be encoded into normal ASP without a PH collapse, so ASP-based ADF solvers must pay a saturation/disjunction penalty.

### Direct AFT implementations

**I found none.** There is no library that exposes AFT operators (`≤ᵢ` bilattices, approximators, stable revision) as a general programmable interface. AFT is used as a *proof technique* and a *semantics-design recipe*; every executable artefact is a solver for a specific instantiation. If we want to compute with an approximator directly, we would be writing it ourselves — which, at 58 atoms with 3-valued interpretations, is a completely reasonable thing to do (the operator is a few dozen lines; §7).

---

## 6. The specific question: which instance matches (a) closure, (b) kernel/interior, (c) hard prohibitions, (d) non-monotone validity?

**Verdict: the caller's guess is *half* right. ADFs win on (a), (b) and (d); they lose badly on (c), and (c) is the one that will hurt in practice.**

**(a) Closure operator — both, easily.** A closure operator is monotone, extensive, idempotent; it is `lfp` of a monotone operator. In ASP: a definite/Horn subprogram gives `lfp(T_P)` and that *is* the closure, computed by clingo in linear time. In ADFs: acceptance conditions that are positive (negation-free) formulas make `G_Ξ` monotone and the grounded interpretation *is* the closure. Dead heat, slight edge to ASP for directness.

**(b) Kernel / interior operator — ADFs, structurally, and this is the interesting one.** An interior operator is monotone, *contractive* (`k(x) ⊑ x`), idempotent — a greatest fixpoint, the dual of closure. AFT is unusually well-suited here because **an approximator is literally a pair `O = (O', O'')` where the lower component builds up and the upper component cuts down.** In the ADF instantiation this is explicit: `U'_Ξ` is the "for all `Z` between `X` and `Y`" (tautology / irrefutability) component and `U''_Ξ` is the "for some `Z`" (satisfiability) component. `U''` is exactly a contracting, interior-flavoured operator on the upper bound, and the AFT machinery runs them *jointly to a fixpoint*. If our system genuinely has both a closure and a kernel that must be simultaneously stable, **that is what a three-valued AFT approximator natively is**, and it is the single strongest argument for taking AFT seriously rather than just using ASP as a constraint solver. In ASP you can encode a kernel — compute the gfp as the lfp of the dual program — but you write two programs and hand-maintain the duality; the three-valued structure is not given to you.

**(c) Hard prohibitions — ASP wins decisively, and ADFs are genuinely awkward here.** This is the part of the guess I would push back on. **ADFs have no global constraint construct.** Every ADF condition is *per-node*: `φₛ` is a formula about `s`. There is no ADF analogue of `:- a, b.` — no way to say "no acceptable interpretation may have both `a` and `b`" without pushing that prohibition into `φ_a` and/or `φ_b` by hand, which (i) duplicates the constraint across nodes, (ii) changes the *identity* of the acceptance condition (so the same node means different things in different models), and (iii) can silently destroy bipolarity — the very property that bought us a whole level of the polynomial hierarchy in §1.4. ASP integrity constraints are first-class, global, non-invasive filters and they compose. For a requirements-vs-prohibitions model where prohibitions are *hard* and *cross-cutting*, this is not a small ergonomic difference; it is the difference between a model you can maintain and one you cannot.

**(d) Non-monotone validity predicate — both, natively.** ADF acceptance conditions are arbitrary propositional formulas, so non-monotonicity is free and unrestricted. ASP gets it via `not`. Genuine tie; the ADF version is more *direct* (you write the formula) while the ASP version is more *disciplined* (negation-as-failure has a well-understood stable semantics and clingo enforces it).

**Scorecard: ADFs 2.5, ASP 2.5 — but the tooling breaks the tie decisively toward ASP** (§5: clingo committed today; the best ADF solver is either 4 years stale or has zero releases).

**The synthesis I would actually propose:** model the *system* in ASP with clingo, because prohibitions and generate-and-test are what ASP is for; and keep the ADF/AFT reading as the **specification** — i.e. write down the approximator `(O', O'')` for our domain, prove the properties we want about its fixpoints using the Table-1 vocabulary, and use clingo as the execution engine for those fixpoints. Strass & Wallner's Table 1 is a *specification language for semantics*, and it is worth using as one even if we never run an ADF solver. If we later find we need a genuine simultaneous closure/kernel fixpoint that ASP cannot express cleanly, implementing the approximator directly (§7) is a small job at 58 atoms.

---

## 7. Is there any published application of AFT/ADFs to *composition of systems*?

**Short answer: not to system composition as we mean it, but the algebraic machinery for compositionality exists inside AFT and is the most under-exploited thing I found in this lane.**

What I found:

**(1) Operator splitting / algebraic modularity — the closest match.** Vennekens, Gilis & Denecker, *Splitting an operator: algebraic modularity results for logics with fixpoint semantics*, ACM Trans. Comput. Log. 7(4):765–797, 2006. This is a *purely algebraic* theory of when an operator (and hence a whole theory in any AFT-instantiated logic) can be decomposed into components whose fixpoints can be computed separately and recombined. That is compositionality, stated at the operator level, applicable to every AFT instance at once. Strass & Wallner explicitly flag applying it to argumentation as future work: *"we want to apply the general operator splitting results of Vennekens et al. to abstract argumentation and compare them to the stand-alone results obtained for AFs and ADFs."* Written 2015; I found no evidence it was ever carried out. **I confirmed this paper exists as a citation but did not retrieve its text** — see failures below.

**(2) Algebraic conditional independence — the modern successor.** arXiv:2412.13712, *An Algebraic Notion of Conditional Independence, and Its Application to Knowledge Representation* (2024). From the abstract, verbatim: *"the notion of conditional independence is studied in the algebraic framework of approximation fixpoint theory. This gives a language-independent account of conditional independence that can be straightforwardly applied to any logic with fixpoint semantics. It is shown how this notion allows to reduce global reasoning to parallel instances of local reasoning, leading to fixed-parameter tractability results."* **"Reduce global reasoning to parallel instances of local reasoning" is a compositionality theorem.** This is the single most relevant paper I found for a composition-of-systems agenda, and it is recent enough to still be open ground.

**(3) Applied-but-not-composition instantiations.** The AFT application list (from arXiv:2211.17262v2) is: logic programming, default logic, autoepistemic logic, abstract argumentation, ADFs, hybrid MKNF, **SHACL** (graph/data-shape validation — arXiv:2109.08285, *Fixpoint Semantics for Recursive SHACL*), and **active integrity constraints** (database repair). Plus **distributed autoepistemic logic applied to access control** (arXiv:2306.02774) — a distributed/multi-agent setting, which is adjacent to composition but is about distributing *knowledge*, not composing *systems*.

**(4) Interdisciplinary transfer, 2024–2026.** The ADF↔**Boolean Network** equivalence (Heyninck/Knorr/Leite LPNMR 2024; Azpeitia et al. arXiv:2407.06106) is a genuinely new result: 2-valued ADF models ↔ BN fixed points, preferred interpretations ↔ minimal trap spaces, admissible ↔ trap spaces, complete ↔ percolated trap spaces. This has pulled a whole systems-biology toolchain (bioLQM, aeon, mpbn, ts-conj, fASP, pyboolnet) into range for ADF problems, and is why BAss exists. **If our "composition" has any dynamical-system flavour, this correspondence means ADF semantics = BN attractor/trap-space analysis, and the biology tools become available to us.** Worth knowing.

**Bottom line for the caller:** nobody has published "AFT for composing systems". The ingredients (operator splitting 2006, algebraic conditional independence 2024) are sitting there unused for argumentation/ADFs. That is either an opportunity or a warning depending on our appetite — it means we would be doing the composition theory ourselves, not adopting it.

---

## What we should actually write it in

**Write it in ASP, targeting clingo — currently v5.8.0 (released 2025-04-03), with the repository `potassco/clingo` last committed 2026-08-04 (today) and `potassco/clasp` on 2026-07-31. Confirmed live via the GitHub API, 815 stars, C++, not archived, with a maintained Python API on PyPI.**

Reasons, in priority order:

1. **It is the only genuinely maintained tool in this space.** The best-performing dedicated ADF solver, k++adf, has its last commit on 2022-01-26. The most capable one, BAss, has zero releases and zero stars and was created in November 2025. YADF's own project page advertises version 0.1.1 from 2018 and requires clingo 4.4.0. goDIAMOND's URL 404s and I could not locate a repository. Betting a project on any of these means betting on unbuilt code.
2. **Hard prohibitions are first-class.** Integrity constraints `:- ...` are exactly requirement (c), they are global rather than per-node, and they compose without touching the rest of the model. ADFs have no equivalent construct and force every prohibition into some node's acceptance formula — which risks destroying bipolarity and with it the polynomial-hierarchy level that made ADFs cheap.
3. **Complexity is a non-issue at 58 atoms.** Normal ASP with choice rules and constraints is NP-complete (existence, brave) / coNP-complete (cautious). Our instance is smaller than the *median* of the standard ADF benchmark suite (median 80 arguments, mean 135). Nothing here is close to a limit.
4. **We do not forfeit the ADF/AFT route by choosing clingo.** YADF and goDIAMOND *are* ASP encodings of ADFs, so an ADF semantics is reachable from clingo if we want it. And the AFT vocabulary from Strass & Wallner's Table 1 remains available as our *specification* language regardless of engine.

**Concretely I would:**
- Model the domain in ASP: definite rules for the closure, choice rules `{a} :- b.` for the union-closed candidate family, integrity constraints `:- ...` for hard prohibitions, `not` for the non-monotone validity predicate.
- Drive it from Python via the `clingo` module, and run the 156 test cases as 156 solve calls (or one multi-shot incremental session — clingo's multi-shot API is designed for exactly this and will be far faster than 156 process spawns).
- **Keep the model bipolar.** Track for every dependency whether it is a support or an attack. This costs nothing to maintain and, if we ever move to an ADF engine, it is worth a full level of the polynomial hierarchy (Strass & Wallner Table 3: grounded and stable verification drop to **P**; admissible/complete/preferred existence drops Σ₂^P → **NP**).
- **Write down the approximator anyway.** Specify our `(O', O'')` pair explicitly and state which Table-1 fixpoint notion each of our intended answers is (grounded = `lfp(O)`; "forced" = grounded; "coherent alternatives" = stable, `x = lfp(O'(·,x))`). At 58 atoms, if we ever need to run the approximator directly rather than via ASP — particularly for the simultaneous closure/kernel behaviour in §6(b), which is the one thing ASP does not give us natively — it is a few dozen lines over a 3-valued vector, and it will be fast.
- **Avoid preferred semantics unless we need it.** It is the expensive one (Π₂^P-c skeptical even for bipolar ADFs, Π₃^P-c in general) and it is where solution-set explosion actually bites.

**Second choice, only if we decide we need native ADF semantics:** `k++adf` (SAT-based, best-in-class on preferred, but last commit 2022-01-26 — expect to fix build issues) with `BAss` (`github.com/sybila/biodivine-bass`, Rust, pushed 2026-02-16) as the modern-but-unproven alternative, chosen specifically if we need to *enumerate* very large solution sets, since BAss represents them symbolically as BDDs rather than enumerating.

---

## What I could not retrieve

**Blocked at the outset:** general web search was unavailable for this entire lane — the session's WebSearch budget (200/200) was exhausted before I made my first call. All discovery was therefore done through the arXiv API, Unpaywall, the GitHub and Bitbucket REST APIs, and direct URL probing. This means **my coverage of non-arXiv, non-DOI-indexed material is weak**, and any solver or paper that lives only on a personal or institutional web page could have been missed unless I guessed its URL.

**Primary sources I did not read directly (obtained secondhand, and labelled as such above):**
- **Brewka & Woltran, "Abstract Dialectical Frameworks", KR 2010** — the original ADF paper. Not fetched. The definition I quote is Pastva & Trinh's 2026 verbatim restatement, explicitly attributed to it. The `U_Ξ` operator attribution comes from Strass & Wallner.
- **Brewka, Strass, Ellmauthaler, Wallner & Woltran, "Abstract Dialectical Frameworks Revisited", IJCAI 2013** — the source of the standard ADF stable-model definition. Not fetched; I rely on Strass & Wallner's Proposition 2.4 (which I did read verbatim) for the claim that it coincides with ultimate two-valued stable models.
- **Brewka, Ellmauthaler, Strass, Wallner & Woltran, "Abstract Dialectical Frameworks. An Overview", FLAP 4(8), 2017** — the handbook chapter. Not fetched.
- **Linsbichler, Maratea, Niskanen, Wallner & Woltran, Artif. Intell. 307:103697, 2022** — the k++adf paper, with the subclass complexity analysis that underpins the SAT approach. **Confirmed open access** (publisher, plus repository copies at `hdl.handle.net/10138/341944` and `hdl.handle.net/11567/1103324`) but I did not fetch it; the Helsinki repository returned an Anubis "Access Denied" page and I ran out of budget before retrying the publisher copy. Everything I say about k++adf comes from the BAss paper's description and the Bitbucket API. **Its subclass complexity results are a real gap** — if the caller wants finer-grained tractable ADF fragments than "bipolar", that paper is where they are.
- **Vennekens, Gilis & Denecker, ACM TOCL 7(4):765–797, 2006** (operator splitting / algebraic modularity) — the most relevant paper to the composition question. **Confirmed to exist only as a bibliography entry** in Strass & Wallner; I did not retrieve its text or check its open-access status. My description of it is from its title and Strass & Wallner's one-sentence characterisation. **This should be lane 4's or a follow-up's first target.**
- **arXiv:2412.13712** (algebraic conditional independence) — I read only the arXiv abstract, not the paper.

**Retrieved but not cleanly readable:**
- **Denecker, Marek & Truszczyński, arXiv:cs/0002002** (default + autoepistemic logic as AFT instances) — downloaded and extracted, but it is two-column and `pdftotext -layout` interleaved the columns, destroying the formulas. **I read it at section-header and theorem-statement granularity only and deliberately did not reproduce its definitions.** Section 3 is where the definitions actually are. If we need the precise AE/default operators, this needs a re-fetch with proper column handling or page-image rendering. I did not do this because default and AE logic are background-generality questions for us rather than candidate implementation targets, and I judged the remaining budget better spent on the complexity table and solver status.

**Unresolved factual conflicts, stated rather than guessed:**
- **YADF version.** The BAss 2026 paper reports testing "yadf (version 2.2)"; the official TU Wien project page advertises **version 0.1.1, released 2018-12-07**. I could not reconcile these and did not find a second distribution point.
- **goDIAMOND.** BAss tested "version 2.0.2". `https://www.dbai.tuwien.ac.at/proj/adf/godiamond/` returns **404**; no GitHub repository matched my searches; no project page found. **I do not know where goDIAMOND lives or whether it is obtainable.**
- **DIAMOND maintenance.** `diamond-adf.sourceforge.net` asserts it is *"actively developed and maintained by the Intelligent Systems Group of Leipzig University"*, but the page carries no dates and specifies clingo ≥4.3.0 (circa 2014) against a current clingo of 5.8.0. **I treat the "actively maintained" claim as unverified and probably stale**, but I did not find a commit log to confirm either way — SourceForge's project API was not queried.
- **QADF** (QBF-based ADF solver, mentioned in Strass & Wallner's discussion) — not investigated at all. No status.

**Claims I am making from reasoning, not from a retrieved source** (repeated here so they are easy to audit):
- That `{a} :- b.` is semantically equivalent to `a :- b, not a'. a' :- b, not a.`, and therefore that ordinary two-valued AFT already covers choice rules without needing non-deterministic AFT. **I found no paper stating this in this session.** High confidence, but verify before relying on it.
- The correction that integrity constraints break union-closure of the answer-set family while bare choice rules preserve it. This is my own analysis of the caller's framing, not a retrieved result.
- The standard complexity figures for normal ASP with choice rules and constraints (NP-complete existence/brave, coNP-complete cautious) are from background knowledge, **not retrieved in this session**. They are textbook and I am confident, but I did not open a source for them, unlike the ADF table which is quoted verbatim.

**Not attempted:** I did not build or run any solver. All liveness statements are repository metadata, not "it compiles". ICCMA competition results past 2019 were not checked (the BAss benchmark set draws on ICCMA 2017 and 2019 only).
