# Insight Ledger — L4 (Bridges, Intents and aggregation)

## 1. Protocols modelled

| protocol | category | repo path | spec file | typechecks | invariant run | verdict |
|---|---|---|---|---|---|---|
| WBTC | bridge | `protocol-repos/bridge/WrappedBTC_bitcoin-token-smart-contracts/` | `quint-models/L4/wbtc.qnt` | yes | `supplyNonNegative`, `mintBurnBook` — ok | modelled |
| Coinbase Bridge (cb-class wrap) | bridge | `protocol-repos/bridge/coinbase_wrapped-tokens-os/` | `quint-models/L4/coinbase.qnt` | yes | `supplyEqualsBalances`, `allowanceBounded` — ok | modelled |
| Circle CCTP | bridge | `protocol-repos/bridge/circlefin_evm-cctp-contracts/` | `quint-models/L4/cctp.qnt` | yes | `globalSupplyConserved`, `usedImpliesAttested` — ok | modelled |
| LayerZero v2 (+ OFT burn-mint) | bridge | `protocol-repos/bridge/LayerZero-Labs_LayerZero-v2/` | `quint-models/L4/layerzero.qnt` | yes | `oftSupplyConserved`, `noDoubleDelivery` — ok | modelled |
| Across | bridge | `protocol-repos/bridge/across-protocol_contracts/` | `quint-models/L4/across.qnt` | yes | `poolBalanced`, `noDoubleFill` — ok | modelled |
| CoW Swap | intent | `protocol-repos/intent/cowprotocol_contracts/` | `quint-models/L4/cow.qnt` | yes | `remainingOk`, `token0Conserved`, `token1Conserved` — ok | modelled |
| 1inch Limit Order Protocol | intent | `protocol-repos/intent/1inch_limit-order-protocol/` | `quint-models/L4/oneinch.qnt` | yes | `remainingOk`, `tokenAConserved` — ok | modelled |
| KyberSwap Smart Intent | intent | `protocol-repos/intent/KyberNetwork_smart-intent-sc/` | `quint-models/L4/kyber.qnt` | yes | `routerMatchesDelegated`, `tokenAConserved` — ok | modelled |
| Hyperliquid Bridge | bridge | *(not cloned)* | — | — | — | profile-only |
| Binance BTCB | bridge | *(not cloned)* | — | — | — | profile-only |
| LiquidMesh | intent | *(not cloned)* | — | — | — | profile-only |
| Binance Wallet | intent | *(not cloned)* | — | — | — | profile-only |
| OKX DEX | intent | *(not cloned)* | — | — | — | profile-only |
| Jupiter | intent | *(not cloned)* | — | — | — | profile-only |
| DFlow | intent | *(not cloned)* | — | — | — | profile-only |

Shared module: `quint-models/L4/common.qnt` (typechecks).

## 2. State shapes

One row per distinct state shape found. A "shape" is a named tuple of state variables that recurs.

| shape | fields | protocols instantiating | differs by |
|---|---|---|---|
| `CustodialWrapSupply` | `totalSupply`, `paused`, optional `blacklisted`, optional `rateLimit.allowance` | WBTC, Coinbase, BTCB (profile) | WBTC has no blacklist/rate-limit; Coinbase has both; BTCB has unbounded `onlyOwner` mint and no pause |
| `TwoPhaseCustodianRequest` | `requester`, `amount`, `status ∈ {Pending,Approved,Rejected,Canceled}` | WBTC | Merchants gate entry; custodian is the sole on-chain truth for mint |
| `BurnMintDomainPair` | `supply[domain]`, `usedNonces`, in-flight `messages/packets` | CCTP, LayerZero OFT | CCTP attests then receives; LZ has three steps send→verify→lzReceive; both conserve Σ supply + in-flight |
| `MessagingChannel` | `outboundNonce`, `inboundPayload`, packet status | LayerZero EndpointV2 | Application-configured verifier set (not in Endpoint state); OFT vs OFTAdapter are orthogonal token topologies on the same channel |
| `OptimisticFillEscrow` | `originPool`, `deposits[id].{input,output,status,relayer}`, `relayerInv`, `relayerRefundOwed` | Across | Relayer fronts dest liquidity; origin escrow reimburses later via root bundle — no mint |
| `NativeEscrowLedger` | `escrowBalance`, validator-signed withdraw, dispute window | Hyperliquid (profile) | Destination credit is a chain-native ledger balance, not a minted ERC-20 |
| `SignedOrderRemaining` | `maker`, `makingAmount`, `takingAmount`, `remaining`, `cancelled` | 1inch, CoW | CoW accumulates `filledAmount` under batch clearing prices; 1inch is permissionless taker fill with remaining/bit invalidators |
| `DelegatedIntent` | `owner`, `amountIn`, `minOut`, `status ∈ {NotDelegated,Delegated,Executed,Revoked}`, router custody | Kyber Smart Intent | Explicit on-chain status machine + guardian role; not a free-form signed order fill |
| `BatchClearingPrices` | per-settlement `tokens[]`, `clearingPrices[]`, trade list | CoW | Uniform price across the batch; limit check `sell*buyPrice ≥ buy*sellPrice` |

