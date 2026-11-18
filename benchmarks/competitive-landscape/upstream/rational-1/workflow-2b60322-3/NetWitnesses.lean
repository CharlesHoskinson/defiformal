import NetFixtures

namespace RationalWorkflow.Net.Witnesses

def main : IO Unit := do
  for (name, passed) in checks do
    if passed then IO.println s!"WITNESS {name} passed"
    else throw (IO.userError s!"WITNESS {name} FAILED")
  for (name, s, ts) in [("net_alias", initial 1 (by norm_num), aliasTransfers),
      ("net_cycle", zeroState, cycleTransfers), ("net_cycle_invoke_only", invokeOnly, cycleTransfers),
      ("net_sequential_agreement", initial 3 (by norm_num), cycleTransfers)] do
    match net s ts with
    | .success post => IO.println s!"NET {name} ALICE {post.ledger.balance (.alice, .usd)} BOB {post.ledger.balance (.bob, .usd)} SUPPLY {post.supply .cash} EVENTS {post.history.length}"
    | .refused reason index _ => IO.println s!"REFUSED {name} {repr reason} {repr index}"
    let sequence := runCalls s (ts.map Instruction.call)
    IO.println s!"SEQUENTIAL {name} FAILURE {repr sequence.failure} COMMITTED {sequence.committed} EVENTS {sequence.state.history.length}"

#eval main

end RationalWorkflow.Net.Witnesses
