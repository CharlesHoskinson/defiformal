# Insight Ledger — L6 (Reserve-backed stablecoins, Prediction markets)

## 1. Protocols modelled

| protocol | category | repo path | spec file | typechecks | invariant run | verdict |
|---|---|---|---|---|---|---|
| Tether USDT | fiat | `protocol-repos/fiat/tethercoin_USDT/` | `quint-models/L6/usdt.qnt` | yes | `inv_supply_conserved` ok; `inv_reserve_covers` **fails** (attest under-backing) | modelled — reserve not on-chain |
| Circle USDC | fiat | `protocol-repos/fiat/circlefin_stablecoin-evm/` | `quint-models/L6/usdc.qnt` | yes | `inv_supply_conserved` ok; `inv_reserve_covers` ok under honest mint/burn coupling | modelled |
| USD1 | fiat | **no repo cloned** | — | — | — | profile-only |
| USDG | fiat | `protocol-repos/fiat/paxosglobal_usdg-contract/` + `paxosglobal_paxos-token-contracts/` | `quint-models/L6/usdg.qnt` | yes | `inv_supply_conserved` ok; `inv_rate_limit_bounded` ok | modelled |
| PYUSD | fiat | `protocol-repos/fiat/paxosglobal_pyusd-contract/` + shared PaxosTokenV2 | `quint-models/L6/pyusd.qnt` | yes | `inv_supply_conserved` ok; `inv_rate_limit_bounded` ok | modelled — const-diff of USDG |
| Kalshi | pred | **no repo cloned** (closed CFTC venue) | — | — | — | profile-only |
| Polymarket | pred | `protocol-repos/pred/Polymarket_ctf-exchange-v2/` + `Polymarket_uma-ctf-adapter/` | `quint-models/L6/polymarket.qnt` | yes | `inv_collateral_conserved` ok; `inv_complementary_lock` ok | modelled — CTF+resolve; CLOB abstracted |
| Azuro | pred | `protocol-repos/pred/Azuro-protocol_Azuro-v2-public/` | `quint-models/L6/azuro.qnt` | yes | `inv_global_cash` ok; `inv_claims_covered` ok | modelled |
| Steakhouse Risk Curators | pred | **no repo cloned** | — | — | — | profile-only — likely Morpho curator, not PM |
| Grove | pred (mis-bucketed) | `protocol-repos/pred/grove-labs_grove-alm-controller/` | `quint-models/L6/grove.qnt` | yes | `inv_usds_debt_covers_proxy` ok; `inv_rate_limits_bounded` ok | modelled — ALM, not prediction market |

Shared module: `quint-models/L6/common.qnt` (typechecks).

## 2. State shapes

| shape | fields | protocols instantiating | differs by |
|---|---|---|---|
| `FIAT_TOKEN_LEDGER` | `balances: Addr→Int`, `totalSupply: Int`, `restricted: Addr→Bool`, `paused: Bool` | USDT, USDC, USDG, PYUSD | mint authority wiring; wipe vs freeze-only |
| `OFFCHAIN_RESERVE_SHADOW` | `reserve: Int` (external, not contract storage) | USDT, USDC, USDG, PYUSD (modelled); all five fiat issuers in profiles | update policy: coupled to mint/burn in model; free `attest` only on USDT step |
| `MINTER_ALLOWANCE_TABLE` | `isMinter: Addr→Bool`, `minterAllowed: Addr→Int` | USDC (`FiatTokenV1.sol` L47–48, L121–145, L329–338) | USDT has single owner issue; Paxos uses SupplyControl roles |
| `LINEAR_RATE_LIMIT` | `capacity`, `remaining`, `slope`, `lastTime` | USDG/PYUSD (`RateLimit.sol`), Grove (`RateLimits.sol`) | keying: per-controller mint (Paxos) vs per-action/per-destination (Grove) |
| `CTF_BINARY_MARKET` | `collateral`, `yesBal`, `noBal`, `lockedCollateral`, `phase`, `payout` | Polymarket | Azuro does **not** use complementary tokens |
| `BOOKMAKER_CONDITION` | `freeLiquidity`, `lockedLiquidity`, `fund`, `reinforcement`, `odds*`, `*Stake`, `*PayoutLiability`, `condState` | Azuro (`LP.sol` L36, `CoreBase.sol` condition struct) | Polymarket has no LP book |
| `ALM_PROXY_CREDIT` | `proxyBal: Asset→Int`, `usdsDebt: Int`, rate limits, `relayerFrozen` | Grove (`MainnetController.sol`, `ALMProxy.sol`) | no peer of this shape in fiat or true PMs |

