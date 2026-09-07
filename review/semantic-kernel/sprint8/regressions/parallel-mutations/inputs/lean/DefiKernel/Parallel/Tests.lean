import DefiKernel.Parallel.Examples
import DefiKernel.Parallel.Preservation

/-! Named bounded comparisons against direct complete ledger, capability, receipt and output
expectations. Equality between implementations is supplementary to the independent oracles. -/
namespace DefiKernel.Parallel.Tests
open Typed Composition Typed.Examples Parallel.Examples

def basic := runParallel cfg boundaries initial [usd 3] [shares 4]
def peerRuns := runParallel cfg boundaries initial [usd 11] [shares 4]
def prefixKept := runParallel cfg boundaries initial [usd 3, usd 8] [shares 4]
def dualRefusal := runParallel cfg boundaries initial [usd 3, usd 8] [shares 4, shares 17]
def routingForeign := source (usd 0) 1
def routingOwn := source (usd 0) 0
def routingRightOwn := source (shares 0) 1

def routeExpected (consumer : I) (q finalBob : ℚ) : Obs := observed [leftEvent 0 3 3,
  transferEvent 1 consumer aliceUSD bobUSD q [output 1 0 .usd finalBob]]
def rightRouteExpected : Obs := observed [rightEvent 0 4 4,
  transferEvent 1 routingRightOwn vaultShare aliceShare 4 [output 1 1 .share 8]]
def routeForeignExpected : Obs := observed [leftEvent 0 3 3]
  (failure 1 routingForeign (.interface .unavailableOutput))
def routeForeign := runParallel sameAssetCfg boundaries initial [usd 3, routingForeign] [peerUSD 4]

def supplyRun := runParallel supplyCfg boundaries initial [usd 2] [shares (-3)]
def supplyLeft := observed [supplyEvent 0 (usd 2) aliceUSD 2 12]
def supplyRight := observed [supplyEvent 0 (shares (-3)) vaultShare (-3) 17]
def statefulRun := runParallel statefulCfg boundaries initial [usd 0, usd 0, usd 0] [shares 4]
def statefulExpected := observed [statefulEvent 0 5 5, statefulEvent 1 (5 / 2) (15 / 2)]
  (failure 2 (usd 0) (.kernel .guard))
def stateSupplyCfg := config usdTransfer statefulSupply [bobUSD] [vaultShare]
def stateSupplyExpected := observed [statefulSupplyEvent 0 10 30, statefulSupplyEvent 1 15 45]

def admissionRefused (actual : R) (reason : AdmissionFailure Party Asset Domain)
    (expected : W := initial) : Bool :=
  match actual with
  | .refused actualReason actualWorld =>
    decide (actualReason = reason) && worldEq actualWorld expected
  | .executed _ => false

def serialChecks (label : String) (config : Config Party Asset Domain)
    (binding : ParallelBoundary Party Asset Domain) (world : W) (left right : B)
    (balance : C → ℚ) (expectedLeft expectedRight : Obs) (expectedStore : Store := store) :
    List (String × Bool) := [
  (label ++ ".lr.complete", matchesExpected (runSerialLR config binding world left right)
    balance expectedLeft expectedRight expectedStore),
  (label ++ ".rl.complete", matchesExpected (runSerialRL config binding world left right)
    balance expectedLeft expectedRight expectedStore)]