## 3. Actions

| action | signature | protocols | preconditions | element symbol (or NONE) |
|---|---|---|---|---|
| `addMintRequest` | `(amt)` | WBTC | merchant role; valid deposit address | `Aw` (merchant gate) |
| `confirmMint` | `(id)` | WBTC | custodian; request Pending | `Xf` (issuance), not `Xm` (no on-chain source proof) |
| `merchantBurn` / `confirmBurn` | `(amt)` / `(id)` | WBTC | merchant / custodian | `Rd` (redemption path is merchant-only) |
| `mint` (rate-limited) | `(dst, amt)` | Coinbase | caller allowlisted; `amt ≤ allowance`; not paused/blacklisted | `Aw`, `Gp`, `Fz`; rate limit is **NONE** |
| `burn` (unwrap) | `(from, amt)` | Coinbase | balance; not blacklisted | `Rd` |
| `depositForBurn` | `(user, amt, dst, recipient)` | CCTP | balance; burn limit; token mapped | `Xf` |
| `attest` | `(nonce)` | CCTP | message exists, not yet attested | `Xm` (attester threshold) |
| `receiveMessage` | `(nonce)` | CCTP | attested; nonce unused | `Xm` + once-only |
| `oftSend` | `(user, amt, recipient)` | LayerZero OFT | balance; burn | `Xf` (token half is app-owned) |
| `verify` | `(nonce)` | LayerZero | packet Sent; receive-lib authorized | `Xm` (DVN config is app param) |
| `lzReceive` | `(nonce)` | LayerZero | payload present; Verified | `Xm`; executor role is liveness not safety |
| `deposit` / `depositV3` | `(depositor, recipient, in, out)` | Across | lock input on origin | `Of`, `Rl` (resource lock of input) |
| `fill` / `fillRelay` | `(id, relayer)` | Across | Unfilled; relayer inventory ≥ out | `Of` |
| `refundRelayer` | `(relayer, amt)` | Across | owed ≥ amt; pool ≥ amt | `Of` (reimbursement) |
| `placeSellOrder` / `createOrder` | `(maker, making, taking)` | CoW, 1inch | off-chain signature (modelled as create) | `In` / partial `Ob` |
| `settleTrade` / `settle` | `(id, fill, prices…)` | CoW | solver-authorized; limit at clearing | `Ba`, `In` |
| `fillOrder` | `(id, taker, fillMaking)` | 1inch | remaining ≥ fill; signature valid | `In` (taker-driven, not solver auction) |
| `cancelOrder` / `invalidate` | `(id)` | 1inch, CoW | maker/owner | NONE (cancellation primitive) |
| `delegate` | `(owner, amountIn, minOut)` | Kyber | not paused; pull tokens to router | `Au`, `In` |
| `execute` | `(id, amountOut)` | Kyber | Delegated; `amountOut ≥ minOut`; guardian | `In`, `Au` |
| `revoke` | `(id)` | Kyber | NotDelegated or Delegated | NONE |

## 4. Invariants

