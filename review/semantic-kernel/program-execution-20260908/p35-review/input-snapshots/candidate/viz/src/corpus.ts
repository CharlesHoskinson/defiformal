/* GENERATED from corpus50/lanes - do not edit by hand.
 * 72 protocol decompositions, 12 categories, ranked from DefiLlama and rwa.xyz
 * on 2026-08-04. Collisions and subset relations are computed, not asserted.
 */
export interface CorpusProtocol {
  name: string; category: string; syms: string[]; rank: string;
  residue: number; forced: string[]; orderKnown: boolean;
}
export interface Collision { syms: string[]; members: string[]; categories: string[] }

export const CORPUS: CorpusProtocol[] = [
  {
    "name": "Uniswap",
    "category": "Spot DEX / AMM",
    "syms": [
      "Cl",
      "Cp",
      "Fd",
      "Fl",
      "Sh",
      "Tg",
      "Tp"
    ],
    "rank": "$3,058.0M TVL (V3 $1,449.0M + V4 $821.9M + V2 $784.1M), DefiLlama 2026-08-04, rank 1 of category 'Dexs'",
    "residue": 5,
    "forced": [
      "Fd",
      "Tg",
      "Tp"
    ],
    "orderKnown": true
  },
  {
    "name": "PancakeSwap",
    "category": "Spot DEX / AMM",
    "syms": [
      "Cl",
      "Cp",
      "Em",
      "Fd",
      "Fl",
      "Sh",
      "Tg",
      "Up"
    ],
    "rank": "$2,049.0M TVL (AMM v2 $1,684.2M + v3 $288.0M + Infinity $73.1M), DefiLlama 2026-08-04, rank 2",
    "residue": 3,
    "forced": [
      "Fd"
    ],
    "orderKnown": true
  },
  {
    "name": "Curve",
    "category": "Spot DEX / AMM",
    "syms": [
      "Ag",
      "Em",
      "Fd",
      "Sh",
      "St",
      "Tg",
      "Tp",
      "Ve"
    ],
    "rank": "$1,277.0M TVL (Curve DEX), DefiLlama 2026-08-04, rank 3",
    "residue": 5,
    "forced": [
      "Ve",
      "St",
      "Fd",
      "Ag"
    ],
    "orderKnown": true
  },
  {
    "name": "Raydium",
    "category": "Spot DEX / AMM",
    "syms": [
      "Cl",
      "Cp",
      "Em",
      "Fd",
      "Sh",
      "Up"
    ],
    "rank": "$819.1M TVL (Raydium AMM), DefiLlama 2026-08-04, rank 4",
    "residue": 3,
    "forced": [
      "Up",
      "Fd"
    ],
    "orderKnown": true
  },
  {
    "name": "Fluid",
    "category": "Spot DEX / AMM",
    "syms": [
      "Cl",
      "Ct",
      "Ex",
      "Gp",
      "Li",
      "Pl",
      "Sh",
      "Tg",
      "Up"
    ],
    "rank": "$283.0M TVL (Fluid DEX component only; Fluid's lending arm is a separate $663.8M entry in 'Lending'), DefiLlama 2026-08-04, rank 5",
    "residue": 4,
    "forced": [
      "Cl",
      "Pl"
    ],
    "orderKnown": false
  },
  {
    "name": "Aave V3",
    "category": "Lending",
    "syms": [
      "Bs",
      "Cd",
      "Ct",
      "Em",
      "Ex",
      "Fd",
      "Fl",
      "Gp",
      "Im",
      "Ix",
      "Li",
      "Pl",
      "Rb",
      "Sl",
      "Tg",
      "Up",
      "Xm"
    ],
    "rank": "$14,358.6M TVL (parent aggregate; Aave V3 alone $14,027.0M), DefiLlama 2026-08-04, rank 1 of category 'Lending'",
    "residue": 6,
    "forced": [
      "Im",
      "Cd",
      "Rb",
      "Fd"
    ],
    "orderKnown": true
  },
  {
    "name": "Morpho",
    "category": "Lending",
    "syms": [
      "Aw",
      "Ct",
      "Em",
      "Ex",
      "Fl",
      "Gp",
      "Im",
      "Ix",
      "Li",
      "Pl",
      "Sh",
      "Sl",
      "Sv",
      "Tg"
    ],
    "rank": "$7,665.5M TVL (Morpho Blue $7,663.5M), DefiLlama 2026-08-04, rank 2",
    "residue": 5,
    "forced": [
      "Sv",
      "Pl",
      "Aw"
    ],
    "orderKnown": true
  },
  {
    "name": "SparkLend",
    "category": "Lending",
    "syms": [
      "Ct",
      "Em",
      "Ex",
      "Fl",
      "Gp",
      "Im",
      "Ix",
      "Li",
      "Pl",
      "Rb",
      "Tg",
      "Up"
    ],
    "rank": "$3,636.9M TVL, DefiLlama 2026-08-04, rank 3",
    "residue": 3,
    "forced": [
      "Im"
    ],
    "orderKnown": true
  },
  {
    "name": "JustLend V1",
    "category": "Lending",
    "syms": [
      "Ct",
      "Em",
      "Ex",
      "Gp",
      "Ix",
      "Li",
      "Pl",
      "Sh",
      "Up"
    ],
    "rank": "$3,385.2M TVL, DefiLlama 2026-08-04, rank 4",
    "residue": 3,
    "forced": [
      "Sh",
      "Li"
    ],
    "orderKnown": true
  },
  {
    "name": "Maple",
    "category": "Lending",
    "syms": [
      "At",
      "Aw",
      "Ct",
      "Em",
      "Ex",
      "Ft",
      "Gp",
      "Ix",
      "Li",
      "Pl",
      "Sh",
      "Sv",
      "Tg",
      "Uc",
      "Up",
      "Wq"
    ],
    "rank": "$2,262.7M TVL, DefiLlama 2026-08-04, rank 5",
    "residue": 5,
    "forced": [
      "Sv",
      "Ct",
      "Li",
      "Uc"
    ],
    "orderKnown": true
  },
  {
    "name": "Compound V3",
    "category": "Lending",
    "syms": [
      "Ct",
      "Em",
      "Ex",
      "Gp",
      "Im",
      "Ix",
      "Li",
      "Pl",
      "Rb",
      "Sl",
      "Tg",
      "Up"
    ],
    "rank": "$1,126.4M TVL, DefiLlama 2026-08-04, rank 6 — below the top five, included because the brief asks whether Aave and Compound decompose identically",
    "residue": 4,
    "forced": [
      "Li",
      "Sl",
      "Im"
    ],
    "orderKnown": true
  },
  {
    "name": "Sky (Sky Lending, ex-MakerDAO)",
    "category": "CDP / collateral-backed stablecoins",
    "syms": [
      "At",
      "Cd",
      "Ct",
      "Em",
      "Ex",
      "Fd",
      "Gp",
      "Ix",
      "Li",
      "Ps",
      "Sl",
      "Tg",
      "Up",
      "Xf"
    ],
    "rank": "$5,665.3M TVL (Sky Lending), DefiLlama 2026-08-04, rank 1 of category 'CDP'",
    "residue": 5,
    "forced": [
      "Li",
      "Ix",
      "At",
      "Fd"
    ],
    "orderKnown": true
  },
  {
    "name": "Ethena (USDe / sUSDe)",
    "category": "CDP / collateral-backed stablecoins",
    "syms": [
      "At",
      "Aw",
      "Bs",
      "Dp",
      "Em",
      "Ex",
      "Fz",
      "Gp",
      "Ix",
      "Rd",
      "Sh",
      "Tg",
      "Tr",
      "Up",
      "Wq",
      "Xf"
    ],
    "rank": "$3,872.9M TVL, DefiLlama 2026-08-04. DefiLlama files it under 'Basis Trading', not 'CDP' — included here because it is the second-largest collateral-backed synthetic dollar and is the assigned delta-neutral stress test",
    "residue": 6,
    "forced": [
      "Dp",
      "Pf",
      "Bs",
      "Tr",
      "Rd",
      "Fz",
      "Ix"
    ],
    "orderKnown": false
  },
  {
    "name": "USDD",
    "category": "CDP / collateral-backed stablecoins",
    "syms": [
      "At",
      "Cd",
      "Ct",
      "Em",
      "Ex",
      "Gp",
      "Ix",
      "Li",
      "Ps",
      "Sl",
      "Tg",
      "Up",
      "Xf"
    ],
    "rank": "$1,299.4M TVL, DefiLlama 2026-08-04, rank 2 of category 'CDP'",
    "residue": 4,
    "forced": [
      "At",
      "Em",
      "Li"
    ],
    "orderKnown": true
  },
  {
    "name": "Lista CDP",
    "category": "CDP / collateral-backed stablecoins",
    "syms": [
      "Cd",
      "Ct",
      "Em",
      "Ex",
      "Gp",
      "Ix",
      "Li",
      "Ps",
      "Sl",
      "Tg",
      "Up"
    ],
    "rank": "$320.7M TVL, DefiLlama 2026-08-04, rank 3 of category 'CDP'",
    "residue": 4,
    "forced": [
      "Li"
    ],
    "orderKnown": true
  },
  {
    "name": "Liquity (V1 + V2)",
    "category": "CDP / collateral-backed stablecoins",
    "syms": [
      "Bs",
      "Cd",
      "Ct",
      "Em",
      "Ex",
      "Fd",
      "Li",
      "Rd",
      "Sl"
    ],
    "rank": "$207.9M TVL (V1 $137.2M + V2 $70.6M), DefiLlama 2026-08-04, rank 4 of category 'CDP'",
    "residue": 5,
    "forced": [
      "Bs",
      "Sl",
      "Rd",
      "Fd"
    ],
    "orderKnown": true
  },
  {
    "name": "crvUSD",
    "category": "CDP / collateral-backed stablecoins",
    "syms": [
      "As",
      "Cd",
      "Cl",
      "Ct",
      "Fd",
      "Gp",
      "Li",
      "Tg",
      "Tp",
      "Up",
      "Ve"
    ],
    "rank": "$72.9M TVL (crvUSD; plus Curve LlamaLend $61.4M filed under 'Lending'), DefiLlama 2026-08-04, rank 5 of category 'CDP'",
    "residue": 4,
    "forced": [
      "Cl",
      "As",
      "Ve",
      "Tp"
    ],
    "orderKnown": true
  },
  {
    "name": "Lido",
    "category": "Liquid staking & restaking",
    "syms": [
      "Bs",
      "Em",
      "Ep",
      "Ex",
      "Fd",
      "Gp",
      "Rb",
      "Sh",
      "Sl",
      "Tg",
      "Up",
      "Vl",
      "Wq"
    ],
    "rank": "$17,578.3M TVL, DefiLlama 2026-08-04, rank 1 of merged 'Liquid Staking'+'Restaking'+'Liquid Restaking'",
    "residue": 5,
    "forced": [
      "Vl",
      "Ex",
      "Bs",
      "Sl",
      "Fd"
    ],
    "orderKnown": true
  },
  {
    "name": "Binance staked ETH (WBETH)",
    "category": "Liquid staking & restaking",
    "syms": [
      "Aw",
      "Ix",
      "Rd",
      "Sh",
      "Up"
    ],
    "rank": "$6,940.0M TVL, DefiLlama 2026-08-04, rank 2",
    "residue": 5,
    "forced": [
      "Rd",
      "Ix",
      "Aw"
    ],
    "orderKnown": false
  },
  {
    "name": "EigenCloud (EigenLayer)",
    "category": "Liquid staking & restaking",
    "syms": [
      "Aw",
      "Bs",
      "Em",
      "Ep",
      "Gp",
      "Rs",
      "Sh",
      "Sl",
      "Tg",
      "Up",
      "Vl",
      "Wq"
    ],
    "rank": "$5,000.8M TVL, DefiLlama 2026-08-04, rank 3",
    "residue": 5,
    "forced": [
      "Vl",
      "Aw",
      "Bs"
    ],
    "orderKnown": true
  },
  {
    "name": "ether.fi (eETH / weETH)",
    "category": "Liquid staking & restaking",
    "syms": [
      "Bs",
      "Em",
      "Ep",
      "Ex",
      "Gp",
      "Rb",
      "Rs",
      "Sh",
      "Sl",
      "Tg",
      "Tr",
      "Up",
      "Vl",
      "Wq"
    ],
    "rank": "$3,293.7M TVL (ether.fi Stake; ether.fi Liquid $276.4M is filed separately under 'Onchain Capital Allocator'), DefiLlama 2026-08-04, rank 4",
    "residue": 4,
    "forced": [
      "Tr",
      "Vl",
      "Rs",
      "Ex"
    ],
    "orderKnown": true
  },
  {
    "name": "Babylon Protocol",
    "category": "Liquid staking & restaking",
    "syms": [
      "Aw",
      "Bs",
      "Em",
      "Ep",
      "Rs",
      "Sl",
      "Vl",
      "Wq",
      "Xm"
    ],
    "rank": "$2,732.9M TVL, DefiLlama 2026-08-04, rank 5",
    "residue": 5,
    "forced": [
      "Xm",
      "Aw",
      "Vl",
      "Bs"
    ],
    "orderKnown": true
  },
  {
    "name": "Hyperliquid",
    "category": "Perpetuals / derivatives",
    "syms": [
      "Ad",
      "Bs",
      "Ct",
      "Ex",
      "Gp",
      "Li",
      "Ob",
      "Pf",
      "Sh",
      "Sl",
      "Vl",
      "Wq",
      "Xf",
      "Xm"
    ],
    "rank": "#1 by perp volume: $7.611b normalized 24h, $54.207b 7d, $195.602b 30d, $10.713b open interest (DefiLlama /perps, 2026-08-04). 44% of all on-chain perp volume.",
    "residue": 6,
    "forced": [
      "Bs",
      "Vl",
      "Ua"
    ],
    "orderKnown": true
  },
  {
    "name": "ApeX Protocol (ApeX Omni)",
    "category": "Perpetuals / derivatives",
    "syms": [
      "Bs",
      "Ct",
      "Em",
      "Ex",
      "Li",
      "Ob",
      "Pf",
      "Sh",
      "Tg",
      "Up",
      "Xf",
      "Xm"
    ],
    "rank": "#2 by perp volume: $1.318b normalized 24h ($1.34b reported), $9.17b 7d, $33.875b 30d, $116.47m OI (DefiLlama /perps, 2026-08-04).",
    "residue": 4,
    "forced": [
      "Ob",
      "Zk",
      "Bs"
    ],
    "orderKnown": true
  },
  {
    "name": "Aster",
    "category": "Perpetuals / derivatives",
    "syms": [
      "Ct",
      "Em",
      "Ex",
      "Gp",
      "Li",
      "Ob",
      "Pf",
      "Pm",
      "Sh",
      "Up",
      "Xf"
    ],
    "rank": "#3 by perp volume: $1.251b normalized 24h, $11.584b 7d, $41.033b 30d, $1.933b OI (DefiLlama /perps, 2026-08-04).",
    "residue": 4,
    "forced": [
      "Pm",
      "Ob",
      "Dp"
    ],
    "orderKnown": false
  },
  {
    "name": "Lighter",
    "category": "Perpetuals / derivatives",
    "syms": [
      "Ad",
      "Ct",
      "Em",
      "Ex",
      "Gp",
      "Li",
      "Ob",
      "Pf",
      "Sh",
      "Up",
      "Wq",
      "Xf",
      "Xm"
    ],
    "rank": "#4 by perp volume: $1.17b normalized 24h ($1.175b reported), $8.384b 7d, $34.221b 30d, $872.18m OI (DefiLlama /perps, 2026-08-04).",
    "residue": 4,
    "forced": [
      "Ob",
      "Zk",
      "Li"
    ],
    "orderKnown": true
  },
  {
    "name": "edgeX",
    "category": "Perpetuals / derivatives",
    "syms": [
      "Bs",
      "Ct",
      "Em",
      "Ex",
      "Gp",
      "Li",
      "Ob",
      "Pf",
      "Sh",
      "Up",
      "Xf",
      "Xm"
    ],
    "rank": "#5 by perp volume: $966.24m normalized 24h ($268.11m reported), $6.986b 7d, $20.522b 30d (DefiLlama /perps, 2026-08-04).",
    "residue": 3,
    "forced": [
      "Ob",
      "Zk",
      "Bs"
    ],
    "orderKnown": true
  },
  {
    "name": "Jupiter Perpetual Exchange",
    "category": "Perpetuals / derivatives",
    "syms": [
      "Ct",
      "Ex",
      "Gp",
      "Li",
      "Pm",
      "Sh",
      "Sr",
      "Up"
    ],
    "rank": "OUTSIDE the volume top 5, included deliberately as the oracle-priced-pool control: #1 in DefiLlama's 'Derivatives' category by TVL at $703.6m (api.llama.fi/protocols, 2026-08-04). Included because all five volume leaders are order-book venues, so a volume-only top 5 would have tested zero pool-based designs.",
    "residue": 4,
    "forced": [
      "Ct",
      "Sr"
    ],
    "orderKnown": true
  },
  {
    "name": "GMX V2 Perps",
    "category": "Perpetuals / derivatives",
    "syms": [
      "Ad",
      "Ct",
      "Em",
      "Ex",
      "Gp",
      "Im",
      "Li",
      "Pf",
      "Pm",
      "Sh",
      "Sr",
      "Tg",
      "Up"
    ],
    "rank": "OUTSIDE the volume top 5, included as the second pool-based control and because the brief specifically asks whether the vocabulary separates Hyperliquid from GMX: #3 in DefiLlama's 'Derivatives' category by TVL at $173.5m across 4 chains (api.llama.fi/protocols, 2026-08-04).",
    "residue": 4,
    "forced": [
      "Im",
      "Sr"
    ],
    "orderKnown": true
  },
  {
    "name": "Pendle",
    "category": "Yield / vaults / aggregators",
    "syms": [
      "Em",
      "Ep",
      "Ft",
      "Gp",
      "Ix",
      "Py",
      "Rd",
      "Up"
    ],
    "rank": "#1 by TVL in DefiLlama categories Yield + Yield Aggregator: $1,197.6m across 12 chains (api.llama.fi/protocols, 2026-08-04). Also $19.06m DEX volume 24h.",
    "residue": 5,
    "forced": [
      "Ve",
      "Ft",
      "Fd"
    ],
    "orderKnown": true
  },
  {
    "name": "Spark Savings (sUSDS / Sky Savings Rate)",
    "category": "Yield / vaults / aggregators",
    "syms": [
      "Gp",
      "Ix",
      "Ps",
      "Rd",
      "Sh",
      "Sr",
      "Tg",
      "Up",
      "Xf"
    ],
    "rank": "#2 by TVL: $1,132.5m across 8 chains (api.llama.fi/protocols, 2026-08-04).",
    "residue": 4,
    "forced": [
      "Ps",
      "Fd"
    ],
    "orderKnown": true
  },
  {
    "name": "Convex Finance",
    "category": "Yield / vaults / aggregators",
    "syms": [
      "Em",
      "Ep",
      "Gp",
      "Ix",
      "Sh",
      "Tg",
      "Up"
    ],
    "rank": "#3 by TVL: $456.4m across 4 chains (api.llama.fi/protocols, 2026-08-04).",
    "residue": 4,
    "forced": [
      "Ve",
      "Ep",
      "Fd"
    ],
    "orderKnown": true
  },
  {
    "name": "CIAN Yield Layer",
    "category": "Yield / vaults / aggregators",
    "syms": [
      "Ct",
      "Em",
      "Ex",
      "Fl",
      "Gp",
      "Ix",
      "Sh",
      "Up",
      "Wq"
    ],
    "rank": "#4 by TVL: $244.5m across 7 chains (api.llama.fi/protocols, 2026-08-04). Largest pure 'Yield Aggregator'-classified protocol.",
    "residue": 4,
    "forced": [
      "Ct",
      "Dp"
    ],
    "orderKnown": true
  },
  {
    "name": "Huma Finance V2",
    "category": "Yield / vaults / aggregators",
    "syms": [
      "At",
      "Aw",
      "Bs",
      "Ep",
      "Ft",
      "Ix",
      "Sh",
      "Tr",
      "Uc",
      "Wq"
    ],
    "rank": "#5 by TVL: $219.3m on Solana (api.llama.fi/protocols, 2026-08-04).",
    "residue": 4,
    "forced": [
      "At",
      "Bs",
      "Sv",
      "Ft"
    ],
    "orderKnown": true
  },
  {
    "name": "Yearn Finance",
    "category": "Yield / vaults / aggregators",
    "syms": [
      "Em",
      "Gp",
      "Ix",
      "Sh",
      "Sr",
      "Tg",
      "Up",
      "Wq"
    ],
    "rank": "OUTSIDE the top 5 (#6 by TVL in Yield + Yield Aggregator: $176.2m across 7 chains, api.llama.fi/protocols, 2026-08-04). Included because the brief names it and because it is the canonical test of whether a strategy is an element.",
    "residue": 4,
    "forced": [
      "Sr",
      "Wq"
    ],
    "orderKnown": true
  },
  {
    "name": "Beefy",
    "category": "Yield / vaults / aggregators",
    "syms": [
      "Em",
      "Gp",
      "Ix",
      "Sh",
      "Up"
    ],
    "rank": "OUTSIDE the top 5 (#9 by TVL in Yield + Yield Aggregator: $104.2m across 40 chains, api.llama.fi/protocols, 2026-08-04). Included as the second strategy-aggregator control named in the brief.",
    "residue": 4,
    "forced": [],
    "orderKnown": true
  },
  {
    "name": "Steakhouse Financial",
    "category": "Yield / vaults / aggregators",
    "syms": [
      "Ct",
      "Ex",
      "Gp",
      "Im",
      "Ix",
      "Sh",
      "Tg",
      "Up"
    ],
    "rank": "OUTSIDE the two Yield categories and OUTSIDE the top 5 as ranked, but the LARGEST vault operator in DeFi by TVL at $3,084.0m across 10 chains (DefiLlama files it under 'Risk Curators', a category holding $8.76b total; api.llama.fi/protocols, 2026-08-04). Included because excluding it would have hidden the category's real answer: the biggest 'vaults' in DeFi are curated Morpho/Euler vaults, and DefiLlama does not classify them as yield products.",
    "residue": 4,
    "forced": [
      "Im",
      "Ct",
      "Tg"
    ],
    "orderKnown": true
  },
  {
    "name": "WBTC",
    "category": "Bridges / cross-domain",
    "syms": [
      "At",
      "Aw",
      "Gp",
      "Rd",
      "Tg",
      "Xf"
    ],
    "rank": "#1 in DefiLlama's 'Bridge' category by TVL: $7,300.5m (api.llama.fi/protocols, 2026-08-04).",
    "residue": 4,
    "forced": [
      "Rd",
      "Fz"
    ],
    "orderKnown": true
  },
  {
    "name": "LayerZero V2",
    "category": "Bridges / cross-domain",
    "syms": [
      "Gp",
      "Tg",
      "Up",
      "Xf",
      "Xm"
    ],
    "rank": "#2 in 'Bridge' by TVL: $6,666.7m across 60 chains (api.llama.fi/protocols, 2026-08-04). Largest general messaging layer.",
    "residue": 4,
    "forced": [
      "Xm",
      "Gs"
    ],
    "orderKnown": true
  },
  {
    "name": "Coinbase Bridge (cbBTC and other wrapped assets)",
    "category": "Bridges / cross-domain",
    "syms": [
      "At",
      "Aw",
      "Gp",
      "Rd",
      "Up",
      "Xf"
    ],
    "rank": "#3 in 'Bridge' by TVL: $6,150.9m, wrapping assets from Bitcoin, XRP, Doge, Cardano and Litecoin (api.llama.fi/protocols, 2026-08-04). DefiLlama description: 'Wrapped tokens backed 1:1 by assets held by Coinbase.'",
    "residue": 3,
    "forced": [
      "Rd",
      "Fz",
      "At"
    ],
    "orderKnown": true
  },
  {
    "name": "Hyperliquid Bridge",
    "category": "Bridges / cross-domain",
    "syms": [
      "Bs",
      "Gp",
      "Vl",
      "Wq",
      "Xf",
      "Xm"
    ],
    "rank": "#4 in 'Bridge' by TVL: $5,893.6m between Hyperliquid L1 and Arbitrum (api.llama.fi/protocols, 2026-08-04).",
    "residue": 4,
    "forced": [
      "Wq",
      "Bs",
      "Vl"
    ],
    "orderKnown": true
  },
  {
    "name": "Binance Bitcoin (BTCB)",
    "category": "Bridges / cross-domain",
    "syms": [
      "At",
      "Aw",
      "Gp",
      "Rd",
      "Xf"
    ],
    "rank": "#5 in 'Bridge' by TVL: $4,363.3m (api.llama.fi/protocols, 2026-08-04).",
    "residue": 2,
    "forced": [
      "Rd",
      "Fz"
    ],
    "orderKnown": true
  },
  {
    "name": "Circle CCTP",
    "category": "Bridges / cross-domain",
    "syms": [
      "Aw",
      "Xf",
      "Xm"
    ],
    "rank": "OUTSIDE the TVL top 5 and structurally UNRANKABLE by TVL — DefiLlama reports $0.0m locked, because burn-and-mint locks nothing. Included deliberately: the brief asks whether 'Xf'/'Xm' separates CCTP from a lock-mint bridge, and a TVL-ranked list would never surface it. Circle Gateway, the related instant-liquidity product, holds $56.8m (api.llama.fi/protocols, 2026-08-04).",
    "residue": 4,
    "forced": [
      "Xm",
      "Aw"
    ],
    "orderKnown": true
  },
  {
    "name": "Across",
    "category": "Bridges / cross-domain",
    "syms": [
      "In",
      "Ix",
      "Oa",
      "Of",
      "Pl",
      "Sh",
      "Xf",
      "Xm"
    ],
    "rank": "OUTSIDE the TVL top 5 (#4 in DefiLlama's separate 'Cross Chain Bridge' category at $17.3m, api.llama.fi/protocols, 2026-08-04 — roughly 400x smaller than WBTC). Included because the brief names it and because it is the one bridge in this lane the vocabulary handles well.",
    "residue": 4,
    "forced": [
      "Pl",
      "Of",
      "Xm"
    ],
    "orderKnown": true
  },
  {
    "name": "LiquidMesh",
    "category": "Intents / aggregation / order flow",
    "syms": [
      "Ag"
    ],
    "rank": "#1 by DEX-aggregator volume: $657.73m 24h, $5.302b 7d, $13.426b 30d across 6 chains (DefiLlama /dex-aggregators, 2026-08-04).",
    "residue": 5,
    "forced": [],
    "orderKnown": true
  },
  {
    "name": "Binance Wallet",
    "category": "Intents / aggregation / order flow",
    "syms": [
      "Ag",
      "Rf"
    ],
    "rank": "#2 by DEX-aggregator volume: $623.02m 24h, $5.133b 7d, $12.511b 30d across 12 chains (DefiLlama /dex-aggregators, 2026-08-04).",
    "residue": 4,
    "forced": [
      "Rf",
      "Gs"
    ],
    "orderKnown": false
  },
  {
    "name": "OKX DEX",
    "category": "Intents / aggregation / order flow",
    "syms": [
      "Ag",
      "Rf"
    ],
    "rank": "#3 by DEX-aggregator volume: $461.89m 24h, $1.876b 7d, $6.785b 30d across 35 chains (DefiLlama /dex-aggregators, 2026-08-04).",
    "residue": 3,
    "forced": [
      "Rf",
      "Gs"
    ],
    "orderKnown": false
  },
  {
    "name": "Jupiter",
    "category": "Intents / aggregation / order flow",
    "syms": [
      "Ag",
      "In",
      "Rf"
    ],
    "rank": "#4 by DEX-aggregator volume: $371.99m 24h, $2.685b 7d, $15.163b 30d on Solana (DefiLlama /dex-aggregators, 2026-08-04). Highest 30d volume in the category.",
    "residue": 4,
    "forced": [
      "In"
    ],
    "orderKnown": true
  },
  {
    "name": "KyberSwap",
    "category": "Intents / aggregation / order flow",
    "syms": [
      "Ag"
    ],
    "rank": "#5 by DEX-aggregator volume: $206.22m 24h, $1.333b 7d, $5.367b 30d across 24 chains (DefiLlama /dex-aggregators, 2026-08-04).",
    "residue": 3,
    "forced": [],
    "orderKnown": true
  },
  {
    "name": "DFlow",
    "category": "Intents / aggregation / order flow",
    "syms": [
      "Ag",
      "Aw",
      "Rf"
    ],
    "rank": "OUTSIDE the top 5 (#6 by DEX-aggregator volume: $171.87m 24h, $876.84m 7d, $3.55b 30d on Solana, DefiLlama /dex-aggregators, 2026-08-04). Included because it is the only protocol in the category whose explicit product is the SALE of order flow, which is the gap the top three reveal.",
    "residue": 4,
    "forced": [
      "Aw"
    ],
    "orderKnown": true
  },
  {
    "name": "1inch",
    "category": "Intents / aggregation / order flow",
    "syms": [
      "Ag",
      "In",
      "Rf"
    ],
    "rank": "OUTSIDE the top 5 (#8 by DEX-aggregator volume: $83.23m 24h, $614.54m 7d, $2.388b 30d across 14 chains, DefiLlama /dex-aggregators, 2026-08-04). Included because the brief names it as a canonical intent system.",
    "residue": 4,
    "forced": [
      "Da",
      "Rl",
      "Gs"
    ],
    "orderKnown": true
  },
  {
    "name": "CoW Swap",
    "category": "Intents / aggregation / order flow",
    "syms": [
      "Ag",
      "Ba",
      "Bs",
      "Em",
      "Fl",
      "In",
      "Rf"
    ],
    "rank": "OUTSIDE the top 5 (#9 by DEX-aggregator volume: $58.51m 24h, $597.65m 7d, $2.479b 30d across 8 chains, DefiLlama /dex-aggregators, 2026-08-04). Included because the brief names it and because it is the only true batch-auction system in the category.",
    "residue": 4,
    "forced": [
      "Bs",
      "Em"
    ],
    "orderKnown": true
  },
  {
    "name": "Ondo Finance (USDY + OUSG + Global Markets)",
    "category": "RWA / tokenised treasuries & private credit",
    "syms": [
      "At",
      "Aw",
      "Ex",
      "Fz",
      "Gp",
      "Ix",
      "Rb",
      "Rd",
      "Sh",
      "Tg",
      "Tr",
      "Up",
      "Xf",
      "Xm"
    ],
    "rank": "DefiLlama parent#ondo-finance $3.47B TVL 2026-08-04 (Ondo Yield Assets $2.53B + Ondo Global Markets $0.95B); rwa.xyz lists USDY alone at $2.15B, #3 tokenized treasury",
    "residue": 7,
    "forced": [
      "Ix",
      "Rb",
      "Tr"
    ],
    "orderKnown": true
  },
  {
    "name": "Circle USYC (Hashnote International Short Duration Yield Fund Ltd.)",
    "category": "RWA / tokenised treasuries & private credit",
    "syms": [
      "At",
      "Aw",
      "Ex",
      "Fz",
      "Gp",
      "Rd",
      "Sh",
      "Up"
    ],
    "rank": "rwa.xyz $3.01B, #1 tokenized treasury 2026-08-04; DefiLlama RWA $3.005B; DefiLlama stablecoins $3.005B circulating",
    "residue": 7,
    "forced": [
      "Sh",
      "Ex",
      "Fz"
    ],
    "orderKnown": true
  },
  {
    "name": "BlackRock BUIDL (BlackRock USD Institutional Digital Liquidity Fund, via Securitize)",
    "category": "RWA / tokenised treasuries & private credit",
    "syms": [
      "At",
      "Aw",
      "Fz",
      "Gp",
      "Ps",
      "Rd",
      "Sh",
      "Up",
      "Xf",
      "Xm"
    ],
    "rank": "rwa.xyz $2.67B, #2 tokenized treasury 2026-08-04; DefiLlama stablecoins $2.687B; DefiLlama's RWA row shows $3.49B (adapter counts wrapped/feeder positions — discrepancy noted, rwa.xyz used)",
    "residue": 8,
    "forced": [
      "Ps",
      "Rd",
      "Fz"
    ],
    "orderKnown": true
  },
  {
    "name": "Maple Finance (syrupUSDC / syrupUSDT + institutional pools)",
    "category": "RWA / tokenised treasuries & private credit",
    "syms": [
      "Aw",
      "Bs",
      "Ct",
      "Em",
      "Fd",
      "Ft",
      "Gp",
      "Pl",
      "Sh",
      "Sv",
      "Tg",
      "Up",
      "Wq"
    ],
    "rank": "DefiLlama $2.263B TVL 2026-08-04 (categorized 'Lending'; largest on-chain private-credit venue by a wide margin — DefiLlama's own 'RWA Lending' category tops out at Aave Horizon $257M)",
    "residue": 7,
    "forced": [
      "Sv",
      "Ft",
      "Bs",
      "Fd"
    ],
    "orderKnown": true
  },
  {
    "name": "Centrifuge (Centrifuge Protocol V3)",
    "category": "RWA / tokenised treasuries & private credit",
    "syms": [
      "At",
      "Aw",
      "Ep",
      "Ex",
      "Gp",
      "Sh",
      "Sv",
      "Tg",
      "Tr",
      "Up",
      "Wq",
      "Xf",
      "Xm"
    ],
    "rank": "DefiLlama parent#centrifuge $1.629B TVL 2026-08-04 (largest tokenization protocol not operated by a single asset manager)",
    "residue": 6,
    "forced": [
      "Ex",
      "Sv",
      "Tr"
    ],
    "orderKnown": true
  },
  {
    "name": "Derive (formerly Lyra V2)",
    "category": "Options / structured products",
    "syms": [
      "Bs",
      "Ct",
      "Em",
      "Ex",
      "Gp",
      "Li",
      "Ob",
      "Op",
      "Pf",
      "Rf",
      "Sh",
      "Up",
      "Xf",
      "Xm"
    ],
    "rank": "DefiLlama options $31.19M notional/30d 2026-08-04 — 87% of the entire on-chain options category ($35.70M/30d total). Reported ~$294M weekly volume and >$1B OI in March 2026 on its own dashboards; the gap indicates DefiLlama undercounts, noted.",
    "residue": 6,
    "forced": [
      "Ob",
      "Op",
      "Bs"
    ],
    "orderKnown": false
  },
  {
    "name": "Rysk V12",
    "category": "Options / structured products",
    "syms": [
      "Ct",
      "Dp",
      "Em",
      "Ep",
      "Ex",
      "Gp",
      "Op",
      "Sh",
      "Up",
      "Wq"
    ],
    "rank": "DefiLlama $29.86M TVL 2026-08-04 — largest options-vault TVL by 8.7x; $1.21M notional/30d (#3 by volume)",
    "residue": 5,
    "forced": [
      "Dp",
      "Ep"
    ],
    "orderKnown": true
  },
  {
    "name": "Hegic",
    "category": "Options / structured products",
    "syms": [
      "Ex",
      "Gp",
      "Op",
      "Sh",
      "Up"
    ],
    "rank": "DefiLlama $9.00M TVL 2026-08-04 — largest TVL in the pure 'Options' category; $0.01M notional/30d (functionally dormant by volume, noted)",
    "residue": 5,
    "forced": [
      "Sh",
      "Op"
    ],
    "orderKnown": true
  },
  {
    "name": "Aevo (Ribbon Finance lineage)",
    "category": "Options / structured products",
    "syms": [
      "Ct",
      "Em",
      "Ex",
      "Gp",
      "Li",
      "Ob",
      "Op",
      "Pf",
      "Sh",
      "Up",
      "Xf",
      "Xm"
    ],
    "rank": "DefiLlama options $1.65M notional/30d 2026-08-04 (#2 by options volume)",
    "residue": 3,
    "forced": [
      "Ob",
      "Op"
    ],
    "orderKnown": false
  },
  {
    "name": "Panoptic V2",
    "category": "Options / structured products",
    "syms": [
      "Cl",
      "Ct",
      "Gp",
      "Li",
      "Op",
      "Pl",
      "Sh",
      "Sr",
      "Up"
    ],
    "rank": "DefiLlama $2.05M TVL 2026-08-04 (#3 in the 'Options' category by TVL)",
    "residue": 4,
    "forced": [
      "Op",
      "Pl"
    ],
    "orderKnown": true
  },
  {
    "name": "Tether USDT",
    "category": "Reserve-backed / fiat stablecoin issuers",
    "syms": [
      "At",
      "Fz",
      "Ps",
      "Rd",
      "Up"
    ],
    "rank": "DefiLlama stablecoins $183.04B circulating 2026-08-04 (#1, 2.5x the #2)",
    "residue": 8,
    "forced": [
      "Ps",
      "Rd",
      "Fz"
    ],
    "orderKnown": false
  },
  {
    "name": "Circle USDC",
    "category": "Reserve-backed / fiat stablecoin issuers",
    "syms": [
      "At",
      "Aw",
      "Fz",
      "Gp",
      "Ps",
      "Rd",
      "Up",
      "Xf",
      "Xm"
    ],
    "rank": "DefiLlama stablecoins $72.20B circulating 2026-08-04 (#2)",
    "residue": 5,
    "forced": [
      "Ps",
      "Aw",
      "Fz"
    ],
    "orderKnown": false
  },
  {
    "name": "World Liberty Financial USD1",
    "category": "Reserve-backed / fiat stablecoin issuers",
    "syms": [
      "At",
      "Fz",
      "Ps",
      "Rd",
      "Up"
    ],
    "rank": "DefiLlama stablecoins $4.00B circulating 2026-08-04 (#3 among fiat-backed; #5 among all stablecoins)",
    "residue": 4,
    "forced": [
      "Ps",
      "Rd",
      "Fz"
    ],
    "orderKnown": false
  },
  {
    "name": "Global Dollar USDG (Paxos / Global Dollar Network)",
    "category": "Reserve-backed / fiat stablecoin issuers",
    "syms": [
      "At",
      "Fd",
      "Fz",
      "Ps",
      "Rd",
      "Up"
    ],
    "rank": "DefiLlama stablecoins $3.42B circulating 2026-08-04 (#4 among fiat-backed)",
    "residue": 4,
    "forced": [
      "Ps",
      "Fd",
      "Fz"
    ],
    "orderKnown": false
  },
  {
    "name": "PayPal USD (PYUSD)",
    "category": "Reserve-backed / fiat stablecoin issuers",
    "syms": [
      "At",
      "Fz",
      "Ps",
      "Rd",
      "Up",
      "Xf",
      "Xm"
    ],
    "rank": "DefiLlama stablecoins $2.68B circulating 2026-08-04 (#5 among fiat-backed)",
    "residue": 4,
    "forced": [
      "Ps",
      "Xm",
      "Fz"
    ],
    "orderKnown": false
  },
  {
    "name": "Kalshi",
    "category": "Prediction markets & other (uncategorized large protocols)",
    "syms": [
      "Aw",
      "Ct",
      "Rd"
    ],
    "rank": "DefiLlama $10.89B volume/30d 2026-08-04 — #1 prediction market by 3.5x, and larger by volume than any other protocol in my entire lane except the stablecoins",
    "residue": 6,
    "forced": [
      "Rd",
      "Ct",
      "Aw"
    ],
    "orderKnown": false
  },
  {
    "name": "Polymarket",
    "category": "Prediction markets & other (uncategorized large protocols)",
    "syms": [
      "Au",
      "Aw",
      "Gp",
      "Gs",
      "Oa",
      "Ob",
      "Rd",
      "Up"
    ],
    "rank": "DefiLlama $3.14B volume/30d and $330.8M TVL 2026-08-04 — #1 on-chain prediction market, ~85% of on-chain prediction-market TVL",
    "residue": 6,
    "forced": [
      "Ob",
      "Oa",
      "Gs",
      "Au"
    ],
    "orderKnown": true
  },
  {
    "name": "Azuro",
    "category": "Prediction markets & other (uncategorized large protocols)",
    "syms": [
      "Em",
      "Ex",
      "Gp",
      "Rd",
      "Rl",
      "Sh",
      "Sv",
      "Up"
    ],
    "rank": "DefiLlama $1.59M TVL 2026-08-04 — largest peer-to-pool (non-order-book) prediction/betting protocol; architecturally distinct from the Polymarket clones above it by volume",
    "residue": 4,
    "forced": [
      "Rl",
      "Sv",
      "Ex"
    ],
    "orderKnown": true
  },
  {
    "name": "Steakhouse Financial (Risk Curators)",
    "category": "Prediction markets & other (uncategorized large protocols)",
    "syms": [
      "Ct",
      "Fd",
      "Gp",
      "Im",
      "Sh",
      "Tg",
      "Wq"
    ],
    "rank": "DefiLlama $3.08B TVL 2026-08-04 — #1 in the 'Risk Curators' category ($8.76B total, DefiLlama's #9 category overall). Included as a large protocol that fits no conventional DeFi category.",
    "residue": 5,
    "forced": [
      "Im",
      "Ct",
      "Fd"
    ],
    "orderKnown": true
  },
  {
    "name": "Grove Finance (Onchain Capital Allocator)",
    "category": "Prediction markets & other (uncategorized large protocols)",
    "syms": [
      "At",
      "Aw",
      "Gp",
      "Sh",
      "Tg",
      "Xf"
    ],
    "rank": "DefiLlama $2.43B TVL 2026-08-04 — #1 in the 'Onchain Capital Allocator' category ($7.74B total, DefiLlama's #12 category). Included as a large protocol that fits no conventional DeFi category.",
    "residue": 4,
    "forced": [
      "At",
      "Xf"
    ],
    "orderKnown": true
  }
];

