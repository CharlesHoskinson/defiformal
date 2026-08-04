---------------------------- MODULE counterexample ----------------------------

EXTENDS legalFull

(* Constant initialization state *)
ConstInit == TRUE

(* Initial state [_transition(0)] *)
State0 == legalFull_legalAssembly_chosen = {}

(* State1 [_transition(0)] *)
State1 == legalFull_legalAssembly_chosen = {Variant("Au", [tag |-> "UNIT"])}

(* State2 [_transition(0)] *)
State2 ==
  legalFull_legalAssembly_chosen
      = { Variant("Au", [tag |-> "UNIT"]), Variant("Gs", [tag |-> "UNIT"]) }

(* The following formula holds true in the last state and violates the invariant *)
InvariantViolation ==
  Skolem((\E legalFull_legalAssembly_law_2738_2 \in { [id |-> "L1",
      raw |-> "(Pl|Im|Cd|Pf|Op) → (Ex|Tp|At) + Ct + (Li|Ad|Sl|Bs)",
      subjects |->
        { Variant("Pl", [tag |-> "UNIT"]),
          Variant("Im", [tag |-> "UNIT"]),
          Variant("Cd", [tag |-> "UNIT"]),
          Variant("Pf", [tag |-> "UNIT"]),
          Variant("Op", [tag |-> "UNIT"]) },
      terms |->
        { { Variant("Ex", [tag |-> "UNIT"]),
            Variant("Tp", [tag |-> "UNIT"]),
            Variant("At", [tag |-> "UNIT"]) },
          {Variant("Ct", [tag |-> "UNIT"])},
          { Variant("Li", [tag |-> "UNIT"]),
            Variant("Ad", [tag |-> "UNIT"]),
            Variant("Sl", [tag |-> "UNIT"]),
            Variant("Bs", [tag |-> "UNIT"]) } },
      externalTerms |-> 0,
      mixedTerms |-> 0,
      asyncRepairable |-> FALSE,
      unsupportedSubject |-> FALSE],
    [id |-> "L2",
      raw |-> "Pl → (Sh|Ix) + exit-liquidity",
      subjects |-> {Variant("Pl", [tag |-> "UNIT"])},
      terms |->
        {{ Variant("Sh", [tag |-> "UNIT"]), Variant("Ix", [tag |-> "UNIT"]) }},
      externalTerms |-> 1,
      mixedTerms |-> 0,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE],
    [id |-> "L3",
      raw |-> "Uc → Aw + At{subject=borrower-financials} + (Bs|Tr) + obligor",
      subjects |-> {Variant("Uc", [tag |-> "UNIT"])},
      terms |->
        { {Variant("Aw", [tag |-> "UNIT"])},
          {Variant("At", [tag |-> "UNIT"])},
          { Variant("Bs", [tag |-> "UNIT"]), Variant("Tr", [tag |-> "UNIT"]) } },
      externalTerms |-> 1,
      mixedTerms |-> 0,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE],
    [id |-> "L4",
      raw |-> "Pf → Ex + Ct + Li + (Ad|Sl|Bs)",
      subjects |-> {Variant("Pf", [tag |-> "UNIT"])},
      terms |->
        { {Variant("Ex", [tag |-> "UNIT"])},
          {Variant("Ct", [tag |-> "UNIT"])},
          {Variant("Li", [tag |-> "UNIT"])},
          { Variant("Ad", [tag |-> "UNIT"]),
            Variant("Sl", [tag |-> "UNIT"]),
            Variant("Bs", [tag |-> "UNIT"]) } },
      externalTerms |-> 0,
      mixedTerms |-> 0,
      asyncRepairable |-> FALSE,
      unsupportedSubject |-> FALSE],
    [id |-> "L5",
      raw |-> "Py → (Sh|Ix|Rb) + Ep + Rd",
      subjects |-> {Variant("Py", [tag |-> "UNIT"])},
      terms |->
        { { Variant("Sh", [tag |-> "UNIT"]),
            Variant("Ix", [tag |-> "UNIT"]),
            Variant("Rb", [tag |-> "UNIT"]) },
          {Variant("Ep", [tag |-> "UNIT"])},
          {Variant("Rd", [tag |-> "UNIT"])} },
      externalTerms |-> 0,
      mixedTerms |-> 0,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE],
    [id |-> "L6",
      raw |->
        "Tr → (Sv | mechanical trigger) + declared seniority + dispute forum + recovery-timing assumption",
      subjects |-> {Variant("Tr", [tag |-> "UNIT"])},
      terms |-> {{Variant("Sv", [tag |-> "UNIT"])}},
      externalTerms |-> 3,
      mixedTerms |-> 1,
      asyncRepairable |-> FALSE,
      unsupportedSubject |-> FALSE],
    [id |-> "L7",
      raw |-> "Cd → Rd | Ps | liquidation capacity",
      subjects |-> {Variant("Cd", [tag |-> "UNIT"])},
      terms |->
        {{ Variant("Rd", [tag |-> "UNIT"]), Variant("Ps", [tag |-> "UNIT"]) }},
      externalTerms |-> 0,
      mixedTerms |-> 1,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE],
    [id |-> "L8",
      raw |-> "Xf → Xm | named custodian, plus a global claim ledger",
      subjects |-> {Variant("Xf", [tag |-> "UNIT"])},
      terms |-> {{Variant("Xm", [tag |-> "UNIT"])}},
      externalTerms |-> 0,
      mixedTerms |-> 1,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE],
    [id |-> "L9",
      raw |-> "Xf → debit(source) = credit(destination)",
      subjects |-> {Variant("Xf", [tag |-> "UNIT"])},
      terms |-> {},
      externalTerms |-> 1,
      mixedTerms |-> 0,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE],
    [id |-> "L10",
      raw |-> "Sb → proof verifier + nullifier set",
      subjects |-> {Variant("Sb", [tag |-> "UNIT"])},
      terms |-> {},
      externalTerms |-> 2,
      mixedTerms |-> 0,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE],
    [id |-> "L11",
      raw |-> "Sd → credential source + verifier + revocation",
      subjects |-> {Variant("Sd", [tag |-> "UNIT"])},
      terms |-> {},
      externalTerms |-> 3,
      mixedTerms |-> 0,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE],
    [id |-> "L12",
      raw |->
        "In → signed constraints + settlement verifier + (solver|fallback) + timeout",
      subjects |-> {Variant("In", [tag |-> "UNIT"])},
      terms |-> {},
      externalTerms |-> 4,
      mixedTerms |-> 0,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE],
    [id |-> "L13",
      raw |->
        "Ex → freshness validation; Gp preferred for high-value obligations",
      subjects |-> {Variant("Ex", [tag |-> "UNIT"])},
      terms |-> {},
      externalTerms |-> 1,
      mixedTerms |-> 0,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE],
    [id |-> "L14",
      raw |-> "illiquid backing → Wq | bounded liquidity reserve",
      subjects |-> {},
      terms |-> {{Variant("Wq", [tag |-> "UNIT"])}},
      externalTerms |-> 0,
      mixedTerms |-> 1,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> TRUE],
    [id |-> "L15",
      raw |-> "Up → Tg | bounded emergency process",
      subjects |-> {Variant("Up", [tag |-> "UNIT"])},
      terms |-> {{Variant("Tg", [tag |-> "UNIT"])}},
      externalTerms |-> 0,
      mixedTerms |-> 1,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE],
    [id |-> "L16",
      raw |->
        "Aw → transfer-time enforcement where eligibility follows the holder",
      subjects |-> {Variant("Aw", [tag |-> "UNIT"])},
      terms |-> {},
      externalTerms |-> 1,
      mixedTerms |-> 0,
      asyncRepairable |-> FALSE,
      unsupportedSubject |-> FALSE],
    [id |-> "L17",
      raw |->
        "Au → bounded scope + revocation + expiry + nonce/domain separation",
      subjects |-> {Variant("Au", [tag |-> "UNIT"])},
      terms |-> {},
      externalTerms |-> 4,
      mixedTerms |-> 0,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE],
    [id |-> "L18",
      raw |->
        "Xm → explicit finality + chain/domain binding + replay protection",
      subjects |-> {Variant("Xm", [tag |-> "UNIT"])},
      terms |-> {},
      externalTerms |-> 3,
      mixedTerms |-> 0,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE],
    [id |-> "L19",
      raw |-> "Of → Xm + Xf + (Bs|Sl) + timeout",
      subjects |-> {Variant("Of", [tag |-> "UNIT"])},
      terms |->
        { {Variant("Xm", [tag |-> "UNIT"])},
          {Variant("Xf", [tag |-> "UNIT"])},
          { Variant("Bs", [tag |-> "UNIT"]), Variant("Sl", [tag |-> "UNIT"]) } },
      externalTerms |-> 1,
      mixedTerms |-> 0,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE],
    [id |-> "L20",
      raw |-> "Rl → Au + single-spend + expiry + fulfillment proof + release",
      subjects |-> {Variant("Rl", [tag |-> "UNIT"])},
      terms |-> {{Variant("Au", [tag |-> "UNIT"])}},
      externalTerms |-> 4,
      mixedTerms |-> 0,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE],
    [id |-> "L21",
      raw |-> "Gs → Au + metering + fee settlement",
      subjects |-> {Variant("Gs", [tag |-> "UNIT"])},
      terms |-> {{Variant("Au", [tag |-> "UNIT"])}},
      externalTerms |-> 2,
      mixedTerms |-> 0,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE],
    [id |-> "L22",
      raw |->
        "Rs → attributed slash condition + non-reflexive capital + loss waterfall",
      subjects |-> {Variant("Rs", [tag |-> "UNIT"])},
      terms |-> {},
      externalTerms |-> 3,
      mixedTerms |-> 0,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE],
    [id |-> "L23",
      raw |-> "Sq → Xm + independent settlement finality",
      subjects |-> {},
      terms |-> {{Variant("Xm", [tag |-> "UNIT"])}},
      externalTerms |-> 1,
      mixedTerms |-> 0,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> TRUE],
    [id |-> "L24",
      raw |-> "(In|Rf|Ba) → an explicit informational edge with a catalog tag",
      subjects |->
        { Variant("In", [tag |-> "UNIT"]),
          Variant("Rf", [tag |-> "UNIT"]),
          Variant("Ba", [tag |-> "UNIT"]) },
      terms |-> {},
      externalTerms |-> 1,
      mixedTerms |-> 0,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE],
    [id |-> "L25",
      raw |->
        "wrapped cross-domain collateral → haircut + cap + independent exit",
      subjects |-> {},
      terms |-> {},
      externalTerms |-> 3,
      mixedTerms |-> 0,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> TRUE],
    [id |-> "L26",
      raw |->
        "Aw + Xf → destination-enforced eligibility + revocation propagation + jurisdictional binding",
      subjects |-> {},
      terms |-> {},
      externalTerms |-> 3,
      mixedTerms |-> 0,
      asyncRepairable |-> FALSE,
      unsupportedSubject |-> TRUE],
    [id |-> "L27",
      raw |->
        "At → named attester + independence + stated assurance + staleness bound + recourse",
      subjects |-> {Variant("At", [tag |-> "UNIT"])},
      terms |-> {},
      externalTerms |-> 5,
      mixedTerms |-> 0,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE],
    [id |-> "L28",
      raw |->
        "Fz → named authority + enumerated triggers + appeal path + holder disclosure",
      subjects |-> {Variant("Fz", [tag |-> "UNIT"])},
      terms |-> {},
      externalTerms |-> 4,
      mixedTerms |-> 0,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE],
    [id |-> "L29",
      raw |->
        "(In|Ba|Rf|Of) → a declared surplus-allocation rule naming the residual claimant",
      subjects |->
        { Variant("In", [tag |-> "UNIT"]),
          Variant("Ba", [tag |-> "UNIT"]),
          Variant("Rf", [tag |-> "UNIT"]),
          Variant("Of", [tag |-> "UNIT"]) },
      terms |-> {},
      externalTerms |-> 1,
      mixedTerms |-> 0,
      asyncRepairable |-> TRUE,
      unsupportedSubject |-> FALSE] }:
    Skolem((\E t_8_1 \in legalFull_legalAssembly_law_2738_2["subjects"]:
      t_8_1 \in legalFull_legalAssembly_chosen
        /\ Skolem((\E legalFull_legalAssembly_term_2734_2 \in legalFull_legalAssembly_law_2738_2[
          "terms"
        ]:
          \A legalFull_legalAssembly_required_2732_2 \in {
            t_9_1 \in legalFull_legalAssembly_term_2734_2:
              t_9_1 \in legalFull_legalAssembly_chosen
          }:
            SetAsFun({ <<
                Variant("Sh", [tag |-> "UNIT"]), [id |-> "E001",
                  name |-> "Pro-rata share accounting",
                  group |-> Variant("G01", [tag |-> "UNIT"]),
                  stratum |-> 0,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |-> "Shares represent a proportional pool claim."]
              >>,
              <<
                Variant("Ix", [tag |-> "UNIT"]), [id |-> "E002",
                  name |-> "Index-based accrual",
                  group |-> Variant("G01", [tag |-> "UNIT"]),
                  stratum |-> 0,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "A global exchange-rate or debt index changes claim value."]
              >>,
              <<
                Variant("Rb", [tag |-> "UNIT"]), [id |-> "E003",
                  name |-> "Rebasing accounting",
                  group |-> Variant("G01", [tag |-> "UNIT"]),
                  stratum |-> 0,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Nominal balances change through global scaling."]
              >>,
              <<
                Variant("Cp", [tag |-> "UNIT"]), [id |-> "E004",
                  name |-> "Constant-product invariant",
                  group |-> Variant("G02", [tag |-> "UNIT"]),
                  stratum |-> 1,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |-> "x·y = k."]
              >>,
              <<
                Variant("Wg", [tag |-> "UNIT"]), [id |-> "E005",
                  name |-> "Weighted-geometric invariant",
                  group |-> Variant("G02", [tag |-> "UNIT"]),
                  stratum |-> 1,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |-> "Multi-asset weighted pricing."]
              >>,
              <<
                Variant("St", [tag |-> "UNIT"]), [id |-> "E006",
                  name |-> "Stable-hybrid invariant",
                  group |-> Variant("G02", [tag |-> "UNIT"]),
                  stratum |-> 1,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Constant-sum near parity, constant-product away from it."]
              >>,
              <<
                Variant("Cl", [tag |-> "UNIT"]), [id |-> "E007",
                  name |-> "Concentrated liquidity",
                  group |-> Variant("G02", [tag |-> "UNIT"]),
                  stratum |-> 1,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Range-specific position state and tick activation."]
              >>,
              <<
                Variant("Pm", [tag |-> "UNIT"]), [id |-> "E008",
                  name |-> "Oracle-priced inventory curve",
                  group |-> Variant("G02", [tag |-> "UNIT"]),
                  stratum |-> 1,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Proactive market making against an external reference."]
              >>,
              <<
                Variant("Ob", [tag |-> "UNIT"]), [id |-> "E009",
                  name |-> "On-chain order book",
                  group |-> Variant("G03", [tag |-> "UNIT"]),
                  stratum |-> 1,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Limit orders, sequencing, cancellation, settlement."]
              >>,
              <<
                Variant("Rf", [tag |-> "UNIT"]), [id |-> "E010",
                  name |-> "Request for quote",
                  group |-> Variant("G03", [tag |-> "UNIT"]),
                  stratum |-> 1,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |-> "Signed maker quote against inventory."]
              >>,
              <<
                Variant("Ba", [tag |-> "UNIT"]), [id |-> "E011",
                  name |-> "Batch-auction clearing",
                  group |-> Variant("G03", [tag |-> "UNIT"]),
                  stratum |-> 2,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |-> "Uniform clearing over a batch."]
              >>,
              <<
                Variant("In", [tag |-> "UNIT"]), [id |-> "E012",
                  name |-> "Intent & solver execution",
                  group |-> Variant("G03", [tag |-> "UNIT"]),
                  stratum |-> 4,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Signed outcome constraints delegated to competing solvers."]
              >>,
              <<
                Variant("Ag", [tag |-> "UNIT"]), [id |-> "E039",
                  name |-> "Aggregation & routing",
                  group |-> Variant("G04", [tag |-> "UNIT"]),
                  stratum |-> 1,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |-> "Multi-venue route construction."]
              >>,
              <<
                Variant("Fl", [tag |-> "UNIT"]), [id |-> "E040",
                  name |-> "Atomic flash liquidity",
                  group |-> Variant("G04", [tag |-> "UNIT"]),
                  stratum |-> 1,
                  atom |-> Variant("AsyncImpossible", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Borrow and repay within one settlement scope or revert."]
              >>,
              <<
                Variant("Pl", [tag |-> "UNIT"]), [id |-> "E013",
                  name |-> "Pooled lending",
                  group |-> Variant("G05", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Shared liquidity pool, many lenders and borrowers."]
              >>,
              <<
                Variant("Im", [tag |-> "UNIT"]), [id |-> "E014",
                  name |-> "Isolated lending market",
                  group |-> Variant("G05", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Per-market risk isolation with its own oracle, LLTV and rate model."]
              >>,
              <<
                Variant("Cd", [tag |-> "UNIT"]), [id |-> "E015",
                  name |-> "Collateralized-debt minting",
                  group |-> Variant("G05", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |-> "Mint a liability against locked collateral."]
              >>,
              <<
                Variant("Uc", [tag |-> "UNIT"]), [id |-> "E016",
                  name |-> "Undercollateralized credit",
                  group |-> Variant("G05", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Credit extended on identity, underwriting and recourse."]
              >>,
              <<
                Variant("Ft", [tag |-> "UNIT"]), [id |-> "E017",
                  name |-> "Fixed-term debt",
                  group |-> Variant("G05", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |-> "Maturity-dated claim with a discount factor."]
              >>,
              <<
                Variant("Ct", [tag |-> "UNIT"]), [id |-> "E018",
                  name |-> "Collateral-threshold test",
                  group |-> Variant("G06", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "The margin/LTV/health computation and its threshold."]
              >>,
              <<
                Variant("Li", [tag |-> "UNIT"]), [id |-> "E019",
                  name |-> "Incentivized liquidation",
                  group |-> Variant("G06", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Third parties repay unhealthy debt for discounted collateral."]
              >>,
              <<
                Variant("Ad", [tag |-> "UNIT"]), [id |-> "E020",
                  name |-> "Auto-deleveraging",
                  group |-> Variant("G06", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Rank-ordered forced close when buffers are exhausted."]
              >>,
              <<
                Variant("Sl", [tag |-> "UNIT"]), [id |-> "E021",
                  name |-> "Socialized-loss allocation",
                  group |-> Variant("G06", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |-> "Losses assigned to an explicit claim class."]
              >>,
              <<
                Variant("Bs", [tag |-> "UNIT"]), [id |-> "E022",
                  name |-> "Staked backstop",
                  group |-> Variant("G06", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |-> "Slashable first-loss capital."]
              >>,
              <<
                Variant("Pf", [tag |-> "UNIT"]), [id |-> "E023",
                  name |-> "Perpetual funding transfer",
                  group |-> Variant("G07", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Periodic payment tethering a perp to an index."]
              >>,
              <<
                Variant("Op", [tag |-> "UNIT"]), [id |-> "E024",
                  name |-> "Option payoff",
                  group |-> Variant("G07", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Strike, expiry, collateralized contingent settlement."]
              >>,
              <<
                Variant("Tr", [tag |-> "UNIT"]), [id |-> "E025",
                  name |-> "Tranche waterfall",
                  group |-> Variant("G07", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Declared seniority over a determined loss event."]
              >>,
              <<
                Variant("Cv", [tag |-> "UNIT"]), [id |-> "E026",
                  name |-> "Mutual cover pool",
                  group |-> Variant("G07", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Adjudicated claims against pooled premium capital."]
              >>,
              <<
                Variant("Py", [tag |-> "UNIT"]), [id |-> "E027",
                  name |-> "Principal/yield separation",
                  group |-> Variant("G07", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |-> "Split a yield-bearing claim into PT and YT."]
              >>,
              <<
                Variant("Sv", [tag |-> "UNIT"]), [id |-> "E057",
                  name |-> "Servicing & determination discretion",
                  group |-> Variant("G07", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Candidate", [tag |-> "UNIT"]),
                  definition |->
                    "A named party's discretionary determination of loss, valuation, cure, waiver or suspension that alters others' claims."]
              >>,
              <<
                Variant("Dp", [tag |-> "UNIT"]), [id |-> "E060",
                  name |-> "Directional position & hedge maintenance",
                  group |-> Variant("G07", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Candidate", [tag |-> "UNIT"]),
                  definition |->
                    "A held directional exposure and the rebalancing that maintains it."]
              >>,
              <<
                Variant("Ex", [tag |-> "UNIT"]), [id |-> "E028",
                  name |-> "External data oracle",
                  group |-> Variant("G08", [tag |-> "UNIT"]),
                  stratum |-> 2,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |-> "Imported off-chain value."]
              >>,
              <<
                Variant("Tp", [tag |-> "UNIT"]), [id |-> "E029",
                  name |-> "Time-weighted price",
                  group |-> Variant("G08", [tag |-> "UNIT"]),
                  stratum |-> 2,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |-> "Cumulative-price accumulator over a window."]
              >>,
              <<
                Variant("Oa", [tag |-> "UNIT"]), [id |-> "E030",
                  name |-> "Optimistic assertion oracle",
                  group |-> Variant("G08", [tag |-> "UNIT"]),
                  stratum |-> 2,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |-> "Assert-then-dispute escalation game."]
              >>,
              <<
                Variant("At", [tag |-> "UNIT"]), [id |-> "E031",
                  name |-> "Reserve / NAV attestation",
                  group |-> Variant("G08", [tag |-> "UNIT"]),
                  stratum |-> 2,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "A named party's statement about backing or value."]
              >>,
              <<
                Variant("Sr", [tag |-> "UNIT"]), [id |-> "E032",
                  name |-> "Streaming accrual",
                  group |-> Variant("G09", [tag |-> "UNIT"]),
                  stratum |-> 2,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |-> "Continuous per-second transfer from escrow."]
              >>,
              <<
                Variant("Ep", [tag |-> "UNIT"]), [id |-> "E033",
                  name |-> "Epoch-gated transition",
                  group |-> Variant("G09", [tag |-> "UNIT"]),
                  stratum |-> 2,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |-> "Snapshot, cutoff, rollover."]
              >>,
              <<
                Variant("Wq", [tag |-> "UNIT"]), [id |-> "E034",
                  name |-> "Withdrawal queue",
                  group |-> Variant("G09", [tag |-> "UNIT"]),
                  stratum |-> 2,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Request now, claim later, against future asset availability."]
              >>,
              <<
                Variant("Em", [tag |-> "UNIT"]), [id |-> "E035",
                  name |-> "Protocol-funded emissions",
                  group |-> Variant("G10", [tag |-> "UNIT"]),
                  stratum |-> 2,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Newly issued tokens paid for measured actions."]
              >>,
              <<
                Variant("Fd", [tag |-> "UNIT"]), [id |-> "E058",
                  name |-> "Surplus & fee distribution",
                  group |-> Variant("G10", [tag |-> "UNIT"]),
                  stratum |-> 2,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Candidate", [tag |-> "UNIT"]),
                  definition |->
                    "The rule naming the residual claimant of fees, spread and surplus."]
              >>,
              <<
                Variant("Tg", [tag |-> "UNIT"]), [id |-> "E036",
                  name |-> "Delayed-governance execution",
                  group |-> Variant("G11", [tag |-> "UNIT"]),
                  stratum |-> 4,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "A timelock between authorization and executability."]
              >>,
              <<
                Variant("Up", [tag |-> "UNIT"]), [id |-> "E037",
                  name |-> "Mutable implementation proxy",
                  group |-> Variant("G11", [tag |-> "UNIT"]),
                  stratum |-> 4,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Code replacement changes the reachable state machine."]
              >>,
              <<
                Variant("Gp", [tag |-> "UNIT"]), [id |-> "E038",
                  name |-> "Guardian or pause",
                  group |-> Variant("G11", [tag |-> "UNIT"]),
                  stratum |-> 4,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |-> "Bounded suppression of reachable transitions."]
              >>,
              <<
                Variant("Au", [tag |-> "UNIT"]), [id |-> "E050",
                  name |-> "Delegated execution scope",
                  group |-> Variant("G11", [tag |-> "UNIT"]),
                  stratum |-> 4,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Persistent policy bounding the calls, assets, destinations, values, chains and time windows a delegate may reach."]
              >>,
              <<
                Variant("Gs", [tag |-> "UNIT"]), [id |-> "E051",
                  name |-> "Sponsored-fee liability",
                  group |-> Variant("G11", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Candidate", [tag |-> "UNIT"]),
                  definition |->
                    "A conditional fee liability with metering and reimbursement."]
              >>,
              <<
                Variant("Xm", [tag |-> "UNIT"]), [id |-> "E041",
                  name |-> "Cross-domain message verification",
                  group |-> Variant("G12", [tag |-> "UNIT"]),
                  stratum |-> 4,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Decide whether a source-domain assertion is acceptable at the destination."]
              >>,
              <<
                Variant("Xf", [tag |-> "UNIT"]), [id |-> "E042",
                  name |-> "Cross-domain asset transfer",
                  group |-> Variant("G12", [tag |-> "UNIT"]),
                  stratum |-> 4,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Create a destination claim against an explicit source debit."]
              >>,
              <<
                Variant("Rl", [tag |-> "UNIT"]), [id |-> "E053",
                  name |-> "Resource lock / reservation",
                  group |-> Variant("G12", [tag |-> "UNIT"]),
                  stratum |-> 4,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Candidate", [tag |-> "UNIT"]),
                  definition |->
                    "Enforceable pre-commitment with exclusivity, expiry, fulfillment and release."]
              >>,
              <<
                Variant("Of", [tag |-> "UNIT"]), [id |-> "E054",
                  name |-> "Optimistic fill & reimbursement",
                  group |-> Variant("G12", [tag |-> "UNIT"]),
                  stratum |-> 4,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Candidate", [tag |-> "UNIT"]),
                  definition |->
                    "A filler advances destination value before finality and holds a contingent reimbursement claim."]
              >>,
              <<
                Variant("Rd", [tag |-> "UNIT"]), [id |-> "E043",
                  name |-> "Direct redemption right",
                  group |-> Variant("G13", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Redeem a liability against backing at a defined rate."]
              >>,
              <<
                Variant("Ps", [tag |-> "UNIT"]), [id |-> "E044",
                  name |-> "Peg-swap module",
                  group |-> Variant("G13", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "1:1 reserve-backed swap with mint/burn authority."]
              >>,
              <<
                Variant("As", [tag |-> "UNIT"]), [id |-> "E045",
                  name |-> "Algorithmic supply adjustment",
                  group |-> Variant("G13", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |->
                    "Supply expansion/contraction driven by measured price."]
              >>,
              <<
                Variant("Aw", [tag |-> "UNIT"]), [id |-> "E046",
                  name |-> "Permission / identity gate",
                  group |-> Variant("G14", [tag |-> "UNIT"]),
                  stratum |-> 2,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |-> "Credential-checked eligibility."]
              >>,
              <<
                Variant("Sb", [tag |-> "UNIT"]), [id |-> "E047",
                  name |-> "Shielded-balance state",
                  group |-> Variant("G14", [tag |-> "UNIT"]),
                  stratum |-> 2,
                  atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                  status |-> Variant("Core", [tag |-> "UNIT"]),
                  definition |-> "Commitments and nullifiers hide ownership."]
              >>,
              <<
                Variant("Sd", [tag |-> "UNIT"]), [id |-> "E048",
                  name |-> "Selective-disclosure proof",
                  group |-> Variant("G14", [tag |-> "UNIT"]),
                  stratum |-> 2,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Candidate", [tag |-> "UNIT"]),
                  definition |->
                    "Prove a policy predicate without revealing the underlying credential."]
              >>,
              <<
                Variant("Fz", [tag |-> "UNIT"]), [id |-> "E056",
                  name |-> "Freeze / forced transfer",
                  group |-> Variant("G14", [tag |-> "UNIT"]),
                  stratum |-> 2,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Candidate", [tag |-> "UNIT"]),
                  definition |->
                    "Issuer- or authority-initiated immobilisation or reassignment of a holder claim without holder authorisation."]
              >>,
              <<
                Variant("Rs", [tag |-> "UNIT"]), [id |-> "E049",
                  name |-> "Restaking / shared security",
                  group |-> Variant("G15", [tag |-> "UNIT"]),
                  stratum |-> 4,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Candidate", [tag |-> "UNIT"]),
                  definition |->
                    "Slashable capital reused to secure additional services."]
              >>,
              <<
                Variant("Vl", [tag |-> "UNIT"]), [id |-> "E059",
                  name |-> "Staking & validator lifecycle",
                  group |-> Variant("G16", [tag |-> "UNIT"]),
                  stratum |-> 3,
                  atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                  status |-> Variant("Candidate", [tag |-> "UNIT"]),
                  definition |->
                    "Delegation, activation, exit, reward accrual and penalty attribution for consensus-securing capital."]
              >> })[
              legalFull_legalAssembly_required_2732_2
            ][
              "stratum"
            ]
              > SetAsFun({ <<
                  Variant("Sh", [tag |-> "UNIT"]), [id |-> "E001",
                    name |-> "Pro-rata share accounting",
                    group |-> Variant("G01", [tag |-> "UNIT"]),
                    stratum |-> 0,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |-> "Shares represent a proportional pool claim."]
                >>,
                <<
                  Variant("Ix", [tag |-> "UNIT"]), [id |-> "E002",
                    name |-> "Index-based accrual",
                    group |-> Variant("G01", [tag |-> "UNIT"]),
                    stratum |-> 0,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "A global exchange-rate or debt index changes claim value."]
                >>,
                <<
                  Variant("Rb", [tag |-> "UNIT"]), [id |-> "E003",
                    name |-> "Rebasing accounting",
                    group |-> Variant("G01", [tag |-> "UNIT"]),
                    stratum |-> 0,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Nominal balances change through global scaling."]
                >>,
                <<
                  Variant("Cp", [tag |-> "UNIT"]), [id |-> "E004",
                    name |-> "Constant-product invariant",
                    group |-> Variant("G02", [tag |-> "UNIT"]),
                    stratum |-> 1,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |-> "x·y = k."]
                >>,
                <<
                  Variant("Wg", [tag |-> "UNIT"]), [id |-> "E005",
                    name |-> "Weighted-geometric invariant",
                    group |-> Variant("G02", [tag |-> "UNIT"]),
                    stratum |-> 1,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |-> "Multi-asset weighted pricing."]
                >>,
                <<
                  Variant("St", [tag |-> "UNIT"]), [id |-> "E006",
                    name |-> "Stable-hybrid invariant",
                    group |-> Variant("G02", [tag |-> "UNIT"]),
                    stratum |-> 1,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Constant-sum near parity, constant-product away from it."]
                >>,
                <<
                  Variant("Cl", [tag |-> "UNIT"]), [id |-> "E007",
                    name |-> "Concentrated liquidity",
                    group |-> Variant("G02", [tag |-> "UNIT"]),
                    stratum |-> 1,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Range-specific position state and tick activation."]
                >>,
                <<
                  Variant("Pm", [tag |-> "UNIT"]), [id |-> "E008",
                    name |-> "Oracle-priced inventory curve",
                    group |-> Variant("G02", [tag |-> "UNIT"]),
                    stratum |-> 1,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Proactive market making against an external reference."]
                >>,
                <<
                  Variant("Ob", [tag |-> "UNIT"]), [id |-> "E009",
                    name |-> "On-chain order book",
                    group |-> Variant("G03", [tag |-> "UNIT"]),
                    stratum |-> 1,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Limit orders, sequencing, cancellation, settlement."]
                >>,
                <<
                  Variant("Rf", [tag |-> "UNIT"]), [id |-> "E010",
                    name |-> "Request for quote",
                    group |-> Variant("G03", [tag |-> "UNIT"]),
                    stratum |-> 1,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |-> "Signed maker quote against inventory."]
                >>,
                <<
                  Variant("Ba", [tag |-> "UNIT"]), [id |-> "E011",
                    name |-> "Batch-auction clearing",
                    group |-> Variant("G03", [tag |-> "UNIT"]),
                    stratum |-> 2,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |-> "Uniform clearing over a batch."]
                >>,
                <<
                  Variant("In", [tag |-> "UNIT"]), [id |-> "E012",
                    name |-> "Intent & solver execution",
                    group |-> Variant("G03", [tag |-> "UNIT"]),
                    stratum |-> 4,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Signed outcome constraints delegated to competing solvers."]
                >>,
                <<
                  Variant("Ag", [tag |-> "UNIT"]), [id |-> "E039",
                    name |-> "Aggregation & routing",
                    group |-> Variant("G04", [tag |-> "UNIT"]),
                    stratum |-> 1,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |-> "Multi-venue route construction."]
                >>,
                <<
                  Variant("Fl", [tag |-> "UNIT"]), [id |-> "E040",
                    name |-> "Atomic flash liquidity",
                    group |-> Variant("G04", [tag |-> "UNIT"]),
                    stratum |-> 1,
                    atom |-> Variant("AsyncImpossible", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Borrow and repay within one settlement scope or revert."]
                >>,
                <<
                  Variant("Pl", [tag |-> "UNIT"]), [id |-> "E013",
                    name |-> "Pooled lending",
                    group |-> Variant("G05", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Shared liquidity pool, many lenders and borrowers."]
                >>,
                <<
                  Variant("Im", [tag |-> "UNIT"]), [id |-> "E014",
                    name |-> "Isolated lending market",
                    group |-> Variant("G05", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Per-market risk isolation with its own oracle, LLTV and rate model."]
                >>,
                <<
                  Variant("Cd", [tag |-> "UNIT"]), [id |-> "E015",
                    name |-> "Collateralized-debt minting",
                    group |-> Variant("G05", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |-> "Mint a liability against locked collateral."]
                >>,
                <<
                  Variant("Uc", [tag |-> "UNIT"]), [id |-> "E016",
                    name |-> "Undercollateralized credit",
                    group |-> Variant("G05", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Credit extended on identity, underwriting and recourse."]
                >>,
                <<
                  Variant("Ft", [tag |-> "UNIT"]), [id |-> "E017",
                    name |-> "Fixed-term debt",
                    group |-> Variant("G05", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Maturity-dated claim with a discount factor."]
                >>,
                <<
                  Variant("Ct", [tag |-> "UNIT"]), [id |-> "E018",
                    name |-> "Collateral-threshold test",
                    group |-> Variant("G06", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "The margin/LTV/health computation and its threshold."]
                >>,
                <<
                  Variant("Li", [tag |-> "UNIT"]), [id |-> "E019",
                    name |-> "Incentivized liquidation",
                    group |-> Variant("G06", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Third parties repay unhealthy debt for discounted collateral."]
                >>,
                <<
                  Variant("Ad", [tag |-> "UNIT"]), [id |-> "E020",
                    name |-> "Auto-deleveraging",
                    group |-> Variant("G06", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Rank-ordered forced close when buffers are exhausted."]
                >>,
                <<
                  Variant("Sl", [tag |-> "UNIT"]), [id |-> "E021",
                    name |-> "Socialized-loss allocation",
                    group |-> Variant("G06", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |-> "Losses assigned to an explicit claim class."]
                >>,
                <<
                  Variant("Bs", [tag |-> "UNIT"]), [id |-> "E022",
                    name |-> "Staked backstop",
                    group |-> Variant("G06", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |-> "Slashable first-loss capital."]
                >>,
                <<
                  Variant("Pf", [tag |-> "UNIT"]), [id |-> "E023",
                    name |-> "Perpetual funding transfer",
                    group |-> Variant("G07", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Periodic payment tethering a perp to an index."]
                >>,
                <<
                  Variant("Op", [tag |-> "UNIT"]), [id |-> "E024",
                    name |-> "Option payoff",
                    group |-> Variant("G07", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Strike, expiry, collateralized contingent settlement."]
                >>,
                <<
                  Variant("Tr", [tag |-> "UNIT"]), [id |-> "E025",
                    name |-> "Tranche waterfall",
                    group |-> Variant("G07", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Declared seniority over a determined loss event."]
                >>,
                <<
                  Variant("Cv", [tag |-> "UNIT"]), [id |-> "E026",
                    name |-> "Mutual cover pool",
                    group |-> Variant("G07", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Adjudicated claims against pooled premium capital."]
                >>,
                <<
                  Variant("Py", [tag |-> "UNIT"]), [id |-> "E027",
                    name |-> "Principal/yield separation",
                    group |-> Variant("G07", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |-> "Split a yield-bearing claim into PT and YT."]
                >>,
                <<
                  Variant("Sv", [tag |-> "UNIT"]), [id |-> "E057",
                    name |-> "Servicing & determination discretion",
                    group |-> Variant("G07", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Candidate", [tag |-> "UNIT"]),
                    definition |->
                      "A named party's discretionary determination of loss, valuation, cure, waiver or suspension that alters others' claims."]
                >>,
                <<
                  Variant("Dp", [tag |-> "UNIT"]), [id |-> "E060",
                    name |-> "Directional position & hedge maintenance",
                    group |-> Variant("G07", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Candidate", [tag |-> "UNIT"]),
                    definition |->
                      "A held directional exposure and the rebalancing that maintains it."]
                >>,
                <<
                  Variant("Ex", [tag |-> "UNIT"]), [id |-> "E028",
                    name |-> "External data oracle",
                    group |-> Variant("G08", [tag |-> "UNIT"]),
                    stratum |-> 2,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |-> "Imported off-chain value."]
                >>,
                <<
                  Variant("Tp", [tag |-> "UNIT"]), [id |-> "E029",
                    name |-> "Time-weighted price",
                    group |-> Variant("G08", [tag |-> "UNIT"]),
                    stratum |-> 2,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |-> "Cumulative-price accumulator over a window."]
                >>,
                <<
                  Variant("Oa", [tag |-> "UNIT"]), [id |-> "E030",
                    name |-> "Optimistic assertion oracle",
                    group |-> Variant("G08", [tag |-> "UNIT"]),
                    stratum |-> 2,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |-> "Assert-then-dispute escalation game."]
                >>,
                <<
                  Variant("At", [tag |-> "UNIT"]), [id |-> "E031",
                    name |-> "Reserve / NAV attestation",
                    group |-> Variant("G08", [tag |-> "UNIT"]),
                    stratum |-> 2,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "A named party's statement about backing or value."]
                >>,
                <<
                  Variant("Sr", [tag |-> "UNIT"]), [id |-> "E032",
                    name |-> "Streaming accrual",
                    group |-> Variant("G09", [tag |-> "UNIT"]),
                    stratum |-> 2,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |-> "Continuous per-second transfer from escrow."]
                >>,
                <<
                  Variant("Ep", [tag |-> "UNIT"]), [id |-> "E033",
                    name |-> "Epoch-gated transition",
                    group |-> Variant("G09", [tag |-> "UNIT"]),
                    stratum |-> 2,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |-> "Snapshot, cutoff, rollover."]
                >>,
                <<
                  Variant("Wq", [tag |-> "UNIT"]), [id |-> "E034",
                    name |-> "Withdrawal queue",
                    group |-> Variant("G09", [tag |-> "UNIT"]),
                    stratum |-> 2,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Request now, claim later, against future asset availability."]
                >>,
                <<
                  Variant("Em", [tag |-> "UNIT"]), [id |-> "E035",
                    name |-> "Protocol-funded emissions",
                    group |-> Variant("G10", [tag |-> "UNIT"]),
                    stratum |-> 2,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Newly issued tokens paid for measured actions."]
                >>,
                <<
                  Variant("Fd", [tag |-> "UNIT"]), [id |-> "E058",
                    name |-> "Surplus & fee distribution",
                    group |-> Variant("G10", [tag |-> "UNIT"]),
                    stratum |-> 2,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Candidate", [tag |-> "UNIT"]),
                    definition |->
                      "The rule naming the residual claimant of fees, spread and surplus."]
                >>,
                <<
                  Variant("Tg", [tag |-> "UNIT"]), [id |-> "E036",
                    name |-> "Delayed-governance execution",
                    group |-> Variant("G11", [tag |-> "UNIT"]),
                    stratum |-> 4,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "A timelock between authorization and executability."]
                >>,
                <<
                  Variant("Up", [tag |-> "UNIT"]), [id |-> "E037",
                    name |-> "Mutable implementation proxy",
                    group |-> Variant("G11", [tag |-> "UNIT"]),
                    stratum |-> 4,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Code replacement changes the reachable state machine."]
                >>,
                <<
                  Variant("Gp", [tag |-> "UNIT"]), [id |-> "E038",
                    name |-> "Guardian or pause",
                    group |-> Variant("G11", [tag |-> "UNIT"]),
                    stratum |-> 4,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Bounded suppression of reachable transitions."]
                >>,
                <<
                  Variant("Au", [tag |-> "UNIT"]), [id |-> "E050",
                    name |-> "Delegated execution scope",
                    group |-> Variant("G11", [tag |-> "UNIT"]),
                    stratum |-> 4,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Persistent policy bounding the calls, assets, destinations, values, chains and time windows a delegate may reach."]
                >>,
                <<
                  Variant("Gs", [tag |-> "UNIT"]), [id |-> "E051",
                    name |-> "Sponsored-fee liability",
                    group |-> Variant("G11", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Candidate", [tag |-> "UNIT"]),
                    definition |->
                      "A conditional fee liability with metering and reimbursement."]
                >>,
                <<
                  Variant("Xm", [tag |-> "UNIT"]), [id |-> "E041",
                    name |-> "Cross-domain message verification",
                    group |-> Variant("G12", [tag |-> "UNIT"]),
                    stratum |-> 4,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Decide whether a source-domain assertion is acceptable at the destination."]
                >>,
                <<
                  Variant("Xf", [tag |-> "UNIT"]), [id |-> "E042",
                    name |-> "Cross-domain asset transfer",
                    group |-> Variant("G12", [tag |-> "UNIT"]),
                    stratum |-> 4,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Create a destination claim against an explicit source debit."]
                >>,
                <<
                  Variant("Rl", [tag |-> "UNIT"]), [id |-> "E053",
                    name |-> "Resource lock / reservation",
                    group |-> Variant("G12", [tag |-> "UNIT"]),
                    stratum |-> 4,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Candidate", [tag |-> "UNIT"]),
                    definition |->
                      "Enforceable pre-commitment with exclusivity, expiry, fulfillment and release."]
                >>,
                <<
                  Variant("Of", [tag |-> "UNIT"]), [id |-> "E054",
                    name |-> "Optimistic fill & reimbursement",
                    group |-> Variant("G12", [tag |-> "UNIT"]),
                    stratum |-> 4,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Candidate", [tag |-> "UNIT"]),
                    definition |->
                      "A filler advances destination value before finality and holds a contingent reimbursement claim."]
                >>,
                <<
                  Variant("Rd", [tag |-> "UNIT"]), [id |-> "E043",
                    name |-> "Direct redemption right",
                    group |-> Variant("G13", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Redeem a liability against backing at a defined rate."]
                >>,
                <<
                  Variant("Ps", [tag |-> "UNIT"]), [id |-> "E044",
                    name |-> "Peg-swap module",
                    group |-> Variant("G13", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "1:1 reserve-backed swap with mint/burn authority."]
                >>,
                <<
                  Variant("As", [tag |-> "UNIT"]), [id |-> "E045",
                    name |-> "Algorithmic supply adjustment",
                    group |-> Variant("G13", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |->
                      "Supply expansion/contraction driven by measured price."]
                >>,
                <<
                  Variant("Aw", [tag |-> "UNIT"]), [id |-> "E046",
                    name |-> "Permission / identity gate",
                    group |-> Variant("G14", [tag |-> "UNIT"]),
                    stratum |-> 2,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |-> "Credential-checked eligibility."]
                >>,
                <<
                  Variant("Sb", [tag |-> "UNIT"]), [id |-> "E047",
                    name |-> "Shielded-balance state",
                    group |-> Variant("G14", [tag |-> "UNIT"]),
                    stratum |-> 2,
                    atom |-> Variant("AsyncRepairable", [tag |-> "UNIT"]),
                    status |-> Variant("Core", [tag |-> "UNIT"]),
                    definition |-> "Commitments and nullifiers hide ownership."]
                >>,
                <<
                  Variant("Sd", [tag |-> "UNIT"]), [id |-> "E048",
                    name |-> "Selective-disclosure proof",
                    group |-> Variant("G14", [tag |-> "UNIT"]),
                    stratum |-> 2,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Candidate", [tag |-> "UNIT"]),
                    definition |->
                      "Prove a policy predicate without revealing the underlying credential."]
                >>,
                <<
                  Variant("Fz", [tag |-> "UNIT"]), [id |-> "E056",
                    name |-> "Freeze / forced transfer",
                    group |-> Variant("G14", [tag |-> "UNIT"]),
                    stratum |-> 2,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Candidate", [tag |-> "UNIT"]),
                    definition |->
                      "Issuer- or authority-initiated immobilisation or reassignment of a holder claim without holder authorisation."]
                >>,
                <<
                  Variant("Rs", [tag |-> "UNIT"]), [id |-> "E049",
                    name |-> "Restaking / shared security",
                    group |-> Variant("G15", [tag |-> "UNIT"]),
                    stratum |-> 4,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Candidate", [tag |-> "UNIT"]),
                    definition |->
                      "Slashable capital reused to secure additional services."]
                >>,
                <<
                  Variant("Vl", [tag |-> "UNIT"]), [id |-> "E059",
                    name |-> "Staking & validator lifecycle",
                    group |-> Variant("G16", [tag |-> "UNIT"]),
                    stratum |-> 3,
                    atom |-> Variant("AsyncNative", [tag |-> "UNIT"]),
                    status |-> Variant("Candidate", [tag |-> "UNIT"]),
                    definition |->
                      "Delegation, activation, exit, reward accrual and penalty attribution for consensus-securing capital."]
                >> })[
                t_8_1
              ][
                "stratum"
              ]))))))

================================================================================
(* Created by Apalache on Tue Aug 04 12:36:02 MDT 2026 *)
(* https://github.com/apalache-mc/apalache *)