| invariant | formal statement | protocols it holds for | verified how | hidden assumption |
|---|---|---|---|---|
| `supplyNonNegative` | `wrap.totalSupply ≥ 0 ∧ pendingBtcPayout ≥ 0` | WBTC | `quint run --invariant=supplyNonNegative` | Off-chain BTC reserve is **not** constrained; only on-chain bookkeeping |
| `mintBurnBook` | `totalSupply = Σ approved mints − Σ burns` | WBTC | `quint run --invariant=mintBurnBook` | Only factory-mediated mint/burn; no direct Controller mint outside Factory |
| `supplyEqualsBalances` | `Σ balances = totalSupply` | Coinbase | `quint run` | Standard ERC-20 accounting; blacklist does not seize balance in model |
| `allowanceBounded` | `0 ≤ allowance ≤ maxAllowance` | Coinbase | `quint run` | Replenish is discrete full top-up (code is time-proportional) |
| `globalSupplyConserved` | `supply[0]+supply[1]+inFlight = 40` | CCTP | `quint run` | No external mint outside bridge; 1:1 burn-mint; attestation honest for conservation (safety is attester threshold, not conservation) |
| `usedImpliesAttested` | `∀ n ∈ usedNonces. messages[n].attested` | CCTP | `quint run` | Attestation precedes receive in model (code verifies sigs inside receive) |
| `oftSupplyConserved` | `supplySrc+supplyDst+inFlight = 30` | LayerZero OFT | `quint run` | Default OFT burn/mint path only — **fails for OFTAdapter lockbox** without counting escrow |
| `noDoubleDelivery` | delivered ⇒ payload cleared | LayerZero | `quint run` | Payload clear-before-execute (EndpointV2.sol:179-180) |
| `poolBalanced` | `originPool = unfilled.inputs + Σ refundOwed` | Across | `quint run` | Single-token pool; no LP fee haircut; refund equals inputAmount |
| `noDoubleFill` | filled ⇒ relayer ≠ 0 | Across | `quint run` | `fillStatuses` maps hash → status once (SpokePool.sol:115) |
| `remainingOk` | `0 ≤ remaining ≤ makingAmount` | CoW, 1inch | `quint run` | No bit-invalidator path in model |
| `token0Conserved` / `tokenAConserved` | `Σ bal + fees = initial` | CoW, 1inch, Kyber | `quint run` | No external mint of trade tokens; CoW fee skim counted in surplus |
| `routerMatchesDelegated` | `routerA = Σ amountIn of Delegated intents` | Kyber | `quint run` | Single token custody; revoke refunds full amountIn |

**Invariant that was wrong then fixed (first-class finding):** CoW `token0Conserved` initially failed because the model burned maker's sell tokens without crediting the counterparty — settlement is a *swap*, not a burn. Real GPv2 transfers sell-side in and buy-side out (`GPv2Settlement.sol:134-138`). After routing fillMaking to the counterparty, the invariant holds. Lesson: intent settlement conservation is pairwise transfer, not supply destruction.

## 5. Recurrences — candidate primitives

| candidate primitive | quint definition | instantiated by (n) | why it is primitive |
|---|---|---|---|
| `CUSTODIAL_WRAPPED_SUPPLY` | `WrapSupply` + `canMintWrap`/`applyBurnWrap` | WBTC, Coinbase, BTCB (3) | On-chain supply is a claim check, not a reserve lock; shared shape across all custodial wrappers |
| `TWO_PHASE_CUSTODIAN_REQUEST` | `CustodianRequest` + Pending→Approved | WBTC (1; distinctive) | Mint authority is split merchant-request / custodian-confirm; not a simple minter role |
| `BURN_MINT_BRIDGE` | `canBurnMintSend` + `burnMintConserved` | CCTP, LayerZero OFT (2+) | Domain supplies move 1:1 via message; conservation is global not local |
| `ATTESTED_MESSAGE_ONCE` | `canDeliverOnce` / `markUsed` | CCTP, LayerZero (2) | Once-only nonce/payload is the anti-double-mint hinge of every Xf path with Xm |
| `OPTIMISTIC_FILL` | `DepositOrder` + fill/refund | Across (1 coded; OKX profile has solver fill) | Liquidity is pre-positioned by filler; origin reimburses — opposite of burn-mint |
| `SIGNED_ORDER_REMAINING` | `SignedOrder` + `applyFillOrder` | 1inch, CoW (2) | Partial fill tracked by remaining/filled; cancel zeroes remaining |
| `BATCH_CLEARING` | `clearsAtLimit` | CoW (1) | Uniform clearing prices + limit inequality is not the same as pairwise RFQ or taker fill |
| `DELEGATED_INTENT_STATUS` | `IntentStatus` machine | Kyber (1) | Explicit DELEGATED custody phase before execute — distinct from pure signed fill |
| `RATE_LIMITED_MINT` | `RateLimitState` | Coinbase (1) | Programmatic allowance replenishment has no vocabulary symbol |
| `ESCROW_BALANCE` | `applyEscrowDeposit/Withdraw` | Across, Hyperliquid profile (2) | Hold-and-release without mint; destination may be ledger not token |

