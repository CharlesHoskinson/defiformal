## Purpose

Keep Vat/UsdsJoin/Usds/IERC1271 as external boundaries, keep captured mocks as test-harness assumptions, and freeze the initialized stable-time domain without claiming the whole source.

## ADDED Requirements

### Requirement: Import closure does not implement token movement

`VatLike`, `UsdsJoinLike`, `UsdsLike`, and `IERC1271` SHALL remain external. Captured `test/mocks` MAY be used only as explicit test-harness assumptions. Mocks and the `susds` branch URL SHALL NOT be presented as mainnet fidelity. No deployed address, block, codehash, or runtime identity SHALL be claimed.

#### Scenario: Mock transfer still needs balance observation
- **WHEN** a deposit fixture uses `UsdsMock.transferFrom`
- **THEN** the observation records pre/post USDS balances and MUST NOT treat a non-reverting call as asset credit by itself

### Requirement: Stable-time domain is explicit and bounded

Campaign D0/D1 SHALL require `initialize()` via proxy, `chi > 0`, and `block.timestamp == rho` so `drip` does not call `vat.suck` or `usdsJoin.exit`. D1 stored `chi = RAY+1` SHALL be an explicit harness storage seed after initialize and SHALL NOT be claimed as protocol-reachable. Accrual, upgrade, and permit SHALL remain named remainders. The whole source domain SHALL NOT be claimed.

#### Scenario: D0 drip does not suck
- **WHEN** a D0 deposit is specified
- **THEN** the package records `timestamp == rho`, `diff = 0`, and no Vat yield realization as an observation of that fixture

### Requirement: Proxy initialize is harness, not deployment identity

SUsds constructor SHALL be recorded as disabling initializers and setting `usdsJoin`/`vat`/`usds`/`vow` immutables. Campaign calls SHALL go through `initialize()` on an ERC1967 proxy built from the captured proxy source. That proxy SHALL NOT be a mainnet identity.

#### Scenario: Implementation-only deposit is excluded
- **WHEN** the uninitialized implementation has `chi = 0`
- **THEN** that path is a named remainder, not a D0/D1 success fixture
