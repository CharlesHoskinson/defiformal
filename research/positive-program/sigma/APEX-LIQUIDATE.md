# `apex.liquidate` — checked, and it forces a refinement to the characterisation

**Three results. The recorded trigger deletion is repaired and witnessed. The 6h
authority omission is `(E<=)`-safe, and the reason why gives 6h the soundness
test it was missing. And `apex.liquidate` is a counterexample to
`CHARACTERISATION.md` as written: it is permission-dependent and it is not a
mandate.**

---

## 1. The trigger deletion is repaired

`ROADMAP` recorded that apex's liquidation *trigger* was deleted as well as its
settlement: the contract prices via `getMarkPriceAcc`, making liquidatability
size-dependent, where v1 used an exogenous scalar.

**Contract, confirmed.** `Margin_flat.sol:1211 _calDebtRatio` calls

    IPriceOracle(IConfig(config).priceOracle()).getMarkPriceAcc(
        amm, IConfig(config).beta(), quoteAmount, false)

so the debt ratio — and therefore eligibility — depends on the position's own
size through the AMM skew.

**Spec, confirmed repaired.** `apex.qnt:485 positionLiquidatable` guards on
`markPriceAccOk(|qs|, quote)` and `debtRatio(qs, bs, base, quote)`. The header
records it: *"Restored as `markPriceAccBase` + `debtRatio`; `var markPrice` is
gone."*

**Witnessed, not asserted:**

    wit_sizeDependentLiquidation   [violation]
    wit_used_markPriceAccBase      [violation]

Both reachable. Deletion D-6 is closed.

## 2. The authority omission is safe — and here is the test

`Margin_flat.sol:869` requires `IConfig(config).routerMap(msg.sender)`. The spec's
`liquidate(target: str)` takes no caller, so 6h scores it OMITTED. Is that an
`(E<=)` restriction or an unsound relaxation?

**Safe, and checked rather than argued:**

- `contracts/core/Router.sol:331 liquidate(baseToken, quoteToken, trader, to)` is
  `external` with **no access modifier** — any user may call it;
- `contracts/core/Config.sol:99 registerRouter` is `onlyOwner`.

So the gate restricts **which contracts may relay**, not **which users may act**.
Every user reaches `Margin.liquidate` through the open Router. Dropping the guard
adds no reachable state.

> **Soundness test for a 6h OMITTED entry.** The omission is `(E<=)`-safe iff the
> gate is **surjective onto users** — every principal can reach the transition
> without a grant from another principal. Router, proxy and adapter gates are
> surjective. Role gates generally are not.

`wbtc.confirmMint`'s `onlyCustodian` is the contrast: not surjective, so dropping
it lets anyone confirm a mint the contract reserves to the custodian. That is a
relaxation, and it is why `wbtc` was deletion 11 while apex's router gate is
merely a declaration.

**Applied to the nine OMITTED entries:** apex's four (`mint`, `burn`,
`closePosition`, `liquidate`) share the one router gate and are all safe by this
test. The remaining five — `uniswap_v2.setFeeTo` and huma's `distributeProfit`,
`distributeLoss`, `disburse`, `closePool` — have **not** been tested here.
`huma.closePool` is `onlyPoolOwnerOrHumaOwner`, which is not surjective on its
face, so it should be assumed unsafe until checked.

## 3. The refinement — permission-dependence is necessary, not sufficient

`CHARACTERISATION.md` §3 separates the mandate by **permission-dependence**: the
guard reads the role coordinate `R`.

**`apex.liquidate` reads `R`.** `routerMap` is a role assignment, mutable by the
owner via `registerRouter`. By the definition as written, `liquidate` is
permission-dependent — and it is obviously not a delegated allocation mandate.
The router exercises no discretion; it relays. Eligibility is fixed by the debt
ratio, a function of positions.

So the characterisation as stated is **too weak**, and apex is the counterexample.

The missing condition is the same property that settled §2:

> **A mandate's gate is NON-SURJECTIVE.** There exist principals who cannot reach
> the transition at all, whatever they do, absent a grant from another principal.

- MetaMorpho: `isAllocator` is reachable only via `setIsAllocator`, `onlyOwner`.
  Mallory cannot allocate until the owner says so. **Non-surjective — a mandate.**
- Liquity V2: a batch manager must be registered before setting rates.
  **Non-surjective — a mandate.**
- apex: any user reaches `Margin.liquidate` through the open Router.
  **Surjective — not a mandate.**

**Corrected statement:**

> The delegated allocation mandate is a transition that is **permission-dependent**
> (its guard reads `R`) **and whose gate is non-surjective** (the permission
> cannot be self-acquired). The basis is permission-free, so it fails the first
> condition already — the theorem of `CHARACTERISATION.md` §5 is unaffected.

The theorem survives because the basis contains no `R`-reading generator at all;
the refinement matters for **classifying** `R`-reading transitions once 6h puts
them in the corpus. Without it, every proxy and router pattern would be scored a
mandate, and the four-witness result of `RESIDUE-MINED.md` would inflate into
noise.

**One criterion, two jobs:** surjectivity decides whether a 6h omission is sound
*and* whether an `R`-reading transition is a mandate. That is a good sign for it
being the right property.

## Reproduce

    sed -n '860,872p'   protocol-repos/perp/ApeX-Protocol_apex-protocol/Margin_flat.sol
    sed -n '1211,1227p' protocol-repos/perp/ApeX-Protocol_apex-protocol/Margin_flat.sol
    grep -n -A6 "function liquidate" protocol-repos/perp/ApeX-Protocol_apex-protocol/contracts/core/Router.sol
    grep -n -A4 "function registerRouter" protocol-repos/perp/ApeX-Protocol_apex-protocol/contracts/core/Config.sol
    cd quint-models-v2 && quint run apex.qnt --invariant=wit_sizeDependentLiquidation --max-steps=25 --max-samples=20000
