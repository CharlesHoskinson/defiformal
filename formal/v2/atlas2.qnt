// atlas2.qnt -- v2 model of the DeFi elements atlas, rebuilt from the corrected theory.
// Nothing here is inherited from formal/atlas.qnt.
//
// Four things the old model did not have:
//   1. the CORRECTED parser: a term with a prose alternative is residue, never a requirement
//   2. TWO operators: requirement-closure Gamma and warrant-interior Delta
//   3. polarity: requirements are dual-Horn (union-closed), hazards are Horn (intersection-closed)
//   4. asset indexing: a second sort of (element, asset) instances with a `backs` relation

module atlas2 {
  type Elem = str
  type Term = { alts: Set[Elem], external: bool }
  type Rule = { id: str, subjects: Set[Elem], terms: List[Term] }

  // ---- a term with an element alternative AND a prose alternative. THE FIX.
  pure def mixedTerm(elems: Set[Elem]): Term = { alts: elems, external: true }
  pure def hardTerm(elems: Set[Elem]): Term  = { alts: elems, external: false }

  // The corrected requirement system L* (OP-ORD section 2). Every subject set is a
  // disjunction of single atoms, which is what makes Gamma union-closed.
  pure val PRICE = Set("Ex","Tp","At","Oa","Sv","Cl","Cp","St","Wg")
  pure val LOSS  = Set("Li","Ad","Sl","Bs")
  pure val TERMINAL = Set("Sl","Ad","Bs","Tr","Cv","Wq","Rd","Ps","Sv","Im","Of")

  pure val LSTAR: List[Rule] = [
    { id: "L1a", subjects: Set("Pl","Im","Cd","Pf","Op"), terms: [hardTerm(PRICE)] },
    { id: "L1c", subjects: Set("Pl","Im","Cd","Pf"), terms: [hardTerm(Set("Ct"))] },
    { id: "L1d", subjects: Set("Pl","Im","Cd","Pf"), terms: [hardTerm(LOSS)] },
    { id: "L2",  subjects: Set("Pl"), terms: [hardTerm(Set("Sh","Ix","Rb")), hardTerm(TERMINAL)] },
    { id: "L3",  subjects: Set("Uc"), terms: [hardTerm(Set("Aw")), hardTerm(Set("At")),
                                              hardTerm(Set("Bs","Tr","Sv","Ft","Ct")),
                                              hardTerm(Set("Sv","Ft","Fz","Ep","Tr"))] },
    { id: "L4",  subjects: Set("Pf"), terms: [hardTerm(Set("Ex","Tp","Oa","At")), hardTerm(Set("Ct")), hardTerm(LOSS)] },
    { id: "L5",  subjects: Set("Py"), terms: [hardTerm(Set("Sh","Ix","Rb")), hardTerm(Set("Ep")), hardTerm(Set("Rd"))] },
    { id: "L7",  subjects: Set("Cd"), terms: [hardTerm(Set("Rd","Ps","Li","Ad","Sl","Bs"))] },
    { id: "L19", subjects: Set("Of"), terms: [hardTerm(Set("Xm")), hardTerm(Set("Xf")), hardTerm(Set("Bs","Sl"))] },
    { id: "L20", subjects: Set("Rl"), terms: [hardTerm(Set("Au"))] },
    { id: "L21", subjects: Set("Gs"), terms: [hardTerm(Set("Au"))] }
  ]

  // The five atlas terms the old engine got wrong, kept here as data so the
  // regression is checkable: under the correction each is residue.
  pure val MIXED: List[Rule] = [
    { id: "L6",  subjects: Set("Tr"), terms: [mixedTerm(Set("Sv"))] },
    { id: "L7x", subjects: Set("Cd"), terms: [mixedTerm(Set("Rd","Ps"))] },
    { id: "L8",  subjects: Set("Xf"), terms: [mixedTerm(Set("Xm"))] },
    { id: "L14", subjects: Set("As"), terms: [mixedTerm(Set("Wq"))] },
    { id: "L15", subjects: Set("Up"), terms: [mixedTerm(Set("Tg"))] }
  ]

  pure def termOpen(S: Set[Elem], t: Term): bool = not(t.external) and t.alts.intersect(S).size() == 0
  pure def ruleOpen(S: Set[Elem], r: Rule): bool =
    r.subjects.intersect(S).size() > 0 and r.terms.select(t => termOpen(S, t)).length() > 0
  pure def gammaClosed(S: Set[Elem]): bool = LSTAR.select(r => ruleOpen(S, r)).length() == 0
  // the OLD engine: mixed terms hard-required their element
  pure def gammaClosedOld(S: Set[Elem]): bool =
    gammaClosed(S) and MIXED.select(r => ruleOpen(S, { ...r, terms: r.terms.foldl([], (acc, t) => acc.append({ ...t, external: false })) })).length() == 0

