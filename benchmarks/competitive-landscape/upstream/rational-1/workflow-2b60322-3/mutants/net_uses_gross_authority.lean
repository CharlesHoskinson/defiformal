import NetFixtures

namespace RationalWorkflow.Net.Witnesses

def control_net_uses_gross_authority : IO Unit := do
  let state := invokeOnly
  let transfers := cycleTransfers
  let passed := settledExactly state transfers (0) (0)
  IO.println s!"CONTROL net_uses_gross_authority {passed}"
  match net state transfers with
  | .success post => IO.println s!"OBSERVED net_uses_gross_authority SUCCESS ALICE {post.ledger.balance (.alice, .usd)} BOB {post.ledger.balance (.bob, .usd)} EVENTS {post.history.length}"
  | .refused reason index post => IO.println s!"OBSERVED net_uses_gross_authority REFUSED {repr reason} INDEX {repr index} ALICE {post.ledger.balance (.alice, .usd)} BOB {post.ledger.balance (.bob, .usd)} EVENTS {post.history.length}"

#eval control_net_uses_gross_authority

end RationalWorkflow.Net.Witnesses
