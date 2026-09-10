# P24 pinned liquidation test entry

This is a source inspection of seven files at Morpho Blue revision `8e26ca6a8dbc5089edcd67fb576248810fd2870a`. No Solidity test or source transaction was executed. `readiness.json` binds all Git blobs, hashes, ten test declarations, the Forge dependency revision, and current EVM tool identity.

The upstream suite provides public-call setup for a bad-debt transition, two no-bad-debt transitions, and an exact healthy-position refusal. The bad-debt test uses one supplier and does not require strictly positive bad debt for every fuzz input. The no-loss fixtures deliberately leave collateral. Future deterministic source observations must distinguish those conditions explicitly.

Two additional cases affect the model: one extra borrow share can make computed bad debt exceed remaining market borrow assets, so the production minimum matters; and repayment of one share can produce one repaid asset with zero seized collateral. The first upstream test has no explicit poststate assertions. The second asserts both returned quantities. Neither is an observation from this workstream yet.

Mock token balances, oracle updates, IRM behavior, actor impersonation, time and market creation belong to the fixture identity. The upstream single-supplier assertions do not define a multi-supplier rounded loss allocation. Preserve that separate obligation.

The existing geth EVM binary still matches its recorded SHA and exposes state-transition execution. The version/help commands do not establish any deployment, fork-specific source behavior, mutant result, Lean proof, or P24 entry acceptance.
