import DefiKernel.Parallel.Preservation
import DefiKernel.Parallel.CompatibilityTests

/-! Concrete initialized conservation, protected collateral and independent mint/burn proofs.
The fixtures are development cases, not external financial fidelity evidence. -/
namespace DefiKernel.Parallel.PreservationFixtures
open Typed Composition Typed.Examples CompatibilityTests

def joined : Joined Party Asset Domain :=
  let l := runBranch cfg (boundary .left) initial [left]
  let r := runBranch cfg (boundary .right) initial [right]
  ⟨mergeWorld leftFP rightFP initial l.world r.world, l, r⟩

def usdRegion : Set C := {c | c.1 = Domain.main ∧ c.2.2 = Asset.usd}
def shareRegion : Set C := {c | c.1 = Domain.main ∧ c.2.2 = Asset.share}
def collateralPredicate (s : State Party Asset Domain) : Prop := s.balance common = 0

def mint : Op := { usdOp with
  deltas := [⟨.usd, cellRef aliceUSD, .lit 2⟩]
  supplyDeltas := [⟨.main, .usd, .lit 2⟩]
  writes := [packed aliceUSD] }
def burn : Op := { shareOp with
  deltas := [⟨.share, cellRef vaultShare, .lit (-4)⟩]
  supplyDeltas := [⟨.main, .share, .lit (-4)⟩]
  writes := [packed vaultShare] }
def supplyCfg := cfg mint burn
def supplyInitial : World Party Asset Domain :=
  { CompatibilityTests.initial with capabilities := ⟨initial.capabilities.entries ++
    [⟨⟨.alice, .main, ⟨10⟩, .changeSupply .main .usd⟩, true⟩,
     ⟨⟨.alice, .main, ⟨11⟩, .changeSupply .main .share⟩, true⟩]⟩ }
def mintInv : I := { left with capabilityIds := [⟨0⟩, ⟨4⟩] }
def burnInv : I := { right with capabilityIds := [⟨2⟩, ⟨3⟩, ⟨5⟩] }
def mintFP : F := ⟨[aliceUSD, aliceUSD], [aliceUSD, aliceUSD]⟩
def burnFP : F := ⟨[vaultShare, vaultShare], [vaultShare, vaultShare]⟩
def supplyJoined : Joined Party Asset Domain :=
  let l := runBranch supplyCfg (boundary .left) supplyInitial [mintInv]
  let r := runBranch supplyCfg (boundary .right) supplyInitial [burnInv]
  ⟨mergeWorld mintFP burnFP supplyInitial l.world r.world, l, r⟩

def refusedMint : I := { mintInv with capabilityIds := [] }
def prefixJoined : Joined Party Asset Domain :=
  let l := runBranch supplyCfg (boundary .left) supplyInitial [mintInv, refusedMint]
  let r := runBranch supplyCfg (boundary .right) supplyInitial [burnInv]
  ⟨mergeWorld (mintFP.append mintFP) burnFP supplyInitial l.world r.world, l, r⟩

-- BEGIN PROOFS

theorem admitted : admit cfg boundary [left] [right] = .ok (leftFP, rightFP) := by
  decide +kernel

theorem executed : runParallel cfg boundary initial [left] [right] = .executed joined := by
  simp only [runParallel, admitted]
  rfl

theorem supply_free : ∀ op template, cfg.registry op = some template →
    template.supplyDeltas = [] := by
  intro op template hs
  change (if op = ⟨10⟩ then some usdOp else if op = ⟨11⟩ then some shareOp else none) =
    some template at hs
  split_ifs at hs <;> cases hs <;> rfl

theorem initial_totals : total initial.state .main .usd = 10 ∧
    total initial.state .main .share = 20 := by decide +kernel

/-- Initialized USD and share conservation each have an actual local induction proof. -/
theorem initialized_two_invariants :
    total joined.world.state .main .usd = 10 ∧ total joined.world.state .main .share = 20 := by
  apply runParallel_two_invariants cfg boundary initial [left] [right] leftFP rightFP admitted
    usdRegion shareRegion (fun s ↦ total s .main .usd = 10)
    (fun s ↦ total s .main .share = 20)
  · exact supports_total (P := Party) Domain.main Asset.usd (· = 10)
  · exact supports_total (P := Party) Domain.main Asset.share (· = 20)
  · intro c hc hw
    have hx : c.2.2 = .usd := hc.2
    simp only [rightFP, List.mem_cons, List.not_mem_nil, or_false] at hw
    rcases hw with rfl | rfl | rfl | rfl <;> cases hx
  · intro c hc hw
    have hx : c.2.2 = .share := hc.2
    simp only [leftFP, List.mem_cons, List.not_mem_nil, or_false] at hw
    rcases hw with rfl | rfl | rfl | rfl <;> cases hx
  · exact initial_totals.1
  · exact initial_totals.2
  · exact local_total_preservation cfg (boundary .left) supply_free .main .usd 10
  · exact local_total_preservation cfg (boundary .right) supply_free .main .share 20

theorem protected_collateral : collateralPredicate joined.world.state := by
  have hi : collateralPredicate initial.state := by unfold collateralPredicate; decide +kernel
  apply (runParallel_executed_supported_frame cfg boundary initial [left] [right]
    leftFP rightFP joined admitted executed {common} collateralPredicate
    (supports_balance common (· = 0)) _).mp hi
  intro c hc
  have he : c = common := Set.mem_singleton_iff.mp hc
  subst c
  decide