## 3. Actions

| action | signature | protocols | preconditions | element symbol (or NONE) |
|---|---|---|---|---|
| `issue` / owner mint | `(amount)` → balances[owner]↑, supply↑ | USDT (`TetherToken.sol` L406–413) | not paused; onlyOwner | NONE (privileged mint; not `Rd`) |
| `mint` with allowance | `(minter, dst, amount)` | USDC | minter flag; allowance≥amount; not blacklisted | `Au` (delegated quantity, not session) — imperfect fit |
| `mint` rate-limited | `(dst, amount)` | USDG, PYUSD | rate limit remaining; not frozen | NONE (flow limit missing from vocab) |
| `redeem` / `burn` | `(src, amount)` | all fiat | balance; privilege role | `Rd` (only if holder-initiated; code is **issuer/minter** burn) |
| `xfer` | `(src, dst, amount)` | all fiat | not restricted; not paused; balance | NONE (base transfer) |
| `blacklist` / `freeze` | `(addr)` | USDT, USDC / USDG, PYUSD | role | `Fz` |
| `destroyBlackFunds` / `wipeFrozen` | `(addr)` | USDT, USDG, PYUSD | must be restricted; burns supply | `Fz` (wipe sub-action; vocab collapses freeze≠wipe) |
| `pause` / `unpause` | `()` | all fiat; Polymarket exchange; Grove freezer is different | admin/pauser role | `Gp` |
| `attestReserve` | `(newReserve)` | model-only (USDT step) | newReserve≥0 | `At` (off-chain; not a contract call) |
| `split` / `merge` | `(user, amount)` | Polymarket CTF | open market; collateral / equal outcomes | NONE |
| `resolve` (binary payout) | `(yes, no) ∈ {[1,0],[0,1],[1,1]}` | Polymarket UMA adapter | open; valid payout | NONE (oracle settlement) |
| `redeem` outcomes | `(user)` | Polymarket | resolved; holds outcomes | `Rd` (conditional claim) |
| `tradeYes` | `(seller, buyer, amt, price)` | Polymarket (abstracted match) | open; inventories | NONE (CLOB fill) |
| `addLiquidity` | `(user, amount)` | Azuro LP | min deposit | `Sh` (simplified shares) |
| `createCondition` | `(reinforcement)` | Azuro Core | free≥reinf | NONE (bookmaker market open) |
| `betYes` / `betNo` | `(user, amount)` | Azuro | condition running; cash; exposure | NONE (bookmaker take) |
| `resolve` condition | `(yesWins)` | Azuro oracle | open condition; fund covers liability | NONE |
| `claim` payout | `(user)` | Azuro | resolved; unclaimed; free≥pay | `Rd` |
| `mintUSDS` / `burnUSDS` | `(amount)` | Grove | relayer; rate limit | NONE (credit-line draw/wipe) |
| `transferAsset` | `(asset, dest, amount)` | Grove | rate limit; proxy balance | `Xf`-adjacent but same-domain |
| `freezeRelayer` | `()` | Grove Freezer | admin | `Gp` misfit — revokes actor, does not pause machine |

## 4. Invariants

