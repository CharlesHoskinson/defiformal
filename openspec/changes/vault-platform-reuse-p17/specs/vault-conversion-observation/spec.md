## Purpose

Freeze ordinary sUSDS share/asset conversion, directed rounding, ordered `_mint`/`_burn`/`drip` effects, overflow premises, and source-selected transfer/authorization refusal.

## ADDED Requirements

### Requirement: Public converters use drip then floor or ceil then mint or burn

`deposit` SHALL compute `shares = assets * RAY / drip()` (floor) then `_mint`. `mint` SHALL compute `assets = _divup(shares * drip(), RAY)` (ceil) then `_mint`. `withdraw` SHALL compute `shares = _divup(assets * RAY, drip())` then `_burn`. `redeem` SHALL compute `assets = shares * drip() / RAY` (floor) then `_burn`. Referral overloads are out of scope.

#### Scenario: D0 deposit is exact
- **WHEN** initialized `chi = RAY`, `timestamp = rho`, finite `USDS.allowance[S][vault] = 10^18`, and `deposit(10^18, R)` succeeds with observed USDS credit
- **THEN** shares minted equal `10^18`, finite USDS allowance is consumed to 0, full logs are `vault.Drip`, `usds.Transfer(S,vault,10^18)`, `vault.Deposit`, `vault.Transfer(0,R,shares)`, and the vault projection is the same list without the USDS Transfer

#### Scenario: D1 deposit floors
- **WHEN** stored `chi = RAY+1`, `timestamp = rho`, and `deposit(10^18, R)` is applied
- **THEN** shares equal `10^18 - 1` and MUST NOT be reported as the ceiling `10^18`

### Requirement: Mint and withdraw use _divup, including the zero-numerator clause

`_divup(x,y)` SHALL be `x != 0 ? ((x-1)/y)+1 : 0`. Campaign domain SHALL keep `chi > 0` so `drip()` is not zero. `_divup(0,0)` returning 0 SHALL remain a named source peculiarity, not a claimed campaign success.

#### Scenario: D1 mint ceils
- **WHEN** stored `chi = RAY+1` by harness storage seed, `timestamp = rho`, sender USDS and finite allowance are `10^18+1`, and `mint(10^18, R)` is applied
- **THEN** assets equal `10^18 + 1` and the fixture MUST NOT reuse a `10^18` USDS balance

### Requirement: Scored source fixtures are complete deterministic witnesses

Every scored stateful source fixture and protected control SHALL bind identities/aliases, balances, totalSupply, finite or infinite allowances, timestamps, initialized state, and either expected post-state or a complete common transition. D1 `chi = RAY+1` SHALL be an explicit harness storage seed, not a protocol-reachability result. Protected redeem/withdraw controls SHALL be independently funded and MUST NOT be initialized through a mutated deposit. `max_or_assets` SHALL NOT appear.

#### Scenario: D1 chi is a storage seed
- **WHEN** a D1 fixture is constructed
- **THEN** `chi_setup` is `storage_seed_chi_after_initialize`, `chi_setup_protocol_reachable` is false, and initialize-only `chi = RAY` is not treated as D1

#### Scenario: Redeem controls are independently funded
- **WHEN** mutant V-TF-SKIP or V-DEP-CEIL is planned
- **THEN** P17-RED-D0, P17-RED-D1 and P17-RED-ALLOW already contain shares, totalSupply and vault USDS in prestate, not produced by the mutated deposit

### Requirement: _mint refuses invalid receiver before transferFrom

`_mint` SHALL require `receiver != 0 && receiver != address(this)` before `usds.transferFrom`. Zero-asset `deposit(0)` SHALL be success with zero shares, not a refusal.

#### Scenario: Zero receiver reverts without transfer
- **WHEN** `deposit(10^18, address(0))` is applied
- **THEN** the revert is `SUsds/invalid-address` and `transferFrom` is not required to have been called

#### Scenario: Zero deposit is success
- **WHEN** `deposit(0, R)` is applied with a valid receiver
- **THEN** shares equal 0 and the case is not classified as a refusal

### Requirement: Transfer and authorization guards are taken from source

The actual transfer refusal SHALL be `_mint`'s `usds.transferFrom` revert. The actual authorization refusal SHALL be `_burn`'s `SUsds/insufficient-allowance` when `owner != msg.sender` and finite allowance is too small, and `SUsds/insufficient-balance` when owner shares are insufficient. A successful external call SHALL NOT prove assets moved; USDS balances SHALL be observed.

#### Scenario: Empty USDS balance is transfer refusal
- **WHEN** a valid receiver is used and the sender has 0 USDS
- **THEN** deposit refuses via the USDS token (`Usds/insufficient-balance` under the captured mock assumption) and sUSDS supply is unchanged

#### Scenario: Spender without allowance cannot redeem
- **WHEN** `redeem` is called by `P ≠ owner` with `allowance[owner][P] = 0`
- **THEN** the revert is `SUsds/insufficient-allowance` and owner shares and vault USDS are unchanged

### Requirement: Overflow protection uses premises, not desired accounting

Successful `_mint` theorems SHALL take `totalSupply + shares < 2^256` and `balanceOf[receiver] + shares < 2^256` as premises. The source comments that overflow checks are unnecessary because balances sum to supply or shares stay below USDS supply SHALL NOT be used as a proved conclusion. Public `assets * RAY` overflow SHALL be 0.8.21 Panic `0x11`, not wrap and not unbounded `mulDiv`.

#### Scenario: Huge deposit product overflows checked mul
- **WHEN** `assets = 2^256/RAY + 1` and `chi = RAY`
- **THEN** deposit refuses before `_mint` and Lean MUST NOT treat `Rounding.mulDiv` unbounded product as that source observation

### Requirement: No-credit negative is execute_ok_iff observation correspondence

The source-independent mint-without-asset-credit negative SHALL use the honest deposit template with `assets > 0`. `Evaluated.Valid` SHALL remain a pre-state precondition and MUST NOT be treated as a post-state predicate. The derived post `post.USDS.vault = pre.USDS.vault + assets` SHALL come from `execute_ok_iff`. A candidate with unchanged vault USDS SHALL be an incorrect proposed observation, not an executor refusal. The matching positive SHALL use the same premises.

#### Scenario: No-credit candidate is not Valid failure
- **WHEN** the honest deposit template with `assets = 10^18` is instantiated
- **THEN** `P17-NEG-MINT-NO-CREDIT` rejects `candidate.USDS.vault = pre.USDS.vault` against `execute_ok_iff` post equality, `not_predicate` is `Evaluated.Valid`, and `P17-POS-DEPOSIT-CREDIT` is the matching positive

### Requirement: Full logs and vault projection are both bound

Scored success observations SHALL record complete relevant EVM logs, including the underlying USDS `Transfer`, and MAY also record an emitter-filtered vault projection. Unrelated logs SHALL be retained and MUST NOT be equated to vault events. Refusal SHALL retain the supplied pre-state beside the revert and MUST NOT claim experimental rollback verification.

#### Scenario: Deposit full log includes USDS Transfer
- **WHEN** P17-DEP-D0 succeeds
- **THEN** the second full-log entry is `usds.Transfer(S, vault, 10^18)` and the vault projection omits that entry because its emitter is not the vault
