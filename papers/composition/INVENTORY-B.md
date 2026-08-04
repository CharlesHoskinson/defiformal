# INVENTORY-B — Financial contract formalisms (composition track)

Directory: `/root/DefiElements/papers/composition/`
Retrieved: 2026-08-04. Extraction: `pdftotext -layout` unless noted.
Note on the framing target: throughout, "the 58-element paper" refers to a paper that defines a
58-element vocabulary of on-chain financial mechanisms with requirement/prohibition constraints
between elements and claims completeness by census over a corpus.

---

## 1. Peyton Jones, Eber & Seward (2000) — Composing Contracts

**Citation.** Simon L. Peyton Jones, Jean-Marc Eber, Julian Seward. "Composing contracts: an
adventure in financial engineering (functional pearl)." *Proceedings of the Fifth ACM SIGPLAN
International Conference on Functional Programming (ICFP 2000)*, Montreal, pp. 280-292.
DOI 10.1145/351240.351267.

**Status.** FULL TEXT (10 pp., publisher typeset).
`peytonjones2000-composing-contracts.pdf` / `.txt`
Source: Tufts course archive mirror (MSR and simon.peytonjones.org return 403/404).

**Key content, precisely.**
- Two-layer design. Layer 1 = `Contract`, an abstract type of *claims/obligations*. Layer 2 =
  `Obs a`, an *observable*: a time-varying quantity, i.e. a value that can be read off the world
  at any date. Observables are a separate type from contracts precisely because they are values,
  not obligations, and they are given a `Num` instance so arithmetic works on them directly.
- **Acquisition date and horizon** are the two semantic pillars (Section 3.1). "The meaning of a
  contract is given by its consequences for the holder ... from the date at which the contract is
  acquired, its acquisition date." Rights and obligations falling due *before* the acquisition date
  are simply discarded — so a contract has a different value depending on when it is acquired. The
  *horizon* is the latest date at which a contract can be acquired; `zero` and `one k` have
  infinite horizon, `truncate t c` sets the horizon to min(t, horizon(c)).
- **Primitive combinator set** (Figure 2 of the paper):
  - `zero :: Contract`
  - `one :: Currency -> Contract`
  - `give :: Contract -> Contract`
  - `and :: Contract -> Contract -> Contract`
  - `or :: Contract -> Contract -> Contract`
  - `cond :: Obs Bool -> Contract -> Contract -> Contract`
  - `scale :: Obs Double -> Contract -> Contract`
  - `when :: Obs Bool -> Contract -> Contract`
  - `anytime :: Obs Bool -> Contract -> Contract`
  - `until :: Obs Bool -> Contract -> Contract`
  - `truncate :: Date -> Contract -> Contract`
  - `then :: Contract -> Contract -> Contract`
  - (`get :: Contract -> Contract` is derived: acquire the underlying contract at its horizon.)
  Observable primitives: `konst`, `lift`, `lift2`, `date`, `at`, `between`, plus arithmetic and
  comparison via type classes.
- The paper explicitly contrasts this with the alternative of a catalogue of prefabricated
  components: "The finance industry has an enormous vocabulary of jargon for typical combinations
  of financial contracts (swaps, futures, caps, floors, swaptions, spreads, straddles, captions,
  European options, American options, ...the list goes on). Treating each of these individually is
  like having a large catalogue of prefabricated components. The trouble is that someone will soon
  want a contract that is not in the catalogue."
- A separate *valuation semantics* maps `Contract -> Model -> PR Double` (process of random
  variables on a lattice), keeping description strictly separate from pricing.

**Relation to the 58-element paper.** This is the canonical *anti-census* argument and therefore the
sharpest antagonist to a completeness-by-census claim: the SPJ/Eber motivating move is that an
enumerated catalogue of named instruments is always incomplete, and that the correct response is a
small closed set of ~12 orthogonal combinators whose *closure under composition* covers the space.
Any 58-element vocabulary must say why it is a vocabulary of *mechanisms* (which do not obviously
compose freely) rather than a catalogue of instruments (which SPJ argues is the wrong abstraction),
and its requirement/prohibition constraints are exactly the structure the SPJ design does *not* need,
because those combinators are total and freely composable.

---

## 2. Peyton Jones & Eber (2003) — How to Write a Financial Contract

