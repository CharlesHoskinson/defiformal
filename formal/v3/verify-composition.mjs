// The third and last summary table, checked where its numbers are written.
//
// The predicates are pairs.mjs's, imported in the same shape rather than
// reimplemented: a pair of satisfying protocols fails if the union breaks the
// laws, the warrants, grounding, a conditional prohibition or a listed one.
import { readFileSync, readdirSync } from "node:fs";
import { PARSED_NEW, MECH, CONSUME, bansCond, ungrounded, armedListed }
  from "../v2/tables.mjs";
import path from "node:path";
import { fileURLToPath } from "node:url";
// Resolved from this file's own location; DEFIFORMAL_ROOT overrides and says so.
const SELF_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const REPO_ROOT = process.env.DEFIFORMAL_ROOT || SELF_ROOT;
if (REPO_ROOT !== SELF_ROOT) console.error(`${path.basename(fileURLToPath(import.meta.url))}: NOTE - reading ${REPO_ROOT} (DEFIFORMAL_ROOT), not ${SELF_ROOT}`);


const tex = readFileSync(`${REPO_ROOT}/paper/atlas.tex`, "utf8");
const E = MECH.slice();
const S2 = a => new Set((a ?? []).filter(e => E.includes(e)));
const sat = X => PARSED_NEW.every(l =>
  !l.subjects.some(s => X.has(s)) || l.terms.every(t => t.external || t.alts.some(a => X.has(a))));
const warranted = X => [...X].every(e => !CONSUME[e] || CONSUME[e].some(c => X.has(c)));

const P = [];
for (const f of readdirSync(`${REPO_ROOT}/corpus50/lanes`)) {
  const d = JSON.parse(readFileSync(`${REPO_ROOT}/corpus50/lanes/${f}`, "utf8"));
  for (const c of d.categories) for (const p of c.protocols)
    P.push({ name: p.name, cat: c.category, S: S2(p.elements) });
}
const ok = P.filter(p => sat(p.S) && warranted(p.S));

const fails = (A, B) => {
  const U = new Set([...A.S, ...B.S]);
  if (!sat(U) || !warranted(U) || ungrounded(U)) return true;
  const bc = bansCond(U); if (bc && bc.length) return true;
  const al = armedListed(U); if (al && al.length) return true;
  return false;
};

// incompatible-partner count per satisfying protocol
const partners = new Map(ok.map(p => [p.name, 0]));
let withinAll = new Map();
for (let i = 0; i < ok.length; i++)
  for (let j = i + 1; j < ok.length; j++) {
    if (!fails(ok[i], ok[j])) continue;
    partners.set(ok[i].name, partners.get(ok[i].name) + 1);
    partners.set(ok[j].name, partners.get(ok[j].name) + 1);
    if (ok[i].cat === ok[j].cat)
      withinAll.set(ok[i].cat, (withinAll.get(ok[i].cat) ?? 0) + 1);
  }

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

// scope to the composition table: the summary tables share row labels
const start = tex.indexOf("category & satisfying & incompatible partners & universal & within-category");
const end = tex.indexOf("label{tab:composition}", start);
if (start < 0 || end < 0) { console.log("  FAIL composition table not found"); process.exit(1); }
const block = tex.slice(start, end);

let fail = 0, cells = 0;
const say = (o, m) => { console.log(`  ${o ? "ok  " : "FAIL"} ${m}`); if (!o) fail++; };

console.log("composition table, read out of atlas.tex\n");
for (const [label, cat] of ROWS) {
  const re = new RegExp("^" + label.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") +
    "\\s*&\\s*(\\d+)/(\\d+)\\s*&\\s*(\\d+)--(\\d+)\\s*&\\s*(\\d+)\\s*&\\s*(\\d+)", "m");
  const m = block.match(re);
  if (!m) { say(false, `${label}: row not found`); continue; }
  const [, psat, ptot, plo, phi, puni, pwit] = m.map(Number);

  const mem = P.filter(p => p.cat === cat);
  const good = mem.filter(p => ok.includes(p));
  const counts = good.map(p => partners.get(p.name));
  const lo = counts.length ? Math.min(...counts) : 0;
  const hi = counts.length ? Math.max(...counts) : 0;
  const uni = counts.filter(c => c === 0).length;
  const wit = withinAll.get(cat) ?? 0;

  const bad = [];
  if (psat !== good.length || ptot !== mem.length)
    bad.push(`satisfying: paper ${psat}/${ptot}, corpus ${good.length}/${mem.length}`);
  if (plo !== lo || phi !== hi) bad.push(`partners: paper ${plo}--${phi}, corpus ${lo}--${hi}`);
  if (puni !== uni) bad.push(`universal: paper ${puni}, corpus ${uni}`);
  if (pwit !== wit) bad.push(`within-category: paper ${pwit}, corpus ${wit}`);
  cells += 4;
  say(bad.length === 0, `${label.padEnd(28)} ` +
      (bad.length ? bad.join("; ") : `${good.length}/${mem.length}  ${lo}--${hi}  ${uni}  ${wit}`));
}

console.log(`\ncells checked against the corpus: ${cells}`);
console.log(fail ? "COMPOSITION TABLE VIOLATED" : "COMPOSITION TABLE VERIFIED");
process.exit(fail ? 1 : 0);
