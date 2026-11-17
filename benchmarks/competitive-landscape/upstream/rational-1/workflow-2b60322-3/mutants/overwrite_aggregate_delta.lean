import NetFixtures

namespace RationalWorkflow.Net.Witnesses

def control_overwrite_aggregate_delta : IO Unit := do
  let state := initial 1 (by norm_num)
  let transfers := aliasTransfers
  let passed := settledExactly state transfers (3/4) (1/4)
  IO.println s!"CONTROL overwrite_aggregate_delta {passed}"
  match net state transfers with
  | .success post => IO.println s!"OBSERVED overwrite_aggregate_delta SUCCESS ALICE {post.ledger.balance (.alice, .usd)} BOB {post.ledger.balance (.bob, .usd)} EVENTS {post.history.length}"
  | .refused reason index post => IO.println s!"OBSERVED overwrite_aggregate_delta REFUSED {repr reason} INDEX {repr index} ALICE {post.ledger.balance (.alice, .usd)} BOB {post.ledger.balance (.bob, .usd)} EVENTS {post.history.length}"

#eval control_overwrite_aggregate_delta

end RationalWorkflow.Net.Witnesses
