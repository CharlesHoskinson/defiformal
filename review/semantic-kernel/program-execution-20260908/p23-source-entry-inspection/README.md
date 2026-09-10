# P23 source-entry mismatch

The development material references Liquity V2 BOLD ordered redemption. This inspection captures a new explicit candidate pin `c8a5a4ee2e9dc024905856b6698a77d849c68c7e`, separate from the P10 Liquity V1 liquidation dispute. The historical development revision was not established.

`TroveManager.sol:826–827` explicitly comments out the unable-to-redeem-any-amount guard. The ordinary redemption method returns actual debt decrease at844; `CollateralRegistry.sol:171–174` burns only a positive actual redeemed amount. This does not establish the empty-set refusal required by program24.1/24.3. No actual empty-set transaction was executed, and other calls or arithmetic may independently revert.

Ordering starts with a pending zombie if present, otherwise the sorted-list tail, then predecessors. ICR below100% is skipped. A simple unconditional interest-order prefix would omit these source distinctions. The partial lot is the minimum of remaining amount and entire debt; the public token-burn boundary is in CollateralRegistry.

P23 remains open. An appropriate source pin or independently reviewed contract resolution must satisfy the full requirement before claiming its empty-set case. This record preserves the mismatch; it does not accept a replacement successful-zero-fill case or close P10/R12. Selected source/config/license bytes and Git blob hashes are in readiness.json. Compiler closure, execution, implementation and proofs remain outstanding.
