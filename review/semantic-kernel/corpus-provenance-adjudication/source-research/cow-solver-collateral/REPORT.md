# cow-solver-collateral — draft source assessment

**Independent review pending. No corpus labels changed.**

Scope: CoW Protocol standard/reduced solver bonding and EBBO reimbursement as described in current official docs; not all authenticated contracts or all historical solvers.

- `dispute-24` / `collateralization`: proposed **supported**. Documented stablecoin/COW (and reduced-pool ETH) assets are placed in DAO-controlled Safes to back solver behavior. EBBO loss creates a reimbursement obligation; failed reimbursement can escalate to a vote that slashes the bond to repay the user. Bond dissolution requires unvouching and a governance process. This meets encumbered assets securing a scoped performance obligation without requiring a credit loan.

The following limits govern these proposals:

- Slashing is governance-conditioned and discretionary, not an automatic smart-contract consequence of every bad settlement. The documentation distinguishes contract, off-chain and social enforcement.
- Funding thresholds are stated in the captured docs only; no claim all governance revisions have been reconciled or that these values are current deployed parameters. A discovered newer draft proposing threshold changes is not adopted as current state.
- The claim concerns standard/reduced bonded solver arrangements. Do not generalize to every address carrying a solver role, including governance-approved wrapper exceptions, or infer a direct retail lending/insurance/staking service.
- No Safe ownership at a block, balance, vote execution, deployed contract revision, actual slashing transaction or release transaction was verified. Documentation supports the proposed rule application; it is not contract execution evidence.
- The official llms index had stale underscore routes; both those404s and a failed ebbo-specifics guess are retained. The final ebbo-rules URL came from the bonding page link.
- Unaccepted source-research draft; no canonical corpus overlay, no semantic-closure declaration and no untouched evaluation.
- Original A/B records, generated intersections, citations and missing original references remain unchanged. New captures do not recover missing original artifacts.
- Each unit uses one publisher family. Multiple pages are not independent-provider corroboration. No formal proof, runtime test or deployed fidelity is claimed.

Retained substantive sources (3, 114040 bytes), retrieved 2026-09-07:

- [bonding](https://docs.cow.fi/cow-protocol/reference/core/auctions/bonding-pools): 8e06ee93e3c244896466a199ad17614f4523cd4b45a8a2d002a961e6bcc43cf0; 2026-09-07T20:14:55.270361+00:00.
- [rules](https://docs.cow.fi/cow-protocol/reference/core/auctions/competition-rules): d2755035266c7e782580a222293191d7ae8668bfc61092be95a4b49b6e5fc881; 2026-09-07T20:14:55.777218+00:00.
- [enforcement](https://docs.cow.fi/cow-protocol/reference/core/auctions/ebbo-rules): 08d140df14aee3d7c0442fae1dbbfedb28e02890135806d4435d8056e65c73ca; 2026-09-07T20:15:47.459467+00:00.

[Exact observations](selection-and-observations.json), [locators](evidence-locators.json) and [proposals with transport assessment](proposed-adjudication.json) preserve the evidence/inference boundary. Failed routes and empty transport captures receive no support. All sources for this unit belong to one publisher family. Search results only located sources; their snippets were not evidence. The bounded stop is source sufficiency for the stated proposal or a remaining retrieval gap, not proof of source absence.

Offline checks use `python3 review/semantic-kernel/corpus-provenance-adjudication/source-research/batch06/build-records.py --verify-only`. [Verification](verification.json) and [manifest](artifact-manifest.json) bind this packet and the shared batch helpers. No protocol or contract execution occurred.
