import WorkflowRevokeProofs

namespace RationalWorkflow

theorem r5_canonical : R5Canonical := by
  constructor
  · intro state call cap valid domain required
    obtain ⟨first, executed, claims⟩ := execute_success state call valid domain
    let revoked := adminUpdate first (.revoke .pool cap)
    have validFirst := claims.valid valid
    have validRevoked : ValidState revoked := validFirst
    have erased : cap ∉ revoked.capabilities := by simp [revoked, adminUpdate, nextCapabilities]
    have unauthorized : ¬ Authorized revoked.capabilities call := by
      intro authority
      exact erased (required_authority _ call cap required authority)
    refine ⟨first, revoked, executed, claims, (admin_success first cap validFirst).2,
      rfl, erased, ?_, (admin_success revoked cap validRevoked).1, ?_⟩
    · exact (execute_refusal revoked call).2.1 domain.1 unauthorized
    · simp [adminUpdate, nextCapabilities]
  · intro state cap valid
    obtain ⟨grant, revoke⟩ := admin_success state cap valid
    refine ⟨grant, revoke, ?_, ?_, ?_⟩
    · intro actor notAdmin
      constructor
      · exact (execute_refusal state (.grant actor cap)).2.1 trivial notAdmin
      · exact (execute_refusal state (.revoke actor cap)).2.1 trivial notAdmin
    · simp [nextCapabilities]
    · simp [nextCapabilities]

#print axioms r5_canonical
end RationalWorkflow
