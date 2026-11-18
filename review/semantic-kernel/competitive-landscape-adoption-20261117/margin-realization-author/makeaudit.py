from pathlib import Path
s=Path('/private/tmp/defiformal-margin-realization-author/First.lean').read_text().replace('open DefiKernel DefiKernel.Typed DefiKernel.Margin','namespace DefiKernel.Margin.RealizationAudit\nopen DefiKernel.Typed')
s=s.replace('private def checks :','''private def refused (actual : Except Typed.Refusal (Funding.State × Realization.Receipt))
    (expected : Typed.Refusal) : Bool :=
  match actual with | .ok _ => false | .error reason => decide (reason=expected)
private def checks :''')
s=s.replace('after.world.capabilities=(CapabilityStore.empty : Store)))]','''after.world.capabilities=(CapabilityStore.empty : Store))),
  ("positive_pnl_requires_invoke",refused (Realization.run (before 5 .primary) 10 .primary price
    ownerContext [⟨1⟩]) .unauthorizedInvoke),
  ("positive_payment_requires_actual_pool_debit",refused (Realization.run (before 5 .primary) 10 .primary price
    ownerContext [⟨0⟩]) .unauthorizedDebit),
  ("actor_binding_before_pool_funding",refused (Realization.run (before 0 .primary) 10 .primary price
    ⟨.pool,.margin⟩ Realization.ids) .actorMismatch),
  ("wrong_token_authority_cannot_debit_other_pool",refused (Realization.run
    ⟨⟨ledger 5,Realization.fixtureStore .primary⟩,position⟩ 10 .secondary price ownerContext Realization.ids)
    .unauthorizedDebit),
  ("positive_subtoken_pnl_zero_transfer_invoke_only",match Realization.run (before 0 .primary) 1 .primary
      price ownerContext [⟨0⟩] with
    | .error _ => false | .ok (after,r) => decide (r.paidTokens=0 ∧ r.floorDustUsd=1 ∧
      after.world.state.balance (.margin,.pool,.primary)=0 ∧
      after.world.state.balance (.margin,.output,.primary)=1)),
  ("positive_subtoken_pnl_still_requires_invoke",refused (Realization.run (before 0 .primary) 1 .primary
    price ownerContext []) .unauthorizedInvoke),
  ("actual_physical_and_claim_totals_conserve",match run 5 10 .primary with
    | .error _ => false | .ok (after,_) => decide (total after.world.state .margin .primary=6 ∧
      total after.world.state .margin .secondary=7 ∧ total after.world.state .margin .claimSecondary=16)),
  ("owner_claims_holding_claims_and_snapshots_frame",match run 5 10 .primary with
    | .error _ => false | .ok (after,_) => decide (after.position=position ∧
      after.world.state.balance (.margin,.owner,.claimSecondary)=11 ∧
      after.world.state.balance (.margin,.holding,.claimSecondary)=5 ∧
      after.world.state.balance (.margin,.pool,.secondary)=5 ∧
      after.world.state.balance (.margin,.output,.secondary)=2)),
  ("marked_pnl_is_distinct_from_close_base_observation",match run 5 10 .primary with
    | .error _ => false | .ok (after,r) => decide (after.position.pnlUsd=100 ∧
      r.basePnlUsd=10 ∧ r.paidTokens=3)),
  ("primary_floor_exact_multiple",match run 5 9 .primary with
    | .error _ => false | .ok (after,r) => decide (r.paidTokens=3 ∧ r.floorDustUsd=0 ∧
      after.world.state.balance (.margin,.pool,.primary)=2)),
  ("fully_depleted_pool_remains_nonnegative",match run 3 10 .secondary with
    | .error _ => false | .ok (after,r) => decide (r.paidTokens=3 ∧
      after.world.state.balance (.margin,.pool,.secondary)=0 ∧
      after.world.state.balance (.margin,.output,.secondary)=5)),
  ("negative_pnl_is_not_realized_as_positive_cash",match run 0 (-10) .secondary with
    | .error _ => false | .ok (after,r) => decide (r.paidTokens=0 ∧
      after.world.state.balance (.margin,.pool,.secondary)=0 ∧
      after.world.state.balance (.margin,.output,.secondary)=2))]''')
s=s.replace('  for (name,passed) in checks do IO.println s!"REALIZATION_FIRST {name} {passed}"','''  if !decide (checks.map Prod.fst).Nodup then throw (IO.userError "BLOCKED: duplicate realization controls")
  match run 5 10 .primary with
  | .error reason => IO.println s!"REALIZATION_OBSERVATION refused {repr reason}"
  | .ok (after,r) => IO.println s!"REALIZATION_OBSERVATION {after.world.state.balance (.margin,.pool,.primary)} {after.world.state.balance (.margin,.output,.primary)} {r.paidTokens} {r.floorDustUsd}"
  for (name,passed) in checks do IO.println s!"REALIZATION_CONTROL {name} {passed}"''')
s+='  IO.println s!"REALIZATION_CONTROL PASSED {checks.length}/{checks.length}"\nend DefiKernel.Margin.RealizationAudit\n'
Path('/private/tmp/defiformal-ci-author/lean/DefiKernel/Margin/RealizationAudit.lean').write_text(s)
