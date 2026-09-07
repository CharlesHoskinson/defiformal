# Arithmetic implementation contract

The identical planning candidate passed nonauthor GPT-6 and native Fable 5.1
medium. The seven Fable findings are adopted without changing the accepted
numeric contract. Original reviewed plan and reports remain frozen.

1. M04 targets `Rounding.divideNat`; F45 also changes under that mutation.
2. `toQuantity` uses an inline `positivity` proof that also elaborates when M11
   removes the scale. Compiler refusal remains blocked evidence.
3. Both asset compiler controls use the actual new `toQuantity` return value.
4. Q06 binds F42 to 25, 67/4 and 33/4. Q07 records F40/F41 payer coincidences.
5. Final verification freshly elaborates RuntimeAudit and ProofAudit separately,
   as well as Verify and the integrated package root.
6. Fixed-positive-denominator mulDiv monotonicity covers both operands, with
   successful result premises. Refusal has no numeric order.
7. Exact error theorems establish that valid subtraction and valid-rate gross
   fees cannot reach their defensive Word.checked subUnderflow branch.

Root currently owns Word, Operations and Rounding. Subsequent workers receive
separate source ownership. No existing kernel source is modified before the
Interface frozen runs complete. Arithmetic remains unaccepted implementation
until its own proof, execution, mutation and native-review gates pass.
