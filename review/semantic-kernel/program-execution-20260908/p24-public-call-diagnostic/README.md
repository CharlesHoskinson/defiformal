# P24 local public-call diagnostics

Four source executions completed against unchanged Morpho Blue `8e26ca6a8dbc5089edcd67fb576248810fd2870a`. Production creation and runtime bytecode match the earlier pinned compilation exactly. Solc 0.8.19 uses viaIR, optimizer 999999, Paris, and no metadata bytecode hash. The root diagnostic harness uses the pinned upstream token and oracle mocks, a zero IRM, one actor for all roles, empty callback data, and no elapsed time.

| Case | Actual observation |
| --- | --- |
| Healthy position | Exact `HEALTHY_POSITION` error; observed market and position structs unchanged. |
| Repay one share | Returned seized assets 0, repaid assets 1; borrow assets 300 → 299; collateral remains 400. |
| Partial liquidation | Seized 1e18; repaid 92500000000000001; collateral remains 9e18; total supply assets stay 2e18. |
| Full liquidation with inflated borrow shares | Returned repayment 92500000000000002; remaining borrow assets before loss 907499999999999998; derived unclamped conversion 907499999999999999. Actual borrow assets/shares and collateral become zero; total supply assets fall by 907499999999999998. |

Stored supplier shares remain unchanged in all four cases. The derived unclamped conversion uses the pinned arithmetic library inside the diagnostic; it is a branch diagnostic, not an independent arithmetic oracle. `decoded-observations.json` maps all sixteen returned words to explicit fields.

Each case starts from fresh local state. The harness runtime is installed directly by `evm run`; it invokes actual production constructors and public calls. The genesis config enables forks through London and the merge, with no Shanghai/Cancun activation. It uses block 0 and timestamp 1. The hash-bound geth 1.15.11 runtime source sets a non-null Random value; the CLI passes the supplied chain config, time, block and state. `evm-source/` preserves those exact launcher/runtime sources. This is a configured Paris source diagnostic, not an observation of a deployed network.

The first attempt failed compilation because the root harness imported WAD from the wrong library. Solc returned process exit 0 with an error in its JSON, which the runner correctly rejected. The second attempt compiled successfully but geth rejected a nonzero genesis block number before source execution. Both attempts and their outputs remain intact. The successful third runner reuses the exact unchanged compiler input/output from attempt 2 and changes only the genesis block number. No failed attempt receives execution credit.

These observations do not close task 25.1 or P24. Independent review, the complete source entry plan, a model and Lean correspondence, source mutants, nonzero-interest and callback coverage, and the explicit multi-supplier rounding/allocation contract remain open. The healthy refusal compares the returned market/position structs, not the full global state. No deployment-history or mainnet-reachability claim is made.
