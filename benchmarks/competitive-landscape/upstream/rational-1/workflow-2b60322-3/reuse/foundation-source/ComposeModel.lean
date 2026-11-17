import WorkflowControl
namespace RationalWorkflow

-- This algebra is defined independently of the executor and contains no success premise.
def algebraStep (r : Vault → ℚ) (b : Cell → ℚ) (call : Call) : Cell → ℚ :=
  fun c => b c + effect r call c
def algebraBalances (r : Vault → ℚ) (b : Cell → ℚ) : List Call → Cell → ℚ
  | [] => b
  | call :: rest => algebraBalances r (algebraStep r b call) rest
def algebraCapabilities (caps : Finset Capability) : List Call → Finset Capability
  | [] => caps
  | call :: rest => algebraCapabilities (nextCapabilities caps call) rest

def AlgebraDomain (r : Vault → ℚ) (b : Cell → ℚ) (caps : Finset Capability) : List Call → Prop
  | [] => True
  | call :: rest => AmountValid call ∧ Authorized caps call ∧ Funded b r call ∧
      AlgebraDomain r (algebraStep r b call) (nextCapabilities caps call) rest

def sumIssued (r : Vault → ℚ) (calls : List Call) (e : Asset) : ℚ :=
  (calls.map (fun call => issued r call e)).sum
def sumBurned (r : Vault → ℚ) (calls : List Call) (e : Asset) : ℚ :=
  (calls.map (fun call => burned r call e)).sum

def workflowCall (p : Principal) (v : Vault) (index : Nat) (q : ℚ) : Call :=
  match index % 4 with
  | 0 => .deposit p false v q
  | 1 => .transfer p .alice .bob (shareAsset v) q
  | 2 => .withdraw p true v q
  | _ => .transfer p .bob .alice .cash q

def workflowCalls (p : Principal) (v : Vault) (amounts : List ℚ) : List Call :=
  amounts.mapIdx (workflowCall p v)

def depositTotal (rate : ℚ) (amounts : List ℚ) : ℚ :=
  (amounts.zipIdx.map (fun (q,j) => if j % 4 = 0 then q / rate else 0)).sum
def withdrawTotal (amounts : List ℚ) : ℚ :=
  (amounts.zipIdx.map (fun (q,j) => if j % 4 = 2 then q else 0)).sum

def WorkflowMember (v : Vault) : Call → Prop
  | .deposit _ false w _ => w = v
  | .transfer _ .alice .bob e _ => e = shareAsset v
  | .withdraw _ true w _ => w = v
  | .transfer _ .bob .alice .cash _ => True
  | _ => False

def workflowFootprint (v : Vault) : Finset Cell :=
  {(.alice,.usd),(.alice,(shareAsset v).native),(.bob,.usd),
    (.bob,(shareAsset v).native),(vaultAccount v,.usd)}

inductive LocalTrace : PublicState → List Call → PublicState → Prop
  | nil (s) : LocalTrace s [] s
  | cons (s middle final call rest)
      (executed : execute s call = .success middle)
      (contract : LocalClaims s middle call)
      (tail : LocalTrace middle rest final) : LocalTrace s (call :: rest) final

structure CompositionClaims (s : PublicState) (calls : List Call) (post : PublicState) : Prop where
  execution : runCalls s calls = ⟨post, none, calls.length⟩
  localContracts : LocalTrace s calls post
  balances : post.ledger.balance = algebraBalances s.rates s.ledger.balance calls
  accounting : ∀ e, post.supply e = s.supply e + sumIssued s.rates calls e - sumBurned s.rates calls e
  rates : post.rates = s.rates
  capabilities : post.capabilities = algebraCapabilities s.capabilities calls
  history : post.history = s.history ++ calls.map (event s.rates)
  valid : ValidState post
  frame : ∀ c, (∀ call ∈ calls, c ∉ writes call) → post.ledger.balance c = s.ledger.balance c

structure WorkflowClaims (s : PublicState) (p : Principal) (v : Vault) (amounts : List ℚ)
    (post : PublicState) : Prop where
  composition : CompositionClaims s (workflowCalls p v amounts) post
  capabilities : post.capabilities = s.capabilities
  cash : post.supply .cash = s.supply .cash
  shares : post.supply (shareAsset v) = s.supply (shareAsset v) +
    depositTotal (s.rates v) amounts - withdrawTotal amounts
  collateral : surplus post v = surplus s v
  nonnegative_collateral : 0 ≤ surplus s v → 0 ≤ surplus post v
  frame : ∀ c, c ∉ workflowFootprint v → post.ledger.balance c = s.ledger.balance c
  other_share : post.supply (shareAsset (!v)) = s.supply (shareAsset (!v))
  prefixes : ∀ j, j ≤ amounts.length → ∃ preState,
    CompositionClaims s ((workflowCalls p v amounts).take j) preState ∧
    (∀ c, 0 ≤ preState.ledger.balance c)

-- Every typed call and every excluded success domain uses the same first-refusal executor.
inductive CallsExecutionSpec : PublicState → List Call → SequenceResult → Prop
  | done (s) : CallsExecutionSpec s [] ⟨s,none,0⟩
  | refused (s call calls reason)
      (reason_exact : expectedRefusal s call = some reason)
      (executed : execute s call = .refused reason s) :
      CallsExecutionSpec s (call::calls) ⟨s,some (reason,0),0⟩
  | success (s post call calls result)
      (domain : SuccessDomain s call)
      (contract : LocalClaims s post call)
      (executed : execute s call = .success post)
      (rest : CallsExecutionSpec post calls result) :
      CallsExecutionSpec s (call::calls) result.bump

def ComposeCanonical (v : Vault) (n : Nat) : Prop :=
  ∀ s p amounts, ValidState s → amounts.length = n →
    (AlgebraDomain s.rates s.ledger.balance s.capabilities (workflowCalls p v amounts) →
      ∃ post, WorkflowClaims s p v amounts post) ∧
    CallsExecutionSpec s (workflowCalls p v amounts) (runCalls s (workflowCalls p v amounts)) ∧
    ((runCalls s (workflowCalls p v amounts)).failure = none ↔
      AlgebraDomain s.rates s.ledger.balance s.capabilities (workflowCalls p v amounts))

end RationalWorkflow