## 6. Distinctions the 58-symbol vocabulary collapses

| element symbol | protocols | how their state machines differ | proposed split |
|---|---|---|---|
| `Xf` | WBTC, CCTP, Across, LayerZero OFT, Hyperliquid | WBTC: mint by custodian with no source verify; CCTP: burn-mint + attestation; Across: lock + optimistic fill + refund; Hyperliquid: escrow + dest ledger credit (no mint); LZ OFT: burn-mint over configurable DVNs | Split into `Xf-custodial-mint`, `Xf-burn-mint`, `Xf-optimistic-fill`, `Xf-escrow-ledger` |
| `Xm` | CCTP, LayerZero, Hyperliquid | CCTP: fixed Circle attester set + threshold; LZ: **per-app** DVN set/threshold (may be 1-of-1); Hyperliquid: endogenous chain validators | Split `Xm-external-attester` vs `Xm-endogenous-validator` vs `Xm-app-configured` |
| `In` | CoW, 1inch, Kyber, OKX (profile) | CoW: solver batch with clearing prices (`Ba`); 1inch: any taker fills remaining; Kyber: delegated status + guardian; OKX: sealed solver auction | Split `In-batch-solver`, `In-taker-fill`, `In-delegated-status`, `In-sealed-auction` |
| `Ag` | Kyber, Jupiter, LiquidMesh, Binance Wallet (profiles) | Bare route calldata vs meta-route-over-routers vs exclusive-pool ownership vs order-flow ownership | `Ag` alone cannot distinguish router, meta-aggregator, and flow owner |
| `Rd` | WBTC, Coinbase, BTCB | WBTC: merchant-only redeem; Coinbase: auto-unwrap to exchange account + jurisdiction; BTCB: self-burn with no on-chain link to BTC payout | Split by *who may redeem* and whether payout is contract-enforced |
| `Of` | Across (and L19 subjects) | Across is the clear optimistic-fill machine; intent solvers "fill" but do not reimburse from a remote escrow root bundle | Keep `Of` for Across-shaped reimbursement; do not overload onto CoW/1inch fills |
| `Gp` / `Fz` | Coinbase vs WBTC vs BTCB | Coinbase has live blacklist+pause; WBTC has neither on the token; BTCB has neither — vocabulary records freeze by *omission* for WBTC, which is the same string as "not examined" | Need positive symbol for **no-freeze guarantee** |

## 7. Mechanisms with no symbol

