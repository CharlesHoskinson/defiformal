# Jupiter Perpetual Exchange / JLP — draft source research

dispute-12/asset_management: proposed **supported**; dispute-13/allocation: proposed **not_evidenced**; dispute-13/redemption: proposed **not_evidenced**. All remain unaccepted.

Unit `unit:lane2:c0:p5`; disputed facets dispute-12, dispute-13. [Exact raw A/B/generated observations](selection-and-observations.json) preserve each facet separately; all actual generated rules remain `INTERSECTION_UNRESOLVED`.

source statement: Official developer documents describe tokens managed by the JLP pool, pool-level AUM accounting and custody balances reserved for trader liabilities. [custody-account](https://developers.jup.ag/docs/perps/custody-account), [pool-account](https://developers.jup.ag/docs/perps/pool-account)

inference under proposed rule: Together with explicit liquidity-provider rebalancing and deposit/withdraw controls, this describes management of the pooled LP capital in the JLP path, beyond incidental treasury holdings. [pool-account](https://developers.jup.ag/docs/perps/pool-account)

source statement: The sources describe target weights, admission limits and fees encouraging liquidity providers to rebalance. [custody-account](https://developers.jup.ag/docs/perps/custody-account), [pool-account](https://developers.jup.ag/docs/perps/pool-account)

bounded evidence gap: An incentive and a permitted-weight constraint are not alone a demonstrated operation distributing capital among destinations. This packet does not establish the particular allocation action or actor-selection path. [custody-account](https://developers.jup.ag/docs/perps/custody-account), [pool-account](https://developers.jup.ag/docs/perps/pool-account)

source statement: Liquidity removal is described as reducing custody assets and carrying a fee. [custody-account](https://developers.jup.ag/docs/perps/custody-account), [pool-account](https://developers.jup.ag/docs/perps/pool-account)

bounded evidence gap: The retained account documentation does not establish holder submission of JLP claims for backing settlement, the token consumption/authorization path and its conditions. A withdrawal accounting field is insufficient alone. [custody-account](https://developers.jup.ag/docs/perps/custody-account), [pool-account](https://developers.jup.ag/docs/perps/pool-account)

Qualifications:

- This is two disputed facets and three separate label claims. A proposed asset_management finding does not resolve the allocation/redemption facet.
- The supported finding concerns management of the JLP liquidity-provider pool already bundled with this corpus unit, not every Jupiter venue or unrelated Lend/managed-vault product.
- The current Custody documentation lists JupUSD along with other assets. No current list, numeric weights, caps or leverage values are asserted to match the historical corpus state.
- Two official JLP user-guide routes returned404. The old route and one explicit fallback attempt are preserved separately; neither was counted as a body or replaced with search text.
- No named live pool configuration, deployed program revision, LP transaction or actual mint/burn/settlement execution was verified. Targets and fee incentives do not prove autonomous rebalancing or an AMM invariant.

Retained 2 primary bodies (597324 bytes) from 4 target URLs. Failed attempts and exact source URLs/times/hashes remain in the retrieval manifests. No more than three bodies were retained for this unit. 8 source locators bind exact original bytes.

The [proposed disposition record](proposed-adjudication.json) binds the current proposed rule, per-label reasoning and full source provenance. No deployment/fidelity or canonical corpus acceptance is claimed.

Independently review the scoped pooled-capital management finding. A later bounded packet should retrieve the actual add/remove-liquidity instruction and JLP claim settlement interface, and the operation distributing exposure; this may settle allocation and redemption separately.

Author: GPT-6 stock Codex harness. Independent review remains pending.
