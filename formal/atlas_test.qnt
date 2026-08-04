module atlasTest {
  import atlas.* from "./atlas"

  run testVocabularyHasFiftyEightMechanisms = allElements.size() == 58

  run testEveryMechanismHasAttributes =
    allElements == elementAttributes.keys()

  run testEmptyProtocolIsClosed = satisfiesClosure(Set())

  run testSourceRelationCounts = all {
    laws.size() == 29,
    laws.filter(law => not(law.unsupportedSubject)).size() == 25,
    protocols.size() == 12,
    protocols.filter(protocol => protocol.dead).size() == 3,
    hazards.size() == 20,
    hazardFamilies.size() == 19,
    projectedHazards.size() == 3,
  }

  run testProtocolClosureMatchesCorpus = all {
    satisfiesClosure(Set(Pl, Ix, Ct, Ex, Li, Bs, Im, Up, Tg, Gp)),
    satisfiesClosure(Set(Sh, Cl, Tp, Fl)),
    satisfiesClosure(Set(Cd, Ix, Ct, Ex, Li, Ps, Sh, Up, Tg, Gp)),
    satisfiesClosure(Set(Cd, Ct, Ex, Li, Rd, Bs)),
    satisfiesClosure(Set(Sh, Pm, Ex, Pf, Ct, Li, Bs, Sl)),
    not(satisfiesClosure(Set(Rb, Ex, Wq, Up, Gp))),
    satisfiesClosure(Set(In, Ba, Ag, Rf)),
    not(satisfiesClosure(Set(Au, Xm, Xf, Of))),
    not(satisfiesClosure(Set(Uc, Ft, Tr, Sh, At, Aw, Wq, Xm))),
    not(satisfiesClosure(Set(As, Rd, Ex, Pl, Ix, Em))),
    not(satisfiesClosure(Set(Ob, Pf, Pl, Ct, Ex, Li))),
    not(satisfiesClosure(Set(Pl, Ix, Ct, Ex, Li, Fl, Up))),
  }

  run testProtocolViolationIds = all {
    violatedLaws(Set(Rb, Ex, Wq, Up, Gp)).map(law => law.id) == Set("L15"),
    violatedLaws(Set(Au, Xm, Xf, Of)).map(law => law.id) == Set("L19"),
    violatedLaws(Set(Uc, Ft, Tr, Sh, At, Aw, Wq, Xm)).map(law => law.id) == Set("L6"),
    violatedLaws(Set(As, Rd, Ex, Pl, Ix, Em)).map(law => law.id) == Set("L1"),
    violatedLaws(Set(Ob, Pf, Pl, Ct, Ex, Li)).map(law => law.id) == Set("L2", "L4"),
    violatedLaws(Set(Pl, Ix, Ct, Ex, Li, Fl, Up)).map(law => law.id) == Set("L15"),
  }

  run testHazardProjectionExposesReversedPolarity = all {
    hazardFree(Set(Uc)),
    not(x11aCoreFree(Set(Uc))),
    not(hazardFree(Set(Uc, Aw, At))),
    x11aCoreFree(Set(Uc, Aw, At)),
    not(hazardFree(Set(Xf, Aw))),
  }

  run testMachineCheckabilityIsStricterThanClosure = all {
    satisfiesClosure(Set(Ex)),
    hazardFree(Set(Ex)),
    not(requirementsFullyExpressible(Set(Ex))),
    requirementsFullyExpressible(Set(Ct)),
  }
}

module rawAssemblyTest {
  import atlas.* from "./atlas"
  import rawAssembly(UNIVERSE = allElements).* from "./atlas"

  run testRawAssemblyAddsOneElement =
    init.then(addElement(Sh)).expect(chosen == Set(Sh))
}

module legalAssemblyTest {
  import atlas.* from "./atlas"
  import legalAssembly(UNIVERSE = allElements).* from "./atlas"

  run testLegalAssemblyPreservesClosure =
    init
      .then(addLegal(Tg))
      .then(addLegal(Up))
      .expect(closure and hazardFreeState)

  run testSponsoredFeeBlockedWithoutAuthority =
    init.then(addLegal(Gs).fail())

  run testSponsoredFeeAllowedAfterAuthority =
    init
      .then(addLegal(Au))
      .then(addLegal(Gs))
      .expect(chosen == Set(Au, Gs))
}

module reflexiveClosedTest {
  import reflexiveLoop(HAS_EXOGENOUS_CAPITAL = false).* from "./atlas"

  run testEndogenousDefenseSpiralsToCollapse =
    init
      .then(shock)
      .then(endogenousDefense)
      .then(endogenousDefense)
      .expect(all {
        reflexiveState.phase == Collapsed,
        reflexiveState.supply == 3,
        reflexiveState.backing == 0,
      })

  run testRecoveryNeedsExogenousCapital =
    init.then(shock).then(recover.fail())
}

module reflexiveCapitalizedTest {
  import reflexiveLoop(HAS_EXOGENOUS_CAPITAL = true).* from "./atlas"

  run testExogenousCapitalCanRecover =
    init
      .then(shock)
      .then(recover)
      .expect(reflexiveState.phase == Recovered)
}