  // ---- Delta, the warrant interior. 27 rows; the ones reachable in this universe.
  pure val CONSUME: List[{ e: Elem, by: Set[Elem] }] = [
    { e: "Ct", by: Set("Pl","Im","Cd","Uc","Ft","Pf","Op","Dp","Tr","Cv","Rs","Vl","Pm","Ob","Fl","Rd") },
    { e: "Li", by: Set("Ct") },
    { e: "Ad", by: Set("Ct","Pf","Ob") },
    { e: "Sl", by: Set("Pl","Im","Cd","Uc","Ft","Pf","Op","Tr","Cv","Rs","Vl","Ob","Dp","Bs","Ct","Xf","Xm") },
    { e: "Bs", by: Set("Pl","Im","Cd","Uc","Pf","Op","Rs","Vl","In","Of","Xm","Xf","Cv","Tr","Ob","Ct","Sl","Rl","Ba","Ft","Wq") },
    { e: "Tp", by: Set("Cp","Cl","St","Wg","Pm","Ob") },
    { e: "Ex", by: Set("Ct","Li","Ad","Pf","Op","Pm","Cd","Pl","Im","Uc","Ft","As","Ps","Rd","Tr","Cv","Sl","Bs","Vl","Dp","Py","Sv","Rl","Oa","Rs","Sr","Cl","St","Wg","Cp","Ob","Of","In") },
    { e: "Xm", by: Set("Xf","Rs","In","Of","Rl","Vl","Ob","Sb","Up","Tg","Gp") },
    { e: "Sv", by: Set("Tr","Pl","Im","Uc","Ft","Cv","Op","Cd","Rl","Sh","Ep","Wq") },
    { e: "Ps", by: Set("At","Cd","Rd","Xf","Fz","Aw","Ix","Sr") },
    { e: "As", by: Set("Ex","Tp","Oa","At") },
    { e: "Fl", by: Set("Cp","Cl","St","Wg","Pm","Pl","Im","Cd","Ob","Ag","Sh","Ix") },
    { e: "Of", by: Set("Xf","In","Rl","Xm") },
    { e: "Pf", by: Set("Ct","Ob","Pm","Ex") },
    { e: "Op", by: Set("Ct","Ob","Ex","Sh","Rf","Pm","Cl") },
    { e: "Py", by: Set("Ix","Sh","Rb","Ft") },
    { e: "Tr", by: Set("Pl","Im","Uc","Ft","Cd","Cv","Rs","Vl","Sh","Ix","Sv","Dp") },
    { e: "Cv", by: Set("Pl","Im","Cd","Uc","Bs","Sh") },
    { e: "Rl", by: Set("In","Xf","Xm","Of","Au","Ob","Rf") },
    { e: "Gs", by: Set("Au","Ob","In","Rl","Aw") },
    { e: "Vl", by: Set("Rs","Bs","Sl","Sh","Wq","Ep","Rb","Ix","Xf","Ob") },
    { e: "Ft", by: Set("Sh","Ix","Rb","Py","Ep","At","Sv","Uc","Tr") },
    { e: "Rb", by: Set("Sh","Ix","Vl","Pl","Im","Cd","Ps","Rd") },
    { e: "Pl", by: Set("Sh","Ix","Rb") },
    { e: "Im", by: Set("Sh","Ix","Rb","Ct") },
    { e: "Uc", by: Set("Sh","Ix","Rb","Ft") },
    { e: "Cd", by: Set("Sh","Ix","Rb","Rd","Ps","As") }
  ]
  pure def unwarranted(S: Set[Elem]): Set[Elem] =
    CONSUME.foldl(Set(), (acc, c) => if (S.contains(c.e) and c.by.intersect(S).size() == 0) acc.union(Set(c.e)) else acc)
  pure def Delta(S: Set[Elem]): Set[Elem] = S.exclude(unwarranted(S))
  pure def warranted(S: Set[Elem]): bool = Delta(S) == S

