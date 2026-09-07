# Babylon Protocol — instruments source research

`spot_asset`: proposed **not_evidenced**. All dispositions remain draft and unaccepted.

Selected `dispute-07`, `unit:lane1:c3:p4` in deterministic order. Raw A-only labels: []; B-only labels: ['spot_asset']. Exact records and original pointers are preserved in [selection-and-observations.json](selection-and-observations.json). The actual generated facet rule is `INTERSECTION_UNRESOLVED`.

source statement: Pinned documentation describes native BTC locked in staking scripts, with the staker as controller/beneficiary and timelocked withdrawal back to a staker-controlled address. [register-stake](https://raw.githubusercontent.com/babylonlabs-io/babylon/0de36afadb84fec624c80b07d743a0d9f5341722/docs/register-bitcoin-stake.md), [staking-script](https://raw.githubusercontent.com/babylonlabs-io/babylon/0de36afadb84fec624c80b07d743a0d9f5341722/docs/staking-script.md)
source statement: The captured official homepage describes native staking without wrapping or bridging; the requested help URL redirected there. [native-staking](https://babylonlabs.io/help-articles/what-is-babylon)
bounded evidence gap: These sources establish the underlying BTC and stake-control workflow, but do not resolve whether the corpus’s exposed instrument meets the proposed current-ownership/control transfer predicate. No separate spot instrument is established merely by naming BTC. [register-stake](https://raw.githubusercontent.com/babylonlabs-io/babylon/0de36afadb84fec624c80b07d743a0d9f5341722/docs/register-bitcoin-stake.md), [staking-script](https://raw.githubusercontent.com/babylonlabs-io/babylon/0de36afadb84fec624c80b07d743a0d9f5341722/docs/staking-script.md)

These findings apply the proposed reusable rule predicates, with exact source lines in [proposed-adjudication.json](proposed-adjudication.json). Evidence spans and their hashes are in [evidence-locators.json](evidence-locators.json).

- The requested help page redirected to the current Babylon homepage. Its Trustless Bitcoin Vault/Aave material is a different product path and is not evidence for this staking-unit instrument label.
- The two pinned files are documentation at revision0de36afadb84fec624c80b07d743a0d9f5341722, not compiled scripts or a historical/deployed configuration.
- Native BTC is a current asset and the staker has conditional control over locked BTC. That fact must not be silently equated with the taxonomy predicate for the product’s exposed instrument. Conversely, absence of a transferable receipt does not itself refute spot_asset.
- The evidence budget does not establish the precise instrument boundary intended by the unresolved unit; no wrapping, BABY-token or third-party liquid-staking instrument is imported.

The strongest positive reading is that the exposed instrument is native BTC itself, whose control the script regulates. The alternative is that BTC is only the input to a staking service. Source inspection does not alone choose this taxonomy boundary; not_evidenced preserves that gap without claiming no spot asset exists.

Captured exactly three primary bodies, 229836 bytes, with actual URLs, timestamps, headers and hashes in [retrievals.json](retrievals.json). Publisher and product scope are recorded per source; related infrastructure is not independent corroboration of a deployed product. No contract compilation/execution or independent deployment verification occurred. No corpus or existing research bytes were changed.

Independently resolve the scoped instrument boundary under the existing reusable rule. If necessary, obtain a separately reviewed concrete instrument/product rights specification; do not promote a spot underlying automatically.

This packet does not adjudicate other facets, recover missing original citations, establish deployed fidelity or provide holdout evidence. Author: GPT-6 stock Codex harness; independent review remains pending.