/** Distinct protocols that decompose to the IDENTICAL element set.
 *  This is the spine of the argument: same parts, different protocol. */
export const COLLISIONS: Collision[] = [
  {
    "syms": [
      "Ag"
    ],
    "members": [
      "LiquidMesh",
      "KyberSwap"
    ],
    "categories": [
      "Intents / aggregation / order flow"
    ]
  },
  {
    "syms": [
      "Ag",
      "Rf"
    ],
    "members": [
      "Binance Wallet",
      "OKX DEX"
    ],
    "categories": [
      "Intents / aggregation / order flow"
    ]
  },
  {
    "syms": [
      "Ag",
      "In",
      "Rf"
    ],
    "members": [
      "Jupiter",
      "1inch"
    ],
    "categories": [
      "Intents / aggregation / order flow"
    ]
  },
  {
    "syms": [
      "At",
      "Fz",
      "Ps",
      "Rd",
      "Up"
    ],
    "members": [
      "Tether USDT",
      "World Liberty Financial USD1"
    ],
    "categories": [
      "Reserve-backed / fiat stablecoin issuers"
    ]
  }
];

/** Strict containment - one protocol's elements are a proper subset of another's. */
export const SUBSETS = [
  {
    "inner": "Raydium",
    "outer": "PancakeSwap",
    "gap": 2
  },
  {
    "inner": "SparkLend",
    "outer": "Aave V3",
    "gap": 5
  },
  {
    "inner": "JustLend V1",
    "outer": "Maple",
    "gap": 7
  },
  {
    "inner": "Compound V3",
    "outer": "Aave V3",
    "gap": 5
  },
  {
    "inner": "USDD",
    "outer": "Sky (Sky Lending, ex-MakerDAO)",
    "gap": 1
  },
  {
    "inner": "Lista CDP",
    "outer": "Sky (Sky Lending, ex-MakerDAO)",
    "gap": 3
  },
  {
    "inner": "Lista CDP",
    "outer": "USDD",
    "gap": 2
  },
  {
    "inner": "Binance staked ETH (WBETH)",
    "outer": "Ethena (USDe / sUSDe)",
    "gap": 11
  },
  {
    "inner": "Binance staked ETH (WBETH)",
    "outer": "Ondo Finance (USDY + OUSG + Global Markets)",
    "gap": 9
  },
  {
    "inner": "edgeX",
    "outer": "Derive (formerly Lyra V2)",
    "gap": 2
  },
  {
    "inner": "Jupiter Perpetual Exchange",
    "outer": "GMX V2 Perps",
    "gap": 5
  },
  {
    "inner": "Beefy",
    "outer": "JustLend V1",
    "gap": 4
  },
  {
    "inner": "Beefy",
    "outer": "Maple",
    "gap": 11
  },
  {
    "inner": "Beefy",
    "outer": "Ethena (USDe / sUSDe)",
    "gap": 11
  },
  {
    "inner": "Beefy",
    "outer": "Convex Finance",
    "gap": 2
  },
  {
    "inner": "Beefy",
    "outer": "CIAN Yield Layer",
    "gap": 4
  },
  {
    "inner": "Beefy",
    "outer": "Yearn Finance",
    "gap": 3
  },
  {
    "inner": "WBTC",
    "outer": "Ethena (USDe / sUSDe)",
    "gap": 10
  },
  {
    "inner": "WBTC",
    "outer": "Ondo Finance (USDY + OUSG + Global Markets)",
    "gap": 8
  },
  {
    "inner": "LayerZero V2",
    "outer": "Ondo Finance (USDY + OUSG + Global Markets)",
    "gap": 9
  },
  {
    "inner": "LayerZero V2",
    "outer": "Centrifuge (Centrifuge Protocol V3)",
    "gap": 8
  },
  {
    "inner": "Coinbase Bridge (cbBTC and other wrapped assets)",
    "outer": "Ethena (USDe / sUSDe)",
    "gap": 10
  },
  {
    "inner": "Coinbase Bridge (cbBTC and other wrapped assets)",
    "outer": "Ondo Finance (USDY + OUSG + Global Markets)",
    "gap": 8
  },
  {
    "inner": "Coinbase Bridge (cbBTC and other wrapped assets)",
    "outer": "BlackRock BUIDL (BlackRock USD Institutional Digital Liquidity Fund, via Securitize)",
    "gap": 4
  },
  {
    "inner": "Coinbase Bridge (cbBTC and other wrapped assets)",
    "outer": "Circle USDC",
    "gap": 3
  },
  {
    "inner": "Hyperliquid Bridge",
    "outer": "Hyperliquid",
    "gap": 8
  },
  {
    "inner": "Binance Bitcoin (BTCB)",
    "outer": "Ethena (USDe / sUSDe)",
    "gap": 11
  },
  {
    "inner": "Binance Bitcoin (BTCB)",
    "outer": "WBTC",
    "gap": 1
  },
  {
    "inner": "Binance Bitcoin (BTCB)",
    "outer": "Coinbase Bridge (cbBTC and other wrapped assets)",
    "gap": 1
  },
  {
    "inner": "Binance Bitcoin (BTCB)",
    "outer": "Ondo Finance (USDY + OUSG + Global Markets)",
    "gap": 9
  },
  {
    "inner": "Binance Bitcoin (BTCB)",
    "outer": "BlackRock BUIDL (BlackRock USD Institutional Digital Liquidity Fund, via Securitize)",
    "gap": 5
  },
  {
    "inner": "Binance Bitcoin (BTCB)",
    "outer": "Circle USDC",
    "gap": 4
  },
  {
    "inner": "Circle CCTP",
    "outer": "Ondo Finance (USDY + OUSG + Global Markets)",
    "gap": 11
  },
  {
    "inner": "Circle CCTP",
    "outer": "BlackRock BUIDL (BlackRock USD Institutional Digital Liquidity Fund, via Securitize)",
    "gap": 7
  },
  {
    "inner": "Circle CCTP",
    "outer": "Centrifuge (Centrifuge Protocol V3)",
    "gap": 10
  },
  {
    "inner": "Circle CCTP",
    "outer": "Circle USDC",
    "gap": 6
  },
  {
    "inner": "LiquidMesh",
    "outer": "Curve",
    "gap": 7
  },
  {
    "inner": "LiquidMesh",
    "outer": "Binance Wallet",
    "gap": 1
  },
  {
    "inner": "LiquidMesh",
    "outer": "OKX DEX",
    "gap": 1
  },
  {
    "inner": "LiquidMesh",
    "outer": "Jupiter",
    "gap": 2
  }
];

export const CATEGORIES = [
  "Spot DEX / AMM",
  "Lending",
  "CDP / collateral-backed stablecoins",
  "Liquid staking & restaking",
  "Perpetuals / derivatives",
  "Yield / vaults / aggregators",
  "Bridges / cross-domain",
  "Intents / aggregation / order flow",
  "RWA / tokenised treasuries & private credit",
  "Options / structured products",
  "Reserve-backed / fiat stablecoin issuers",
  "Prediction markets & other (uncategorized large protocols)"
];
