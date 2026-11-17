# Independent quantified conversion-domain review

**ACCEPT_WITH_LIMITATIONS** for this exact arithmetic proof increment. No blocking finding or required repair. Typed-wrapper correspondence remains separate and II.2 is not closed.

Baseline: `95352f1b386cbedd831ed03d7906f36c160ea8b2`. Candidate digest: `1f87130adaa6cc747290f316e4532090029b8a33b510aed9b4386bfdc390b94e`. Both file hashes match the freeze: ConversionDomain.lean `d318b96d5123e79512cd80148217f9075600ca85be5053d32c4e7aee9d6919ee`, root entrypoint `e16d2159b215096460be18165c325c5585c8a14fb8d4be3cb452f641daa32bfb`. The root adds the new import. Compared 227 remaining tracked Lean/config inputs in author and isolated review trees against baseline Git objects; they match. Candidate bytes in the isolated checkout remain unchanged after verification.

Requested reviewer: `gpt-6-astra`, medium reasoning. No provider-returned model identifier or attested effort is exposed to this independent Codex subagent; actual identity remains unavailable. Review copied the frozen candidate into the assigned isolated baseline checkout only; no author/root source or task checkbox was edited.

## Theorem assessment

The native operation first checks 256-bit multiplication of assets by RAY, then floors division by chi, then checks the quotient Word bound. The new admissibility predicate matches that actual successful arithmetic domain: positive Word192 chi and product strictly below 2^256 for arbitrary Word256 assets.

`floorWord` constructs the result directly from natural floor division. Its Word bound follows from quotient ≤ numerator and the checked-product bound, rather than an assumed successful output or an externally supplied quotient bound. `native_success` proves the actual `convertToShares` executable returns this constructed word for every admissible input. `successful_iff_admissible` proves the converse as well, so the declared domain is not merely a sufficient selected subset.

`floor_bounds` states the lower/strict-upper integer interval. `rational_floor_interval` correctly lifts the raw scale-1 amounts to rationals: q ≤ assets*RAY/chi < q+1. It does not falsely assert equality to an unrounded rational result. Its use of the existing rational-error theorem first derives the required successful division result internally; success is not a new caller premise.

`native_overflow` and `native_zero_rate` reflect execution order. Overflow is selected even when chi is zero; divisionByZero requires a bounded product. `native_error_iff`, quantified over all Vault.Failure values, gives an exhaustive and bidirectional classification. `no_quotient_overflow` follows by contradiction from that classification. Zero asset amounts with positive chi are included; the both-overflow-and-zero-rate case is explicitly accounted for. The proofs preserve the native checked multiplication semantics rather than inventing a wider full-product algorithm.

All eight explicit theorem statements are useful quantified results over the actual native definition. Historical theorem statements are untouched. No sorry, native_decide or custom axiom is introduced.

## Independent execution

In `/private/tmp/defiformal-ci-baseline/lean`, with the provided pinned compiler and isolated cached build state, independently ran:

- `lake build DefiKernel.Vault.ConversionDomain`: exit 0.
- Fresh `lake env lean <review>/AuditConversionDomain.lean`: exit 0; 30 theorem constants and 3 supplemental declarations, forbidden=0.
- `lake env leanchecker -v DefiKernel.Vault.ConversionDomain`: exit 0 with exactly one matching replay marker.

The 30 audited theorem constants include generated constants alongside eight explicit theorem statements; they are not thirty distinct new financial claims. Only standard permitted axioms occur. Exact commands, raw logs and tool hashes are saved in execution.json and adjacent files. Lean version is 4.33.0-rc2, arm64-apple-darwin24.6.0, commit `d8b18978322de05a8f3dba51ef03cf5461676c17`; compiler SHA-256 `1b370cfcbf44e80d1b004ab1b1ab9a4c73951f9f7c242140bcff9bc577576554`.

## Scope limits and disposition

This is the arithmetic conversion layer. It does not yet prove correspondence of a typed deposit execution, ledger update, asset-indexed wrapper, fee-bearing operation or deployed contract. The underlying conversion has no fee term, so no fee claim is inferred. Rates are raw Word192 chi and amounts raw scale-1 units. Native multiplication overflow remains a real refusal; the theorem does not widen that successful domain.

Dependencies are reused from the pinned cache and trusted by the same-kernel leanchecker; no independent dependency rebuild or full campaign is claimed. Root/full hosted integration is a separate delivery check. Author command/session wall intervals remain process evidence, not human authoring effort.

Accept this exact prerequisite for integration, retaining the quantified domain/rounding/error claims above. Continue typed-wrapper work under a separate exact-candidate review; leave II.2 and all unrelated effort/reproduction gates open. No completed agenda task is credited.
