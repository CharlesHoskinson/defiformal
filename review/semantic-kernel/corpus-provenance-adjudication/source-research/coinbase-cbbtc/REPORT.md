# coinbase-cbbtc — draft source assessment

**Independent review pending. No corpus labels changed.**

Scope: cbBTC on Base/Ethereum only; documentary minting in September2024 and current Coinbase account transfer terms for eligible US customers; no other bundled wrapped product inference.

- `dispute-21` / `mint_burn`: proposed **supported**. Coinbase describes customer-directed cbBTC minting to Base/Ethereum; the proposed rule is disjunctive (creates OR destroys supply). This supports documentary issuance, with Coinbase executing customer-directed outbound wrapping. Burn implementation and deployed role authorization remain unverified.
- `dispute-22` / `async_cross_domain`: proposed **supported**. The cbBTC workflow causally connects the Coinbase account ledger with an external Base/Ethereum wallet: sending wraps and delivers; receiving unwraps and credits BTC. The agreement states network-pending transfers are incomplete until confirmation and wrapping requests need not be immediate. This is a custodial ledger/on-chain boundary, not a verified atomic Bitcoin-to-Base bridge.
- `dispute-22` / `offchain_legal_settlement`: proposed **supported**. For customers subject to the US agreement, wrapped-token redemption/shortfall obligations are stated alongside formal complaints and arbitration/court routes for agreement disputes. The proposed classification concerns contractual enforcement of those scoped obligations, not a claim that routine redemptions require litigation or that every holder in every jurisdiction has the same remedy.

The following limits govern these proposals:

- The September25 2024 newsletter is historical. Its then-current supported chains, proof-of-reserves plans and promotional claims are not current operational facts. Its /en-ca URL is not evidence of present Canadian eligibility; current Help lists Canada among excluded cbBTC regions.
- The US terms body is dated July22 2026. Apply its wrapped-token Appendix4 section8, not cbETH staking terms or section13 custom stablecoin terms. General transfer and dispute clauses are connected through this agreement and the cbBTC identity link; this is a proposed source interpretation, not a legal enforceability opinion.
- Appchain consensus, trustless bridging, guaranteed finality, fixed confirmation count, universal redemption access and absence of pauses are not established. A successful outbound request is not yet a completed network transfer.
- Coinbase controls the described account service; no mint/burn role address or bytecode was pinned. The failed whitepaper host supplies no support. No documentary issuance claim implies an audited total-supply invariant.
- Only cbBTC is assessed. The parent bundle remains bundled; no result is inherited by cbETH or other Coinbase wrapped assets.
- Unaccepted source-research draft; no canonical corpus overlay, no semantic-closure declaration and no untouched evaluation.
- Original A/B records, generated intersections, citations and missing original references remain unchanged. New captures do not recover missing original artifacts.
- Each unit uses one publisher family. Multiple pages are not independent-provider corroboration. No formal proof, runtime test or deployed fidelity is claimed.

Retained substantive sources (3, 2104081 bytes), retrieved 2026-09-07:

- [help](https://help.coinbase.com/en/coinbase/trading-and-funding/sending-or-receiving-cryptocurrency/coinbase-wrapped-btc): 376b88f2e0af3ef899061dd597303d7bca0a7de3d7a7710c45353095f9c60562; 2026-09-07T20:13:53.374876+00:00.
- [terms](https://www.coinbase.com/legal/user_agreement/united_states): bf8d99c20a22c0952401243f5209a444f396e6a88b1574d1053ddff7370ddae6; 2026-09-07T20:13:54.227743+00:00.
- [issuance](https://www.coinbase.com/en-ca/bytes/archive/is-btc-poised-for-a-bigger-rally): a84166294dd553d52b9b3cbd9fb5a3974ebb01f967f6782cf32e332e2559fadb; 2026-09-07T20:16:55.678170+00:00.

[Exact observations](selection-and-observations.json), [locators](evidence-locators.json) and [proposals with transport assessment](proposed-adjudication.json) preserve the evidence/inference boundary. Failed routes and empty transport captures receive no support. All sources for this unit belong to one publisher family. Search results only located sources; their snippets were not evidence. The bounded stop is source sufficiency for the stated proposal or a remaining retrieval gap, not proof of source absence.

Offline checks use `python3 review/semantic-kernel/corpus-provenance-adjudication/source-research/batch06/build-records.py --verify-only`. [Verification](verification.json) and [manifest](artifact-manifest.json) bind this packet and the shared batch helpers. No protocol or contract execution occurred.
