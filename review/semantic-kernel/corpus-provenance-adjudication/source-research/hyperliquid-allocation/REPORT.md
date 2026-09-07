# Hyperliquid — mechanisms source research

`allocation`: proposed **supported**. All dispositions remain draft and unaccepted.

Selected `dispute-08`, `unit:lane2:c0:p0` in deterministic order. Raw A-only labels: ['allocation']; B-only labels: []. Exact records and original pointers are preserved in [selection-and-observations.json](selection-and-observations.json). The actual generated facet rule is `INTERSECTION_UNRESOLVED`.

source statement: The legacy vault guide describes a leader trading on behalf of a vault, with trades applied to vault capital, and identifies validator-operated perpetual markets as its permitted instruments. [vault-leaders](https://hyperliquid.gitbook.io/hyperliquid-docs/hypercore/vaults/for-vault-leaders-legacy)
source statement: The protocol-vault page describes HLP deploying liquidity across market-making strategies, liquidation activity and Earn. [protocol-vaults](https://hyperliquid.gitbook.io/hyperliquid-docs/hypercore/vaults/protocol-vaults)
inference under proposed rule: The documented leader selects trading exposure for pooled capital, providing the authorized-actor and identified-destination components of the allocation rule. HLP is additional scoped strategy context, not proof of a universal allocation formula. [protocol-vaults](https://hyperliquid.gitbook.io/hyperliquid-docs/hypercore/vaults/protocol-vaults), [vault-leaders](https://hyperliquid.gitbook.io/hyperliquid-docs/hypercore/vaults/for-vault-leaders-legacy)

These findings apply the proposed reusable rule predicates, with exact source lines in [proposed-adjudication.json](proposed-adjudication.json). Evidence spans and their hashes are in [evidence-locators.json](evidence-locators.json).

- The captured vault overview now describes HyperEVM/CoreWriter vaults, while the leader guide explicitly concerns legacy HyperCore vaults. Search snippets contained older overview wording; conclusions use actual captured bytes.
- The allocation finding is scoped to the leader-managed vault path already included in the broad corpus context. It is not a claim about every Hyperliquid trade, all vault implementations or chain staking.
- The legacy guide excludes spot and HIP-3, whereas the newer vault overview describes broader access. These are distinct product generations, not interchangeable permissions.
- No live vault address, actual trade, HLP allocation amount, strategy implementation or historical state was inspected. Current pages do not establish the 2026-08-04 deployment snapshot.
- The withdrawal position-reduction rule is retained as a qualification on manager control; no unconditional discretion or successful withdrawal guarantee is inferred.

Merely holding USDC in a venue would not establish allocation. The explicit leader trading authority over the vault’s exposure is the additional source premise; a generic customizable-vault claim is not used as its substitute.

Captured exactly three primary bodies, 1190389 bytes, with actual URLs, timestamps, headers and hashes in [retrievals.json](retrievals.json). Publisher and product scope are recorded per source; related infrastructure is not independent corroboration of a deployed product. No contract compilation/execution or independent deployment verification occurred. No corpus or existing research bytes were changed.

Independent review of the scoped leader-vault allocation finding. Any exact HLP allocation or historical vault implementation claim requires its own version/address/strategy evidence.

This packet does not adjudicate other facets, recover missing original citations, establish deployed fidelity or provide holdout evidence. Author: GPT-6 stock Codex harness; independent review remains pending.
