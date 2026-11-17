import WorkflowControl
import LocalContracts

namespace RationalWorkflow

theorem ledger_ext (left right : DefiKernel.State)
    (h : ∀ cell, left.balance cell = right.balance cell) : left = right := by
  cases left with
  | mk lb ln =>
    cases right with
    | mk rb rn =>
      have : lb = rb := funext h
      cases this
      rfl

theorem public_ext (left right : PublicState)
    (ledger : left.ledger = right.ledger) (rates : left.rates = right.rates)
    (caps : left.capabilities = right.capabilities) (history : left.history = right.history) :
    left = right := by
  cases left
  cases right
  simp_all

theorem admin_post (state post : PublicState) (call : Call)
    (zero : ∀ cell, effect state.rates call cell = 0)
    (claims : LocalClaims state post call) : post = adminUpdate state call := by
  apply public_ext
  · apply ledger_ext
    intro cell
    simpa [adminUpdate, zero cell] using claims.balances cell
  · exact claims.rates
  · exact claims.capabilities
  · exact claims.history

theorem admin_success (state : PublicState) (cap : Capability) (valid : ValidState state) :
    execute state (.grant .pool cap) = .success (adminUpdate state (.grant .pool cap)) ∧
    execute state (.revoke .pool cap) = .success (adminUpdate state (.revoke .pool cap)) := by
  constructor
  · obtain ⟨post, executed, claims⟩ := execute_success state (.grant .pool cap) valid
      (by simp [SuccessDomain, AmountValid, Authorized, Funded])
    rw [admin_post state post (.grant .pool cap) (by intro cell; rfl) claims] at executed
    exact executed
  · obtain ⟨post, executed, claims⟩ := execute_success state (.revoke .pool cap) valid
      (by simp [SuccessDomain, AmountValid, Authorized, Funded])
    rw [admin_post state post (.revoke .pool cap) (by intro cell; rfl) claims] at executed
    exact executed

theorem required_authority (caps : Finset Capability) (call : Call) (cap : Capability)
    (required : cap ∈ requiredCapabilities call) (authority : Authorized caps call) : cap ∈ caps := by
  cases call <;> simp_all [requiredCapabilities, Authorized] <;> aesop

end RationalWorkflow
