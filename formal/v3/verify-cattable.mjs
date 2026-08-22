// Round five's blocker 7, and the largest one left: the gates must fail on the
// manuscript errors they claim to detect.
//
// claims.mjs recomputes 109 claims from the corpus and never opens the paper, so
// altering a table cell in atlas.tex changes nothing it reports. A wrapper that
// asked whether each computed value appears somewhere in the paper was written
// and deleted: substring-matching small integers is meaningless.
//
// This runs the other way. It parses the category table OUT of atlas.tex, cell
// by cell, and checks each cell against the corpus. A number is checked where it
// is written, which is what "reproducible from a committed script" has to mean.
import { readFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
// Resolved from this file's own location; DEFIFORMAL_ROOT overrides and says so.
const SELF_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const REPO_ROOT = process.env.DEFIFORMAL_ROOT || SELF_ROOT;
if (REPO_ROOT !== SELF_ROOT) console.error(`${path.basename(fileURLToPath(import.meta.url))}: NOTE - reading ${REPO_ROOT} (DEFIFORMAL_ROOT), not ${SELF_ROOT}`);


const ROOT = `${REPO_ROOT}/expansion`;
const tex = readFileSync(`${REPO_ROOT}/paper/atlas.tex`, "utf8");

const ROWS = [
  ["Spot exchange", "01-spot-exchange"],
  ["Lending", "02-lending"],
  ["Collateralised-debt stablecoins", "03-cdp-stablecoins"],
  ["Liquid staking", "04-liquid-staking"],
  ["Perpetual futures", "05-perpetuals"],
  ["Yield vaults", "06-yield-vaults"],
  ["Bridges", "07-bridges"],
  ["Intents and aggregation", "08-intents"],
  ["Tokenised real-world assets", "09-rwa"],
  ["Options", "10-options"],
  ["Reserve-backed stablecoins", "11-fiat-stablecoins"],
  ["Prediction markets", "12-prediction"],
];

function lane(slug) {
  const v = JSON.parse(readFileSync(`${ROOT}/${slug}/verdicts.json`, "utf8"));
  const rows = Array.isArray(v) ? v : (v.verdicts ?? v.results ?? []);
  let ob = 0, cov = 0, inad = 0;
  const els = new Set();
  for (const r of rows) {
    // field names read off the schema, not guessed: obligationsTotal,
    // obligationsCovered, construction, verdict
    ob += r.obligationsTotal ?? 0;
    cov += r.obligationsCovered ?? 0;
    if (String(r.verdict).toUpperCase().includes("INADMISSIBLE")) inad++;
    for (const e of r.construction ?? []) els.add(e);
  }
  return { elements: els.size, obligations: ob, discharged: cov,
           residue: ob - cov, inadmissible: inad };
}

let fail = 0;
const say = (ok, m) => { console.log(`  ${ok ? "ok  " : "FAIL"} ${m}`); if (!ok) fail++; };

console.log("category table, cell by cell, read out of atlas.tex\n");
let cells = 0;
const tot = { obligations: 0, discharged: 0, residue: 0, inadmissible: 0 };

for (const [label, slug] of ROWS) {
  const re = new RegExp("^" + label.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") +
    "\\s*&\\s*(\\d+)\\s*&\\s*(\\d+)\\s*&\\s*(\\d+)\\s*&\\s*(\\d+)\\s*&\\s*(\\d+)", "m");
  const m = tex.match(re);
  if (!m) { say(false, `${label}: row not found in atlas.tex`); continue; }
  const [, el, ob, di, rs, ia] = m.map(Number);
  const c = lane(slug);
  const pairs = [["elements", el, c.elements], ["obligations", ob, c.obligations],
                 ["discharged", di, c.discharged], ["residue", rs, c.residue],
                 ["inadmissible", ia, c.inadmissible]];
  const bad = pairs.filter(p => p[1] !== p[2]);
  cells += pairs.length;
  say(bad.length === 0, `${label.padEnd(32)} ` +
      (bad.length ? bad.map(p => `${p[0]}: paper ${p[1]}, corpus ${p[2]}`).join("; ")
                  : `${el} ${ob} ${di} ${rs} ${ia}`));
  tot.obligations += c.obligations; tot.discharged += c.discharged;
  tot.residue += c.residue; tot.inadmissible += c.inadmissible;
}

const tm = tex.match(/^total\s*&\s*---\s*&\s*(\d+)\s*&\s*(\d+)\s*&\s*(\d+)\s*&\s*(\d+)/m);
if (!tm) say(false, "total row not found");
else {
  const [, ob, di, rs, ia] = tm.map(Number);
  cells += 4;
  say(ob === tot.obligations && di === tot.discharged &&
      rs === tot.residue && ia === tot.inadmissible,
      `total row  paper ${ob} ${di} ${rs} ${ia}  corpus ${tot.obligations} ${tot.discharged} ${tot.residue} ${tot.inadmissible}`);
}

console.log(`\ncells checked against the corpus: ${cells}`);
console.log(fail ? "CATEGORY TABLE VIOLATED" : "CATEGORY TABLE VERIFIED");
process.exit(fail ? 1 : 0);
