# 1.1b — characteristic laws for the reduced basis `|P|=4`

**Date:** 2026-08-07  
**Source:** `basis/BASIS.md` §2 (not re-derived; packaged as gate artifact)

The lane families F1–F8 collapsed or merged. The live generators are:

| primitive | characteristic law (one line) | separates from |
|---|---|---|
| **P1 Led** | only ops that change stored `Q`; conservation `‖bal‖=sup` | Prop (computes, does not store), Post (cannot write Q by no-forgery) |
| **P2 Prop** | `π(a,b,c)=⌊a·b/c⌋` with unit `π(a,c,c)=a` and round-trip `≤` | Led (no multiplicative term), Cmp (result not B) |
| **P3 Cmp** | sole producer of sort `B` used as guards | Led/Prop/Post (none have result B) |
| **P4 Post** | exogenous write of `Σ` or `Φ` not forced by prior `Q` | Led (conservative), Prop (term former only) |

## Pair / family tests already run

| test | result |
|---|---|
| PRO_RATA vs INDEX (F1/F7) | collapsed into Prop+Led / Prop+Post |
| pairs 2–3 | collapsed (artifact taxonomy) |
| deferred-claim cluster (F2-class) | **autonomy separates 2–2** under 6h |

## Status of gate 1.1b

- **Reduced basis laws:** recorded here from BASIS (characteristic, not newly machine-checked in Lean).
- **Mechanism-pair autonomy:** machine-checked cluster + WBTC (`GATE-1.1B-PAIR4-RETEST.md`).
- **Still open:** Lean/Quint formalization that each P_i is not definable from the others (that is closer to **1.2 pairwise independence**).

**Honest disposition:** 1.1b is **PARTIAL** — enough laws exist to name each of the four generators and to separate the deferred-claim cluster; full independence proofs remain 1.2.
