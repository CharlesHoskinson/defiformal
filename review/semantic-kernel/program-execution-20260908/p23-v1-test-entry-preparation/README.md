The pinned Liquity V1 tests provide setup examples for the P23 redemption work. This capture contains six upstream test, helper and configuration files from commit `3e64ee1b52c50d51587c64c1cf75e0ba82934979`. Each file was checked against its Git blob. No test or EVM transaction was run.

The partial-redemption case at `TroveManagerTest.js:2701` starts three positions, combines their LUSD balances and redeems 55,000 LUSD after the bootstrap period. It expects two positions to close and the third to retain approximately 4,600 LUSD debt. This is setup guidance: the suite replaces production contracts with tester artifacts, uses rounding tolerances and changes the base rate through a tester method. A production-source observation still needs exact input, call, output and compiler bindings.

The zero-debt case at line3573 does not establish the required empty-eligible-set refusal. It mints through a tester method, catches any VM exception and has no active assertion on unexpected success. Its body also does not advance the newly deployed system past bootstrap. A title or passing test run would not identify which refusal occurred.

The captured helper signatures also distinguish redemption amount, gas price and maximum fee. Copy the actual public-call arguments deliberately; some wrapper calls and comments do not make that distinction clear. The stale-hint, minimum-debt and TCR refusals remain separate cases from the required empty eligible set.

The static catalog lists37 redemption test declarations, including one declared skipped. These are not execution counts. `TroveManagerTester.sol` is absent from the pinned Git tree despite the suite requesting that artifact; this is a source-inventory observation, not a measured Hardhat failure. The production43-source closure and its successful Solidity0.6.11 compilation remain separate, earlier evidence.

Use `readiness.json` for exact findings and source locations, `capture.json` for source identities, and `redemption-test-catalog.json` for the declaration inventory. P23 task24.1 and the required source observations remain open.
