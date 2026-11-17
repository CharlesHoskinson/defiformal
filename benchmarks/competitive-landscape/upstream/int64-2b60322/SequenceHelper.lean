import TransferHelper
namespace Benchmark
theorem sequenceLaw (b : Ledger) (ts : List Instruction) (h : traceValid b ts) :
    total (run b ts) = total b := by
  induction ts generalizing b with
  | nil => rfl
  | cons t ts ih =>
    exact (ih (transfer b t) h.2).trans (transferLaw b t h.1).1
end Benchmark
