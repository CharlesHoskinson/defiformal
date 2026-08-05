// Stage-4 residue taxonomy.
// One hand-assigned group code per residue item, in the order the items appear
// in RESIDUE.json (which is the order of `node formal/v3/residue.mjs`).
// Every count in EXTENSIONS.md is computed from this file, not asserted.
import fs from 'node:fs';

const A = {
  // ---------------- 04-liquid-staking (48) ----------------
  'Babylon Protocol': ['INSTR','INSTR','CONSTR','INSTR','QUANT','TRUST','PARTY','CONSTR','INSTR','FLOW','CONSTR'],
  'Binance staked ETH (WBETH)': ['MANDATE','PARTY','LEGAL','LEGAL','LEGAL','LEGAL','QUANT','DOMAIN','LEGAL'],
  'EigenCloud (EigenLayer)': ['INSTR','PARTY','MANDATE','QUANT','PARTY','LOSS','LOSS','LEGAL','CONSTR'],
  'ether.fi (eETH / weETH)': ['QUANT','INSTR','INSTR','INSTR','INSTR','QUANT','PARTY','DOMAIN','MANDATE','FLOW','PARTY'],
  'Lido': ['PARTY','QUANT','PARTY','INSTR','INSTR','INSTR','LOSS','DOMAIN'],

  // ---------------- 05-perpetuals (47) ----------------
  'ApeX Protocol (ApeX Omni)': ['TRUST','TRUST','TRUST','TRUST','TRUST','DOMAIN','QUANT','LOSS','LEVEL','PARTY'],
  'Aster': ['TRUST','OPAQUE','TRUST','TRUST','TRUST','LEVEL','INSTR','QUANT','INSTR','PARTY','PARTY'],
  'edgeX': ['TRUST','TRUST','TRUST','TRUST','TRUST','TRUST','DOMAIN','PARTY','LOSS'],
  'Hyperliquid': ['TRUST','TRUST','TRUST','TRUST','TRUST','INSTR','LOSS','LEVEL','FLOW','QUANT'],
  'Lighter': ['TRUST','TRUST','TRUST','TRUST','TRUST','FLOW','DOMAIN'],

  // ---------------- 06-yield-vaults (51) ----------------
  'CIAN Yield Layer': ['MANDATE','QUANT','QUANT','LEVEL','QUANT','MANDATE','MANDATE','MANDATE','PARTY','FLOW'],
  'Convex Finance': ['LEVEL','INSTR','INSTR','INSTR','INSTR','LEVEL','LEVEL','FLOW','LEVEL','PARTY'],
  'Huma Finance V2': ['MANDATE','INSTR','FLOW','INSTR','QUANT','LEVEL','LEGAL','PARTY','QUANT','MANDATE','PARTY','LEGAL'],
  'Pendle': ['INSTR','INSTR','INSTR','INSTR','INSTR','FLOW','INSTR','MANDATE','LEVEL','MANDATE'],
  'Spark Savings (sUSDS / Sky Savings Rate)': ['LOSS','MANDATE','MANDATE','MANDATE','MANDATE','MANDATE','DOMAIN','MANDATE','MANDATE'],

  // ---------------- 07-bridges (61) ----------------
  'Binance Bitcoin (BTCB)': ['LEGAL','LEGAL','LEGAL','PARTY','LEGAL','PARTY','PARTY','LEGAL','DOMAIN','DOMAIN','LEGAL','PARTY'],
  'Coinbase Bridge (cbBTC and other wrapped assets)': ['LEGAL','DOMAIN','INSTR','LEGAL','OPAQUE','MANDATE','PARTY','PARTY','OPAQUE','PARTY','DOMAIN'],
  'Hyperliquid Bridge': ['TRUST','QUANT','INSTR','DOMAIN','DOMAIN','PARTY','PARTY','PARTY','LOSS','PARTY','PARTY','CONSTR'],
  'LayerZero V2': ['LEVEL','LEVEL','TRUST','PARTY','DOMAIN','LEVEL','PARTY','PARTY','PARTY','LEVEL','DOMAIN','LEVEL'],
  'WBTC': ['LEGAL','LEGAL','DOMAIN','LEGAL','PARTY','LEGAL','QUANT','PARTY','PARTY','PARTY','PARTY','PARTY','LEVEL','LEGAL'],

  // ---------------- 08-intents (72) ----------------
  'Binance Wallet': ['OPAQUE','OPAQUE','INSTR','FLOW','TRUST','OPAQUE','PARTY','PARTY','OPAQUE','OPAQUE','FLOW','FLOW','LEGAL','LEGAL','LEGAL','DOMAIN'],
  'Jupiter': ['LEVEL','INSTR','LEVEL','INSTR','INSTR','TRUST','OPAQUE','FLOW','FLOW','FLOW','PARTY','MANDATE','ADJUD','OPAQUE','LEVEL','PARTY'],
  'KyberSwap': ['LEVEL','INSTR','INSTR','TRUST','FLOW','LEVEL','FLOW','INSTR','FLOW','ADJUD','FLOW','PARTY','LEVEL','FLOW'],
  'LiquidMesh': ['OPAQUE','PARTY','INSTR','ADJUD','TRUST','LEGAL','FLOW','INSTR','FLOW','OPAQUE','CONSTR','ADJUD','INSTR','DOMAIN'],
  'OKX DEX': ['INSTR','INSTR','PARTY','PARTY','ADJUD','PARTY','FLOW','LEVEL','OPAQUE','OPAQUE','OPAQUE','PARTY'],

  // ---------------- 10-options (51) ----------------
  'Aevo (Ribbon Finance lineage)': ['INSTR','INSTR','INSTR','LOSS','LEVEL','QUANT','QUANT','LOSS','LOSS','OPAQUE','OPAQUE'],
  'Derive (formerly Lyra V2)': ['INSTR','INSTR','INSTR','QUANT','INSTR','TRUST','INSTR','QUANT','LOSS','INSTR'],
  'Hegic': ['INSTR','INSTR','INSTR','CONSTR','INSTR','MANDATE','INSTR','PARTY'],
  'Panoptic V2': ['INSTR','INSTR','INSTR','INSTR','QUANT','LOSS','INSTR','LEVEL','QUANT','DOMAIN'],
  'Rysk V12': ['INSTR','INSTR','INSTR','PARTY','INSTR','INSTR','CONSTR','CONSTR','CONSTR','INSTR','MANDATE','CONSTR'],

  // ---------------- 12-prediction (55) ----------------
  'Azuro': ['INSTR','INSTR','INSTR','INSTR','INSTR','QUANT','ADJUD','PARTY','INSTR','INSTR','FLOW','LOSS'],
  'Grove Finance (Onchain Capital Allocator)': ['LEVEL','LEVEL','INSTR','MANDATE','MANDATE','LEGAL','LEGAL','LEGAL','FLOW','LEVEL','LEGAL','PARTY'],
  'Kalshi': ['INSTR','INSTR','LEGAL','INSTR','INSTR','LOSS','LOSS','LOSS','ADJUD','ADJUD','ADJUD','LEGAL','LEGAL'],
  'Polymarket': ['INSTR','INSTR','LEGAL','ADJUD','INSTR','DOMAIN','LEGAL','ADJUD'],
  'Steakhouse Financial (Risk Curators)': ['MANDATE','MANDATE','MANDATE','INSTR','PARTY','PARTY','FLOW','LEGAL','ADJUD','ADJUD'],
};

