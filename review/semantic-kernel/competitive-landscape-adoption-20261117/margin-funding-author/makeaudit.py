from pathlib import Path
s=Path('/private/tmp/defiformal-margin-funding-author/First.lean').read_text()
s=s.replace('open DefiKernel DefiKernel.Typed DefiKernel.Margin','namespace DefiKernel.Margin.FundingAudit\nopen DefiKernel.Typed')
s=s.replace('private def checks :', '''private def refused (actual : Except Funding.Refusal (Funding.State × Funding.Receipt))
    (expected : Funding.Refusal) : Bool :=
  match actual with | .ok _ => false | .error reason => decide (reason=expected)
private def custom (payIds holdingIds : List CapabilityId) (configured : Bool := true)
    (ctx : InvocationContext Party Domain := ownerContext) :=
  Funding.run (before 0 3) latest domain prices ⟨0,0,3⟩ configured ctx payIds holdingIds
private def checks :''')
s=s.replace('(\"secondary_payment_requires_holding_configuration\",match run 0 3 false with\n    | .ok _ => false | .error reason => decide (reason=Funding.Refusal.emptyHoldingAddress))]', '''("secondary_payment_requires_holding_configuration",refused (run 0 3 false) .emptyHoldingAddress),
  ("missing_holding_invoke",refused (custom Funding.payIds [⟨5⟩]) (.typed .unauthorizedInvoke)),
  ("missing_holding_supply",refused (custom Funding.payIds [⟨4⟩]) (.typed .unauthorizedSupply)),
  ("holding_configuration_precedes_holding_invoke",refused (custom Funding.payIds [] false) .emptyHoldingAddress),
  ("payment_invoke_precedes_holding_configuration",refused (custom [] [] false) (.typed .unauthorizedInvoke)),
  ("secondary_debit_precedes_holding_configuration",refused (custom [⟨0⟩,⟨1⟩,⟨2⟩] [] false) (.typed .unauthorizedDebit)),
  ("wrong_actor_precedes_payment",refused (custom Funding.payIds Funding.holdingIds true ⟨.pool,.margin⟩)
    (.typed .actorMismatch)),
  ("wrong_preledger_bucket",refused (Funding.run (before 0 3) latest domain prices ⟨0,0,0⟩ false
    ownerContext Funding.payIds Funding.holdingIds) (.typed .guard)),
  ("secondary_payment_preserves_physical_totals",match run 0 3 true with
    | .error _ => false | .ok (after,_) => decide (total after.world.state .margin .primary=100 ∧
      total after.world.state .margin .secondary=3 ∧ total after.world.state .margin .claimPrimary=7 ∧
      total after.world.state .margin .claimSecondary=19)),
  ("primary_payment_needs_no_holding_rights_or_configuration",match Funding.run (before 3 0) latest domain
      prices ⟨0,3,0⟩ false ownerContext Funding.payIds [] with
    | .error _ => false | .ok (after,r) => decide (r.holdingCollateralClaimSecondary=0 ∧
      r.insufficientPrimaryFundingPayment=false ∧ after.world.state.balance (.margin,.holding,.claimSecondary)=5)),
  ("partial_secondary_distinguishes_three_observations",match Funding.run (before 0 1) latest domain prices
      ⟨0,0,1⟩ true ownerContext Funding.payIds Funding.holdingIds with
    | .error _ => false | .ok (after,r) => decide (r.insufficientPrimaryFundingPayment=true ∧
      r.payment.sourceRemainingCostUsd=4 ∧ r.payment.economicShortfallUsd=4 ∧
      r.holdingCollateralClaimSecondary=1 ∧ after.world.state.balance (.margin,.holding,.claimSecondary)=6)),
  ("quote_keeps_latest_factors_in_receipt",decide ((Funding.quote position latest domain).latest=latest)),
  ("zero_delta_quote_is_zero",decide (let q:=Funding.quote position ⟨0,0,0⟩ (by decide);
      q.feePrimary=0 ∧ q.pendingClaimPrimary=0 ∧ q.pendingClaimSecondary=0)),
  ("monotonic_snapshot_domain_is_not_a_silent_unsigned_subtraction",decide
    (¬ Funding.Admissible {position with snapshots:=⟨2,0,0⟩} latest)),
  ("zero_size_quote_is_zero",decide (let q:=Funding.quote {position with sizeUsd:=0} latest (by decide);
      q.feePrimary=0 ∧ q.pendingClaimPrimary=0 ∧ q.pendingClaimSecondary=0)),
  ("secondary_receipt_retains_claims_even_with_positive_source_residual",match Funding.run (before 0 1)
      latest domain prices ⟨0,0,1⟩ true ownerContext Funding.payIds Funding.holdingIds with
    | .error _ => false | .ok (after,r) => decide (r.funding.pendingClaimPrimary=2 ∧
      r.funding.pendingClaimSecondary=3 ∧ after.position.snapshots=position.snapshots ∧
      after.position.sizeUsd=position.sizeUsd ∧ after.position.impactUsd= -1))]''')
s=s.replace('  for (name,passed) in checks do IO.println s!"FUNDING_FIRST {name} {passed}"','''  if !decide (checks.map Prod.fst).Nodup then throw (IO.userError "BLOCKED: duplicate funding controls")
  let q:=Funding.quote position latest domain
  IO.println s!"FUNDING_QUOTE {q.feePrimary} {q.pendingClaimPrimary} {q.pendingClaimSecondary}"
  match run 0 3 true with
  | .error reason => IO.println s!"FUNDING_OBSERVATION refused {repr reason}"
  | .ok (after,r) => IO.println s!"FUNDING_OBSERVATION {after.world.state.balance (.margin,.output,.secondary)} {after.world.state.balance (.margin,.costRecipient,.secondary)} {after.world.state.balance (.margin,.holding,.claimSecondary)} {after.world.state.balance (.margin,.owner,.claimSecondary)} {r.payment.sourceRemainingCostUsd} {r.payment.economicShortfallUsd} {r.insufficientPrimaryFundingPayment}"
  for (name,passed) in checks do IO.println s!"FUNDING_CONTROL {name} {passed}"''')
s+='  IO.println s!"FUNDING_CONTROL PASSED {checks.length}/{checks.length}"\nend DefiKernel.Margin.FundingAudit\n'
Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/FundingAudit.lean').write_text(s)
