# Maple — mechanisms source research

`allocation`: proposed **supported**. All dispositions remain draft and unaccepted.

Selected `dispute-02`, `unit:lane1:c1:p4` in deterministic order. Raw A-only labels: ['allocation']; B-only labels: []. Exact records and original pointers are preserved in [selection-and-observations.json](selection-and-observations.json). The actual generated facet rule is `INTERSECTION_UNRESOLVED`.

source statement: The documented Pool Delegate administers strategies and can fund an agreed institutional loan using pool funds. [actors](https://docs.maple.finance/technical-resources/protocol-overview/protocol-actors)
source statement: The funding flow requests capital via PoolManager for a specified loan; pool cash approval is constrained by withdrawal reserves. [open-loan-manager](https://docs.maple.finance/technical-resources/loan-managers/open-term-loan-manager), [pool-manager](https://docs.maple.finance/technical-resources/pools/pool-manager)
inference under proposed rule: A named authorized actor distributes pool capital to identified loan destinations, satisfying the proposed allocation predicate within this documented architecture. [actors](https://docs.maple.finance/technical-resources/protocol-overview/protocol-actors), [open-loan-manager](https://docs.maple.finance/technical-resources/loan-managers/open-term-loan-manager)

These findings apply the proposed reusable rule predicates, with exact source lines in [proposed-adjudication.json](proposed-adjudication.json). Evidence spans and their hashes are in [evidence-locators.json](evidence-locators.json).

- The corpus says Maple without a resolved version or pool. These are current official architecture documents, not proof of which pool or revision existed on the corpus historical date.
- The Open Term Loan Manager page explicitly describes loans without collateral. Its funding flow supports allocation only; do not import that loan subtype into the corpus’s collateral/custodian narrative or adjudicate those retained labels.
- Search snippets for PoolManager contained an older configuration list. The captured body instead describes current admin-gated configuration; all conclusions use captured bytes.
- No selected loan address, current Pool Delegate address, underlying legal counterparty, contract source pin or execution was independently verified.

Underwriting or custody alone would not show capital distribution. The documented loan funding destination and authority supply that additional link; this is not inferred from holding an underlying allocation product.

Captured exactly three primary bodies, 2285169 bytes, with actual URLs, timestamps, headers and hashes in [retrievals.json](retrievals.json). The documents belong to one publisher family. No contract compilation/execution or independent deployment verification occurred. No corpus or existing research bytes were changed.

Independent review of the scoped allocation finding. Any historical pool or secured-loan claim needs its own exact pool/version/source and legal-scope packet.

This packet does not adjudicate other facets, recover missing original citations, establish deployed fidelity or provide holdout evidence. Author: GPT-6 stock Codex harness; independent review remains pending.
