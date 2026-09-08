/-
  Fixture-author insertion fragment for F03 next pass.
  Paste into lean/DefiKernel/Nary/Tests.lean. Do NOT import BinaryCorrespondence.
  Observation is already imported; these names are DefiKernel.Nary.*.

  Keep the existing independent literal LR/RL/both-count checks.
  Add both-count projection, malformed-suffix precedence, failed/exhausted
  prefix, and supplementary direct Interleaving comparison through the shared
  Observation conversions.
-/

-- Local F03 extras (Tests may own these; do not put them in Observation).
def f03MalformedBranches : Branches BranchId P A D
  | .left => [inv14, inv999]
  | .right => [inv15]
def f03MalformedSchedule : Schedule BranchId := []
def f03MalformedReason : AdmissionFailure BranchId P A D :=
  .structural .left ⟨1, .interface .unknownOperation⟩
def f03MalformedRun :=
  runNary fundedCfg binaryRoster f03Bounds f03Initial f03MalformedBranches
    f03MalformedSchedule

def f03FailedPrefix : Schedule BranchId := [.left, .right, .right]
def f03ExhaustedPrefix : Schedule BranchId := [.left, .right, .left]
def f03FailedPrefixRun :=
  runPrefix fundedCfg f03Bounds f03Initial f03Branches f03FailedPrefix
def f03ExhaustedPrefixRun :=
  runPrefix fundedCfg f03Bounds f03Initial f03Branches f03ExhaustedPrefix

-- Independent expected machines for skip prefixes: extra token consumes a slot
-- and appends no attempt. Built from the existing F03 LR literals, not from
-- runPrefix or runInterleaving.
def f03FailedPrefixExpected : MB :=
  ⟨f03AfterLeft,
    fun b ↦ match b with
      | .left => localSucc [ev 0 inv14 f03Initial (sr f03AfterLeft rec14)]
      | .right => localFail 2 0 [] [] f03RightFail,
    [⟨.left, 0, inv14, f03Initial, .ok (sr f03AfterLeft rec14)⟩,
      ⟨.right, 0, inv15, f03AfterLeft, .error (.kernel .guard)⟩]⟩
def f03ExhaustedPrefixExpected : MB :=
  ⟨f03AfterLeft,
    fun b ↦ match b with
      | .left => ⟨2, [ev 0 inv14 f03Initial (sr f03AfterLeft rec14)], [], 1, none⟩
      | .right => localFail 1 0 [] [] f03RightFail,
    [⟨.left, 0, inv14, f03Initial, .ok (sr f03AfterLeft rec14)⟩,
      ⟨.right, 0, inv15, f03AfterLeft, .error (.kernel .guard)⟩]⟩

-- Projection of the n-ary first mismatch through the shared diagnostic.
def f03ProjectedCounts :=
  projectScheduleMismatch f03Branches f03EmptySched f03BothCount

-- Append these rows to f03Checks. Keep the existing independent LR/RL/both-count
-- rows. binaryRunAgrees/binaryAdmitAgrees/binaryPrefixAgrees call the same
-- Observation conversions the proofs relate.
--
-- ("nary.f03.both-count-projection",
--   decide (f03ProjectedCounts.expectedLeft = 1 ∧
--     f03ProjectedCounts.observedLeft = 0 ∧
--     f03ProjectedCounts.expectedRight = 1 ∧
--     f03ProjectedCounts.observedRight = 0)),
-- ("nary.f03.both-count-direct",
--   binaryAdmitAgrees fundedCfg f03Bounds f03Branches f03EmptySched),
-- ("nary.f03.malformed-suffix",
--   refusedEq f03MalformedRun f03MalformedReason f03Initial f03MalformedSchedule),
-- ("nary.f03.malformed-suffix-direct",
--   binaryAdmitAgrees fundedCfg f03Bounds f03MalformedBranches f03MalformedSchedule),
-- ("nary.f03.failed-prefix",
--   cmpMachine binaryRoster f03FailedPrefixRun f03FailedPrefixExpected),
-- ("nary.f03.failed-prefix-direct",
--   binaryPrefixAgrees fundedCfg f03Bounds f03Initial f03Branches f03FailedPrefix),
-- ("nary.f03.exhausted-prefix",
--   cmpMachine binaryRoster f03ExhaustedPrefixRun f03ExhaustedPrefixExpected),
-- ("nary.f03.exhausted-prefix-direct",
--   binaryPrefixAgrees fundedCfg f03Bounds f03Initial f03Branches f03ExhaustedPrefix),
-- ("nary.f03.lr-direct",
--   binaryRunAgrees fundedCfg f03Bounds f03Initial f03Branches f03LR),
-- ("nary.f03.rl-direct",
--   binaryRunAgrees fundedCfg f03Bounds f03Initial f03Branches f03RL)
--
-- Notes:
-- * `nary.f03.malformed-suffix` is the independent structural expectation.
--   Full-branch analysis precedes the empty-schedule count error.
-- * `*-direct` rows are supplementary Interleaving comparisons.
-- * `binaryRunAgrees` uses `binaryParticipants`, not `Examples.binaryRoster`.
--   Those rosters have the same order `[left, right]`.
-- * Do not manufacture expected receipts/worlds by calling runNary or
--   runInterleaving.
