# Referee actions

## Referee A (order theory, proofs) - major revision, 39 findings

- **Gamma undefined but used in eight statements.** ACTIONED. Composition is now defined as the definite closure of the union, on the deterministic fragment, with the scope stated in the definition. Fix(Gamma) and Fix(Delta) replaced throughout by the model classes. The headline compositionality and non-compositionality results now concern the same operation.
- **Glyph collision: clause sets and model classes shared \mathcal{R}.** ACTIONED. Clause sets are now Req, Proh, War.
- **Sole obstruction claim refuted by our own prop:mixed.** ACTIONED in abstract, introduction and body.
- **thm:bilattice: Adm is not the diagonal, it is a subset.** ACTIONED.
- **meas:frag upper bound is |Adm| itself.** ACTIONED - stated as a witnessed lower bound with no non-trivial upper bound known.
- **lem:cm false as quoted for empty premise with |B|>=2.** ACTIONED - hypothesis B nonempty added.
- **thm:convex needs Cn(empty)=empty.** ACTIONED.
- **cor:lattice hides nonempty-consumer-set hypothesis.** ACTIONED.
- **thm:excomp acyclicity in the proof but not the statement, cited to the wrong result.** ACTIONED.
- **Corpus computations labelled Proposition.** ACTIONED - relabelled Measurement.
- OUTSTANDING: bibliography has three entries for about fifteen named theorems; no related work section.

## Referee B (reproduction) - major revision

- **prop:perps false: seven perpetuals, not eight; Jupiter Perpetual Exchange excluded from its own enumeration.** ACTIONED, and the exception is now the result. Six order-book venues drop the same three mechanisms; Jupiter, the only oracle-priced pool venue, drops nothing because it carries Pm and no Pf so no arc reaches them. The canonical form separates the two microstructures without being told about either.
- **prop:ct: Ct is primitive in three protocols.** ACTIONED - Jupiter Perps, CIAN and Kalshi named.
  Recorded ACTIONED before the manuscript was edited: atlas.tex still read "a primitive in none"
  at two sites and titled the measurement "never primitive" until the law-table commit. The
  three protocols were recomputed at that point and confirmed under the 29-row system.
- **Arc count contradiction, 13 versus 15.** ACTIONED - one figure, fifteen distinct arcs.
  This entry read "twelve" until audited. `node formal/v2/digraph.mjs` reports 16 arcs with
  multiplicity over the laws and 15 distinct; atlas.tex says 15 at four sites and "fifteen"
  at a fifth. The manuscript and the code agreed with each other and not with this log.
- **59 percent and 90.3 percent stated as each other.** ACTIONED.
- **meas:width has no producing code.** ACTIONED - downgraded to an explicitly indicative remark, and no inference depends on it.
- **Degenerate sampler affects specific figures.** ACTIONED - named in the provenance remark; the meet-violation count replaced by the rerun range.
- **Lean work claimed nowhere in the paper.** ACTIONED - a section now states what is formalised and, honestly, that the polarity lemma is immediate from its Lean definition.
- OUTSTANDING: meas:frag stored output terminates in an uncaught TypeError; the figure needs recomputation before it can stand.
- CONFIRMED by the referee and retained: the 179,864,061-pair enumeration is genuinely exhaustive and correctly labelled; the whole of the pairwise composition section reproduces exactly, including the Uniswap and Aave witness.

## Review loop cycle 1

- **Naked attributions (8).** ACTIONED. Cites added for Avron, Tarski (twice), Caspard-Monjardet, Edelman-Jamison, Edelman 1980, Isbell/Edmonds-Fulkerson, and Grotschel-Lovasz-Schrijver. The remaining grep hit is a false positive: Schaefer is named on one line and cited on the next. Bibliography is now 20 entries with zero bibtex warnings.

- **meas:frag outstanding major from Referee B.** ACTIONED by downgrade rather than repair. Its only stored output terminates in an uncaught TypeError, so the certification rate it reported is not reproducible. The measurement is now a conjecture asserting only a witnessed lower bound, with the rate explicitly not claimed. If the computation is repaired it can be promoted back.
  The bound recorded here was 11026 and is stale: conj:frag now witnesses $2^{22} = 4{,}194{,}304$
  by exhibiting twenty-two free elements whose every subset is admissible. The paper's bound is
  the larger one and the log was the smaller.