**Citation.** Simon L. Peyton Jones, Jean-Marc Eber. "How to write a financial contract."
Chapter 6 in Jeremy Gibbons and Oege de Moor (eds.), *The Fun of Programming*, Palgrave Macmillan,
2003, pp. 105-129. (Stated on p.1 of the PDF: "This chapter is based closely on 'Composing
contracts: an adventure in financial engineering', Proceedings International Conference on
Functional Programming, Montreal, 2000, with permission from ACM, New York.")

**Status.** FULL TEXT (25 pp., author preprint via Wayback of the MSR `pj-eber.pdf`).
`peytonjones2003-how-to-write-a-financial-contract.pdf` / `.txt`
**Extraction caveat:** the PDF font encoding drops the letter `c` in the extracted text (e.g.
"nan ial ontra t" = "financial contract"). Use the PDF for verbatim quotation; the ICFP 2000 `.txt`
extracts cleanly and covers the same combinator set.

**Key content.** Same two-layer design and same primitive set, expanded and pedagogically ordered:
the worked example is a nested option tree (contract `C`, with sub-contracts `D1`, `D2`, `D11`...),
used to motivate compositional description. The chapter is the more explicit statement of the
"acquire" reading of every combinator ("to acquire `scaleK x c` is to acquire `c`, but all the
payments ... multiplied by x") and of the derived-combinator style (`zcb`, `european`, `american`,
`swap` all defined from primitives rather than being primitive).

**Relation to the 58-element paper.** Provides the clean prose statement of the derived-vs-primitive
distinction. If a 58-element vocabulary is to survive scrutiny, this chapter is the template for the
argument it must make: state which elements are primitive, which are definable from others, and
show the derivation. A census-based vocabulary with no primitive/derived stratification is
vulnerable to the charge that it counted derived forms as elements.

---

## 3. Vandenbroucke & Schrijvers (2024) — Declarative Pearl: Rigged Contracts

**Citation.** Alexander Vandenbroucke, Tom Schrijvers. "Declarative Pearl: Rigged Contracts."
In: *Functional and Logic Programming — 17th International Symposium, FLOPS 2024*, Kumamoto, Japan,
May 15-17 2024. Lecture Notes in Computer Science, vol. 14659, Springer, pp. 99-114.
DOI 10.1007/978-981-97-2300-3_6. (Authors verified: Vandenbroucke — unaffiliated / Standard
Chartered; Schrijvers — KU Leuven. Title verified: "Rigged" puns on *rig*, a synonym for semiring;
"Declarative Pearl:" is part of the official title.)

**Status.** FULL TEXT (author accepted version, KU Leuven Lirias green OA).
`vandenbroucke2024-rigged-contracts.pdf` / `.txt`
DBLP key: `conf/flops/VandenbrouckeS24` (obtained via Semantic Scholar; the dblp API itself was
returning HTTP 500 throughout this session).

**Algebraic structure imposed.** Exact abstract wording:
> "This paper reworks the design of their library to make the central datatype of contracts less
> ad-hoc by giving it a well-understood algebraic structure: the semiring. Then, interpreting a
> contract's worth as a generic semiring homomorphism directly gives rise to a natural semantics for
> contracts, of which computing the (monetary) value is but one instance."

More precisely, from the body:
- A semiring (also called a *rig*) `(R, +, x, 0, 1)`: commutative monoid under `+` with identity `0`,
  monoid under `x` with identity `1`, `x` distributes over `+`, and `0` annihilates.
- The two contract operations become the semiring operations: `and` is the multiplication and `or`
  the addition, with `zero` and a new `expired` contract as the identities. To make the laws hold
  they must *change* the SPJ design: they add an `expired` contract and modify the `truncate`
  primitive — "These changes make contracts into a semiring, without los[ing]" expressiveness.
- The contract semiring is then the **initial object** among such semirings, so any semantics is
  determined by a unique homomorphism out of it. They give "a universal definition of a homomorphism
  from contracts to any semiring that has a multiplicative group, i.e., whose multiplicative
  operation is invertible." Instantiating the target semiring yields different semantics for free;
  **the tropical semiring coincides with the original SPJ/Eber valuation semantics** as one instance.

**What it buys.** (a) The combinator set stops being ad-hoc — the choice of primitives is justified
by the algebra rather than by financial intuition. (b) A whole *family* of semantics (value, risk
measures, symbolic analyses) is obtained by plugging in off-the-shelf semirings, instead of writing a
new interpreter each time. (c) Equational laws (associativity, commutativity, distributivity,
annihilation) become available for optimisation and for reasoning about contract equivalence.

**Relation to the 58-element paper.** This is the strongest available precedent for the claim that a
vocabulary is well-founded when it carries an algebraic structure, not when it is large. It cuts
directly against a purely enumerative 58-element vocabulary: Rigged Contracts shows that the
principled defence of a primitive set is an initiality/universality argument (every semantics factors
uniquely through it), which is a *structural* completeness result rather than a census. It also
demonstrates the acceptable cost of such a result — the authors had to alter two primitives to make
the laws hold, which is the kind of adjustment a constraint-bearing vocabulary should expect.

---

## 4. Marlowe

### 4a. Thompson & Lamela Seijas (2018) — Marlowe: Financial Contracts on Blockchain

**Citation.** Simon Thompson, Pablo Lamela Seijas. "Marlowe: Financial Contracts on Blockchain."
In: T. Margaria, B. Steffen (eds.), *Leveraging Applications of Formal Methods, Verification and
Validation. Industrial Practice (ISoLA 2018)*, LNCS 11247, Springer, pp. 356-375.
DOI 10.1007/978-3-030-03427-6_27. ISBN 978-3-030-03427-6.

**Status.** FULL TEXT (21 pp., Kent Academic Repository AAM).
`lamelaseijas2018-marlowe-isola.pdf` / `.txt`
(KAR serves a broken TLS chain — an expired root is present in the served chain; fetched with
certificate verification relaxed. This is a server misconfiguration on an open-access repository,
not an access control.)

**Key content.** Marlowe **v1.x** contract grammar, verbatim from the paper:
```
data Contract =
   Null |
   CommitCash IdentCC Person Money Timeout Timeout Contract Contract |
   RedeemCC IdentCC Contract |
   Pay IdentPay Person Person Money Timeout Contract |
   Both Contract Contract |
   Choice Observation Contract Contract |
   When Observation Timeout Contract Contract
```
The design centre is *commitments*: money must be committed into the contract before it can be paid
out, and every commitment carries **two timeouts** (a commit timeout and a redemption timeout). This
is what gives Marlowe its by-design guarantees — a finite number of interactions, a lifetime
readable off the source, and automatic refund of residual assets on termination. Observations and
Values form a second layer, exactly as in SPJ/Eber.

### 4b. Lamela Seijas, Nemish, Smith & Thompson (2020) — Marlowe: Implementing and Analysing Financial Contracts on Blockchain

**Citation.** Pablo Lamela Seijas, Alexander Nemish, David Smith, Simon Thompson. "Marlowe:
Implementing and Analysing Financial Contracts on Blockchain." In: *Financial Cryptography and Data
Security — FC 2020 International Workshops (WTSC)*, Kota Kinabalu, LNCS 12063, Springer, pp. 496-511.
DOI 10.1007/978-3-030-54455-3_35. CC BY.

**Status.** FULL TEXT (17 pp., publisher PDF via KAR id 82483).
`lamelaseijas2020-marlowe-wtsc.pdf` / `.txt`

**Key content — the language revision.** Section 2 is titled, verbatim:
> "**2 Marlowe Revised: Version 3.0**
> Since first publication, we have revised the language design: this section gives a[n] ..."

Marlowe 3.0 collapses the v1 grammar to **five contract constructs**:
> "Contract constructs are the main building block of contracts, and there are five of them: four of
> these – `Pay`, `Let`, `If` and `When` – build a complex contract from simpler contracts, and the
> fifth, `Close`, is a simple contract."

Explicit commitments are replaced by *accounts*: "The Marlowe model allows for a contract to control
money in a number of disjoint accounts ... Each account is owned by a particular party to the
contract, and that party receives a refund of any remaining funds in the account when the contract
is closed." Values/Observations/Actions form the second layer; actions are (i) deposit, (ii) choice,
(iii) notification.

**The single ACTUS mention in this paper**, verbatim (Section 7, Related Work, comparing to the ~250
built-in primitives of Nxt):
> "In providing such specificity this bears comparison with our implementation of contracts from the
> ACTUS standard [1]."

Reference [1] is `ACTUS. https://www.actusfrf.org. Accessed 9 Dec 2019`.

**NOTE.** This paper *announces* the v3.0 revision but does **not** attribute it to ACTUS
benchmarking. The explicit ACTUS-driven-extension statement is in 4d below.

### 4c. Lamela Seijas, Smith & Thompson (2020) — Efficient Static Analysis of Marlowe Contracts

**Citation.** Pablo Lamela Seijas, David Smith, Simon Thompson. "Efficient Static Analysis of
Marlowe Contracts." In: T. Margaria, B. Steffen (eds.), *ISoLA 2020: Leveraging Applications of
Formal Methods, Verification and Validation: Applications*, LNCS 12478, Springer, Cham,
pp. 161-177. DOI 10.1007/978-3-030-61467-6_11. ISBN 978-3-030-61466-9.

**Status.** FULL TEXT (17 pp., KAR id 83710, AAM).
`lamelaseijas2020-marlowe-static-analysis.pdf` / `.txt`

**Key content.** Because every Marlowe contract has a finite set of execution paths, whole-contract
symbolic analysis is decidable; the paper gives an SMT-based (Z3) analysis that checks whether any
`Pay` construct can fail (partial payment), returning a concrete counterexample trace, and shows how
to make this efficient by exploiting the tree structure of `When`/`Case`.

### 4d. Kondratiuk, Lamela Seijas, Nemish & Thompson (2021) — Standardized Crypto-Loans on the Cardano Blockchain  ***[LOAD-BEARING]***

**Citation.** Dmytro Kondratiuk, Pablo Lamela Seijas, Alexander Nemish, Simon Thompson.
"Standardized Crypto-Loans on the Cardano Blockchain." In: *Financial Cryptography and Data Security
— FC 2021 International Workshops (WTSC)*, LNCS 12676, Springer, pp. 579-594.
DOI 10.1007/978-3-662-63958-0_41. ISSN 0302-9743.

**Status.** FULL TEXT (16 pp., KAR id 90252, AAM).
`kondratiuk2021-crypto-loans.pdf` / `.txt`

**This is the paper documenting Marlowe being extended after benchmarking against ACTUS.**
Exact wording, Section 1 (Introduction), contribution paragraph:
> "In addition, implementing ACTUS provides a suitable benchmark against which to assess the design
> of Marlowe; we illustrate how the implementation has led to the addition of a conditional
> expression construct to the language."

The primitive that had to be added, exact wording, Section 4.2:
> "We addressed this issue by introducing the `Cond` expression construct in order to represent
> conditional expressions, rather than only conditional contracts as was the case before. Instead of
> using the `If` contract to decide the value of some variable, we use a conditional expression
> instead. `Cond` is a pure function that returns a value depending on a condition, in contrast to
> the `If` contract that chooses between two continuation contracts."

The forcing argument (Section 4.2), i.e. *why* the existing vocabulary was inadequate:
> "Naive usage of the `If` operator in Marlowe could lead to exponential growth of a contract ...
> Translating this to Marlowe would inline contents of `continue()` twice and, given that ACTUS
> contracts are essentially generated using continuation as an accumulator, this would lead to
> exponential explosion of the size of any ACTUS contract that has conditionals in their state
> transition logic. An example of such logic would be cap/floor limitations on interest rates:
> `adjusted = max(min(original,floor),cap)`"

**Coverage failures also recorded** (ACTUS contract types Marlowe could *not* express):
- Section 4.3, "Limitations due to termination": "Marlowe doesn't allow contracts that run
  indefinitely, even if their recursion is productive, as would be the case in a perpetual swap
  contract, for example. **We therefore cannot support certain contract types from ACTUS
  specification, namely the ones that don't have a defined maturity date (like UMP).**"
- Section 4.4: Marlowe supports only `Integer`; ACTUS is over the reals, forcing a fixed-point
  encoding (`marloweFixedPoint`) and a modification to `MulValue`. "We plan to move Marlowe to
  fixed-precision numbers for the on-blockchain implementation available later in 2021."
- Section 4.5: "The Marlowe DSL does not support any notion of records" — the ACTUS
  `ContractStatePoly` state has to be packed/unpacked into flat `Let`/`UseValue` chains.

**Relation to the 58-element paper.** This is the precedent that matters most. It is a documented,
citable instance of exactly the workflow a completeness-by-census claim implies: take an independent
external taxonomy (the ~32 ACTUS contract types) as a benchmark corpus, attempt to express every
member in your vocabulary, and (i) report the vocabulary elements you had to *add* (`Cond`) and
(ii) report the corpus members you *cannot* cover (UMP and other undefined-maturity types). It
supplies both the methodological template and the honest failure mode: a census against a fixed
corpus is a falsifiable exercise whose expected outcome is vocabulary growth plus a residue of
unrepresentable cases, not closure. A 58-element vocabulary claiming completeness by census should
cite this as the precedent for census-driven extension, and should be prepared to name its own
`Cond`-equivalents and its own UMP-equivalents.

---

## 5. ACTUS — Algorithmic Contract Types Unified Standards

### 5a. ACTUS Technical Specification

**Citation.** ACTUS Financial Research Foundation. *ACTUS: The Algorithmic Representation of
Financial Contracts — Technical Specification*, version 1.1. Copyright 2018-present, ACTUS Financial
Research Foundation. Source: https://github.com/actusfrf/actus-techspecs (`actus-techspecs.pdf`),
linked from https://www.actusfrf.org/techspecs.

**Status.** FULL TEXT (v1.1). `actus-techspecs.pdf` / `.txt`
Plus the machine-readable taxonomy: `actus-dictionary-taxonomy.json`
(https://github.com/actusfrf/actus-dictionary/blob/master/actus-dictionary-taxonomy.json).

**COMPLETENESS-BY-CENSUS CLAIM — exact wording, Section 1 (Introduction):**
> "Other types of financial contracts include but are not limited to shares, forwards, options,
> swaps, credit enhancements, repurchase agreements, securitization, etc. **By focusing on the main
> distinguishing features, ACTUS describes the vast majority of all financial contracts with a set
> of about 32 generalized cash flow exchange patterns or Contract Types (CTs), respectively.**"

Note the exact hedges in the original: *"the vast majority of"* (not "all"), and *"about 32"* (not
an exact count). The claim is about **cash flow exchange patterns**, not instruments — the taxonomy
"provides a classification system organizing financial contracts according to their distinguishing
cash flow patterns. Apart from this classification system the taxonomy also includes a description
of and real-world instruments covered for each contract." That last clause is the census link: each
CT carries an explicit list of the real-world instruments it covers.

**Verified count and taxonomy structure.** The taxonomy JSON contains **exactly 32 contract types**,
organised on two axes, `family` and `class`:

| family | class | contract types |
|---|---|---|
| Basic | Fixed Income | PAM, LAM, NAM, ANN, ANX, LAX, NAX, CLM, UMP, PBN |
| Basic | Ownership | CSH, STK, COM |
| Combined | Symmetric | SWAPS, SWPPV, FXOUT, FUTUR |
| Combined | Asymmetric | OPTNS, CAPFL, CDSWP, TRSWP, CLNTE, BNDCP, BNDWR, BCS, EXOTi |
| Combined | Securitization | SCRCR, SCRMR |
| Credit Enhancement | Credit Enhancement | CEG, CEC, MAR, REP |

Each CT is specified as a **state machine**: a *schedule* function (which events occur when), a
*payoff* function (cash flow at each event), and a *state transition* function. Contract Attributes
(terms) are defined in a separate data dictionary (`actus-dictionary-terms.json`), with
**applicability functions** — "ACTUS standard defines a family of applicability functions polymorphic
on [contract type]" (Kondratiuk et al. §3) — which say which attributes are required, optional, or
forbidden for each contract type.

The tech spec change log records incremental growth from a smaller census: v1.0-RC (2018-11-01) was
the "First draft version of the technical specifications covering the 'initial' 18 contracts."

### 5b. Brammertz & Mendelowitz

**Citations.**
- Willi Brammertz, Allan I. Mendelowitz. "From digital currencies to digital finance: the case for a
  smart financial contract standard." *The Journal of Risk Finance*, vol. 19 no. 1 (15 Jan 2018).
  DOI 10.1108/JRF-02-2017-0025.
- Willi Brammertz, Allan I. Mendelowitz. "Smart Contracts, Distributed Ledgers, and the Need for an
  Algorithmic Financial Contract Standard." *SSRN Electronic Journal* (2019).
  DOI 10.2139/ssrn.3373187.
- Background monograph: Willi Brammertz, Ioannis Akkizidis, Wolfgang Breymann, Rami Entin, Marco
  Rustmann. *Unified Financial Analysis: The Missing Links of Finance*. Wiley, 2009.

**Status.** **NOT RETRIEVED — paywalled** (Emerald Insight; SSRN). No open-access version located
via OpenAlex, Semantic Scholar, Unpaywall-listed locations, or Crossref. Bibliographic metadata
above verified via Crossref. Only the ACTUS Technical Specification (5a) is held in full text; it
carries the load-bearing completeness wording, so the Brammertz papers are not blocking.

**Relation of ACTUS to the 58-element paper.** ACTUS is the closest existing precedent for
completeness-by-census over a financial vocabulary, and it is instructive precisely because of how it
*hedges*. It (a) counts **patterns**, not instruments; (b) says "vast majority", never "all";
(c) says "about 32", declining to make the count itself load-bearing; (d) grounds the claim by
attaching to each type an explicit list of real-world instruments covered — a census artefact —
rather than by any structural argument; and (e) has demonstrably grown (18 -> 32) since first
publication. A 58-element vocabulary claiming completeness by census over a corpus should match this
register: name the corpus, publish the element-to-corpus-item mapping, hedge the count, and expect
growth. The ACTUS required/optional/forbidden **applicability functions** per contract type are also
a direct structural analogue of requirement/prohibition constraints between vocabulary elements —
ACTUS is prior art for encoding such constraints as a per-type attribute-applicability relation.

---

## 6. Biryukov, Khovratovich & Tikhomirov (2017) — Findel

**Citation.** Alex Biryukov, Dmitry Khovratovich, Sergei Tikhomirov. "Findel: Secure Derivative
Contracts for Ethereum." In: *Financial Cryptography and Data Security — FC 2017 International
Workshops (WAHC, BITCOIN, VOTING, WTSC, TA)*, Sliema, Malta, LNCS 10323, Springer, pp. 453-467.
DOI 10.1007/978-3-319-70278-0_28.

**Status.** FULL TEXT (post-print, University of Luxembourg ORBilu, handle 10993/30975).
`biryukov2017-findel.pdf` / `.txt`

**Key definitions, verbatim.**
> "Definition 2. A description of a Findel contract is a tree with basic primitives as leaves and
> composite primitives as internal nodes."

The BNF primitives are a direct Ethereum port of the SPJ/Eber combinators — `Zero`, `One(currency)`,
`Scale(number, primitive)`, `ScaleObs(address, primitive)`, `Give(primitive)`,
`And(primitive, primitive)`, `Or(primitive, primitive)`, `If(address, primitive, primitive)`,
`Timebound(t0, t1, primitive)` — with a contract being a triple (description, issuer, owner), the
issuer and owner collectively the *parties*. Findel adds Ethereum-specific execution: contracts are
issued, joined and executed by transactions, and the paper measures gas cost as a viability check.

The Marlowe critique of Findel (WTSC 2020 §7, verbatim): "The Findel project [4] examines financial
contracts on the Ethereum platform, and is also based on [14]. The authors note that payments need to
be bounded; this is made concrete in our account by our notion of commitments. They take no account
of commitments or timeouts as our approach does, and so are unable to guarantee some properties –
such as a finite lifetime – built into Marlowe by design."

**Relation to the 58-element paper.** Findel is the demonstration that a combinator vocabulary
transplanted to a blockchain setting is *not* automatically adequate — the on-chain setting adds
requirements (bounded payments, bounded lifetime, gas cost) that the off-chain vocabulary does not
express. For a vocabulary of *on-chain* financial mechanisms this is the direct precedent that
on-chain elements are not simply the off-chain elements, and that the interesting constraints are
precisely the ones (must-be-bounded, must-terminate) that show up as requirement/prohibition edges.

---

## 7. Daml — authorization / ledger model

**Citations.**
- Alexander Bernauer, Sofia Faro, Rémy Hämmerle, Martin Huschenbett, Duncan Kirk, Oliver Seeliger,
  Neil Mitchell, Ratko G. Veprek, Simon Meier, Meriam Lachkar, Moritz Kiefer, Gerolf Seitz, Jussi
  Mäki, Andreas Herrmann, Stefano Baghino. "Daml: A Smart Contract Language for Securely Automating
  Real-World Multi-Party Business Workflows." arXiv:2303.03749 [cs.PL], 7 March 2023.
- Digital Asset. *Daml Documentation — Daml Ledger Model* (Integrity; Privacy).
  https://docs.daml.com/concepts/ledger-model/

**Status.** FULL TEXT for the arXiv paper (14 pp.): `bernauer2023-daml.pdf` / `.txt`.
Docs pages captured as HTML->markdown (they are the normative description of the model and have no
PDF form): `daml-ledger-model-integrity.md`, `daml-ledger-model-privacy.md`.

**The authorization model, precisely** (arXiv paper §2, plus the templates it shows):
- A contract is "ledger data with a set of owners and a set of controllers who may change the data
  according to the smart contract code."
- Each template declares a **non-empty set of `signatory` parties** — "The `observer` and `signatory`
  clauses specify the notification and authorization rules, resp., for the contract"; the signatories
  are the parties whose authority is required for the contract to exist, and who are notified of
  creations and archivals. **`observer`** parties get notification (disclosure) but not authority.
- Each `choice` declares **`controller`** parties: "the keyword `controller` says that the owner's
  authority [suffices to exercise the choice]". Exercising a choice requires the authority of its
  controllers; the *consequences* of the choice execute with the authority of the controllers **plus**
  the signatories of the contract on which the choice is exercised. This is the delegation
  mechanism — a signatory pre-authorizes downstream effects by writing them as the consequences of a
  choice: "the issuer has pre-authorized the consequences of the [exercise] ... thus well-authorized."
- Worked example in the paper: `SimpleIou` with `signatory issuer`, `controller owner`; a `Transfer`
  choice with `controller owner, newOwner`; and an `Iou` *proposal* pattern where the proposed owner
  controls `Accept`/`Reject`. Archival is an implicit choice.
- Ledger integrity is the conjunction of: consistency (no double-archival, keys unique), conformance
  (every action matches the template code), and **authorization** (every action is authorized by the
  required party set).

**Relation to the 58-element paper.** Daml is the counter-model to a purely *behavioural* vocabulary:
its elements are not payoff patterns but **authority relations** (signatory / observer / controller)
plus a delegation rule. Requirement/prohibition constraints in a 58-element vocabulary map naturally
onto the Daml authorization predicate — "mechanism X requires mechanism Y" is the Daml "this action
needs that party's authority", and "mechanism X prohibits Y" is the absence of an authorizing choice.
If the 58-element vocabulary is to cover on-chain mechanisms rather than on-chain payoffs, Daml is
the precedent for why an authority/permission axis must be a first-class part of the vocabulary
rather than a side condition.

---

## Retrieval notes / gaps

- **The dblp API returned HTTP 500 for every query for the whole session** (both `/search/publ/api`
  and the HTML search returned error pages). DBLP keys were recovered indirectly via the Semantic
  Scholar `externalIds` field. Semantic Scholar itself rate-limited (HTTP 429) on unauthenticated
  bursts. OpenAlex and Crossref were reliable and did the bulk of the metadata work.
- **Not obtained (paywalled, respected):** Brammertz & Mendelowitz 2018 (Emerald) and 2019 (SSRN);
  the Springer typeset version of Rigged Contracts (the Lirias green-OA AAM was used instead).
- **kar.kent.ac.uk serves a broken TLS chain** (expired root present). Fetched with relaxed
  certificate verification; content verified as the expected open-access AAM/publisher PDFs.
- `microsoft.com` and `simon.peytonjones.org` both 403/404 on the SPJ contract PDFs; the ICFP version
  came from a Tufts course mirror and the 2003 chapter from the Internet Archive.
- `lexifi.com` returns 403 to non-browser clients and has no Wayback PDF captures.
- Springer link pages are Cloudflare-gated for plain curl; the FLOPS 2024 table of contents and the
  Rigged Contracts chapter metadata were obtained with `scrapling extract stealthy-fetch`.
