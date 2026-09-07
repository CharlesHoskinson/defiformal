# JustLend V1 collateralization — proposed disposition

**Draft: supported for the scoped source-level architecture; independent review pending.** No corpus labels were changed.

The deterministic triage selects `dispute-01`, `unit:lane1:c1:p3`, mechanisms/collateralization. Raw A lists collateralization and liquidation; B lists liquidation. The generated record retains liquidation and leaves collateralization unresolved. Exact original observations and JSON pointers are in [selection-and-observations.json](selection-and-observations.json).

The proposed `R-collateralization` requires identified assets to secure an obligation through encumbrance or checks. Asset custody and Compound lineage alone are insufficient. The captured source provides the missing operational link:

- The official documentation distinguishes V1 pooled jToken markets from V2 isolated markets and places V1 risk checks in the Comptroller. Its repository link supplies provenance context. [Official architecture documentation](https://docs.justlend.org/developers/justlend_v2/)
- `getHypotheticalAccountLiquidityInternal` weights entered-market balances by collateral factors, exchange rates and oracle prices, compares them with debt plus hypothetical effects, and returns a shortfall. `borrowAllowed` refuses a positive shortfall. Redemption, transfer and market exit also constrain removal of assets used by these checks. [Pinned Comptroller](https://github.com/justlend/justlend-protocol/blob/f28f3b462a4f281761e23423554563e15fc9f028/contracts/Comptroller.sol#L322)
- `borrowFresh` invokes that permission check before transferring funds and updating debt. The token’s redemption and transfer routines similarly invoke controller permissions. [Pinned CToken](https://github.com/justlend/justlend-protocol/blob/f28f3b462a4f281761e23423554563e15fc9f028/contracts/CToken.sol#L751)

The inference under the proposed rule is collateralization of the borrowing obligation, with the actual checks as evidence. This is a new proposed source-grounded reason, not a vote for annotator A.

Scope matters: membership selects the collateral set; nonmember redemption may bypass the liquidity test. Listing, pauses, prices, arithmetic, freshness and available cash also constrain operations. Collateral sufficiency alone does not guarantee successful borrowing. The full qualifications and claim-to-locator map are in [proposed-adjudication.json](proposed-adjudication.json).

Exactly three primary bodies were retrieved and retained: one current official documentation page and two source files pinned at `f28f3b462a4f281761e23423554563e15fc9f028`. They total 163683 bytes. All belong to the same publisher family. [retrievals.json](retrievals.json) preserves exact requested/final URLs, UTC timestamps, headers, hashes and attempts; [evidence-locators.json](evidence-locators.json) binds 14 exact byte/line spans. Git ref discovery is separately recorded metadata, not an extra contract body. Two search rounds located the official sources; search snippets are discovery only and are not accepted evidence.

The documentation supports V1 architecture scope, but neither it nor this source selection establishes a deployed implementation, proxy state, address binding or behavior on the corpus’s historical date. No dependency compilation, Solidity execution, security proof, deployment fidelity, synthetic recovery or holdout evaluation occurred. Original missing citations remain missing. Energy rental and all other unit/facet labels are outside this packet.

Next: independently review the proposed rule application. Keep the old raw/generated observations and triage immutable even if a future overlay accepts this new evidence.
