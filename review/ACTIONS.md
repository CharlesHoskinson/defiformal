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
- **Arc count contradiction, 13 versus 15.** ACTIONED - one figure, twelve distinct arcs.
- **59 percent and 90.3 percent stated as each other.** ACTIONED.
- **meas:width has no producing code.** ACTIONED - downgraded to an explicitly indicative remark, and no inference depends on it.
- **Degenerate sampler affects specific figures.** ACTIONED - named in the provenance remark; the meet-violation count replaced by the rerun range.
- **Lean work claimed nowhere in the paper.** ACTIONED - a section now states what is formalised and, honestly, that the polarity lemma is immediate from its Lean definition.
- OUTSTANDING: meas:frag stored output terminates in an uncaught TypeError; the figure needs recomputation before it can stand.
- CONFIRMED by the referee and retained: the 179,864,061-pair enumeration is genuinely exhaustive and correctly labelled; the whole of the pairwise composition section reproduces exactly, including the Uniswap and Aave witness.

## Review loop cycle 1

- **Naked attributions (8).** ACTIONED. Cites added for Avron, Tarski (twice), Caspard-Monjardet, Edelman-Jamison, Edelman 1980, Isbell/Edmonds-Fulkerson, and Grotschel-Lovasz-Schrijver. The remaining grep hit is a false positive: Schaefer is named on one line and cited on the next. Bibliography is now 20 entries with zero bibtex warnings.

- **meas:frag outstanding major from Referee B.** ACTIONED by downgrade rather than repair. Its only stored output terminates in an uncaught TypeError, so the certification rate it reported is not reproducible. The measurement is now a conjecture asserting only the witnessed lower bound of 11026, with the rate explicitly not claimed. If the computation is repaired it can be promoted back.

- Step 4, the honest question: meas:frag was the claim I could not have defended, which is why it was downgraded in the same turn rather than recorded as pending.
