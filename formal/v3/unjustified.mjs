/* Definition "Justified, minimal" allows an element to be carried for
 * admissibility while discharging no obligation. Council pass 2, finding 6,
 * turned on exactly that. The checker reports it per construction as
 * `unjustifiedElements` and nothing has ever aggregated it over the sixty.
 *
 * Two questions the paper should be able to answer and cannot yet:
 *   how often does a construction carry an element that discharges nothing?
 *   and are those elements load-bearing for admissibility, or just baggage?
 */
import fs from "node:fs";
import path from "node:path";
import { asSet, admissibility } from "/root/defiformal/formal/v3/construct.mjs";

const root = "/root/defiformal/expansion";
let apps = 0, withUnjust = 0, totalUnjust = 0;
const byElement = {}, rows = [];

for (const slug of fs.readdirSync(root).filter(d => /^\d\d-/.test(d))) {
  const vp = path.join(root, slug, "verdicts.json");
  if (!fs.existsSync(vp)) continue;
  for (const v of JSON.parse(fs.readFileSync(vp, "utf8"))) {
    apps++;
    const u = v.unjustifiedElements || [];
    if (!u.length) continue;
    withUnjust++; totalUnjust += u.length;
    for (const e of u) byElement[e] = (byElement[e] ?? 0) + 1;

    /* is each one load-bearing? drop it and see whether admissibility survives */
    const X = v.construction;
    const loadBearing = u.filter(e => !admissibility(asSet(X.filter(x => x !== e))).admissible);
    rows.push({ slug, app: v.app, unjust: u, loadBearing });
  }
}

console.log(`constructions: ${apps}`);
console.log(`carrying at least one element that discharges no obligation: ${withUnjust}`);
console.log(`such elements in total: ${totalUnjust}`);
console.log(`\nby element: ${Object.entries(byElement).sort((a,b)=>b[1]-a[1]).map(([e,c])=>`${e} ${c}`).join(", ") || "(none)"}`);

const bearing = rows.reduce((a, r) => a + r.loadBearing.length, 0);
console.log(`\nof those ${totalUnjust}, load-bearing for admissibility: ${bearing}`);
console.log(`carried and doing nothing at all:                  ${totalUnjust - bearing}`);

console.log(`\nper construction:`);
for (const r of rows)
  console.log(`  ${r.app.slice(0,38).padEnd(39)} carries ${r.unjust.join(",").padEnd(12)} of which load-bearing: ${r.loadBearing.join(",") || "none"}`);