| mechanism | protocols | what it does | why no existing symbol fits |
|---|---|---|---|
| Rate-limited mint with programmatic replenishment | Coinbase `MintForwarder`/`RateLimit.sol` | Caps continuous mint without cold masterMinter | Not `Aw` (identity), not `Ep` (epoch), not `Gp` (pause) |
| Two-phase merchant/custodian mint request | WBTC `Factory.sol` | Merchant proposes, custodian alone confirms | `Aw` names the gate but not the two-role handshake; no request-queue element |
| Per-application verifier configuration | LayerZero | Safety is an OApp parameter, not protocol constant | `Xm` asserts verification without saying who configures the verifier set |
| Safety/liveness role split (DVN vs Executor) | LayerZero | Corrupt DVN mints false; absent Executor only stalls | No symbol for liveness-only workers |
| Dual token topology on one messenger (burn-mint OFT vs lockbox OFTAdapter) | LayerZero | Same user API, opposite attack surfaces | Single `Xf` covers both |
| Origin-pool refund via merkle root bundle | Across HubPool/SpokePool | Relayer reimbursed after challenge window | `Of` is closest but omits merkle accounting and multi-chain repayment |
| Bit invalidator vs remaining invalidator | 1inch | Two incompatible cancel/fill bookkeeping schemes | No cancel/invalidation primitive at all |
| Sealed solver auction over affiliated solvers | OKX (profile) | ~2s auction; operator may bid | Not `Ba` (witness explicitly refused batch-auction); not plain `In` |
| Order-flow ownership / demand capture | Binance Wallet, Jupiter, OKX (profiles) | Who owns the user order is the product | Vocabulary has match mechanisms, nothing for flow ownership |
| Exclusive pool as only permitted taker | Kyber (profile + Smart Intent commercial model) | Router owns venues it routes to | `Ag` is routing-to, not exclusive-taker-of |
| Endogenous verifier = destination validator set | Hyperliquid (profile) | Bridge trust = chain trust | `Xm`/`Vl` do not compose to "bridge inherits L1 security" |
| Off-chain reserve attestation consumed as ground truth | WBTC, Coinbase, BTCB | DefiLlama etc. scrape issuer JSON | `At` exists but does not distinguish self-published address list vs audited PoR vs contract balance |

## 8. Cross-protocol connections

| from | to | what flows | shared state | composition hazard |
|---|---|---|---|---|
| LayerZero Endpoint | OFT / OFTAdapter / any OApp | packets (nonce, payload) | outbound/inbound nonces per path | App owner can retarget DVNs mid-flight; conservation is app-level not Endpoint-level |
| CCTP TokenMessenger | USDC (mint/burn token) | burn messages → mint | domain supply of USDC | Attester compromise mints without burn (conservation assumes honest Xm) |
| Across origin SpokePool | destination SpokePool + relayer inventory | deposit intent → fill | `fillStatuses` hash; later refund | Relayer inventory is off-protocol capital; pool insolvency if refund roots lie |
| Across | CCTP / OFT messengers (periphery) | some deposits route via CCTP/OFT | oftMessengers mapping in SpokePool | Nested Xf: Across Of composed with burn-mint — double trust surface |
| WBTC | LayerZero / CCIP (profile: cross-chain leg) | wrapped BTC representation across chains | WBTC supply on multiple EVM chains | Custodial wrap + messaging: X19-class hazard (restricted claim into weaker representation) |
| CoW Settlement | Balancer Vault + arbitrary interactions | sell tokens in, buy tokens out, DEX pulls mid-settle | `filledAmount`; vault balances | Solver-chosen interactions can reenter external protocols; user protection is signature bounds only |
| 1inch LOP | any taker / aggregator (Kyber, OKX, Jupiter…) | signed maker liquidity | remaining invalidator | Aggregators fill 1inch orders as a venue class — `Ag` consuming `In` |
| Kyber Smart Intent | action contracts (swap hooks, zap) | delegated token pull → external call | `intentStatuses`, approvals | Action contract must be role-gated; malicious action drains delegated custody |
| Hyperliquid escrow (profile) | HyperCore ledger | USDC lock → balance credit | escrow contract balance | Fungible with CCTP-native USDC on same chain under different trust |
| Intent routers (Jupiter, OKX…) | CoW / 1inch / AMMs | order flow | none on-chain between routers | Meta-aggregation is containment of constructions, not union of element sets |

## 9. Code vs prior profile disagreements