| invariant | formal statement | protocols it holds for | verified how | hidden assumption |
|---|---|---|---|---|
| `inv_supply_conserved` | `sum(balances) = totalSupply` | USDT, USDC, USDG, PYUSD | `quint run --max-steps=20 --max-samples=200` ok | fee stays on-ledger (USDT fee to owner) |
| `inv_nonneg` | balances, supply ≥ 0 | all modelled | run ok | no overflow (Quint unbounded int) |
| `inv_reserve_covers` | `reserve ≥ totalSupply` | USDC/USDG/PYUSD when mint/burn couple reserve | USDC/USDG/PYUSD ok | **issuer updates reserve with every mint/burn**; no free attest in step |
| `inv_reserve_covers` | same | USDT | **violated** (attestReserve sets reserve &lt; supply) | 1:1 backing is **not** an on-chain invariant; `At` is prose |
| wipe residual | wipe shrinks supply, not reserve | USDT `destroyBlackFunds`, USDG/PYUSD `wipeFrozen` | reserve≥supply still holds after wipe (surplus) | seized liability may still be “owed” legally (USDC profile); code just burns |
| `inv_rate_limit_bounded` | `0 ≤ remaining ≤ capacity` | USDG, PYUSD, Grove | run ok | `currentLimit` caps refill; stored remaining may be stale until consume |
| `inv_collateral_conserved` | free collateral + locked = 250 | Polymarket | run ok | no fees; single market; no reward-token OO bonds |
| `inv_complementary_lock` | open ⇒ locked = totalYes = totalNo | Polymarket | run ok | binary partition only; no scalar markets |
| `inv_global_cash` | free+fund+cash=700 (open) / free+cash=700 (resolved) | Azuro | run ok after fix | lockedLiquidity is a **view** of reinforcement inside fund, not extra cash |
| `inv_claims_covered` | resolved ⇒ free ≥ unclaimed payouts | Azuro | run ok | resolve rejects if free+fund &lt; winLiab (model guard; real Azuro uses reinforcement math) |
| `inv_usds_debt_covers_proxy` | `proxyBal[USDS] ≤ usdsDebt` | Grove | run ok | all USDS on proxy came from mintUSDS; external inflows not modelled |

## 5. Recurrences — candidate primitives

| candidate primitive | quint definition | instantiated by (n) | why it is primitive |
|---|---|---|---|
| `BALANCE_LEDGER` | `canTransfer` / `applyTransfer` / `applyMint` / `applyBurn` / `supplyConserved` in `common.qnt` | 4 fiat + Polymarket collateral + Azuro cash (6+) | every protocol is ultimately ERC20-shaped accounting |
| `RESTRICTED_ADDRESS` | `isRestricted` / `setRestricted` / `eitherRestricted` | USDT blacklist, USDC blacklist, USDG/PYUSD freeze (4) | same guard on transfer; wipe is optional extension |
| `MINTER_ALLOWANCE` | `canMintWithAllowance` / `consumeAllowance` | USDC (1); conceptually Circle multi-minter | quantity-delegated mint distinct from role-only mint |
| `LINEAR_REFILL_RATE_LIMIT` | `RateLimit` type + `currentLimit` / `consumeLimit` / `refundLimit` | USDG, PYUSD, Grove (3); same math in two repos | **identical elapsed-time refill**; strongest cross-category recurrence in this lane |
| `COMPLEMENTARY_OUTCOME_SPLIT` | `canSplit` / `canMerge` / `redeemPayout` / `validBinaryPayout` | Polymarket (1 in lane; CTF family) | YES+NO=collateral identity is the PM atomic, not order-book |
| `BOOKMAKER_POOL_BET` | `betPayout` / `canBook` + Azuro condition fields | Azuro (1) | opposite market design to CTF; pool is counterparty |
| `OFFCHAIN_RESERVE_CLAIM` | `reserveCovers` | all fiat (5 profiles; 4 models) | category essence: on-chain liability, off-chain asset; not enforceable in EVM code |

## 6. Distinctions the 58-symbol vocabulary collapses

