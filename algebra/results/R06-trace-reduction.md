---
title: Compatibility is trace-determined
status: PROVED + MEASURED
---

# Compatibility is trace-determined

**Status: PROVED + MEASURED**

Since `R ∩ W` is union-closed ([[R02-lattice]]), a composite fails only by a
prohibition covered by `A ∪ B` and by neither alone. So compatibility depends
only on the traces `H ∩ A`.

Measured: 0 inconsistencies in 1,936 checks; 9 distinct traces over 4,000 models.
The compatibility graph is a **blow-up of a 9-vertex quotient**.

**Caveat:** that quotient is complete (density 1.000), so perfection holds
trivially — and the observed composition failures must come from the
non-membership conditions, not the prohibition clutter.