def checks : List (String × Bool) := [
  ("parallel.fixture.catalog", validateCatalog cfg.registry cfg.catalog),
  ("parallel.fixture.basic.complete", matchesExpected basic (balanceTable 7 3 16 4)
    basicLeft basicRight),
  ("parallel.fixture.same-asset.complete", matchesExpected
    (runParallel sameAssetCfg boundaries initial [usd 3] [peerUSD 4])
    (balanceTable 7 3 20 0 16 5) basicLeft (observed [peerEvent 0 4 5])),
  ("parallel.fixture.refusal.peer-runs", matchesExpected peerRuns (balanceTable 10 0 16 4)
    (observed [] (failure 0 (usd 11) (.kernel .insufficientFunds))) basicRight),
  ("parallel.fixture.refusal.prefix-kept", matchesExpected prefixKept (balanceTable 7 3 16 4)
    (observed [leftEvent 0 3 3] (failure 1 (usd 8) (.kernel .insufficientFunds))) basicRight),
  ("parallel.fixture.refusal.dual", matchesExpected dualRefusal (balanceTable 7 3 16 4)
    (observed [leftEvent 0 3 3] (failure 1 (usd 8) (.kernel .insufficientFunds)))
    (observed [rightEvent 0 4 4] (failure 1 (shares 17) (.kernel .insufficientFunds)))),
  ("parallel.fixture.refusal.guard", matchesExpected
    (runParallel cfg boundaries initial [usd (-1)] [shares 4]) (balanceTable 10 0 16 4)
    (observed [] (failure 0 (usd (-1)) (.kernel .guard))) basicRight),
  ("parallel.fixture.refusal.input-unit", let wrong :=
      {usd 3 with inputs := [.literal ⟨.amount .share, 3⟩]}
    matchesExpected (runParallel cfg boundaries initial [wrong] [shares 4])
      (balanceTable 10 0 16 4)
      (observed [] (failure 0 wrong (.interface .inputUnit))) basicRight),
  ("parallel.fixture.refusal.missing-capability", let missing := {usd 3 with capabilityIds := []}
    matchesExpected (runParallel cfg boundaries initial [missing] [shares 4])
      (balanceTable 10 0 16 4)
      (observed [] (failure 0 missing (.kernel .unauthorizedInvoke))) basicRight),
  ("parallel.fixture.empty.right", matchesExpected
    (runParallel cfg boundaries initial [usd 3] []) (balanceTable 7 3 20 0)
      basicLeft (observed [])),
  ("parallel.fixture.empty.left", matchesExpected
    (runParallel cfg boundaries initial [] [shares 4]) (balanceTable 10 0 16 4)
      (observed []) basicRight),
  ("parallel.fixture.empty.both", matchesExpected
    (runParallel cfg boundaries initial [] []) (balanceTable 10 0 20 0)
      (observed []) (observed [])),
  ("parallel.fixture.routing.peer-only", matchesExpected routeForeign
    (balanceTable 7 3 20 0 16 5) routeForeignExpected (observed [peerEvent 0 4 5])),
  ("parallel.fixture.routing.funded-literal", matchesExpected
    (runParallel sameAssetCfg boundaries initial [usd 3, usd 5] [peerUSD 4])
    (balanceTable 2 8 20 0 16 5) (observed [leftEvent 0 3 3, leftEvent 1 5 8])
      (observed [peerEvent 0 4 5])),
  ("parallel.fixture.routing.own-history", matchesExpected
    (runParallel sameAssetCfg boundaries initial [usd 3, routingOwn] [peerUSD 4])
    (balanceTable 4 6 20 0 16 5) (routeExpected routingOwn 3 6) (observed [peerEvent 0 4 5])),
  ("parallel.fixture.routing.both-own-history", matchesExpected
    (runParallel cfg boundaries initial [usd 3, routingOwn] [shares 4, routingRightOwn])
    (balanceTable 4 6 12 8) (routeExpected routingOwn 3 6) rightRouteExpected),
  ("parallel.fixture.routing.shared-qualified-key", matchesExpected
    (runParallel sharedReadCfg boundaries initial [noOpInvocation] [noOpInvocation])
    (balanceTable 10 0 20 0) sharedReadExpected sharedReadExpected),
  ("parallel.fixture.boundary.local-identity", matchesExpected
    (runParallel timedCfg timedBoundaries initial timedLeft timedRight)
    (balanceTable 8 2 14 6) timedExpectedLeft timedExpectedRight),
  ("parallel.fixture.capability.revoked", matchesExpected
    (runParallel cfg boundaries revokedInitial [usd 3] [shares 4])
    (balanceTable 7 3 20 0) basicLeft
      (observed [] (failure 0 (shares 4) (.kernel .unauthorizedInvoke))) revokedStore),
  ("parallel.fixture.capability.actual-revoke", decide
    (revokeCapability cfg.authority adminContext store ⟨2⟩ = .ok revokedStore)),
  ("parallel.fixture.capability.reusable-shared-grant",
    let l := {usd 3 with parties := [.alice, .bob]}
    let r := {usd 4 with parties := [.vault, .pool]}
    matchesExpected (runParallel reusableCfg boundaries initial [l] [r])
      (balanceTable 7 3 20 0 16 5)
      (observed [transferEvent 0 l aliceUSD bobUSD 3 []])
      (observed [transferEvent 0 r vaultUSD poolUSD 4 []])),
  ("parallel.fixture.supply.complete", matchesExpected supplyRun (balanceTable 12 0 17 0)
    supplyLeft supplyRight),
  ("parallel.fixture.supply.both-receipts", match supplyRun with
    | .refused _ _ => false
    | .executed result => decide (∀ d a, result.supply d a =
        if d = .main ∧ a = .usd then 2 else if d = .main ∧ a = .share then -3 else 0)),
  ("parallel.fixture.supply.prefix-refusal", matchesExpected
    (runParallel supplyCfg boundaries initial [usd 2, usd (-13)] [shares (-3)])
    (balanceTable 12 0 17 0)
    (observed [supplyEvent 0 (usd 2) aliceUSD 2 12]
      (failure 1 (usd (-13)) (.kernel .insufficientFunds))) supplyRight),
  ("parallel.fixture.stateful.prefix", matchesExpected statefulRun
    (balanceTable (5 / 2) (15 / 2) 16 4)
    statefulExpected basicRight),
  ("parallel.fixture.stateful.supply", matchesExpected
    (runParallel stateSupplyCfg boundaries initial [usd 3] [shares 0, shares 0])
    (balanceTable 7 3 45 0) basicLeft stateSupplyExpected),
  ("parallel.fixture.cancelling.admission", admissionRefused
    (runParallel (config usdTransfer cancelling) boundaries initial [usd 3] [cancellingInvocation])
    (.conflict .writeWrite aliceUSD)),
  ("parallel.fixture.cancelling.funded", matchesExpected
    (runParallel (config usdTransfer cancelling) boundaries initial [] [cancellingInvocation])
    (balanceTable 10 0 20 0) (observed []) cancellingExpected),
  ("parallel.fixture.refusal.world-preserved", admissionRefused
    (runParallel cfg boundaries initial [usd 3] [usd 3]) (.conflict .writeWrite aliceUSD)),
  ("parallel.fixture.refusal.suffix-world-preserved", let unknown := {usd 0 with operation := ⟨99⟩}
    admissionRefused (runParallel cfg boundaries initial [usd 3, unknown] [shares 4])
      (.structural .left ⟨1, .interface .unknownOperation⟩)),
  ("parallel.fixture.raw-context-differs", match basic,
      runSerialLR cfg boundaries initial [usd 3] [shares 4] with
    | .executed p, .executed s =>
      observationsEqual basic (runSerialLR cfg boundaries initial [usd 3] [shares 4]) &&
      match p.right.events, s.right.events with
      | pe :: _, se :: _ => !worldEq pe.before se.before
      | _, _ => false
    | _, _ => false)
  ] ++
  serialChecks "parallel.fixture.basic" cfg boundaries initial [usd 3] [shares 4]
    (balanceTable 7 3 16 4) basicLeft basicRight ++
  serialChecks "parallel.fixture.prefix" cfg boundaries initial [usd 3, usd 8] [shares 4]
    (balanceTable 7 3 16 4)
    (observed [leftEvent 0 3 3] (failure 1 (usd 8) (.kernel .insufficientFunds))) basicRight ++
  serialChecks "parallel.fixture.routing" sameAssetCfg boundaries initial
    [usd 3, routingForeign] [peerUSD 4] (balanceTable 7 3 20 0 16 5)
    routeForeignExpected (observed [peerEvent 0 4 5]) ++
  serialChecks "parallel.fixture.boundary" timedCfg timedBoundaries initial timedLeft timedRight
    (balanceTable 8 2 14 6) timedExpectedLeft timedExpectedRight ++
  serialChecks "parallel.fixture.supply" supplyCfg boundaries initial [usd 2] [shares (-3)]
    (balanceTable 12 0 17 0) supplyLeft supplyRight ++
  serialChecks "parallel.fixture.stateful" statefulCfg boundaries initial [usd 0, usd 0, usd 0]
    [shares 4] (balanceTable (5 / 2) (15 / 2) 16 4) statefulExpected basicRight ++
  serialChecks "parallel.fixture.revoked" cfg boundaries revokedInitial [usd 3] [shares 4]
    (balanceTable 7 3 20 0) basicLeft
    (observed [] (failure 0 (shares 4) (.kernel .unauthorizedInvoke))) revokedStore ++
  serialChecks "parallel.fixture.same-asset" sameAssetCfg boundaries initial [usd 3] [peerUSD 4]
    (balanceTable 7 3 20 0 16 5) basicLeft (observed [peerEvent 0 4 5]) ++
  serialChecks "parallel.fixture.peer-runs" cfg boundaries initial [usd 11] [shares 4]
    (balanceTable 10 0 16 4)
    (observed [] (failure 0 (usd 11) (.kernel .insufficientFunds))) basicRight ++
  serialChecks "parallel.fixture.dual" cfg boundaries initial [usd 3, usd 8] [shares 4, shares 17]
    (balanceTable 7 3 16 4)
    (observed [leftEvent 0 3 3] (failure 1 (usd 8) (.kernel .insufficientFunds)))
    (observed [rightEvent 0 4 4] (failure 1 (shares 17) (.kernel .insufficientFunds))) ++
  serialChecks "parallel.fixture.both-own-history" cfg boundaries initial
    [usd 3, routingOwn] [shares 4, routingRightOwn]
    (balanceTable 4 6 12 8) (routeExpected routingOwn 3 6) rightRouteExpected ++
  serialChecks "parallel.fixture.stateful-supply" stateSupplyCfg boundaries initial
    [usd 3] [shares 0, shares 0] (balanceTable 7 3 45 0) basicLeft stateSupplyExpected ++
  serialChecks "parallel.fixture.shared-qualified-key" sharedReadCfg boundaries initial
    [noOpInvocation] [noOpInvocation] (balanceTable 10 0 20 0)
    sharedReadExpected sharedReadExpected ++
  serialChecks "parallel.fixture.supply-prefix" supplyCfg boundaries initial
    [usd 2, usd (-13)] [shares (-3)] (balanceTable 12 0 17 0)
    (observed [supplyEvent 0 (usd 2) aliceUSD 2 12]
      (failure 1 (usd (-13)) (.kernel .insufficientFunds))) supplyRight

end DefiKernel.Parallel.Tests
