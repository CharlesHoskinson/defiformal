# P31 ZKIR dependency navigation

This is a root source-navigation record over the captured crate versions. It is input preparation for the native AGY adapter author and fresh Grok review. It does not implement or accept the semantic contract.

## Commitment data flow

The ZKIR preprocessing path concatenates its inputs and computed outputs, then passes that field slice and the commitment randomness to `transient_commit`. That helper puts the opening first. The `FieldRepr` implementation for `[Fr]` writes the slice directly, without a length prefix. The circuit path explicitly assembles randomness, inputs and outputs in that same order, calls the standard library Poseidon gadget, and asserts equality with public input index1. These source expressions resolve the previously uncaptured preimage-layout dependency.

The CPU hash and circuit hash both use `PoseidonChip` with fixed-length initialization from the number of input elements. This is source-level alignment, not proof that the implementations or generated constraints agree. The internal sponge/permutation constraints, field operations, witness and public-input binding, and actual harness execution remain required within the declared adapter scope.

## Field identity

The transient-crypto wrapper `Fr` contains `outer::Scalar`, which aliases `midnight_curves::Fq`. The standard library field is also `midnight_curves::Fq`. The separate embedded curve scalar aliases `midnight_curves::Fr`; it must not be substituted merely because its Rust identifier matches the wrapper name. The captured Fq modulus is `0x73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001`. The decimal value and agreement with the four little-endian limbs are recomputed in navigation.json.

Arithmetic is over that field. Any supported bounded-integer financial operation needs an explicit representation and range/no-wrap correspondence; source capture does not supply it. Fq arithmetic also calls `blst`, whose exact locked package is recorded as an uncaptured external dependency in navigation.json. Capturing all twelve Midnight packages is not a full dependency build closure.

## Transcript boundary

`PiSkip` has preprocessing behavior: a false guard records a skip and adjusts the transcript input cursor; the other branch checks the associated public-transcript elements. The circuit match arm is empty. This difference must be accounted for by the adapter's witness, transcript, skip and public-instance interface. It is not, by itself, proof of a circuit bug or of soundness. Source index/bounds assumptions must remain explicit.

## Next implementation obligations

The AGY author must declare the supported opcodes and representation, witness/public-input ordering, transcript rules, and commitment interface, and establish scoped correspondence with real execution before adapter acceptance. Compiler source-to-installed-binary correspondence remains a disclosed assumption unless separately established; no new universal compiler-correctness or mandatory reproducible-build gate is introduced here. Full P31, P19/P20 integration and the whole roadmap remain open.

All fourteen anchors bind original repository paths, complete source hashes, line intervals and exact excerpt hashes. No downloaded source or circuit was executed by this navigation step.