  // ---- polarity. Bans are Horn (pure negative): intersection-closed, not union-closed.
  pure def bansOK(S: Set[Elem]): bool = and {
    not(S.contains("Fl") and (S.contains("Cp") or S.contains("Cl")) and (S.contains("Pl") or S.contains("Cd") or S.contains("Im"))),
    not(S.contains("Fl") and (S.contains("Xf") or S.contains("Rl") or S.contains("Of")))
  }
  // conditional rows. X11a* has a single-atom antecedent; X19*/X18 are CONJUNCTIVE.
  pure def condOK(S: Set[Elem]): bool = and {
    not(S.contains("Uc")) or (S.contains("Aw") and S.contains("At")),
    not(S.contains("Aw") and S.contains("Xf")) or S.intersect(Set("At","Fz","Xm")).size() > 0,
    not(S.contains("Oa") and S.contains("Li")) or S.intersect(Set("Ex","Tp")).size() > 0
  }
  pure def admissible(S: Set[Elem]): bool = gammaClosed(S) and warranted(S) and bansOK(S) and condOK(S)

  // ---- F6 / T2. The congruence fragment: delete Fl, split every conjunctive
  // antecedent into its single-atom strengthenings. All rows then have single-atom
  // antecedents, so the family is union-closed and (+) is a congruence on it.
  pure def inFragment(S: Set[Elem]): bool = and {
    admissible(S),
    not(S.contains("Fl")),
    not(S.contains("Aw")) or S.intersect(Set("At","Fz","Xm")).size() > 0,
    not(S.contains("Xf")) or S.intersect(Set("At","Fz","Xm")).size() > 0,
    not(S.contains("Oa")) or S.intersect(Set("Ex","Tp")).size() > 0,
    not(S.contains("Li")) or S.intersect(Set("Ex","Tp")).size() > 0
  }

  // ================= Layer 3: asset-indexed instances (F5) =================
  // Reflexivity is provably inexpressible over element TYPES (P4: the requirement
  // relation is a DAG with no self-loops). It becomes expressible over pairs.
  type Inst = { e: Elem, a: str }
  type Proto = { name: str, insts: Set[Inst], backs: Set[(Inst, Inst)] }

  // backs := reads ; over^-1 -- "the solvency of i1 is a function of the market value of i2"
  pure def step(P: Proto, X: Set[Inst]): Set[Inst] =
    P.backs.filter(p => X.contains(p._1)).map(p => p._2)
  pure def reach(P: Proto, X: Set[Inst]): Set[Inst] = {
    val a = X.union(step(P, X))
    val b = a.union(step(P, a))
    val c = b.union(step(P, b))
    c.union(step(P, c))
  }
  pure def hasCycle(P: Proto): bool = P.insts.exists(i => reach(P, step(P, Set(i))).contains(i))

  // Terra: UST's algorithmic stability reads LUNA's market value, and LUNA's
  // redemption value reads UST. Two element types, two assets, one 2-cycle.
  pure val TERRA: Proto = {
    name: "Terra",
    insts: Set({e:"As",a:"UST"}, {e:"Rd",a:"LUNA"}, {e:"Ex",a:"UST"}),
    backs: Set(({e:"As",a:"UST"}, {e:"Rd",a:"LUNA"}), ({e:"Rd",a:"LUNA"}, {e:"As",a:"UST"}))
  }
  // crvUSD: comparable element set, but the backing chain terminates in an
  // exogenous asset (ETH), which nothing in the protocol issues.
  pure val CRVUSD: Proto = {
    name: "crvUSD",
    insts: Set({e:"As",a:"crvUSD"}, {e:"Rd",a:"crvUSD"}, {e:"Ct",a:"ETH"}, {e:"Ex",a:"ETH"}),
    backs: Set(({e:"As",a:"crvUSD"}, {e:"Ct",a:"ETH"}), ({e:"Rd",a:"crvUSD"}, {e:"Ct",a:"ETH"}),
               ({e:"Ct",a:"ETH"}, {e:"Ex",a:"ETH"}))
  }
  // the forgetful functor U : instances -> flat element sets (GR-CAT P8)
  pure def U(P: Proto): Set[Elem] = P.insts.map(i => i.e)
}

module atlas2_test {
  import atlas2.*

  // ---------- F1 / P14: the parser fix, as a regression
  // Lido-like: Up present with no Tg. The old engine hard-required Tg and rejected it.
  pure val LIDOISH = Set("Sh","Bs","Ex","Ct","Up","Rd","Ep")
  run parserFixTest = all {
    assert(not(gammaClosedOld(Set("Up")))),   // old: Up -> Tg was mandatory
    assert(gammaClosed(Set("Up")))            // new: "Tg | bounded emergency process" is residue
  }

