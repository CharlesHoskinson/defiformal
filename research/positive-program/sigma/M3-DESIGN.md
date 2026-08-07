# M3 design note — n-ary binding (2026-08-07)

## Contract (what we will prove)

1. **Stable ports.** Indices are global port names; a machine exposes a finite port set.
2. **Global Binding.** A finite set of undirected port-pairs that must agree on state.
3. **Agreement.** `Agrees B s` means every bound pair has equal values under `s : Idx → ℤ`.
4. **Reindex invariance.** If two bindings have the same symmetric closure as relations, they induce the same agreement predicate (parenthesization / listing order does not matter).
5. **N-ary composite.** The composite constraint is agreement on the *union* of binding sets; union is associative/commutative, so multi-party composition is bracket-independent at the constraint level.
6. **Negative companion.** Pair-local stepwise κ (only edges within a designated left/right cut) cannot express a cross edge that skips the cut — so binary pair-local composition cannot state an arbitrary triple binding.

## Out of scope (M3)
- Full operational transition systems / reachability
- Lifting full M1 Cons through transitions (only state-agreement constraints)
- Corpus mapping (M4)
- Fusion / Prop rounding (M2 remains local)

## File
`lean/Defialgebra/Nary.lean`
