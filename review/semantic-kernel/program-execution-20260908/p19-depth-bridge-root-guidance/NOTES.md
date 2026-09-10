# Depth bridge handoff for the next author round

This is root source analysis and one bounded diagnostic against frozen R25. It is not a production proof or an independent Grok review. AGY R26 was live throughout; its source and caches were not inspected. Reconcile this guidance with completed R26 before the next author dispatch.

The outstanding depth premise concerns `TreeJson.depth (moduleToTreeJson ir)`. Existing admission instead bounds `jsonDepth (decodedIRToJson ir)`, defined using `jsonDepthFuel 100`. Existing `jsonDepth_stable_of_le64` and `jsonMaxArrayLength_stable_of_le64` already establish stability at larger fuel on that semantic JSON document. Their types were checked in the completed R25 reviewer build; they do not establish the missing representation bridge.

A possible proof route, still unproved here:

1. Establish the object-fold maximum identity for `Json.mkObj` on distinct-key field lists. `mkObj` constructs a `Std.TreeMap.Raw.ofList`. Work with its traversal/lookup semantics, retaining key distinctness and recursive child metric hypotheses.
2. Use that identity and the array list fold identity to relate `jsonDepthFuel fuel tree.toJson` to `min fuel tree.depth`. Recursive distinct-key conditions suffice for object preservation; the existing `TreeJson.Valid` supplies them. The array-length part of Valid is not what justifies the depth identity.
3. Establish equality of the two module representations' *depth measurements*, including recursive expressions and all typed/step/run payload and envelope fields. Do not assume structural equality of their underlying raw maps. For record constructors whose child Json values are structurally equal, existing representation lemmas can be reused; other constructors require the child metric relation.
4. Combine the measured-depth bridge at fuel 100 with the existing admission bound 64. Derive the actual parser depth premise and retain the full accepted domain. This closes neither whole-module decoding nor the lexical scanner by itself.

The following pinned standard-library interfaces were checked successfully:

- `Std.TreeMap.Raw.foldl_eq_foldl_toList`: exposes the fold as a list fold.
- `Std.TreeMap.Raw.toList_insert_perm`: relates insertion traversal to the inserted pair plus the old traversal with that key removed; requires a well-formed map and comparator instances.
- `Std.TreeMap.Raw.ofList_equiv_foldl`: relates `ofList` to a fold of insertions by map equivalence.
- `Std.TreeMap.Raw.Equiv.foldl_eq`: equates folds for well-formed equivalent maps. It requires equivalence of the stored values; it does not alone equate recursively different Json representations.
- `Std.TreeMap.Raw.getElem?_ofList_of_mem`: gives lookup from a distinct-key source list.

Do not drop the distinct-key condition in a general helper. The executed invalid-tree diagnostic used `[("k", [[null]]), ("k", null)]`: syntactic depth was 3, while depth after `toJson` was 1 because the later duplicate replaces the deeper value. This is not a counterexample within `TreeJson.Valid` or the admitted production domain.

Avoid using `Json` Boolean equality as a new proof shortcut. The pinned `Lean/Data/Json/Basic.lean` implements it through a private `partial def beq'`, so a computation returning true supplies no accessible recursive kernel equations for the desired bridge. The earlier library-reference example already distinguishes Boolean equality from raw-tree structural equality. Prefer the total fold, membership, and permutation interfaces above.

The lexical obligation remains separate. `scanLexicalFuel` carries depth, an object/array scope stack, a numeric buffer and a whitespace flag; string skipping consumes a variable-length suffix. A scanner proof must maintain those states through encoded strings, numbers and container boundaries, preserve key uniqueness and array limits, and prove enough fuel for the real character stream. Existing token parser inversion does not establish this additional scanner's result.
