# Fees and Quantity development result

Implemented only `Arithmetic/Fees.lean` and `Arithmetic/Quantity.lean`. Both have clean final LSP diagnostics, and the pinned targeted build passed. All 37 explicit owned theorems were checked with `#print axioms`; only `propext`, `Classical.choice` and `Quot.sound` occur. These are implementation-author checks, not independent/native acceptance.

Fees validates natural rates before division, preserves the two quote conventions, and proves independent floor/ceiling success specifications. Gross quotes exist exactly for valid rates and can return only `invalidRate`. On-top quotes have exactly the invalid-rate or final-addition-overflow cases. Actual successful calls conserve charged = received + fee. Zero/unit rates, zero amounts, exact fractions and one-unit gross rounding are proved for every width, including width zero through the unrestricted statements.

Quantity uses the exact positive-scale amount expression and a self-contained `positivity` proof. Inverse conversion rejects scale, sign, nonintegrality and input overflow in that order. Universal success is equivalent to a positive-scale in-range natural multiple; both same-scale round trips and the exact ordered error predicates are proved. Nat floor only supplies a candidate: equality is checked before construction, so no fractional input is truncated.

The final fee prefix control returned eight true literal comparisons. Actual M09/M10 prefix edits compiled and falsified their respective over-unit-rate and gross-net comparisons while preserving the separately checked on-top and zero-width siblings. The separate M11 barecast prefix compiled and changed its literal 7/4 observation from true to false. Its expected unused-scale warning is retained. These three edits are development constructibility probes, not official frozen package mutation evidence or the future 45-fixture inventory.

All original development failures are retained: the initial Quantity simp mismatch, two LSP proof refinements, and the first two fee bind/pure simplification failures. No expected result or production semantic contract was weakened. Final dependency bytes were unchanged across captured compilation. New external Quantity imports are `Mathlib.Data.Rat.Floor` and `Mathlib.Tactic.Positivity`; bind them in the final projection metadata.

No existing source, root integration, S10 evidence or corpus file was changed by this task. Parent owns final integration, proof inventory, financial fixtures, all official mutants/controls and native acceptance.
