# The element vocabulary — 58 mechanisms

Decompose using **only** these symbols. Where a protocol does something this
vocabulary cannot name, that is a **residue** finding and is the most valuable
thing you can report — do not invent symbols, do not force a bad fit.

## Claims & accounting
- `Sh` pro-rata share accounting — shares represent a proportional pool claim
- `Ix` index-based accrual — a global index changes claim value
- `Rb` rebasing accounting — nominal balances change by global scaling

## Pool pricing
- `Cp` constant-product invariant (x·y=k)
- `Wg` weighted-geometric invariant (multi-asset weights)
- `St` stable-hybrid invariant (constant-sum near parity)
- `Cl` concentrated liquidity (range positions, ticks)
- `Pm` oracle-priced inventory curve (proactive market making)

## Execution
- `Ob` on-chain order book
- `Rf` request for quote (signed maker quote)
- `Ba` batch-auction clearing (uniform price over a batch)
- `In` intent & solver execution (signed outcome constraints)

## Liquidity catalysis
- `Ag` aggregation and routing (multi-venue route construction)
- `Fl` atomic flash liquidity (borrow+repay in one settlement scope)

## Credit
- `Pl` pooled lending — shared pool, many lenders/borrowers
- `Im` isolated lending market — per-market risk fence
- `Cd` collateralized-debt minting — mint a liability against collateral
- `Uc` undercollateralized credit — identity/underwriting/recourse
- `Ft` fixed-term debt — maturity-dated claim

## Solvency
- `Ct` collateral-threshold test — the margin/LTV/health computation
- `Li` incentivized liquidation — third parties paid to close positions
- `Ad` auto-deleveraging — rank-ordered forced close
- `Sl` socialized-loss allocation — loss assigned to a claim class
- `Bs` staked backstop — slashable first-loss capital

## Risk transfer
- `Pf` perpetual funding transfer — payment tethering perp to index
- `Op` option payoff — strike/expiry/collateralized settlement
- `Tr` tranche waterfall — declared seniority over a loss event
- `Cv` mutual cover pool — adjudicated claims on pooled premium
- `Py` principal/yield separation — split into PT and YT
- `Sv` servicing & determination discretion *(candidate)*
- `Dp` directional position & hedge maintenance *(candidate)*

## Truth
- `Ex` external data oracle (push/pull/medianizer)
- `Tp` on-chain time-weighted price
- `Oa` optimistic assertion oracle (assert-then-dispute)
- `At` reserve/NAV/financial attestation

## Time & queueing
- `Sr` streaming accrual · `Ep` epoch-gated transition · `Wq` withdrawal queue

## Incentives
- `Em` protocol-funded emissions
- `Fd` surplus & fee distribution *(candidate)*

## Control & authority
- `Tg` delayed-governance execution (timelock)
- `Up` mutable implementation proxy
- `Gp` emergency guardian or pause
- `Au` delegated execution scope (session policy, account abstraction)
- `Gs` sponsored-fee liability (paymaster) *(candidate)*

## Cross-domain
- `Xm` cross-domain message verification
- `Xf` cross-domain asset transfer
- `Rl` resource lock / reservation *(candidate)*
- `Of` optimistic fill & reimbursement *(candidate)*

## Stability
- `Rd` direct redemption right
- `Ps` peg-swap module (1:1 reserve-backed)
- `As` algorithmic supply adjustment

## Access & privacy
- `Aw` permission/identity gate
- `Sb` shielded-balance state
- `Sd` selective-disclosure proof *(candidate)*
- `Fz` freeze / forced transfer *(candidate)*

## Security reuse & staking
- `Rs` restaking / shared security *(candidate)*
- `Vl` staking & validator lifecycle *(candidate)*

---

## Contested register — NOT usable without a note
`Bc` bonding-curve issuance · `Tw` time-weighted AMM execution ·
`Da` Dutch-auction descent · `Cg` credit delegation · `Ir` insurance reserve ·
`Zk` verifiable state proof · `Ve` vote-escrow · `Kg` credential-gated transfer ·
`Ua` unified-balance ledger · `Sq` shared ordering commitment

## Degenerate limit
`CSM` constant sum — a limit of `St`, not an element
