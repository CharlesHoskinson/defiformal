# Lista CDP — trust source research

`issuer`: proposed **not_evidenced**; `keeper`: proposed **supported**. All dispositions remain draft and unaccepted.

Selected `dispute-03`, `unit:lane1:c2:p3` in deterministic order. Raw A-only labels: []; B-only labels: ['issuer', 'keeper']. Exact records and original pointers are preserved in [selection-and-observations.json](selection-and-observations.json). The actual generated facet rule is `INTERSECTION_UNRESOLVED`.

source statement: The pinned documentation explicitly describes liquidators starting liquidation and actors restarting Dutch auctions, with gas compensation; any user including the borrower may perform those roles. [liquidation](https://raw.githubusercontent.com/lista-dao/gitbook/5c8ba79b51f08af745dd00966f806ecd47f3ad2a/protocol/loan-liquidation.md)
inference under proposed rule: Starting or restarting the protocol’s liquidation auction is a stated external transition-maintenance role, which supports the proposed keeper label at documentation scope. [liquidation](https://raw.githubusercontent.com/lista-dao/gitbook/5c8ba79b51f08af745dd00966f806ecd47f3ad2a/protocol/loan-liquidation.md)
source statement: The sources identify lisUSD as the CDP borrowing product and describe custody through contracts, but this packet does not establish the authority controlling issuance. [cdp-scope](https://docs.bsc.lista.org/introduction/collateral-debt-position-lisusd), [faq](https://raw.githubusercontent.com/lista-dao/gitbook/5c8ba79b51f08af745dd00966f806ecd47f3ad2a/faq.md)
bounded evidence gap: Protocol branding, borrower access and MakerDAO lineage do not identify a named issuance authority; propose not_evidenced, not refuted or not_applicable. [cdp-scope](https://docs.bsc.lista.org/introduction/collateral-debt-position-lisusd), [faq](https://raw.githubusercontent.com/lista-dao/gitbook/5c8ba79b51f08af745dd00966f806ecd47f3ad2a/faq.md)

These findings apply the proposed reusable rule predicates, with exact source lines in [proposed-adjudication.json](proposed-adjudication.json). Evidence spans and their hashes are in [evidence-locators.json](evidence-locators.json).

- The keeper finding is a documentation-level role claim, not proof of an implemented automation service, required keeper quorum, availability or liveness.
- The pinned liquidation page contains malformed rename text and says borrowed lisUSD is auctioned, then describes sold collateral. Preserve that wording ambiguity; this packet does not resolve the auction’s asset-flow semantics. The explicit actor/restart description is narrower.
- The FAQ mixes CDP, staking and governance-token material. Only CDP/lisUSD paragraphs are used; no trust role is inherited from LISTA distribution, slisBNB staking or MakerDAO code.
- The issuer predicate remains missing evidence within the three-body budget. Contract mint authorization, ward/admin roles, and exact authorization bindings were not acquired.
- The pinned Gitbook revision binds document bytes, not contract code or deployed configuration. Its relationship to historical published documentation has not been established.

Any callable function alone would not establish a keeper. The liquidation source additionally states the actor’s initiation/restart role and reward. Conversely, describing a decentralized token does not prove or disprove a named issuer authority.

Captured exactly three primary bodies, 502700 bytes, with actual URLs, timestamps, headers and hashes in [retrievals.json](retrievals.json). The documents belong to one publisher family. No contract compilation/execution or independent deployment verification occurred. No corpus or existing research bytes were changed.

Independent keeper review may still leave the facet unresolved. A separate authorized packet should retrieve the official mint/adapter authorization path and identify which named role or contract controls lisUSD issuance; do not accept issuer by product naming.

This packet does not adjudicate other facets, recover missing original citations, establish deployed fidelity or provide holdout evidence. Author: GPT-6 stock Codex harness; independent review remains pending.
