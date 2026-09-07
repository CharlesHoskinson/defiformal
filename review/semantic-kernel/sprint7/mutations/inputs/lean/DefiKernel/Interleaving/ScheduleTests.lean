import DefiKernel.Interleaving.Schedule
import DefiKernel.Parallel.Examples

/-! Exact schedule mismatch and ordered admission controls. Financial execution controls ensure
the accepted overlap example is funded and authorized; admission itself performs no transfer. -/
namespace DefiKernel.Interleaving.ScheduleTests
open Typed Composition Parallel Typed.Examples Parallel.Examples

def accepted {E X : Type} (result : Except E X) : Bool :=
  match result with
  | .ok _ => true
  | .error _ => false

def refused (actual : Except (Interleaving.AdmissionFailure Party Asset Domain)
    (Footprint Party Asset Domain × Footprint Party Asset Domain))
    (expected : Interleaving.AdmissionFailure Party Asset Domain) : Bool :=
  match actual with
  | .error reason => decide (reason = expected)
  | .ok _ => false

def unknown : I := { usd 0 with operation := ⟨99⟩ }
def invalidCfg : Config Party Asset Domain := { cfg with catalog := cfg.catalog ++ cfg.catalog }

def checks : List (String × Bool) := [
  ("interleaving.schedule.balanced", accepted (checkSchedule 2 2 [.left, .right, .left, .right])),
  ("interleaving.schedule.block-left", accepted (checkSchedule 2 2 [.left, .left, .right, .right])),
  ("interleaving.schedule.block-right", accepted
    (checkSchedule 2 2 [.right, .right, .left, .left])),
  ("interleaving.schedule.empty", accepted (checkSchedule 0 0 [])),
  ("interleaving.schedule.empty-left", accepted (checkSchedule 0 2 [.right, .right])),
  ("interleaving.schedule.empty-right", accepted (checkSchedule 2 0 [.left, .left])),
  ("interleaving.schedule.missing-right", decide
    (checkSchedule 2 2 [.left, .right, .left] = .error ⟨2, 2, 2, 1⟩)),
  ("interleaving.schedule.missing-left", decide
    (checkSchedule 2 2 [.right, .left, .right] = .error ⟨2, 1, 2, 2⟩)),
  ("interleaving.schedule.excess-left", decide
    (checkSchedule 1 1 [.left, .right, .left] = .error ⟨1, 2, 1, 1⟩)),
  ("interleaving.schedule.excess-right", decide
    (checkSchedule 1 1 [.right, .left, .right] = .error ⟨1, 1, 1, 2⟩)),
  ("interleaving.schedule.empty-extra-left", decide
    (checkSchedule 0 0 [.left] = .error ⟨0, 1, 0, 0⟩)),
  ("interleaving.schedule.empty-extra-right", decide
    (checkSchedule 0 0 [.right] = .error ⟨0, 0, 0, 1⟩)),
  ("interleaving.schedule.both-wrong-counts", decide
    (checkSchedule 1 2 [.left, .left] = .error ⟨1, 2, 2, 0⟩)),
  ("interleaving.schedule.disjoint-admitted", accepted
    (Interleaving.admit cfg boundaries [usd 3] [shares 4] [.right, .left])),
  ("interleaving.schedule.overlap-admitted", accepted
    (Interleaving.admit cfg boundaries [usd 3] [usd 4] [.left, .right])),
  ("interleaving.schedule.overlap-left-funded", accepted
    (executeStep cfg (boundaries .left 0) 0 [] (.invoke (usd 3)) initial)),
  ("interleaving.schedule.overlap-right-funded", accepted
    (executeStep cfg (boundaries .right 0) 0 [] (.invoke (usd 4)) initial)),
  ("interleaving.schedule.unreachable-left-suffix", refused
    (Interleaving.admit cfg boundaries [usd 11, unknown] [shares 4] [.left, .right, .left])
    (.structural .left ⟨1, .interface .unknownOperation⟩)),
  ("interleaving.schedule.unreachable-right-suffix", refused
    (Interleaving.admit cfg boundaries [usd 3] [shares 21, unknown] [.right, .left, .right])
    (.structural .right ⟨1, .interface .unknownOperation⟩)),
  ("interleaving.schedule.precedence-configuration", refused
    (Interleaving.admit invalidCfg boundaries [unknown] [unknown] []) .configuration),
  ("interleaving.schedule.precedence-left", refused
    (Interleaving.admit cfg boundaries [usd 3, unknown] [unknown] [])
    (.structural .left ⟨1, .interface .unknownOperation⟩)),
  ("interleaving.schedule.precedence-right", refused
    (Interleaving.admit cfg boundaries [usd 3] [shares 4, unknown] [])
    (.structural .right ⟨1, .interface .unknownOperation⟩)),
  ("interleaving.schedule.precedence-counts", refused
    (Interleaving.admit cfg boundaries [usd 3] [shares 4] []) (.schedule ⟨1, 0, 1, 0⟩)),
  ("interleaving.schedule.empty-admitted", accepted
    (Interleaving.admit cfg boundaries [] [] []))]

end DefiKernel.Interleaving.ScheduleTests
