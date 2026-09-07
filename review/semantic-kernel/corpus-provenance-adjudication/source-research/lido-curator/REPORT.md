# Lido — trust source research

`curator`: proposed **supported**. All dispositions remain draft and unaccepted.

Selected `dispute-05`, `unit:lane1:c3:p0` in deterministic order. Raw A-only labels: []; B-only labels: ['curator']. Exact records and original pointers are preserved in [selection-and-observations.json](selection-and-observations.json). The actual generated facet rule is `INTERSECTION_UNRESOLVED`.

source statement: The documented DAO votes on staking module registration and sets growth targets used for stake allocation. [staking-router](https://docs.lido.fi/contracts/staking-router/)
source statement: The documented Curated NodeOperatorsRegistry contains DAO-selected operators; the governance-levers page names the module-management role and its holder. [node-operators](https://docs.lido.fi/contracts/node-operators-registry/), [protocol-levers](https://docs.lido.fi/guides/protocol-levers/)
inference under proposed rule: DAO selection of eligible operators/modules and allocation targets is a named choice over staking destinations relied on by users, satisfying the proposed curator predicate for this scoped governance/module path. [node-operators](https://docs.lido.fi/contracts/node-operators-registry/), [staking-router](https://docs.lido.fi/contracts/staking-router/)

These findings apply the proposed reusable rule predicates, with exact source lines in [proposed-adjudication.json](proposed-adjudication.json). Evidence spans and their hashes are in [evidence-locators.json](evidence-locators.json).

- The captured governance-levers page explicitly describes Lido V3 and contains address assertions. Those statements are not verified chain state or proof of the corpus’s historical configuration.
- NodeOperatorsRegistry documentation describes the Curated module since the V2 upgrade; the router documentation also contains newer mechanisms. No claim is made that all three pages form one deployed version.
- The finding is scoped to DAO selection/module allocation and the documented Curated module. Community Staking, Simple DVT, stVaults and other product paths do not automatically inherit identical curator roles.
- Programmatic allocation is not itself proof of discretionary curation. The documented DAO choice of eligible modules/operators and growth targets is the additional premise used.
- No claim that every node operator is a curator, that governance cannot change, or that listed role-holder addresses were independently verified.

Validator participation or a passive operator label would not establish curator. The DAO’s documented selection and allocation-setting powers do; permissionless modules elsewhere do not negate that narrower path or acquire its permissions.

Captured exactly three primary bodies, 425476 bytes, with actual URLs, timestamps, headers and hashes in [retrievals.json](retrievals.json). The documents belong to one publisher family. No contract compilation/execution or independent deployment verification occurred. No corpus or existing research bytes were changed.

Independent review of the governance/module-scoped curator finding. To make a historical or module-wide statement, separately bind exact versions, roles and active module configuration.

This packet does not adjudicate other facets, recover missing original citations, establish deployed fidelity or provide holdout evidence. Author: GPT-6 stock Codex harness; independent review remains pending.
