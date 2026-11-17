import NetFixtures

namespace RationalWorkflow.Net.Witnesses

def control_net_uses_sequential_guards : IO Unit := do
  let state := zeroState
  let transfers := cycleTransfers
  let passed := settledExactly state transfers (0) (0)
  IO.println s!"CONTROL net_uses_sequential_guards {passed}"
  match net state transfers with
  | .success post => IO.println s!"OBSERVED net_uses_sequential_guards SUCCESS ALICE {post.ledger.balance (.alice, .usd)} BOB {post.ledger.balance (.bob, .usd)} EVENTS {post.history.length}"
  | .refused reason index post => IO.println s!"OBSERVED net_uses_sequential_guards REFUSED {repr reason} INDEX {repr index} ALICE {post.ledger.balance (.alice, .usd)} BOB {post.ledger.balance (.bob, .usd)} EVENTS {post.history.length}"

#eval control_net_uses_sequential_guards

end RationalWorkflow.Net.Witnesses
