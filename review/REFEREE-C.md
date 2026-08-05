# Referee C -- report on *An Algebra of Mechanism Composition*

**Remit:** significance, framing, and whether the paper earns its conclusions.
**Method:** read `paper/atlas.tex` in full twice (the manuscript was under active
revision during this review -- HEAD moved from `b6c32a3` to `f5bbd2a` between my
first and second pass; findings below are against `f5bbd2a`, current at time of
writing). Cross-checked against `corpus50/VERDICT.md`, `algebra/REQUIREMENTS.md`,
`papers/{composition,convex,order}/INVENTORY.md`, `paper/refs.bib`, and spot-verified
one collision claim (Jupiter/1inch) against `corpus50/lanes/lane2-*.json`. I also read
Referee A's and Referee B's reports to avoid duplication: A covers definitional
correctness, B covers numeric reproduction. Nothing below repeats their itemized
findings except where it bears on significance.

**Recommendation: major revision.**

**Answer to the question I was asked to prioritize (point 4):** with one exception,
the applied results are restatements of facts any working DeFi engineer already
knows, expressed in closure-operator notation. "Perp exchanges need a collateral
test, an oracle and a liquidation incentive, and these follow from having leveraged
positions rather than being independently chosen" is not news; it is close to
definitional. The one exception -- Uniswap composed with Aave arms exactly the
recorded prohibition `X2` (flash liquidity + AMM + lending) -- is a genuinely sharp,
concrete result, but its evidential value is undercut by an undisclosed risk: `X2`
is one of only two hand-written prohibition rows doing all the discriminating work
in the entire corpus (Measurement `meas:ablation58`), and the paper never states
whether `X2` was written before or independently of knowledge of flash-loan
manipulation attacks, or reverse-engineered to catch this exact case. If the latter,
recovering it is confirmation, not discovery. See Finding 4.

---

## Findings

### 1. The abstract and conclusion contradict the paper's own corrected body -- **major**

The abstract states "all eight perpetual venues derive the same three solvency
mechanisms rather than choosing them," and the Conclusion repeats it: "eight
perpetual venues agree to the symbol." But the body, as currently written
(`meas:perps`/`prop:perps` + the added `meas:jupiter`), says the category has
**seven** protocols, of which **six** agree on `{Ct,Ex,Li}` and the seventh -- Jupiter
Perpetual Exchange -- derives **none** of them, for a structurally explained reason
(oracle-priced pool vs. order-book microstructure), and the paper itself calls this
"more informative than a uniform claim would have been."

