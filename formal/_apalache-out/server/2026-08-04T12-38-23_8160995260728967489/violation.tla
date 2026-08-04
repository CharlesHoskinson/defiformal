---------------------------- MODULE counterexample ----------------------------

EXTENDS legalFull

(* Constant initialization state *)
ConstInit == TRUE

(* Initial state [_transition(0)] *)
State0 == legalFull_legalAssembly_chosen = {}

(* State1 [_transition(0)] *)
State1 == legalFull_legalAssembly_chosen = {Variant("Fl", [tag |-> "UNIT"])}

(* State2 [_transition(0)] *)
State2 ==
  legalFull_legalAssembly_chosen
      = { Variant("Fl", [tag |-> "UNIT"]), Variant("Xm", [tag |-> "UNIT"]) }

(* The following formula holds true in the last state and violates the invariant *)
InvariantViolation ==
  Variant("Fl", [tag |-> "UNIT"]) \in legalFull_legalAssembly_chosen
    /\ ~({
      t_6_1 \in legalFull_legalAssembly_chosen:
        t_6_1
            \in { Variant("Sh", [tag |-> "UNIT"]),
              Variant("Ix", [tag |-> "UNIT"]),
              Variant("Rb", [tag |-> "UNIT"]),
              Variant("Cp", [tag |-> "UNIT"]),
              Variant("Wg", [tag |-> "UNIT"]),
              Variant("St", [tag |-> "UNIT"]),
              Variant("Cl", [tag |-> "UNIT"]),
              Variant("Pm", [tag |-> "UNIT"]),
              Variant("Ob", [tag |-> "UNIT"]),
              Variant("Rf", [tag |-> "UNIT"]),
              Variant("Ba", [tag |-> "UNIT"]),
              Variant("In", [tag |-> "UNIT"]),
              Variant("Ag", [tag |-> "UNIT"]),
              Variant("Fl", [tag |-> "UNIT"]),
              Variant("Pl", [tag |-> "UNIT"]),
              Variant("Im", [tag |-> "UNIT"]),
              Variant("Cd", [tag |-> "UNIT"]),
              Variant("Uc", [tag |-> "UNIT"]),
              Variant("Ft", [tag |-> "UNIT"]),
              Variant("Ct", [tag |-> "UNIT"]),
              Variant("Li", [tag |-> "UNIT"]),
              Variant("Ad", [tag |-> "UNIT"]),
              Variant("Sl", [tag |-> "UNIT"]),
              Variant("Bs", [tag |-> "UNIT"]),
              Variant("Pf", [tag |-> "UNIT"]),
              Variant("Op", [tag |-> "UNIT"]),
              Variant("Tr", [tag |-> "UNIT"]),
              Variant("Cv", [tag |-> "UNIT"]),
              Variant("Py", [tag |-> "UNIT"]),
              Variant("Sv", [tag |-> "UNIT"]),
              Variant("Dp", [tag |-> "UNIT"]),
              Variant("Ex", [tag |-> "UNIT"]),
              Variant("Tp", [tag |-> "UNIT"]),
              Variant("Oa", [tag |-> "UNIT"]),
              Variant("At", [tag |-> "UNIT"]),
              Variant("Sr", [tag |-> "UNIT"]),
              Variant("Ep", [tag |-> "UNIT"]),
              Variant("Wq", [tag |-> "UNIT"]),
              Variant("Em", [tag |-> "UNIT"]),
              Variant("Fd", [tag |-> "UNIT"]),
              Variant("Tg", [tag |-> "UNIT"]),
              Variant("Up", [tag |-> "UNIT"]),
              Variant("Gp", [tag |-> "UNIT"]),
              Variant("Au", [tag |-> "UNIT"]),
              Variant("Gs", [tag |-> "UNIT"]),
              Variant("Xm", [tag |-> "UNIT"]),
              Variant("Xf", [tag |-> "UNIT"]),
              Variant("Rl", [tag |-> "UNIT"]),
              Variant("Of", [tag |-> "UNIT"]),
              Variant("Rd", [tag |-> "UNIT"]),
              Variant("Ps", [tag |-> "UNIT"]),
              Variant("As", [tag |-> "UNIT"]),
              Variant("Aw", [tag |-> "UNIT"]),
              Variant("Sb", [tag |-> "UNIT"]),
              Variant("Sd", [tag |-> "UNIT"]),
              Variant("Fz", [tag |-> "UNIT"]),
              Variant("Rs", [tag |-> "UNIT"]),
              Variant("Vl", [tag |-> "UNIT"]) }
          /\ SetAsFun({ <<
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
                definition |-> "Nominal balances change through global scaling."]
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
                definition |-> "Periodic payment tethering a perp to an index."]
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
                definition |-> "Newly issued tokens paid for measured actions."]
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
            t_6_1
          ][
            "group"
          ]
            = Variant("G12", [tag |-> "UNIT"])
    }
      = {})

================================================================================
(* Created by Apalache on Tue Aug 04 12:39:56 MDT 2026 *)
(* https://github.com/apalache-mc/apalache *)