  // ---------- F3: the old prize is dead, and it dies on WARRANT, not on a hazard
  run flXmDeadTest = all {
    assert(gammaClosed(Set("Fl","Xm"))),                 // it still closes
    assert(bansOK(Set("Fl","Xm"))),                      // it still arms no ban
    assert(not(warranted(Set("Fl","Xm")))),              // but neither element has anything to be for
    assert(unwarranted(Set("Fl","Xm")) == Set("Fl","Xm")),
    assert(not(admissible(Set("Fl","Xm")))),
    // the surviving shape: supply both warrants and it becomes admissible again
    assert(admissible(Set("Sh","In","Fl","Xm")))
  }

  // ---------- F4: (+) is not a congruence for ADMISSIBILITY (four closures)
  pure val A = Set("Au","Rl","Xm")
  pure val B = Set("Au","Cp","Fl")
  run notJoinClosedTest = all {
    assert(admissible(A)), assert(admissible(B)),
    assert(not(admissible(A.union(B))))          // X21: Fl meets Rl
  }
  run notMeetClosedTest = all {
    assert(admissible(A)), assert(admissible(Set("Aw","Sl","Xf","Xm"))),
    assert(not(admissible(A.intersect(Set("Aw","Sl","Xf","Xm")))))   // {Xm}, unwarranted
  }
  run notUpClosedTest = all {
    assert(admissible(Set())), assert(not(admissible(Set("Fl"))))
  }
  run notDownClosedTest = all {
    assert(admissible(Set("Xf","Xm"))), assert(not(admissible(Set("Xm"))))
  }
  // ...but observational equivalence IS preserved, because (+) is union and union is
  // total, associative and commutative. Never write "congruence" unqualified.
  run compositionIsMonoidTest = all {
    assert(A.union(B) == B.union(A)),
    assert(A.union(B).union(Set("Ct")) == A.union(B.union(Set("Ct")))),
    assert(A.union(A) == A),
    assert(A.union(Set()) == A)
  }

  // ---------- F6 / T2: on the fragment, (+) IS a congruence
  pure val F1x = Set("Sh","Ix","Pl","Ct","Ex","Bs")
  pure val F2x = Set("Sh","Rd","Ps","At")
  run congruenceFragmentTest = all {
    assert(inFragment(F1x)), assert(inFragment(F2x)),
    assert(inFragment(F1x.union(F2x))),
    assert(admissible(F1x.union(F2x)))
  }
  // and B leaves the fragment exactly because it carries Fl
  run fragmentExcludesFlTest = all {
    assert(admissible(B)), assert(not(inFragment(B)))
  }

  // ---------- F5: reflexivity, with the control
  run terraCycleTest = all {
    assert(hasCycle(TERRA)),
    assert(not(hasCycle(CRVUSD)))
  }
  // ...and the cycle is invisible after forgetting the asset index (P8)
  run forgetfulKernelTest = all {
    assert(U(TERRA) == Set("As","Rd","Ex")),
    // no set of element types can contain a requirement cycle: L* is a DAG,
    // so the flat image of Terra is indistinguishable from an acyclic protocol
    assert(gammaClosed(U(TERRA)) == gammaClosed(Set("As","Rd","Ex")))
  }

  // ---------- F7: Uc under the corrected polarity
  pure val MAPLEISH = Set("Sh","Uc","Aw","At","Ct","Ft","Ep","Ex","Rb")
  run ucRealizableTest = all {
    assert(gammaClosed(MAPLEISH)),
    assert(condOK(MAPLEISH)),
    assert(admissible(MAPLEISH))
  }

  // ---------- polarity (P1), as executable statements
  // requirement rows have single-atom antecedents => union-closed
  run gammaUnionClosedTest = all {
    assert(gammaClosed(Set("Pl","Sh","Ct","Ex","Bs"))),
    assert(gammaClosed(Set("Gs","Au"))),
    assert(gammaClosed(Set("Pl","Sh","Ct","Ex","Bs").union(Set("Gs","Au"))))
  }
  // warrant rows too
  run deltaUnionClosedTest = all {
    assert(warranted(Set("Pl","Sh"))), assert(warranted(Set("Gs","Au"))),
    assert(warranted(Set("Pl","Sh").union(Set("Gs","Au"))))
  }
  // bans are intersection-closed but NOT union-closed
  run banPolarityTest = all {
    assert(bansOK(Set("Fl","Cp"))), assert(bansOK(Set("Fl","Pl"))),
    assert(not(bansOK(Set("Fl","Cp").union(Set("Fl","Pl"))))),
    assert(bansOK(Set("Fl","Cp").intersect(Set("Fl","Pl"))))
  }
}