This is not a rounding error. The corrected body result (six agree, one is a
diagnostic exception) is a *better* and *more falsifiable* finding than "all eight
agree" -- it is the kind of result this whole remit is asking for, because the
exception does real work. But the two places a reader actually forms an opinion of
the paper (abstract, conclusion) still report the disproven, weaker, uniform version.
This looks like a revision artifact: the body was fixed in response to a referee
finding (Referee B: "seven perpetuals, not eight ... ACTIONED, and the exception is
now the result") but the propagation to the framing text was missed. Fix: rewrite
both passages to lead with the six-plus-exception structure; it is a stronger claim,
not a weaker one, so this is a free improvement, not a concession.

### 2. No related-work section exists in the manuscript, despite the comparison already being done -- **major**

`paper/refs.bib` has 19 entries. Exactly two are ever `\cite`d in the body
(`geiger1968`, `bkkr1969`, `schaefer1978`). Every other entry -- including
`dealfaro2001` (interface automata), `peytonjones2000`, `kondratiuk2021` (Marlowe vs.
ACTUS), `actus`, `jegou1993`, `salamonjeavons2008`, `chudnovsky2006`, `lovasz1972`,
`tarski1955`, `avron1996`, `edelman1980`, `edelmanjamison1985`, `caspardmonjardet2004`,
`isbell1958`, `edmondsfulkerson1970` -- is either named informally in a theorem title
("Blocker duality; Isbell 1958, Edmonds-Fulkerson 1970") with no `\cite`, or not
mentioned in the text at all. Grepping the current body for "interface", "assume",
"Marlowe", "ACTUS", "Peyton" returns nothing.

This matters because the task this paper is doing -- reformulating a compatibility
question as a clique problem and conjecturing perfection to get a tractability
result -- is a **named move** in the CSP literature (Jegou 1993; Salamon-Jeavons,
*Perfect Constraints Are Tractable*, CP 2008), and the paper's own commissioned
research already worked out a defensible position: the microstructure literature
puts a clique on the *assignment* graph (one clique = one solution), while this
paper puts a clique on the *solution-compatibility* graph (one clique = a
pairwise-composable family of solutions) -- a different object, and the transfer
claim survives scrutiny (`papers/composition/INVENTORY.md`, "HEADLINE FINDING").
**But none of this is in the paper.** As submitted, a reader has no way to
distinguish a disclosed transfer of a known technique from an undisclosed
rediscovery, and the paper reads as though the graph/clique/perfect-graph idea is its
own. The fix exists already, in a sister file, unused: cite it, in exactly the
two-part form the research already drafted.

The gap is worse for "Open problem 1" (is `Adm` a lattice under any order; is meet
intersection). Inigo Incer's PhD thesis (*The Algebra of Contracts*, 2022) computes a
complete lattice **with a computed meet = conjunction** for assume-guarantee
contracts -- the exact shape of structure this paper lists as open -- and the internal
research flagged that a reader who knows that thesis "will ask why the meet is not
computed the same way." Incer is not even in `refs.bib`. An open problem cannot be
asserted as open without checking the nearest published formalism that solves the
analogous question; right now the paper hasn't.

Financial-contract DSLs fare the same way. `refs.bib`'s own note on ACTUS is exactly
right ("Claims the vast majority of all financial contracts; NOT a completeness
result") -- someone on this project already knows not to cite ACTUS as completeness
precedent. That correct instinct never reaches the paper, because ACTUS is never
discussed there. Marlowe (`kondratiuk2021`) is the one directly on-point precedent
for "benchmark a financial vocabulary against a corpus and record what it can't
express" (their census-driven extension after benchmarking against ACTUS) -- this
paper is doing exactly that move and doesn't say so.

**Fix:** write an actual Related Work section (half a page suffices for each of the
four areas named in this review's brief) using the material that is already sitting,
fully drafted, in `papers/{composition,convex,order}/INVENTORY.md`. This is the
single highest-value, lowest-effort improvement available to the paper.

### 3. The headline theorems are immediate consequences of the setup; the real contribution is the negative/diagnostic layer, and the framing inverts the emphasis -- **major**

Once requirements/warrants are defined as clauses with exactly one negative literal
(dual-Horn) and prohibitions as purely negative (Horn), "the dual-Horn model classes
are union-closed and form a complete lattice; the Horn ones are not" is a one-line
application of the Pol-Inv Galois connection -- fifty-year-old constraint theory,
correctly cited, but not a new result at the level of "does this follow from the
setup." The paper is honest about this in isolated places ("A lattice says little
about any individual protocol") but the abstract leads with the theorem list as the
headline achievement, and the Conclusion's first paragraph ("Three things are
settled") repeats the pattern.

The parts of the paper that are *not* immediate, and that I would defend as genuine
contributions, are the negative/diagnostic results: the vacuity finding
(`meas:ablation58` -- the 79 positive clauses exclude **zero** elements across all 72
seeds; all discriminating power is two hand-written prohibitions), the tension result
(`meas:tradeoff` -- repairing the warrant relation to restore invariance makes the
operator reject 82% of deployed protocols and become anti-correlated with reality),
and the honest "Honest scale" remark conceding the convex-geometry structure is
"real but thin" and that its thinness is *the same fact* as the vacuity result. These
are the parts of the paper that could not have been guessed in advance and that cost
real corpus work to discover. The paper already half-knows this (Section 5's own
framing: "the more serious finding") but the front matter doesn't act on it.
**Recommendation: restructure the abstract and introduction to lead with the
vacuity/tension results, and present the lattice/convex-geometry machinery explicitly
as the scaffolding required to state them precisely, not as the headline.**

### 4. The applied results, examined one by one, mostly restate known facts -- **major** (this is the direct answer to point 4)

- **Perpetual venues derive `{Ct,Ex,Li}`.** That an order-book perpetual exchange
  requires a collateral check, a price oracle, and a liquidation incentive, and that
  these are consequences of running leveraged positions rather than independent
  design choices, is not information a DeFi practitioner lacks. It is close to
  constitutive of what "order-book perpetual exchange" *means*. The paper's own
  "Honest scale" remark undercuts the apparent depth further: the specialization
  digraph has 12 arcs on 58 vertices, so canonical forms are "exact but weak on most
  inputs" and the composition theorem "reduces to near-union in the common case." The
  Jupiter exception (Finding 1) is the one place this section earns its keep, because
  it is falsifiable and was not obviously true in advance from vocabulary alone -- the
  canonical form separated a microstructure distinction (order-book vs. oracle-priced
  pool) that the raw element sets did not surface. Keep that one; the six-way
  agreement claim underneath it is decoration.
- **Collateral test (`Ct`) is never primitive.** Same critique: "a collateral check is
  a consequence of collateralized lending, not an independent design choice" is true
  by construction of what collateralized lending is.
- **Canonical forms don't resolve the fibres (USDT/USD1 etc.).** This is a genuine,
  informative negative result -- it rules out a natural repair (maybe compression
  would disambiguate) and does so cleanly. Keep it.
- **Uniswap + Aave arms `X2`.** The one place the framework produces a result a
  practitioner would not already have stated in exactly this form: two protocols,
  individually admissible, jointly cover a hand-written five-element hazard clutter.
  But -- and this is the point the assignment most wants answered -- the corpus's own
  measurement (`meas:clutter`) reports only 20 prohibition rows total, of which only
  **one** (`X2`) is directly enforceable by membership, and (`meas:whereitfails`)
  every observed composition failure in the entire 1,830-pair sweep traces back to
  that handful of rows. Flash-loan price manipulation via AMM+lending composition is
  one of the best-known exploit patterns in DeFi history (predating this project by
  several years). The paper never discloses whether `X2` was authored independently
  of that knowledge or extracted from it after the fact. If the latter, `ex:uniaave`
  is confirmation that a rule catches the case it was built to catch, not discovery
  of a new risk. This is answerable -- state the provenance of the 20 prohibition
  rows and whether any were written with a specific historical incident in mind -- and
  it should be answered before this example is used as "the sharpest statement the
  framework produces."

### 5. The completeness claim is asserted, not made testable, from the paper alone -- **major**

The Introduction says: "coverage degrades systematically as more of a protocol's
substance lies off-chain, and the off-chain fraction is inversely correlated with
capital held." No number, no method, no citation accompanies this in the paper.

A rigorous, falsifiable completeness benchmark already exists --
`corpus50/VERDICT.md` -- three independently briefed lanes, rankings pulled live from
DefiLlama/rwa.xyz, explicit residue recording, and a blunt verdict: **"the vocabulary
is a good vocabulary of on-chain state machines and it is not a basis for DeFi. Not
one of the 69 protocols was fully expressible,"** with category coverage as low as
25% for intent systems and fiat-backed stablecoins. This is exactly the kind of
completeness statement the assignment brief asks whether the paper supports with a
testable definition -- and the answer is: a testable one exists, was already produced
by this project, and **is not in the paper**. `atlas.tex` should either inline the
coverage table or cite the document by name; as written, a reviewer cannot check the
completeness claim without leaving the manuscript.

Separately: `atlas.tex`'s applied corpus is stated as 72 protocols; `VERDICT.md`'s
completeness benchmark is 69. The paper should clarify the relationship (same base
corpus plus 3, or a disjoint validation set) -- if disjoint, that materially
strengthens the completeness argument and should be said explicitly; if the same
corpus the vocabulary was fit to, the completeness measurement is not an independent
test and the paper should say that too.

### 6. Citation practice is inconsistent -- **minor**

Where a bib entry exists, cite it. `tarski1955`, `avron1996`, `edelman1980`,
`edelmanjamison1985`, `caspardmonjardet2004`, `isbell1958`, `edmondsfulkerson1970` are
all in `refs.bib` and all are used only as plain-text names in theorem titles or
prose ("by Avron's representation theorem," "by Tarski's theorem"), never `\cite`d.
Trivial to fix; worth fixing, because a paper this dependent on attributed classical
results should not read as though it is guessing at citations.

### 7. What is missing (point 5) -- **major**

One section: **Related Work.** Not a stylistic nicety -- the paper makes an implicit
novelty claim (the clique/perfect-graph reformulation, presented as original) that it
cannot support without it, and an implicit completeness claim (Section "What this
document is not") that it cannot make testable without it. Both fixes already exist,
drafted, in this project's own supporting files. This is a half-day of writing, not a
new research program, and it is worth more to the paper's credibility than any single
additional theorem.

---

## Recommendation: major revision

The paper has real content: the vacuity finding and the trade-off between structural
invariance and empirical fidelity are honest, well-quantified, and not guessable in
advance, and the Jupiter/order-book-vs-pool exception and the Uniswap+Aave example
show the formalism can occasionally say something a raw element-set inventory
couldn't. But as submitted it oversells the lattice-theoretic machinery as its
headline contribution when that machinery is close to immediate from the polarity
setup; it presents a graph-clique-perfection conjecture without disclosing that the
same move is established CSP practice, despite its own commissioned research having
already drafted the honest version of that disclosure; its one sharpest applied
example carries an undisclosed circularity risk; its completeness claim is asserted
rather than made checkable even though a rigorous, checkable version of exactly that
claim already exists in a sibling document; and its abstract and conclusion currently
misstate its own best result in a direction that makes it *less* interesting than
what the body, correctly, now says. None of this requires new mathematics to fix. All
of it requires the authors to use material they have already produced.
