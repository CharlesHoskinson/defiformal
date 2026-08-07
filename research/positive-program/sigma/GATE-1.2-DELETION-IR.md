# Gate 1.2 — IR deletion experiment (gen-ir-v2ten)

**Status: MEASURED (heuristic)** 2026-08-07

For each primitive P_i, count IR declaration names keyword-tagged to P_i.
If those nodes are deleted, that fraction of the IR surface disappears.
Coverage witness for non-definability option 2 in GATE-1.2-SKETCH —
not a formal term-language proof.

Total named nodes walked: **66489**

Script: `gate12_deletion_ir.py`

## Tag totals

| tag | count | share |
|---|---:|---:|
| OTHER | 57972 | 87.2% |
| Led | 5024 | 7.6% |
| Post | 3279 | 4.9% |
| Prop | 175 | 0.3% |
| Cmp | 39 | 0.1% |

## Deletion impact

| delete | nodes removed | residual |
|---|---:|---:|
| Led | 5024 | 61465 |
| Prop | 175 | 66314 |
| Cmp | 39 | 66450 |
| Post | 3279 | 63210 |

## Interpretation

- Led/Prop/Post each tag non-trivial IR mass.
- Cmp under-counted (many guards unnamed).
- OTHER dominates (KERNEL + untagged) — expected.
- **1.2 not formally closed**; this is constructive corpus evidence only.