| element symbol | protocols | how their state machines differ | proposed split |
|---|---|---|---|
| `Fz` | USDT `destroyBlackFunds` vs USDC `blacklist` only vs Paxos `freeze`+`wipeFrozen` | USDC freezes transfer rights but **keeps supply** (liability remains); USDT/Paxos can burn wiped balances | `Fz-block` (transfer deny) vs `Fz-wipe` (supply destroy) |
| `Rd` | USDT owner `redeem` vs holder CTF `redeemPositions` vs Azuro `claim` vs legal off-chain stablecoin redemption | Code “redeem” is often **issuer burn**, not a holder right against reserves; PM redeem is conditional on oracle payout | `Rd-issuer-burn` vs `Rd-holder-claim` vs `Rd-legal-offchain` |
| `Gp` | ERC20 `pause` flag vs Grove `freezeRelayer` | Pause halts all user ops; Grove freezer **revokes the relayer role** while proxy keeps balances — “machine running, nobody may act” | `Gp-global-pause` vs `Gp-actor-revoke` |
| `Au` | USDC minter allowance vs EIP-2612/3009 permits vs Grove relayer role | Allowance is a **quantity budget** on mint, not a session-scoped user delegation | `Au-quantity-budget` vs `Au-session-delegate` |
| `At` | all fiat profiles claim attestation | No protocol stores reserve on-chain; `At` never appears as a state variable or guarded action in code | demote `At` to off-chain obligation, or require an oracle feed shape |
| `Sh` | Azuro LP deposit NFTs (modelled fungible) vs Grove ERC4626 `depositERC4626` | Share math differs; Azuro liquidity tree ≠ ERC4626 exchange rate | keep `Sh` but site the exchange-rate law |

## 7. Mechanisms with no symbol

| mechanism | protocols | what it does | why no existing symbol fits |
|---|---|---|---|
| Linear refill rate limit | USDG/PYUSD `RateLimit.sol`; Grove `RateLimits.sol` | `current = min(cap, remaining + slope·Δt)`; consume on privileged transfer/mint | Not `Ep` (no epoch boundary), not `Gp`, not `Au`. Flow limiter is first-class control plane. |
| Complementary outcome mint (CTF) | Polymarket | Split collateral into YES+NO; merge reverse; redeem by payout vector | Not `Sh` (not pro-rata pool share); not options primitives in vocab |
| Bookmaker reinforcement lock | Azuro | LP locks `reinforcement` into a condition fund; bets change fund and liability | Not AMM `Cp`; not lending collateral |
| Optimistic-oracle resolve + dispute reset | Polymarket UMA adapter | `resolve` pulls OO price; `priceDisputed` resets question; manual resolve admin path | No oracle/dispute symbol; `At` is reserve attestation, not outcome price |
| Credit-line draw against foreign governance | Grove `mintUSDS` via Sky vault `draw` | Capital enters by minting stablecoin debt, not user deposit | Not `Rd`, not deposit `Sh`; mandate/credit facility |
| Stateless custody proxy | Grove `ALMProxy` | Assets sit in a proxy with no logic; controller `doCall`s | Inverse of upgradeable implementation; vocabulary has upgrade/`Tg` not custody shell |
| Novation / clearing house | Kalshi (profile) | Bilateral trade extinguished; CH becomes counterparty | Explicitly noted in supp-12; no symbol |
| Transfer fee skimming | USDT `basisPointsRate`/`maximumFee` | Fee to owner on transfer | Not `Fd` (no surplus distribution schedule) |

## 8. Cross-protocol connections

| from | to | what flows | shared state | composition hazard |
|---|---|---|---|---|
| USDC (or USDT) | Polymarket CTF collateral | stablecoin as `collateral` for split | Polymarket assumes redeemable $1 token | Stablecoin `Fz`/`pause` freezes settlement asset mid-market |
| USDC | Grove proxy / PSM swaps | USDC held and swapped to USDS | Grove `proxyBal` | Rate limit + freezer can strand allocator; USDC blacklist of proxy |
| Sky USDS credit | Grove | `mintUSDS`/`burnUSDS` debt | `usdsDebt` vs Sky vault | Grove authority is Sky-rooted; dual governance |
| UMA OO | Polymarket adapter | resolved price → payout vector | `questions[id].resolved` | Dispute/reset can delay redeem while inventory trades |
| Azuro oracle | Azuro Core | winning outcomes | `condState`, liabilities | Centralized oracle role; cancel path refunds differently |
| Reserve attestation (any fiat) | every DeFi consumer of the token | “is it solvent?” belief | none on-chain | Composition treats ERC20 as final; reserve gap is invisible |