theorem joined_authority :
    (∀ event ∈ joined.left.events,
      ReceiptAuthorized initial (boundary .left event.index) event.result.receipt) ∧
    (∀ event ∈ joined.right.events,
      ReceiptAuthorized initial (boundary .right event.index) event.result.receipt) :=
  runParallel_executed_authority cfg boundary initial [left] [right] joined executed

theorem joined_nonnegative : ∀ c, 0 ≤ joined.world.state.balance c :=
  (runParallel_executed_nonnegative cfg boundary initial [left] [right] joined executed).1

/-- A predicate with empty declared support can still change if support is not proved. -/
theorem unsupported_counterexample :
    AgreeOn (∅ : Set C) initial.state joined.world.state ∧
    initial.state.balance aliceUSD = 10 ∧ joined.world.state.balance aliceUSD ≠ 10 := by
  refine ⟨?_, ?_, ?_⟩
  · intro c hc
    cases hc
  · decide +kernel
  · decide +kernel

theorem unsupported_is_not_supported :
    ¬ Supports (∅ : Set C) (fun s : State Party Asset Domain ↦ s.balance aliceUSD = 10) := by
  intro h
  have hc := unsupported_counterexample
  exact hc.2.2 ((h initial.state joined.world.state hc.1).mp hc.2.1)

/-- Correct support alone does not frame a predicate whose selected cell is written. -/
theorem written_support_counterexample :
    Supports {aliceUSD} (fun s : State Party Asset Domain ↦ s.balance aliceUSD = 10) ∧
    aliceUSD ∈ leftFP.writes ∧ initial.state.balance aliceUSD = 10 ∧
    joined.world.state.balance aliceUSD ≠ 10 := by
  exact ⟨supports_balance aliceUSD (· = 10), by decide,
    unsupported_counterexample.2.1, unsupported_counterexample.2.2⟩

theorem supply_admitted : admit supplyCfg boundary [mintInv] [burnInv] =
    .ok (mintFP, burnFP) := by decide +kernel

theorem supply_executed : runParallel supplyCfg boundary supplyInitial [mintInv] [burnInv] =
    .executed supplyJoined := by
  simp only [runParallel, supply_admitted]
  rfl

theorem supply_receipts : supplyJoined.left.events.length = 1 ∧
    supplyJoined.right.events.length = 1 ∧ supplyJoined.supply .main .usd = 2 ∧
    supplyJoined.supply .main .share = -4 := by decide +kernel

theorem supply_totals : total supplyJoined.world.state .main .usd = 12 ∧
    total supplyJoined.world.state .main .share = 16 := by
  have hu := runParallel_executed_accounting supplyCfg boundary supplyInitial [mintInv] [burnInv]
    supplyJoined supply_executed Domain.main Asset.usd
  have hs := runParallel_executed_accounting supplyCfg boundary supplyInitial [mintInv] [burnInv]
    supplyJoined supply_executed Domain.main Asset.share
  rw [supply_receipts.2.2.1] at hu
  rw [supply_receipts.2.2.2] at hs
  have hiu : total supplyInitial.state .main .usd = 10 := initial_totals.1
  have his : total supplyInitial.state .main .share = 20 := initial_totals.2
  rw [hiu] at hu
  rw [his] at hs
  constructor <;> linarith

theorem prefix_admitted : admit supplyCfg boundary [mintInv, refusedMint] [burnInv] =
    .ok (mintFP.append mintFP, burnFP) := by decide +kernel

theorem prefix_executed :
    runParallel supplyCfg boundary supplyInitial [mintInv, refusedMint] [burnInv] =
      .executed prefixJoined := by
  simp only [runParallel, prefix_admitted]
  rfl

/-- A successful supply-changing prefix retains its exact receipt before a local refusal. -/
theorem prefix_refusal_receipts : prefixJoined.left.events.length = 1 ∧
    prefixJoined.left.failure =
      some ⟨1, some (.invoke refusedMint), .kernel .unauthorizedInvoke⟩ ∧
    prefixJoined.right.events.length = 1 ∧ prefixJoined.right.failure = none ∧
    prefixJoined.supply .main .usd = 2 ∧ prefixJoined.supply .main .share = -4 := by
  decide +kernel

theorem prefix_authority :
    (∀ event ∈ prefixJoined.left.events,
      ReceiptAuthorized supplyInitial (boundary .left event.index) event.result.receipt) ∧
    (∀ event ∈ prefixJoined.right.events,
      ReceiptAuthorized supplyInitial (boundary .right event.index) event.result.receipt) :=
  runParallel_executed_authority supplyCfg boundary supplyInitial
    [mintInv, refusedMint] [burnInv] prefixJoined prefix_executed

theorem prefix_accounting (d : Domain) (a : Asset) :
    total prefixJoined.world.state d a = total supplyInitial.state d a + prefixJoined.supply d a :=
  runParallel_executed_accounting supplyCfg boundary supplyInitial
    [mintInv, refusedMint] [burnInv] prefixJoined prefix_executed d a

end DefiKernel.Parallel.PreservationFixtures
