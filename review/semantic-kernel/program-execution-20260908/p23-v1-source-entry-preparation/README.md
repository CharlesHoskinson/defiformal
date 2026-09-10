# P23 V1 source candidate

Liquity V1 pin `3e64ee1b52c50d51587c64c1cf75e0ba82934979` contains an active `totalETHDrawn > 0` guard at TroveManager.sol:999. This supplies a concrete source candidate for the required refusal. The earlier V2 mismatch remains preserved in `../p23-source-entry-inspection/`.

The guard rejects zero collateral drawn, which is broader than an empty list. Earlier fee, bootstrap, TCR, amount, balance and system-debt checks can stop execution first. This inspection does not establish a reachable empty-set transaction. Source execution must observe the actual failure and its precedence before accepting the case.

Traversal uses collateral-ratio order, validated hints, pending rewards and cancellation of stale or below-minimum partial fills. Full closure also burns the liquidation reserve. A payment/debt proof must include these boundaries or explicitly delimit the admitted domain. Zero maxIterations is an unlimited sentinel in the source.

This is a new ordered-redemption pin, separate from the P10 liquidation dispute. Selected source/config/license bytes have Git blob and SHA256 identities in readiness.json. Source execution, observation freeze, Lean proofs, mutations and fresh Grok review remain pending. Task24.1 and P23 remain open.
