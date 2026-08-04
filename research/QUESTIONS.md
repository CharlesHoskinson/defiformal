# 15 open questions about the DeFi kernel / periodic-table concept

Generated from building the law engine and hitting its limits. Ordered by how
much the answer would change the visualisation.

## A. Questions the law engine just raised

1. **Only 25 of 77 law terms name an element — the other 52 are prose
   ("exit-liquidity", "a terminal loss path", "explicit finality assumption").
   Is a mechanism taxonomy that cannot express most of its own requirements in
   its own vocabulary actually closed?** If the answer is no, the Lock-Up can
   only ever test a quarter of what it claims to test.

2. **Three live protocols (Lido, CCTP, Centrifuge) fail law closure under the
   engine.** Are those genuine violations, incomplete element lists in the
   corpus, or laws stated too strongly? Each answer implies a different fix.

3. **Euler — the protocol whose whole narrative role is "every element correct,
   the table is blind to it" — does NOT close: it has `Up` without `Tg`.** Is
   the narrative wrong, or is the element list wrong? The best moment in the
   Lock-Up design depends on this.

4. **The reflexive loop is not in the law graph at all.** Cycle detection over
   the laws finds nothing for Terra; reflexivity lives only in hazard rule X1
   as prose. Should reflexivity be a *derived* property of the requirement
   graph (a cycle) rather than an asserted hazard?

5. **In-degree is nearly flat — the most-required element is required by 4
   laws, most by 0–2.** Is that a real property of DeFi, or an artifact of
   laws being written about categories rather than elements? "Weight"
   (size-by-in-degree) has almost no dynamic range to work with.

## B. Questions about the concept's foundations

6. Has anyone else built a **mechanism-level** (not protocol-level) taxonomy of
   DeFi, and did they hit the same "most requirements are prose" wall?

7. Is there prior art for **composition rules as a formal type system** — where
   a protocol is well-typed iff its requirement graph closes? Session types,
   linear types, and effect systems all look adjacent.

8. What does the academic literature on **financial primitives / contract
   algebras** (ACTUS, Findel, DAML, Marlowe) say about closure and
   composability? Marlowe in particular claims a small complete set.

9. Chemistry's periodic table predicted *undiscovered* elements from gaps. Does
   this table have any predictive gap structure at all, or is that analogy
   dead? What would a genuine "missing element" prediction look like here?

10. Is **stratum (S0–S4) derivable** from the requirement graph by topological
    rank, and where does the computed rank disagree with the hand-assigned
    depth? Disagreements are either errors in the atlas or evidence the axis is
    not what it claims.

## C. Questions about formal modelling

11. Can protocol composition be modelled as a **state machine whose invariants
    are the 29 laws**, such that a "pie" is a violated invariant and a hazard is
    a reachable bad state? That is exactly what Quint is for.

12. Would **model checking find hazard combinations nobody has written down** —
    reachable states that violate a safety property but are not among the 19
    hazard rules? That would turn the table from a record into an instrument.

13. Can the **reflexive loop be expressed as a temporal property** (a fairness
    or liveness violation) rather than as a hazard rule — something like "once
    collateral value depends on its own output, no fair execution restores the
    peg"?

14. What is the right formal treatment of the `|` alternatives — nondeterministic
    choice, refinement, or a lattice of legal configurations? This decides
    whether "Substitution Space" is a real object or a metaphor.

## D. Question about the visualisation itself

15. Is there any existing interactive artifact — in chemistry, biology,
    linguistics, or engineering — that successfully visualises **a constraint
    system over a vocabulary** (rather than a network or a hierarchy)? If a
    good precedent exists, it beats inventing one.
