# P31 adapter source readiness — pending review

These four records identify concrete Moriarty, Compact, ZKIR and proof-carrying-transaction boundaries from Moriarty commit `7307349d0275af6fcb4144e1661d8b59d6b2663a`. Thirteen source/license files are preserved with their Git blob identities and SHA-256 hashes. Moriarty working files are not modified. This is pinned source inspection; no compiler, runtime, K prover or Lean proof was run for this preparation.

The main implementation priority remains P19/P20. These records prepare tasks32.1–32.4; none is independently accepted, none closes an adapter implementation task, and P31 remains open. Existing source APIs support specific candidate mappings, but full semantic correspondence and trusted transaction acceptance still require implementation and proof.

Two boundaries affect future design: the Moriarty canonical codec uses strings/booleans/records/arrays rather than accepting arbitrary JSON values, and funded repayment decrements the unallocated remainder of a transfer while checking distinct allocation IDs. Do not substitute wire-format equality or an overly restrictive one-allocation-per-transfer rule for the actual source relation.

The Compact mapper is a restricted numeric Core mapping. The recorded compiler route uses `--skip-zk`; generated snapshot/ZKIR artifacts do not establish proofs or ledger settlement. The public Moriarty evaluator requires a deployment-owned authentication/verify-and-commit backend, which is not implemented by the inspected interface package.
