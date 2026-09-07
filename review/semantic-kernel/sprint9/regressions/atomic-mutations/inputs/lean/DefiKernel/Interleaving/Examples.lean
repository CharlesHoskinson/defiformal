import DefiKernel.Interleaving.Execution
import DefiKernel.Parallel.Examples

/-! Exact rational development fixtures. Expected ledgers, receipts and outputs are direct tables;
none is extracted from `runInterleaving`. These fixtures make no deployed-protocol fidelity claim.
-/
namespace DefiKernel.Interleaving.Examples
open Typed Composition Parallel Typed.Examples Parallel.Examples

abbrev R := Interleaving.Result Party Asset Domain
abbrev M := Machine Party Asset Domain

def matchesExpected (actual : R) (balance : C → ℚ) (left right : Obs)
    (consumedLeft consumedRight : Nat) (expectedStore : Store := store) : Bool :=
  match actual with
  | .refused _ _ _ => false
  | .executed _ m => decide ((∀ c, m.world.state.balance c = balance c) ∧
      m.world.capabilities = expectedStore ∧ m.left.observe = left ∧ m.right.observe = right ∧
      m.left.consumed = consumedLeft ∧ m.right.consumed = consumedRight)

def admissionRefused (actual : R) (reason : Interleaving.AdmissionFailure Party Asset Domain)
    (schedule : Schedule) (expected : W := initial) : Bool :=
  match actual with
  | .refused r w s => decide (r = reason ∧ s = schedule) && worldEq w expected
  | .executed _ _ => false

def sharedBalance (alice bob vault : ℚ) : C → ℚ := fun c ↦
  if c = aliceUSD then alice else if c = bobUSD then bob else if c = vaultUSD then vault
  else if c = protectedCell then 9 else 0

def sharedInitial : W := ⟨⟨sharedBalance 0 0 10, by
  intro c
  simp only [sharedBalance]
  repeat' split
  all_goals decide⟩, store⟩
def sharedCfg := config (transferTemplate .usd (.literal .vault) (.literal .alice))
  (transferTemplate .usd (.literal .vault) (.literal .bob)) [aliceUSD] [bobUSD]
def sharedLeft : B := [usd 7]
def sharedRight : B := [peerUSD 6]
def sharedLR := runInterleaving sharedCfg boundaries sharedInitial sharedLeft sharedRight
  [.left, .right]
def sharedRL := runInterleaving sharedCfg boundaries sharedInitial sharedLeft sharedRight
  [.right, .left]
def withdrawalLeft := observed [transferEvent 0 (usd 7) vaultUSD aliceUSD 7 [output 0 0 .usd 7]]
def withdrawalRight := observed
  [transferEvent 0 (peerUSD 6) vaultUSD bobUSD 6 [output 0 1 .usd 6]]

def replenishInitial : W := ⟨⟨sharedBalance 10 0 0, by
  intro c
  simp only [sharedBalance]
  repeat' split
  all_goals decide⟩, store⟩
def replenishCfg := config (transferTemplate .usd (.literal .alice) (.literal .vault))
  (transferTemplate .usd (.literal .vault) (.literal .bob)) [vaultUSD] [bobUSD]
def depositExpected := observed [transferEvent 0 (usd 7) aliceUSD vaultUSD 7 [output 0 0 .usd 7]]
def replenishLR := runInterleaving replenishCfg boundaries replenishInitial [usd 7]
  [peerUSD 6, peerUSD 1] [.left, .right, .right]
def replenishRL := runInterleaving replenishCfg boundaries replenishInitial [usd 7]
  [peerUSD 6, peerUSD 1] [.right, .left, .right]

/-- Both branches invoke component 0, so the fully qualified output key is identical. -/
def snapshotCfg := config usdTransfer shareTransfer [bobUSD] [aliceShare]
def snapshotConsumer := source (usd 0) 0
def snapshotRun := runInterleaving snapshotCfg boundaries initial
  [usd 3, snapshotConsumer] [usd 1] [.left, .right, .left]
def snapshotLeft := observed [leftEvent 0 3 3,
  transferEvent 1 snapshotConsumer aliceUSD bobUSD 3 [output 1 0 .usd 7]]
def snapshotRight := observed [leftEvent 0 1 4]

/-- The peer transfers four dollars into Alice's balance between the two live reads. -/
def liveCfg := config statefulTransfer
  (transferTemplate .usd (.literal .vault) (.literal .alice)) [bobUSD] [aliceUSD]
def liveRun := runInterleaving liveCfg boundaries initial [usd 0, usd 0] [peerUSD 4]
  [.left, .right, .left]
