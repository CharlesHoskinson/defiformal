# 1.1a expanded independent-witness census (heuristic)

Script: `gate11a_census_expand.py`. False positives possible; human confirm before quoting counts as closed.

## N6-onceOnly

Independent: **2** · Shared-only: **0** · Hits: 2

| spec | class |
|---|---|
| `quint-models/L4/cctp.qnt` | **INDEPENDENT** |
| `quint-models/L4/layerzero.qnt` | **INDEPENDENT** |

## N5-custody-wrap

Independent: **1** · Shared-only: **1** · Hits: 2

| spec | class |
|---|---|
| `quint-models/L4/coinbase.qnt` | **SHARED** |
| `quint-models/L4/wbtc.qnt` | **INDEPENDENT** |

## N8-delegation

Independent: **0** · Shared-only: **1** · Hits: 1

| spec | class |
|---|---|
| `quint-models/L4/kyber.qnt` | **SHARED** |

## F2-deferred-claim

Independent: **4** · Shared-only: **1** · Hits: 5

| spec | class |
|---|---|
| `quint-models/L2/etherfi.qnt` | **INDEPENDENT** |
| `quint-models/L2/lido.qnt` | **INDEPENDENT** |
| `quint-models/L3/hyperliquid.qnt` | **INDEPENDENT** |
| `quint-models/L3/lighter.qnt` | **INDEPENDENT** |
| `quint-models/L5/ondo.qnt` | **SHARED** |

## F7-index

Independent: **4** · Shared-only: **2** · Hits: 6

| spec | class |
|---|---|
| `quint-models/L1/aave_v3.qnt` | **INDEPENDENT** |
| `quint-models/L1/compound_v3.qnt` | **SHARED** |
| `quint-models/L1/fluid.qnt` | **SHARED** |
| `quint-models/L1/justlend.qnt` | **INDEPENDENT** |
| `quint-models/L1/sparklend.qnt` | **INDEPENDENT** |
| `quint-models/L3/pendle.qnt` | **INDEPENDENT** |

## N1-swap

Independent: **6** · Shared-only: **0** · Hits: 6

| spec | class |
|---|---|
| `quint-models/L1/fluid.qnt` | **INDEPENDENT** |
| `quint-models/L1/pancakeswap.qnt` | **INDEPENDENT** |
| `quint-models/L1/raydium_cp.qnt` | **INDEPENDENT** |
| `quint-models/L1/uniswap_v2.qnt` | **INDEPENDENT** |
| `quint-models/L1/uniswap_v3.qnt` | **INDEPENDENT** |
| `quint-models/L1/uniswap_v4.qnt` | **INDEPENDENT** |

## Reading

- N6 once-only now shows multiple independents (layerzero-class markers).
- N8 delegation independents include v2 metamorpho/cian patterns if present in v1 tree.
- SHARED rows still collapse under restated condition 1.
