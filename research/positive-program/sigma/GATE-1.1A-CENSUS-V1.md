# Gate 1.1a — independent-witness census v1

**Status: MEASURED (partial)** 2026-08-07

Method: `GATE-1.1A-METHOD.md`. Script: `gate11a_census_v1.py`.

INDEPENDENT = local action/var/type for the mechanism. SHARED = common helper call only.
Hand overrides applied for N6 cctp and N3 aave/compound (see script OVERRIDES).

Retired: pre-method identifier counts (28/50, 31/19).

## Summary

| primitive | independent | shared-only | ≥2 independent? |
|---|---:|---:|---|
| N6-onceOnly | 1 | 1 | **NO** |
| N5-custody-wrap | 1 | 1 | **NO** |
| N8-delegation | 1 | 1 | **NO** |
| F2-deferred-claim | 4 | 1 | **YES** |
| F7-index-accrual | 5 | 1 | **YES** |
| N1-cp-swap | 3 | 3 | **YES** |
| F5-health | 7 | 4 | **YES** |
| N3-rateCurve | 0 | 6 | **NO** |
| N10-authz | 5 | 0 | **YES** |

**5 / 9 primitives meet ≥2 independent witnesses.**

## Detail

### N6-onceOnly

Independent **1**, shared-only **1**

| spec | class |
|---|---|
| `quint-models/L4/layerzero.qnt` | **INDEPENDENT** |
| `quint-models/L4/cctp.qnt` | **SHARED** |

### N5-custody-wrap

Independent **1**, shared-only **1**

| spec | class |
|---|---|
| `quint-models/L4/wbtc.qnt` | **INDEPENDENT** |
| `quint-models/L4/coinbase.qnt` | **SHARED** |

### N8-delegation

Independent **1**, shared-only **1**

| spec | class |
|---|---|
| `quint-models-v2/metamorpho.qnt` | **INDEPENDENT** |
| `quint-models/L4/kyber.qnt` | **SHARED** |

### F2-deferred-claim

Independent **4**, shared-only **1**

| spec | class |
|---|---|
| `quint-models/L2/etherfi.qnt` | **INDEPENDENT** |
| `quint-models/L2/lido.qnt` | **INDEPENDENT** |
| `quint-models/L3/lighter.qnt` | **INDEPENDENT** |
| `quint-models/L5/ondo.qnt` | **INDEPENDENT** |
| `quint-models/L5/centrifuge.qnt` | **SHARED** |

### F7-index-accrual

Independent **5**, shared-only **1**

| spec | class |
|---|---|
| `quint-models/L1/aave_v3.qnt` | **INDEPENDENT** |
| `quint-models/L1/fluid.qnt` | **INDEPENDENT** |
| `quint-models/L1/justlend.qnt` | **INDEPENDENT** |
| `quint-models/L1/sparklend.qnt` | **INDEPENDENT** |
| `quint-models/L3/pendle.qnt` | **INDEPENDENT** |
| `quint-models/L1/compound_v3.qnt` | **SHARED** |

### N1-cp-swap

Independent **3**, shared-only **3**

| spec | class |
|---|---|
| `quint-models/L1/uniswap_v2.qnt` | **INDEPENDENT** |
| `quint-models/L1/uniswap_v3.qnt` | **INDEPENDENT** |
| `quint-models/L1/uniswap_v4.qnt` | **INDEPENDENT** |
| `quint-models/L1/fluid.qnt` | **SHARED** |
| `quint-models/L1/pancakeswap.qnt` | **SHARED** |
| `quint-models/L1/raydium_cp.qnt` | **SHARED** |

### F5-health

Independent **7**, shared-only **4**

| spec | class |
|---|---|
| `quint-models/L1/aave_v3.qnt` | **INDEPENDENT** |
| `quint-models/L1/justlend.qnt` | **INDEPENDENT** |
| `quint-models/L1/morpho_blue.qnt` | **INDEPENDENT** |
| `quint-models/L2/crvusd.qnt` | **INDEPENDENT** |
| `quint-models/L3/apex.qnt` | **INDEPENDENT** |
| `quint-models/L3/gmx.qnt` | **INDEPENDENT** |
| `quint-models/L5/panoptic.qnt` | **INDEPENDENT** |
| `quint-models/L1/compound_v3.qnt` | **SHARED** |
| `quint-models/L1/fluid.qnt` | **SHARED** |
| `quint-models/L1/sparklend.qnt` | **SHARED** |
| `quint-models/L2/liquity.qnt` | **SHARED** |

### N3-rateCurve

Independent **0**, shared-only **6**

| spec | class |
|---|---|
| `quint-models/L1/aave_v3.qnt` | **SHARED** |
| `quint-models/L1/compound_v3.qnt` | **SHARED** |
| `quint-models/L1/fluid.qnt` | **SHARED** |
| `quint-models/L1/maple.qnt` | **SHARED** |
| `quint-models/L1/sparklend.qnt` | **SHARED** |
| `quint-models/L5/panoptic.qnt` | **SHARED** |

### N10-authz

Independent **5**, shared-only **0**

| spec | class |
|---|---|
| `quint-models/L3/spark.qnt` | **INDEPENDENT** |
| `quint-models/L6/pyusd.qnt` | **INDEPENDENT** |
| `quint-models/L6/usdc.qnt` | **INDEPENDENT** |
| `quint-models/L6/usdg.qnt` | **INDEPENDENT** |
| `quint-models/L6/usdt.qnt` | **INDEPENDENT** |

## Disposition

Gate 1.1a is **MEASURED** on a fixed 9-primitive sample under the independence method.
Not a full BASIS family census. Extend PRIM + OVERRIDES to close remaining rows.
Primitives failing ≥2 independent (N5, N3 as scored) must not be pruned solely on count.
