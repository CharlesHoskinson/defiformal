import NetModel

set_option synthInstance.maxSize 8192

namespace RationalWorkflow.Net.Witnesses

def capabilities : Finset Capability :=
  [.invoke .vault .transfer, .invoke .vault .deposit, .invoke .vault .withdraw,
   .supply .vault false, .supply .vault true].toFinset ∪
    (([.alice, .bob, .vault, .pool] : List Account).flatMap fun account =>
      [Asset.cash, .shareA, .shareB].map fun asset => Capability.debit .vault account asset).toFinset

def initial (amount : ℚ) (nonnegative : 0 ≤ amount) : PublicState where
  ledger := ⟨fun cell => if cell = (.alice, .usd) then amount else 0,
    fun cell => by split_ifs; exact nonnegative; exact le_refl 0⟩
  rates := fun vault => if vault then 7/5 else 3/2
  capabilities := capabilities
  history := []

def zeroState : PublicState := initial 0 (by norm_num)
def invokeOnly : PublicState := { zeroState with capabilities := {.invoke .vault .transfer} }
def noAuthority : PublicState := { zeroState with capabilities := ∅ }
def cells : List Cell := DefiKernel.Examples.allCells
def assets : List Asset := [.cash, .shareA, .shareB]

def observeEvent (e : Event) : List Call × List ℚ × List ℚ × List ℚ :=
  (e.calls, cells.map e.delta, assets.map e.issued, assets.map e.burned)
def observe (s : PublicState) :
    List ℚ × List ℚ × List ℚ × Finset Capability × List (List Call × List ℚ × List ℚ × List ℚ) :=
  (cells.map s.ledger.balance, assets.map s.supply, [s.rates false, s.rates true],
    s.capabilities, s.history.map observeEvent)

def refusedExactly (result : NetResult) (reason : Reason) (index : Option Nat) (s : PublicState) : Bool :=
  match result with
  | .refused actual actualIndex post => decide (actual = reason ∧ actualIndex = index ∧ observe post = observe s)
  | .success _ => false

def accountName : Account → String
  | .alice => "alice" | .bob => "bob" | .vault => "vaultA" | .pool => "vaultB"
def actorName : Principal → String
  | .alice => "alice" | .bob => "bob" | .vault => "operator" | .pool => "admin"
def assetName : Asset → String
  | .cash => "cash" | .shareA => "shareA" | .shareB => "shareB"
def encode (t : Instruction) : RawCall :=
  .transfer (actorName t.actor) (accountName t.source) (accountName t.target) (assetName t.asset) (.exact t.amount)
def net (s : PublicState) (ts : List Instruction) : NetResult :=
  executeNet s "operator" (ts.map encode)

def aliasTransfers : List Instruction :=
  [⟨.vault, .alice, .bob, .cash, 1/3⟩, ⟨.vault, .alice, .bob, .cash, 1/6⟩,
   ⟨.vault, .bob, .alice, .cash, 1/4⟩, ⟨.vault, .alice, .alice, .cash, 5/6⟩]
def cycleTransfers : List Instruction :=
  [⟨.vault, .alice, .bob, .cash, 1/3⟩, ⟨.vault, .bob, .alice, .cash, 1/3⟩,
   ⟨.vault, .alice, .alice, .cash, 7/3⟩, ⟨.vault, .bob, .bob, .cash, 0⟩]

def settledExactly (s : PublicState) (ts : List Instruction) (alice bob : ℚ) : Bool :=
  match net s ts with
  | .refused _ _ _ => false
  | .success post => decide (
      cells.map post.ledger.balance = cells.map (fun c =>
        if c = (.alice, .usd) then alice else if c = (.bob, .usd) then bob else s.ledger.balance c) ∧
      assets.map post.supply = assets.map s.supply ∧
      post.rates false = s.rates false ∧ post.rates true = s.rates true ∧ post.capabilities = s.capabilities ∧
      post.history.map observeEvent = s.history.map observeEvent ++
        [(ts.map Instruction.call, cells.map (fun c =>
          if c = (.alice, .usd) then alice - s.ledger.balance c
          else if c = (.bob, .usd) then bob - s.ledger.balance c else 0), [0,0,0], [0,0,0])])

def sequentialRefusedExactly (s : PublicState) (reason : Reason) : Bool :=
  let result := runCalls s (cycleTransfers.map Instruction.call)
  decide (result.failure = some (reason, 0) ∧ result.committed = 0 ∧ observe result.state = observe s)

def sequentialAgreement : Bool :=
  let s := initial 3 (by norm_num)
  let sequence := runCalls s (cycleTransfers.map Instruction.call)
  match net s cycleTransfers with
  | .refused _ _ _ => false
  | .success post => decide (sequence.failure = none ∧ sequence.committed = 4 ∧
      cells.map sequence.state.ledger.balance = cells.map post.ledger.balance ∧
      assets.map sequence.state.supply = assets.map post.supply ∧
      sequence.state.capabilities = post.capabilities ∧
      sequence.state.rates false = post.rates false ∧ sequence.state.rates true = post.rates true ∧
      sequence.state.history.map observeEvent = cycleTransfers.map (fun t => observeEvent (event s.rates t.call)) ∧
      post.history.length = 1 ∧ sequence.state.history.length = 4)

def validRaw : RawCall := .transfer "operator" "alice" "bob" "cash" (.exact 1)
def invalidTarget : RawCall := .transfer "operator" "unknown" "bob" "cash" (.exact (-1))
def malformed : RawCall := .transfer "operator" "alice" "bob" "cash" (.malformed "0.5")
def negative : RawCall := .transfer "operator" "alice" "bob" "cash" (.exact (-1))

def checks : List (String × Bool) := [
  ("net_alias", settledExactly (initial 1 (by norm_num)) aliasTransfers (3/4) (1/4)),
  ("net_cycle", settledExactly zeroState cycleTransfers 0 0 && sequentialRefusedExactly zeroState .insufficientFunds),
  ("net_cycle_invoke_only", settledExactly invokeOnly cycleTransfers 0 0 && sequentialRefusedExactly invokeOnly .unauthorized),
  ("net_sequential_agreement", sequentialAgreement),
  ("net_invalid_request_actor", refusedExactly (executeNet zeroState "unknown" [validRaw]) .badTarget none zeroState),
  ("net_first_invalid_precedes_authority", refusedExactly
    (executeNet noAuthority "operator" [validRaw, invalidTarget, malformed, negative]) .badTarget (some 1) noAuthority),
  ("net_mixed_actor_precedes_number", refusedExactly
    (executeNet noAuthority "operator" [.transfer "alice" "alice" "bob" "cash" (.malformed "0.5")])
      .badTarget (some 0) noAuthority),
  ("net_bad_number", refusedExactly (executeNet noAuthority "operator" [validRaw, malformed]) .badNumber (some 1) noAuthority),
  ("net_bad_amount", refusedExactly (executeNet noAuthority "operator" [validRaw, negative]) .badAmount (some 1) noAuthority),
  ("net_unsupported_record", refusedExactly
    (executeNet noAuthority "operator" [validRaw, .deposit "unknown" "unknown" "unknown" (.malformed "x")])
      .badOperation (some 1) noAuthority),
  ("net_authority_before_funds", refusedExactly (executeNet noAuthority "operator" [validRaw]) .unauthorized none noAuthority),
  ("net_insufficient_aggregate_funds", refusedExactly (executeNet zeroState "operator" [validRaw]) .insufficientFunds none zeroState)
]

end RationalWorkflow.Net.Witnesses
