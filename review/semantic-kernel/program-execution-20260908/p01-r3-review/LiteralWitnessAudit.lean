import DefiKernel.Nary.Tree.RecoveryChecks

-- Reviewer-owned expected observations. No candidate source is changed.
-- These constants encode the stated transfers directly; no executor, analyzer,
-- receipt extractor, snapshot function or candidate expected-value helper constructs them.
namespace P01R3LiteralAudit
open DefiKernel Typed Composition Parallel
open DefiKernel.Typed.Examples
open DefiKernel.Nary.Tree
open DefiKernel.Nary.Tree.RecoveryChecks.Funded

abbrev C := Cell Party Asset Domain
abbrev I := Invocation Party Asset Domain

def expectedCaps : List CapabilityId :=
  [⟨0⟩, ⟨1⟩, ⟨2⟩, ⟨3⟩, ⟨4⟩, ⟨5⟩, ⟨6⟩, ⟨7⟩, ⟨8⟩, ⟨9⟩, ⟨10⟩, ⟨11⟩]
def usd3 : I := ⟨⟨0⟩, ⟨10⟩, [], [.literal ⟨.amount .usd, (3 : ℚ)⟩], expectedCaps, none⟩
def usd8 : I := ⟨⟨0⟩, ⟨10⟩, [], [.literal ⟨.amount .usd, (8 : ℚ)⟩], expectedCaps, none⟩
def usd7 : I := ⟨⟨0⟩, ⟨10⟩, [], [.literal ⟨.amount .usd, (7 : ℚ)⟩], expectedCaps, none⟩
def usd6 : I := ⟨⟨0⟩, ⟨10⟩, [], [.literal ⟨.amount .usd, (6 : ℚ)⟩], expectedCaps, none⟩
def share4 : I := ⟨⟨1⟩, ⟨11⟩, [], [.literal ⟨.amount .share, (4 : ℚ)⟩], expectedCaps, none⟩
def outputUSD : OutputObservation Asset := ⟨0, ⟨⟨0⟩, ⟨0⟩⟩, ⟨.amount .usd, (3 : ℚ)⟩⟩
def outputShare : OutputObservation Asset := ⟨0, ⟨⟨1⟩, ⟨0⟩⟩, ⟨.amount .share, (4 : ℚ)⟩⟩
def receiptUSD : Receipt Party Asset Domain := .invoked
  ⟨⟨10⟩, [], [⟨.amount .usd, (3 : ℚ)⟩], expectedCaps, none⟩
  ⟨true, [((.main, .alice, .usd), -3), ((.main, .bob, .usd), 3)],
    [], [], [], [], [], [(.main, .alice, .usd), (.main, .bob, .usd)]⟩
def receiptShare : Receipt Party Asset Domain := .invoked
  ⟨⟨11⟩, [], [⟨.amount .share, (4 : ℚ)⟩], expectedCaps, none⟩
  ⟨true, [((.main, .vault, .share), -4), ((.main, .alice, .share), 4)],
    [], [], [], [], [], [(.main, .vault, .share), (.main, .alice, .share)]⟩
def refusedLocal : CanonicalLocal Party Asset Domain :=
  ⟨2, ⟨[⟨0, .invoke usd3, receiptUSD, [outputUSD]⟩], [outputUSD], 1,
    some ⟨1, some (.invoke usd8), .kernel .insufficientFunds⟩⟩⟩
def peerLocal : CanonicalLocal Party Asset Domain :=
  ⟨1, ⟨[⟨0, .invoke share4, receiptShare, [outputShare]⟩], [outputShare], 1, none⟩⟩
def expectedLocals : List (Fin 2 × CanonicalLocal Party Asset Domain) :=
  [(0, refusedLocal), (1, peerLocal)]

def comparisons : List (String × Bool) := [
  ("review.r2.shared-001-full-local-literals",
    decide ((canonicalOf fin2Roster tmRefuse001).locals = expectedLocals)),
  ("review.r2.shared-100-full-local-literals",
    decide ((canonicalOf fin2Roster tmRefuse100).locals = expectedLocals)),
  ("review.r2.isolated-001-full-local-literals",
    match refuseAdmit001 with
    | .ok assoc => decide ((isolatedCanonical fin2Roster fundedCfg naryBounds fundedInitial
        refuseBranches assoc fin2Fork).locals = expectedLocals)
    | .error _ => false),
  ("review.r2.isolated-100-full-local-literals",
    match refuseAdmit100 with
    | .ok assoc => decide ((isolatedCanonical fin2Roster fundedCfg naryBounds fundedInitial
        refuseBranches assoc fin2Fork).locals = expectedLocals)
    | .error _ => false),
  ("review.r3.lr-exact-opposite-failures",
    match lookupLeaf tmF15NormLR.locals 0, lookupLeaf tmF15NormLR.locals 1 with
    | some a, some b => decide (a.failure = none) &&
      decide (b.failure = some ⟨0, some (.invoke usd6), .kernel .insufficientFunds⟩)
    | _, _ => false),
  ("review.r3.rl-exact-opposite-failures",
    match lookupLeaf tmF15NormRL.locals 0, lookupLeaf tmF15NormRL.locals 1 with
    | some a, some b => decide (b.failure = none) &&
      decide (a.failure = some ⟨0, some (.invoke usd7), .kernel .insufficientFunds⟩)
    | _, _ => false)
]

def main : IO Unit := do
  if comparisons.isEmpty then throw (IO.userError "BLOCKED empty reviewer checks")
  if !(comparisons.map Prod.fst).Nodup then throw (IO.userError "BLOCKED duplicate reviewer checks")
  for (label, ok) in comparisons do IO.println s!"{label}: {ok}"
  if (comparisons.any fun row => !row.2) then throw (IO.userError "Reviewer literal mismatch")
#eval main
end P01R3LiteralAudit
