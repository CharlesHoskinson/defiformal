# P16 equation/reduction diagnostic

**Confirmed successful technique on the old frozen partial snapshot:** orient `numerator1` as `Q96 * liquidity.value`, keeping the symbolic argument second. With that sole computational change and a commutativity step preserving the existing bound proof, the previously stalled `primary_add` prefix compiles with its unchanged final `rfl` in **1.625 seconds**. This is a reversible diagnostic, not production authorship or implementation acceptance.

Input: capped r1 archive SHA-256 `73263ef038032357ec789a09fa6c086206426f8e1beade9250b5ea999dd73185`. All work used the existing private reviewer sandbox. No W16 source/cache or active r2 source was inspected or changed. Lean/tool identity is the same pinned 4.33.0-rc2 recorded in the preceding partial review.

## Cause and controlled result

Pinned Lean core `Init/Prelude.lean:1791–1793` defines multiplication by recursion on its **second** argument:

```lean
protected def Nat.mul : Nat → Nat → Nat
  | _, Nat.zero => Nat.zero
  | a, Nat.succ b => Nat.add (Nat.mul a b) a
```

The frozen `numerator1 L` is `L.value * Q96`, where Q96 unfolds to `2^96`. Symbolic normalization can therefore expose recursion down a huge concrete second argument. Using `Q96 * L.value` instead blocks that recursion on the symbolic second argument. These forms are mathematically commutative but behave differently under definitional reduction. This explains why the same unchanged one-layer match equality becomes tractable after the orientation change; it does not identify every internal reduction step or prove that all later declarations are fixed.

The reviewer-local patch changes only the `numerator1` multiplication order and adds `rw [Nat.mul_comm (2 ^ 96) L.value]` after unfolding in the existing `numerator1_lt_u256` proof. No statement was weakened. The SqrtPriceMath target built in **1.674 seconds, exit 0**. The old exact proof prefix through `primary_add`, previously timed out at eight seconds after its selector rewrite, then compiled in **1.625 seconds, exit 0**. It retained the same selector rewrite and final `rfl`; no new proof strategy was substituted. `logs/orientation.patch`, original/probe sources and command receipts bind this result. The native author must adapt and check the corresponding change against its current r2 source, then continue required bounds and audits. No full current candidate was run here.

## Equation inspection

The imported environment contains `addPrimary` and its generated matcher, but neither `addPrimary.eq_def` nor `addPrimary.eq_1` is pre-existing. A combined equation-inspection command hit an eight-second cap. Simple definition inspection succeeds. Raw elaborated expressions show the original and independently elaborated RHS use the same discriminant type `Except Failure U256` and output type `Except Failure U160`, with distinct generated `match_1` constants. Their visible cases agree; no outcome/type mismatch was found. Merely delta-unfolding both matcher wrappers also timed out. Thus an existing cheap generated-equation shortcut was not established; the orientation probe supplied the effective bypass.

## Preservation and limits

All nine original Lean source hashes were restored after the probe, and the original SqrtPriceMath cache target was rebuilt successfully in 2.337 seconds. The probe cache is not being handed off as the original implementation. The frozen archive and earlier review remain unchanged.

One routing mistake is explicitly preserved: the reused old prefix probe embedded its earlier review's marker-log path and appended two marker lines. Those exact appended lines were removed by matching the earlier sealed manifest hash; **all files in that prior review's manifest now match their sealed hashes**. `logs/marker-routing-incident.json` records the incident. No author source/evidence was affected.

This result confirms a concrete reduction-sensitive representation choice for the frozen r1 case. It grants no acceptance, source-execution credit, pre-cast bound, fallback-positivity proof or completed audit. Native Grok remains the implementation author. Checker and sandbox are released.
