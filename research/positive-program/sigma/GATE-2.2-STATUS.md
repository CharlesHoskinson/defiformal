# Gate 2.2 — status (CLOSED 2026-08-07 AFK)

## Counts

| quantity | count |
|---|---:|
| Original work-list | 19 |
| Steakhouse reclassified (MetaMorpho) | 1 |
| Remaining dispositioned | **18** |
| New Quint v2 specs (typecheck OK) | **6** |
| Formal exclusions | **12** |
| Contracts cloned this session | **8** |

## Specs landed

| app | file | fidelity |
|---|---|---|
| Ethena | `quint-models-v2/ethena.qnt` | contract-grounded partial + 6h |
| Lista CDP | `quint-models-v2/lista.qnt` | Interaction.sol deposit/borrow/payback |
| CIAN | `quint-models-v2/cian.qnt` | AccountManager + keeper execute (6h) |
| USD1 | `quint-models-v2/usd1.qnt` | Stablecoin.sol full control plane |
| OKX DEX | `quint-models-v2/okx_dex.qnt` | simplified router |
| Jupiter Perps | `quint-models-v2/jupiter_perps.qnt` | IDL partial (not line-cited) |

## Exclusions

See `GATE-2.2-ACQUISITION.md` — OFF_CHAIN (4), PERMISSIONED (2), NO_SOURCE (6).

## Active after close

- Phase 1 remains **blocked on honest corpus / autonomy law** (1.1b) — new 6h specs help
  but do not by themselves re-run pair-4 across the whole corpus.
- Gate 2.3 remains **MEASURED** on the historical ten; optional later remeasure may include
  the six new specs (out of scope for this close).