| protocol | prior profile claims | code shows | which is right |
|---|---|---|---|
| Coinbase | Element set includes `Up` (proxy); rate limit noted only as residue | Repo is FiatTokenProxy + MintForwarder/RateLimit; rate limit is load-bearing on-chain state (`allowances`, `maxAllowances`) | Code: rate limit is first-class mechanism missing from vocabulary; profile right about proxy, wrong to leave rate limit only as residue without a symbol |
| WBTC | Corpus sometimes carries freeze/timelock | Token inherits no blacklist; Factory/Controller are plain multisig with no delay (`confirmMintRequest` onlyCustodian) | Code: no Fz, no Tg on the mint path; profile witness that drops them is correct |
| LayerZero | Corpus sometimes carries Up/Gp/timelock on endpoint | EndpointV2 is non-proxy immutable bytecode; pause accessors absent; mutability is library registry + defaults | Code wins; mutable *configuration* ≠ upgradeable *implementation* |
| Across | Listed with bridges; Of is the right family | SpokePool is deposit/fill/refund — economically closer to **intent fill** than to burn-mint bridge | Both: it is Xf+Of, but state machine matches intent-fill more than custodial wrap |
| Kyber | Profile (legacy router) emphasizes exclusive pools + surplus fee | Smart Intent contracts show delegated status machine, guardian roles, unordered nonces — a different product surface | Both true for different Kyber surfaces; vocabulary collapses them under `Ag`/`In` |
| CoW | `Ba` + `In` | Settlement is solver-gated batch with `filledAmount` and clearing prices — matches | Profile correct; code confirms batch clearing is real, not marketing |
| 1inch | Often lumped as aggregator | Limit Order Protocol is pure signed-order fill — no routing engine in this repo | Code: this package is `In`/`Ob`-like, not `Ag`; aggregation is a separate 1inch product |

## 10. Open questions for the mathematicians

1. **Is `Xf` a single morphism type?** Code exhibits at least four non-isomorphic state machines (custodial mint, burn-mint, optimistic fill, escrow-ledger). Should the carrier treat these as distinct generators with a shared "cross-domain asset motion" property, or as one generator with parameters?

2. **Where does conservation live?** Burn-mint conserves Σ domain supply; custodial wrap conserves nothing on-chain against BTC; optimistic fill conserves origin pool vs refunds but **not** global token supply across chains. What is the right invariant interface for composition of Xf-like maps?

3. **Is once-only delivery (`ATTESTED_MESSAGE_ONCE`) a primitive or a property of `Xm`?** Every safe Xf path needs it; it is the only thing preventing double mint. Should it be an explicit generator with a requirement row?

4. **How should app-configured security (LayerZero DVNs) be typed?** `Xm` as a constant is false; `Xm` as a parameter of the OApp is accurate. Does the abstract structure have room for *security as configuration state* rather than protocol constant?

5. **Is optimistic fill (`Of`) a bridge primitive, an intent primitive, or a composition of `Rl` + filler capital + refund?** Across implements all three in one contract. Modelling them fused loses the composition surface with CCTP/OFT periphery; modelling them separate needs a proven coupling.

6. **What is the type of a signed order with remaining?** Shared by CoW and 1inch, but CoW adds batch clearing and solver authority. Is `SIGNED_ORDER_REMAINING` the primitive and `Ba`/`solver-gate` decorations, or is batch settlement irreducible?

7. **Does delegated intent status (Kyber) need its own generator?** It inserts a custody phase (DELEGATED) that pure signed-fill protocols lack. Is this `Au`+`In`, or a new construction?

8. **How do we name "no freeze" positively?** WBTC's lack of blacklist is a user-facing guarantee that the vocabulary can only record by omitting `Fz` — identical to not measuring. Need a positive admissibility atom.

9. **Order-flow ownership:** Binance Wallet / Jupiter / OKX make economic sense only as owners of demand. Element-set union cannot express "protocol A is the order-flow source for protocol B." Is containment or a separate "flow" morphisms required?

10. **Rate limits and continuous authorities:** Coinbase's replenishing mint allowance is a quantitative bound on an authority. The vocabulary has thresholds for stake and quorums but not for rate. Is rate a first-class constraint language feature?

11. **Composition hazard X19 and friends:** Profile marks restricted claim bridged into weaker representation. Across+CCTP and WBTC+LZ are concrete instances. Can the positive model *construct* the hazard as a typed composition failure rather than a prohibition table row?

12. **Profile-only protocols (Hyperliquid, BTCB, Jupiter, OKX, LiquidMesh, DFlow, Binance Wallet):** their residue lists in `supp-07`/`supp-08` already point at missing generators (endogenous security, flow ownership, sealed auction, exclusive taker). When repos become available, which of these should be promoted from profile claims to executable invariants first?