const REPAIR = {
  PARTY:   'c',
  MANDATE: 'a',
  ADJUD:   'a',
  LEVEL:   'd',
  LEGAL:   'c',
  DOMAIN:  'c',
  CONSTR:  'b',
  TRUST:   'a',
  LOSS:    'a',
  INSTR:   'a',
  FLOW:    'c',
  QUANT:   'b',
  OPAQUE:  'b',
};

const d = JSON.parse(fs.readFileSync('C:/defiformal-work/RESIDUE.json', 'utf8'));
const cursor = {};
const tagged = [];
for (const r of d.residue) {
  const list = A[r.app];
  if (!list) throw new Error('no assignment block for app: ' + r.app);
  const i = (cursor[r.app] = (cursor[r.app] ?? -1) + 1);
  if (i >= list.length) throw new Error('assignment underflow for ' + r.app + ' at ' + i);
  tagged.push({ ...r, g: list[i] });
}
for (const [app, list] of Object.entries(A)) {
  const used = (cursor[app] ?? -1) + 1;
  if (used !== list.length) throw new Error(`assignment length mismatch ${app}: used ${used} of ${list.length}`);
}
if (tagged.length !== 385) throw new Error('expected 385, got ' + tagged.length);

const by = (f) => tagged.reduce((m, t) => (m[f(t)] = (m[f(t)] || 0) + 1, m), {});
const groups = {};
for (const t of tagged) {
  const g = (groups[t.g] ??= { n: 0, cats: new Set(), apps: new Set(), catN: {}, items: [] });
  g.n++; g.cats.add(t.category); g.apps.add(t.category + '/' + t.app);
  g.catN[t.category] = (g.catN[t.category] || 0) + 1;
  g.items.push(t);
}

const rows = Object.entries(groups).sort((a, b) => b[1].n - a[1].n);
console.log('=== GROUPS (n=' + tagged.length + ', ' + rows.length + ' groups) ===');
for (const [name, g] of rows) {
  console.log(`${name.padEnd(8)} n=${String(g.n).padStart(3)}  cats=${g.cats.size}  apps=${g.apps.size}  repair=${REPAIR[name]}  ` +
    Object.entries(g.catN).sort((a,b)=>b[1]-a[1]).map(([c,n])=>c.slice(0,2)+':'+n).join(' '));
}
console.log('\n=== REPAIR KIND DISTRIBUTION ===');
const rk = {};
for (const t of tagged) rk[REPAIR[t.g]] = (rk[REPAIR[t.g]] || 0) + 1;
for (const k of ['a','b','c','d']) console.log(`  (${k}) ${rk[k] || 0}  = ${((rk[k]||0)/385*100).toFixed(1)}%`);

console.log('\n=== PER-CATEGORY GROUP PROFILE ===');
const cats = [...new Set(tagged.map(t => t.category))].sort();
const gnames = rows.map(r => r[0]);
console.log('cat'.padEnd(20) + gnames.map(g => g.slice(0,6).padStart(7)).join(''));
for (const c of cats) {
  const line = gnames.map(g => String(tagged.filter(t => t.category === c && t.g === g).length).padStart(7)).join('');
  console.log(c.padEnd(20) + line);
}

fs.writeFileSync('C:/Users/charl/AppData/Local/Temp/claude/C--Users-charl/79bb0ef2-ea83-49e8-b036-bcc1cf8ffb4f/scratchpad/tagged.json',
  JSON.stringify(tagged, null, 1));
console.log('\nwrote tagged.json');