- Step 4, the honest question: meas:frag was the claim I could not have defended, which is why it was downgraded in the same turn rather than recorded as pending.

- **Referee A: no related work section.** ACTIONED. Four paragraphs covering interface theories, constraint satisfaction, financial contract formalisms, and what is absent from the literature.

## Clone-theory lane

- **thm:closure attributed the union/intersection characterisation to Geiger and BKKR.** ACTIONED. Neither states it - the words Horn, dual-Horn, union and max never appear in Geiger. The citable source is Jeavons-Cohen-Gyssens 1997 Example 5.3.5 p.541, now cited. BKW 2017 Thm 32 added as the modern Pol-Inv statement and as the open-access substitute for BKKR, which could not be obtained.
- **Positioning confirmed, not refuted.** Pol-Inv quantifies over languages and carries no cardinality-extremal content about subfamilies of a single family, so it does not settle the composable-fragment question. Stated explicitly in related work.
- **The combinatorial question is unnamed.** Zero hits across constraint satisfaction, lattice theory and the union-closed-families literature for maximum union-closed subfamily; the Frankl work concerns families already union-closed. Recorded as a contribution claim rather than a retrieval.
- Schaefer remark verified exact against p.222; no change needed.

## Referee C (significance) - major revision

- **Applied results largely restate what practitioners know.** ACCEPTED. The perpetuals result is close to definitional - nobody designs a perp DEX without a liquidation engine - and the paper no longer presents it as a discovery. Its value is that the canonical form separates order-book from oracle-pool microstructure without being told either exists, which is a statement about the method rather than about DeFi.
- **Uniswap+Aave circularity undisclosed.** ACTIONED, and this was the sharpest finding. X2 was recorded by authors who already knew the flash-loan pattern, so the example recovers a known hazard rather than discovering one. Now stated in a provenance remark, together with what the example does show: the decompositions were made protocol by protocol without reference to X2 or to each other, and the covering was computed rather than sought, so a hazard written as a condition on one system is recovered as a property of a pair.
- **Abstract and conclusion still claimed eight perpetual venues.** ACTIONED - framing text now matches the corrected body.
- **No related work section.** ACTIONED in the previous cycle.
- **Abstract inverts the emphasis.** ACTIONED - it now says the structural results are near-immediate from clause polarity and the substantive findings are diagnostic.
- **Completeness asserted without its number.** ACTIONED - the corpus figures are inlined: not one of 72 protocols fully expressible, coverage 25 to 73 percent by category.
- **Inconsistent citation.** ACTIONED in the previous cycle.

## Review loop cycle 2

- **Step 4: conj:perfect claimed falsifiability by a finite search at our scale.** Indefensible - |Adm| is of order 10^16. ACTIONED by strengthening rather than downgrading: the trace reduction is now a stated proposition, so the graph is a blow-up of a quotient on the trace space and perfection may be decided there, citing Lovasz replication for blow-ups. The accompanying measurement records that the quotient is currently complete, so perfection presently holds trivially - one enforceable prohibition row of five elements, and no union of sampled protocols covers it.
- Naked attributions: three grep hits, all false positives with the cite on the adjacent line. Verified by inspection.
- All majors from all three referees are actioned. "None outstanding" was written above two
  OUTSTANDING bullets in this same file and is withdrawn: Referee A's bibliography/related-work
  item is resolved, but Referee B's meas:frag recomputation stands open by the downgrade rather
  than by repair. A closing line that contradicts the entries above it is worth less than no
  closing line.

## Audit, 2026-08-22

Every ACTIONED claim above was checked against the manuscript rather than taken. Four entries
disagreed with the text they described:

- `prop:ct` was recorded ACTIONED while atlas.tex still said "a primitive in none" at two sites
  and titled the measurement "never primitive". Fixed in the manuscript.
- the arc count in this log said twelve where the code and the paper both say fifteen.
- the meas:frag bound in this log was stale by three orders of magnitude.
- the closing line contradicted the OUTSTANDING entries above it.

Two defects in the manuscript that no LaTeX pass can see were found in the same sweep and fixed:
`conj:frag` was cross-referenced as a Measurement twice, and two ties read
`Measurement~\nMeasurement~\ref{...}`, typesetting as "Measurement Measurement 7".
atlas.log reports zero undefined references in every case, because both halves are well formed.
`formal/v3/xref-kinds.py` now checks the first class across all 134 labelled environments.
