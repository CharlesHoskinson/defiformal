Morpho compiler readiness

The exact14-source closure at8e26ca6a8dbc5089edcd67fb576248810fd2870a compiled with Solidity0.8.19+commit.7dd6d404. The downloaded compiler matches the SHA256 in the captured official ethereum/solc-bin Linux manifest. Effective settings follow the pinned foundry.toml: viaIR=true, optimizer enabled with999999runs, EVMparis and metadata bytecodeHash=none. The root source pragma fixes0.8.19.

The compiler exited0 and produced20contract/library/interface artifacts with no errors. Morpho creation/runtime bytecode sizes are16014/15582bytes. The recorded runtime bytes are compiler output before constructor-specific immutable substitution, not an observed deployed runtime. Original standard input/output, compiler identity and hashes are retained.

This is a compiler check only. No liquidation, token transfer, callback or oracle transaction was executed; no reachable-loss/no-bad-debt/refusal observation or P24 task acceptance follows. The allocation/remainder contract and full source execution and independent review remain open.