def liveLeft := observed [statefulEvent 0 5 5, statefulEvent 1 (9 / 2) (19 / 2)]
def liveRight := observed [transferEvent 0 (peerUSD 4) vaultUSD aliceUSD 4 [output 0 1 .usd 9]]

def peerOnly := source (usd 0) 1
def peerOnlyRun := runInterleaving sameAssetCfg boundaries initial [usd 3, peerOnly]
  [peerUSD 4] [.left, .right, .left]
def peerOnlyLeft := observed [leftEvent 0 3 3]
  (failure 1 peerOnly (.interface .unavailableOutput))
def peerOnlyRight := observed [peerEvent 0 4 5]

def immediateRun := runInterleaving cfg boundaries initial [usd 11, usd 1]
  [shares 4, shares 2] [.left, .right, .left, .right]
def middleRun := runInterleaving cfg boundaries initial [usd 3, usd 8, usd 1]
  [shares 4, shares 2] [.left, .right, .left, .right, .left]
def dualRun := runInterleaving cfg boundaries initial [usd 3, usd 8, usd 1]
  [shares 4, shares 17, shares 1] [.left, .right, .left, .right, .left, .right]
def middleLeft := observed [leftEvent 0 3 3]
  (failure 1 (usd 8) (.kernel .insufficientFunds))
def continuedRight := observed [rightEvent 0 4 4, rightEvent 1 2 6]

def supplyRun := runInterleaving supplyCfg boundaries initial [usd 2, usd (-13), usd 1]
  [shares (-3)] [.left, .right, .left, .left]
def supplyLeft := observed [supplyEvent 0 (usd 2) aliceUSD 2 12]
  (failure 1 (usd (-13)) (.kernel .insufficientFunds))
def supplyRight := observed [supplyEvent 0 (shares (-3)) vaultShare (-3) 17]

def schedules : List (String × Schedule) := [
  ("llrr", [.left, .left, .right, .right]), ("lrlr", [.left, .right, .left, .right]),
  ("lrrl", [.left, .right, .right, .left]), ("rllr", [.right, .left, .left, .right]),
  ("rlrl", [.right, .left, .right, .left]), ("rrll", [.right, .right, .left, .left])]
def disjointLeft : B := [usd 3, usd 2]
def disjointRight : B := [shares 4, shares 2]
def disjointLeftExpected := observed [leftEvent 0 3 3, leftEvent 1 2 5]

/-- Directly supplied attempt oracles include all pre/post cells and the entire capability store. -/
structure ExpectedAttempt where
  branch : BranchId
  index : Nat
  invocation : I
  before : C → ℚ
  after : C → ℚ
  outcome : Except Composition.Failure Evt

def attemptMatches (actual : Attempt Party Asset Domain) (expected : ExpectedAttempt) : Bool :=
  decide (actual.branch = expected.branch ∧ actual.index = expected.index ∧
    actual.invocation = expected.invocation ∧
    (∀ c, actual.before.state.balance c = expected.before c) ∧
    actual.before.capabilities = store) &&
  match actual.outcome, expected.outcome with
  | .error actualReason, .error expectedReason => decide (actualReason = expectedReason)
  | .ok result, .ok event => decide
      ((∀ c, result.world.state.balance c = expected.after c) ∧
        result.world.capabilities = store ∧ result.receipt = event.receipt ∧
        result.outputs = event.outputs)
  | _, _ => false

def attemptsMatch (actual : R) (expected : List ExpectedAttempt) : Bool :=
  match actual with
  | .refused _ _ _ => false
  | .executed _ m => m.attempts.length == expected.length &&
      (m.attempts.zip expected).all fun (a, e) ↦ attemptMatches a e

def sharedLRAttempts : List ExpectedAttempt := [
  ⟨.left, 0, usd 7, sharedBalance 0 0 10, sharedBalance 7 0 3,
    .ok (transferEvent 0 (usd 7) vaultUSD aliceUSD 7 [output 0 0 .usd 7])⟩,
  ⟨.right, 0, peerUSD 6, sharedBalance 7 0 3, sharedBalance 7 0 3,
    .error (.kernel .insufficientFunds)⟩]
def replenishRLAttempts : List ExpectedAttempt := [
  ⟨.right, 0, peerUSD 6, sharedBalance 10 0 0, sharedBalance 10 0 0,
    .error (.kernel .insufficientFunds)⟩,
  ⟨.left, 0, usd 7, sharedBalance 10 0 0, sharedBalance 3 0 7,
    .ok (transferEvent 0 (usd 7) aliceUSD vaultUSD 7 [output 0 0 .usd 7])⟩]

end DefiKernel.Interleaving.Examples
