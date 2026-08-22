// Extending the location-checking pattern to the second summary table.
//
// verify-cattable.mjs checks the category table against the expansion verdicts.
// This table is about a different object: the 72 corpus decompositions, not the
// 60 exhibited constructions. Its footprint column is therefore not the category
// table's element column and the two must not be cross-checked.
import { readFileSync, readdirSync } from "node:fs";
import * as T from "../v2/tables.mjs";
import path from "node:path";
import { fileURLToPath } from "node:url";
// Resolved from this file's own location; DEFIFORMAL_ROOT overrides and says so.
const SELF_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const REPO_ROOT = process.env.DEFIFORMAL_ROOT || SELF_ROOT;
if (REPO_ROOT !== SELF_ROOT) console.error(`${path.basename(fileURLToPath(import.meta.url))}: NOTE - reading ${REPO_ROOT} (DEFIFORMAL_ROOT), not ${SELF_ROOT}`);

const VOCAB = new Set(T.MECH);   // the corpus carries symbols outside the 58, e.g. Ve

const tex = readFileSync(`${REPO_ROOT}/paper/atlas.tex`, "utf8");

const CORPUS = [];
for (const f of readdirSync(`${REPO_ROOT}/corpus50/lanes`)) {
  const d = JSON.parse(readFileSync(`${REPO_ROOT}/corpus50/lanes/${f}`, "utf8"));
  for (const c of d.categories)
    for (const p of c.protocols)
      CORPUS.push({ cat: c.category, syms: p.elements ?? [] });   // field read off the schema
}

// Explicit map. The two summary tables share row labels, so the search is also
// scoped to the footprints block below - an unanchored match reads the category
// table and reports differences that are not there.
const ROWS = [
  ["Spot exchange", "Spot DEX / AMM"],
  ["Lending", "Lending"],
  ["CDP stablecoins", "CDP / collateral-backed stablecoins"],
  ["Liquid staking", "Liquid staking & restaking"],
  ["Perpetual futures", "Perpetuals / derivatives"],
  ["Yield vaults", "Yield / vaults / aggregators"],
  ["Bridges", "Bridges / cross-domain"],
  ["Intents", "Intents / aggregation / order flow"],
  ["Real-world assets", "RWA / tokenised treasuries & private credit"],
  ["Options", "Options / structured products"],
  ["Reserve-backed stablecoins", "Reserve-backed / fiat stablecoin issuers"],
  ["Prediction markets", "Prediction markets & other (uncategorized large protocols)"],
];

// the footprints table only
const start = tex.indexOf("category & footprint & exclusive to it & in every member");
const end = tex.indexOf("label{tab:footprints}", start);
if (start < 0 || end < 0) { console.log("  FAIL footprints table not found"); process.exit(1); }
const block = tex.slice(start, end);

let fail = 0, cells = 0;
const say = (ok, m) => { console.log(`  ${ok ? "ok  " : "FAIL"} ${m}`); if (!ok) fail++; };

console.log("footprints table, read out of atlas.tex\n");
for (const [label, cat] of ROWS) {
  const re = new RegExp("^" + label.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") +
    "\\s*&\\s*(\\d+)\\s*&\\s*([^&]*?)\\s*&\\s*([^\\\\]*?)\\s*\\\\\\\\", "m");
  const m = block.match(re);
  if (!m) { say(false, `${label}: row not found`); continue; }
  const paperFoot = Number(m[1]);
  const mem = CORPUS.filter(p => p.cat === cat);
  // the footprint is over the VOCABULARY, not over every symbol the corpus
  // records: Ve appears in two categories and is not one of the 58.
  const foot = new Set(mem.flatMap(p => p.syms).filter(e => VOCAB.has(e)));
  const others = new Set(CORPUS.filter(p => p.cat !== cat).flatMap(p => p.syms).filter(e => VOCAB.has(e)));
  const excl = [...foot].filter(e => !others.has(e)).sort();
  const every = [...foot].filter(e => mem.every(p => p.syms.includes(e))).sort();

  const pe = (m[2].match(/[A-Z][a-z]/g) ?? []).sort();
  const pv = (m[3].match(/[A-Z][a-z]/g) ?? []).sort();
  const eq = (a, b) => a.length === b.length && a.every((x, i) => x === b[i]);

  const bad = [];
  if (paperFoot !== foot.size) bad.push(`footprint: paper ${paperFoot}, corpus ${foot.size}`);
  if (!eq(pe, excl)) bad.push(`exclusive: paper {${pe}}, corpus {${excl}}`);
  if (!eq(pv, every)) bad.push(`in every member: paper {${pv}}, corpus {${every}}`);
  cells += 3;
  say(bad.length === 0,
      `${label.padEnd(28)} ` + (bad.length ? bad.join("; ")
        : `${foot.size}  excl {${excl}}  all {${every}}`));
}

console.log(`\ncells checked against the corpus: ${cells}`);
console.log(fail ? "FOOTPRINTS TABLE VIOLATED" : "FOOTPRINTS TABLE VERIFIED");
process.exit(fail ? 1 : 0);
