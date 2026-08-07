# Gate 2.2 — acquisition ledger (18 remaining after Steakhouse)

**Status:** LEDGER CLOSED 2026-08-07 (AFK agenda loop)  
**Rule:** every row is ACQUIRE | OFF_CHAIN | PERMISSIONED | NO_SOURCE with evidence.  
Silent skip is forbidden. Steakhouse already reclassified (MetaMorpho) — not on this list.

## Final disposition

| decision | n | outcome |
|---|---:|---|
| **SPEC (typecheck clean)** | **6** | ethena, lista, cian, usd1, okx_dex, jupiter_perps (partial IDL) |
| **OFF_CHAIN** | **4** | Kalshi, Binance Wallet, BTCB, WBETH |
| **PERMISSIONED** | **2** | BUIDL, USYC |
| **NO_SOURCE** | **6** | Aster, edgeX, LiquidMesh, DFlow, Aevo (ABI only), Rysk (client only) |
| **total** | **18** | every row decided |

---

## Ledger

| # | application | decision | evidence / artifact | notes |
|---|---|---|---|---|
| 1 | Kalshi | **OFF_CHAIN** | CFTC DCM; no public L1 matching | excluded |
| 2 | BlackRock BUIDL | **PERMISSIONED** | Securitize KYC issuance | excluded |
| 3 | Circle USYC (Hashnote) | **PERMISSIONED** | KYC tokenised T-bill | excluded |
| 4 | Binance Wallet | **OFF_CHAIN** | CEX product surface | excluded |
| 5 | Binance Bitcoin (BTCB) | **OFF_CHAIN** | operator mint/burn | excluded |
| 6 | Binance staked ETH (WBETH) | **OFF_CHAIN** | operator LST receipt | excluded |
| 7 | Aster | **NO_SOURCE** | no official public core repo | excluded until source |
| 8 | edgeX | **NO_SOURCE** | no official public core repo | excluded until source |
| 9 | LiquidMesh | **NO_SOURCE** | no durable public contracts | excluded until source |
| 10 | Ethena (USDe / sUSDe) | **SPEC** | `protocol-repos/cdp/ethena-labs_bbp-public-assets` → `quint-models-v2/ethena.qnt` | typecheck OK |
| 11 | Lista CDP | **SPEC** | `protocol-repos/cdp/lista-dao_lista-dao-contracts` → `lista.qnt` | typecheck OK |
| 12 | CIAN Yield Layer | **SPEC** | `protocol-repos/yield/cian-ai_cian-protocol` → `cian.qnt` | typecheck OK; 6h keeper |
| 13 | OKX DEX | **SPEC** | `protocol-repos/intent/okxlabs_Web3-DEX-Router-EVM-V1` → `okx_dex.qnt` | typecheck OK |
| 14 | World Liberty USD1 | **SPEC** | `protocol-repos/fiat/worldliberty_usd1-smart-contracts` → `usd1.qnt` | typecheck OK |
| 15 | Aevo | **NO_SOURCE** | `aevoxyz/aevo-sdk` ABIs only; exchange core not public | reclassified from ACQUIRE |
| 16 | Rysk V12 | **NO_SOURCE** | `rysk-finance/ryskV12-cli` client only | reclassified from ACQUIRE |
| 17 | Jupiter Perpetual Exchange | **SPEC (PARTIAL)** | IDL surrogate repo → `jupiter_perps.qnt` | IDL-shaped, not line-cited |
| 18 | DFlow | **NO_SOURCE** | no public repo found (probed orgs) | excluded |

---

## Cloned repos (this session)

| path | files (approx) |
|---|---:|
| `protocol-repos/cdp/ethena-labs_bbp-public-assets` | 776 |
| `protocol-repos/cdp/lista-dao_lista-dao-contracts` | 661 |
| `protocol-repos/yield/cian-ai_cian-protocol` | 90 |
| `protocol-repos/intent/okxlabs_Web3-DEX-Router-EVM-V1` | 482 |
| `protocol-repos/fiat/worldliberty_usd1-smart-contracts` | 1175 |
| `protocol-repos/opt/aevoxyz_aevo-sdk` | 41 |
| `protocol-repos/opt/rysk-finance_ryskV12-cli` | 52 |
| `protocol-repos/perp/julianfssen_jupiter-perps-anchor-idl-parsing` | 64 |

---

## Specs (typecheck)

```
cd quint-models-v2
for f in ethena lista cian usd1 okx_dex jupiter_perps; do quint typecheck $f.qnt; done
# all EXIT 0
```

---

## Gate 2.2 close criteria

Gate 2.2 required: for each unspecced application, either a Phase-2-style spec or an
explicit written exclusion. **Met.** Remaining NO_SOURCE/OFF_CHAIN/PERMISSIONED rows
are not silent skips — they are corpus exclusions with reasons.

Steakhouse remains reclassified to MetaMorpho (prior session).

**2.2 CLOSED as coverage disposition of the 18.** Generation remeasurement (2.3) already
showed flat rates; expanding the corpus with 6 new specs is coverage work for a future
remeasure, not a reopening of 2.3's measured ten.
