// mandate.qnt -- stage-4: the bounded delegate mandate, and what it costs.
//
// The mandate is the run's most-converged residue group: a named agent may move a
// quantity inside an envelope. It has a fixed five-part shape:
//
//     named agent -> domain whitelist -> magnitude cap -> rate-of-change limit or delay
//                 -> revocation
//
// Two encodings are compared, and the comparison IS the result.
//
//   PRESENCE encoding  -- each part is an atom; the row is one dual-Horn requirement
//                         over the element sort. Union-closed. Free on thm:closure.
//   MAGNITUDE encoding -- the cap is a number the protocol must respect. NOT union-closed:
//                         two protocols each inside a cap compose to one that is not.
//
// The second is exhibited as a counterexample, so the price of putting numbers in the
// carrier is a witnessed fact rather than an assertion.

module mandate {
  type Elem = str
  type Proto = Set[Elem]

  // ---------------------------------------------------------------- presence encoding

  // The five parts, as atoms of an enlarged element sort.
  pure val AGENT  = Set("agent")                      // a named party may write
  pure val DOMAIN = Set("whitelist", "enumerated")    // what it may write to
  pure val CAP    = Set("floorCeiling", "shareCap")   // how far
  pure val RATE   = Set("stepLimit", "cooldown", "tokenBucket", "slope")  // how fast
  pure val REVOKE = Set("revocable", "guardianVeto", "timelockCancel")    // who can stop it

  /// The mandate row: `Md -> AGENT + DOMAIN + CAP + RATE + REVOKE`.
  /// One negative literal (`Md`), five positive disjunctive terms: dual-Horn, exactly the
  /// shape of every existing requirement in the atlas.
  pure def satMandate(X: Proto): bool =
    not(X.contains("Md")) or (
      AGENT.intersect(X)  != Set() and
      DOMAIN.intersect(X) != Set() and
      CAP.intersect(X)    != Set() and
      RATE.intersect(X)   != Set() and
      REVOKE.intersect(X) != Set()
    )

  /// How much of the envelope a protocol actually closes. The stage-3 residue answers
  /// this per protocol, and the answer is set-valued -- which is why the presence
  /// encoding is enough to carry the finding.
  pure def envelopeParts(X: Proto): int =
    (if (AGENT.intersect(X)  != Set()) 1 else 0) +
    (if (DOMAIN.intersect(X) != Set()) 1 else 0) +
    (if (CAP.intersect(X)    != Set()) 1 else 0) +
    (if (RATE.intersect(X)   != Set()) 1 else 0) +
    (if (REVOKE.intersect(X) != Set()) 1 else 0)

  // Three real shapes from the corpus, written in the atoms above.
  pure val SPARK = Set("Md", "agent", "enumerated", "floorCeiling", "cooldown")  // 4 of 5
  pure val CIAN  = Set("Md", "agent", "whitelist", "shareCap")                   // 3 of 5
  pure val JUP   = Set("Md", "agent")                                            // 1 of 5

  // ---------------------------------------------------------------- magnitude encoding

  // The same mandate with the cap as a number: the agent's holding may not exceed `capBP`
  // basis points of the whole. This is what a repair that "puts the numbers in" must say.
  type QProto = { elems: Set[Elem], allocBP: int }
  pure val capBP: int = 5000

  pure def satMagnitude(P: QProto): bool =
    not(P.elems.contains("Md")) or P.allocBP <= capBP

  // Composition is union on the element sort and addition on the magnitude -- the only
  // reading under which the composite describes both parties' exposure.
  pure def compose(P: QProto, Q: QProto): QProto =
    { elems: P.elems.union(Q.elems), allocBP: P.allocBP + Q.allocBP }

  // ---------------------------------------------------------------- the two results

  /// PRESENCE: union-closed, exhaustively over a 12-atom universe.
  /// This is thm:closure applied to the new row; nothing in the theory moves.
  pure val UNIV: Set[Elem] =
    Set("Md","agent","whitelist","enumerated","floorCeiling","shareCap",
        "stepLimit","cooldown","tokenBucket","slope","revocable","guardianVeto")

  run presenceUnionClosedTest = all {
    assert(UNIV.powerset().forall(X =>
             UNIV.powerset().forall(Y =>
               (satMandate(X) and satMandate(Y)) implies satMandate(X.union(Y))))),
    assert(satMandate(Set())),                    // the empty protocol satisfies it
    assert(envelopeParts(SPARK) == 4),
    assert(envelopeParts(CIAN) == 3),
    assert(envelopeParts(JUP) == 1),
    assert(not(satMandate(SPARK))),               // no revocation part: row unsatisfied
    assert(not(satMandate(JUP)))
  }

  /// MAGNITUDE: NOT union-closed. Two mandates each at 30% of the whole are each inside a
  /// 50% cap; the composite is at 60% and is not. The witness is explicit.
  pure val A: QProto = { elems: Set("Md","agent"), allocBP: 3000 }
  pure val B: QProto = { elems: Set("Md","agent"), allocBP: 3000 }

  run magnitudeNotUnionClosedTest = all {
    assert(satMagnitude(A)),
    assert(satMagnitude(B)),
    assert(not(satMagnitude(compose(A, B)))),
    // and the failure is not an artefact of one pair: it is generic above half the cap
    assert(Set(2501, 3000, 4000, 5000).forall(v =>
             not(satMagnitude(compose({ elems: Set("Md","agent"), allocBP: v },
                                      { elems: Set("Md","agent"), allocBP: v })))))
  }

  /// The composite still satisfies the PRESENCE row wherever both parts did, which is the
  /// contrast the paper needs: the same finding is union-closed at one granularity and not
  /// at the other, so the granularity is the design decision.
  pure val SPARK_FULL: Proto = SPARK.union(Set("revocable"))
  pure val GROVE: Proto = Set("Md","agent","enumerated","shareCap","slope","timelockCancel")

  run granularityIsTheChoiceTest = all {
    assert(satMandate(SPARK_FULL)),
    assert(satMandate(GROVE)),
    assert(satMandate(SPARK_FULL.union(GROVE))),
    assert(satMagnitude({ elems: Set("Md"), allocBP: 3000 })),
    assert(not(satMagnitude(compose({ elems: Set("Md"), allocBP: 3000 },
                                    { elems: Set("Md"), allocBP: 3000 }))))
  }
}