## 9. Code vs prior profile disagreements

| protocol | prior profile claims | code shows | which is right |
|---|---|---|---|
| USDC | element set includes `Rd`, `At`, rich reserve narrative | Contract is mint/burn/blacklist/pause ERC20; **no reserve, no holder redeem** | Code for on-chain machine; profile for legal off-chain — do not encode `Rd`/`At` as contract actions |
| USDT | similar fiat decomposition | `issue`/`redeem` onlyOwner; `destroyBlackFunds`; optional transfer fee | Code: single-key mint and wipe; fee is real and profile-underplayed |
| USDG | `Tg` timelock + `Fd` rewards + freeze | Rate-limited SupplyControl + freeze/wipe; timelock is deployment/governance wrap, not token transfer path | Code: rate limit is the load-bearing on-chain control; timelock does not gate freeze |
| PYUSD | separate construction | `PYUSD.sol` is name/symbol/decimals only over PaxosTokenV2 | Code: **same state machine as USDG** up to constants/roles |
| Polymarket | often framed as exchange | CTF split/merge/redeem + signed order match + UMA resolve | Code: **issuance identity (CTF) is the economic core**; CLOB is inventory reallocation |
| Azuro | prediction market like Polymarket | LP bookmaker with reinforcement and fixed/dynamic odds | Code: **not CTF**; opposite risk design (pool is house) |
| Grove | listed under prediction markets | ALM controller: rate limits, ERC4626/7540, Aave, Curve, CCTP | Code: **not a prediction market**; category error in corpus |
| Kalshi / USD1 / Steakhouse | full element measurements | no source in `protocol-repos` | profile-only; cannot validate state machines from code |

## 10. Open questions for the mathematicians

1. **Is off-chain reserve (`At` + 1:1 claim) a primitive of the carrier, or an external assumption outside composition?** Code never enforces it; `inv_reserve_covers` fails as soon as attest is free. How should the positive model treat obligations with no state variable?

2. **Should `Fz-block` and `Fz-wipe` be distinct generators?** USDC blacklist leaves totalSupply unchanged; USDT/Paxos wipe burns supply. Composition with lending/collateral cares which one you have.

3. **Is linear refill rate limit a stratum-0 or stratum-2 control primitive?** It recurs in Paxos stablecoins and Grove ALM with the same formula; the prior vocabulary has no flow limiter, yet it is the main on-chain throttle for privileged value movement.

4. **How do complementary-outcome tokens (CTF) and bookmaker-pool conditions (Azuro) sit in one prediction-market sort?** Their state shapes share almost nothing; only “event → payout” is common. Is “prediction market” a category of purpose rather than a construction?

5. **What is the primitive for credit-line mint against foreign governance (Grove `mintUSDS`)?** Not deposit, not borrow against local collateral, not `Rd`. Capital appears by authorised debt.

6. **Where does novation/clearing (Kalshi) live if the vocabulary has rights without obligors?** Supp-12 residual says `Rd` names a right to be paid and carries no obligor — is the carrier missing a counterparty-sort?

7. **Does composition require an explicit “settlement asset” wire** from fiat tokens into PM collateral and ALM inventories, with freeze/pause propagating as a hazard type?

8. **PYUSD vs USDG: if two protocols share one state machine up to constants, is that one construction with parameters, or two elements?** Empirical answer here: one machine, const instantiation — the vocabulary’s separate measurements overstate distinction.

9. **Holder redeem vs issuer burn:** both called redeem in prose/code. Construction synthesis must not treat them as the same morphism.

10. **Grove freezer vs global pause:** if admissibility treats `Gp` as “system can halt,” Grove’s actor-revoke is a different modal operator (liveness of roles vs liveness of functions). Does the constraint table need role-liveness?
)
