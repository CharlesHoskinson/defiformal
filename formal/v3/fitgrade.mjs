// fitgrade.mjs — grade every assignment by how well the element fits.
//
// Council findings 4 and 9, together: the checker verifies that a declared
// element exists and is present in the construction, never that the cited
// evidence supports it. Where the fit is poor the authoring convention already
// says so in the obligation text, in capitals. Those admissions were never
// counted, so the headline coverage figure weighs a forced fit exactly as much
// as an exact one.
//
// This counts them. It reports coverage as a band rather than a point: the
// upper end takes every assignment at face value, the lower end keeps only
// assignments carrying no self-declared qualification.
//
//   node formal/v3/fitgrade.mjs <expansion-root> [--json out.json]

import { readFileSync, writeFileSync, readdirSync, existsSync } from "node:fs";
import { join } from "node:path";

const root = process.argv[2];
if (!root) { console.error("usage: node fitgrade.mjs <expansion-root> [--json out]"); process.exit(2); }
const jsonAt = process.argv.indexOf("--json");

// The qualification rule is the paper's, not this script's. meas:covsens states
// 205 of 570 assigned rows and a 29.0% strict reading; that figure is produced
// by case-insensitive stem matching on approximat, forced and partial. An
// earlier version here matched five uppercase markers exactly, adding UNKNOWN
// and ABSENT and missing inflected forms, and reported 193 and 29.9% instead.
// Two scripts computing one quantity by two rules is the defect that took the
// law systems a whole review round to find, so this defers to the paper.
const QUAL_RE = /(approximat|forced|partial)/i;
const MARKERS = ["APPROXIMATE", "FORCED", "PARTIAL", "UNKNOWN", "ABSENT", "EXACT"];
const RE = new RegExp(`\\b(${MARKERS.join("|")})\\b`);

const lanes = readdirSync(root).filter(d => /^\d\d-/.test(d)).sort();
const perMarker = Object.fromEntries(MARKERS.map(m => [m, 0]));
const perLane = [];
let rows = 0, assigned = 0, qualified = 0, clean = 0;

for (const lane of lanes) {
  const dir = join(root, lane, "specs");
  if (!existsSync(dir)) continue;
  let lRows = 0, lAssigned = 0, lQual = 0;
  for (const f of readdirSync(dir).filter(f => f.endsWith(".json")).sort()) {
    const spec = JSON.parse(readFileSync(join(dir, f), "utf8"));
    for (const o of spec.functionalObligations ?? []) {
      rows++; lRows++;
      const els = o.elements ?? [];
      if (!els.length) continue;
      assigned++; lAssigned++;
      const text = ["text", "note", "notes", "rationale"].map(k => o[k] ?? "").join(" ");
      const found = new Set();
      let m; const re = new RegExp(RE.source, "g");
      while ((m = re.exec(text)) !== null) found.add(m[1]);
      for (const k of found) perMarker[k]++;
      const q = QUAL_RE.test(text);   // the paper's rule, not the marker set
      if (q) { qualified++; lQual++; } else clean++;
    }
  }
  perLane.push({ lane, rows: lRows, assigned: lAssigned, qualified: lQual,
                 clean: lAssigned - lQual });
}

const pc = (a, b) => (100 * a / b).toFixed(1);
console.log(`authored obligation rows          ${rows}`);
console.log(`rows carrying at least one element ${assigned}   (${pc(assigned, rows)}% — the headline figure)`);
console.log(`  of those, self-qualified         ${qualified}   (${pc(qualified, assigned)}% of assigned)`);
console.log(`  of those, unqualified            ${clean}   (${pc(clean, assigned)}% of assigned)`);
console.log();
console.log("markers, counted per row (a row may carry more than one):");
for (const k of MARKERS) {
  if (!perMarker[k]) continue;
  console.log(`  ${k.padEnd(12)} ${String(perMarker[k]).padStart(4)}   ${pc(perMarker[k], assigned)}% of assigned`);
}
console.log();
console.log(`COVERAGE BAND: ${pc(clean, rows)}% to ${pc(assigned, rows)}%`);
console.log("  upper: every assignment at face value");
console.log("  lower: only assignments whose text declares no qualification");
console.log();
console.log("by lane:");
console.log("lane".padEnd(22) + "rows  assigned  qualified   band");
for (const l of perLane) {
  console.log(l.lane.padEnd(22) + String(l.rows).padStart(4) +
    String(l.assigned).padStart(10) + String(l.qualified).padStart(11) +
    `   ${pc(l.clean, l.rows)}%–${pc(l.assigned, l.rows)}%`);
}

if (jsonAt > -1 && process.argv[jsonAt + 1]) {
  writeFileSync(process.argv[jsonAt + 1],
    JSON.stringify({ rows, assigned, qualified, clean, perMarker, perLane }, null, 2));
  console.log(`\nwrote ${process.argv[jsonAt + 1]}`);
}
