/* Council pass 2, finding 9: the 45.5% pools authored ledger rows, and the
 * lanes chose the granularity. Measure how much that choice can move it.
 *
 * Micro-average pools all rows. Macro-averages weight each application, or each
 * category, equally, which removes the effect of a lane writing more rows.
 * The spread between them is the sensitivity the figure has to atomisation.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
// Resolved from this file's own location; DEFIFORMAL_ROOT overrides and says so.
const SELF_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const REPO_ROOT = process.env.DEFIFORMAL_ROOT || SELF_ROOT;
if (REPO_ROOT !== SELF_ROOT) console.error(`${path.basename(fileURLToPath(import.meta.url))}: NOTE - reading ${REPO_ROOT} (DEFIFORMAL_ROOT), not ${SELF_ROOT}`);


const root = `${REPO_ROOT}/expansion`;
const apps = [], cats = [];
let tot = 0, cov = 0, approx = 0, assigned = 0;

for (const slug of fs.readdirSync(root).filter(d => /^\d\d-/.test(d))) {
  const vp = path.join(root, slug, "verdicts.json");
  if (!fs.existsSync(vp)) continue;
  const V = JSON.parse(fs.readFileSync(vp, "utf8"));
  let ct = 0, cc = 0;
  for (const v of V) {
    tot += v.obligationsTotal; cov += v.obligationsCovered;
    ct += v.obligationsTotal;  cc += v.obligationsCovered;
    apps.push({ app: v.app, slug, n: v.obligationsTotal, c: v.obligationsCovered,
                pct: 100 * v.obligationsCovered / v.obligationsTotal });
  }
  cats.push({ slug, n: ct, c: cc, pct: 100 * cc / ct });

  /* how many assigned rows the lanes themselves flagged as approximate */
  const sd = path.join(root, slug, "specs");
  for (const f of fs.readdirSync(sd).filter(f => f.endsWith(".json"))) {
    for (const o of JSON.parse(fs.readFileSync(path.join(sd, f), "utf8")).functionalObligations || []) {
      if (!(o.elements || []).length) continue;
      assigned++;
      if (/approx|loose|stretch|forced|imperfect|only partly|partial/i.test(o.note || "")) approx++;
    }
  }
}

const mean = a => a.reduce((x, y) => x + y, 0) / a.length;
const micro = 100 * cov / tot;
const macroApp = mean(apps.map(a => a.pct));
const macroCat = mean(cats.map(c => c.pct));

console.log(`micro-average, all ${tot} rows pooled:        ${micro.toFixed(1)}%`);
console.log(`macro-average over ${apps.length} applications:        ${macroApp.toFixed(1)}%`);
console.log(`macro-average over ${cats.length} categories:            ${macroCat.toFixed(1)}%`);
console.log(`spread between the three:                    ${(Math.max(micro, macroApp, macroCat) - Math.min(micro, macroApp, macroCat)).toFixed(1)} points`);

const ns = apps.map(a => a.n).sort((a, b) => a - b);
console.log(`\nrows per application: min ${ns[0]}, median ${ns[Math.floor(ns.length/2)]}, max ${ns[ns.length-1]}`);
console.log(`a lane writing at the finest rate recorded ${(ns[ns.length-1]/ns[0]).toFixed(2)}x the rows of the coarsest`);

console.log(`\nassigned rows: ${assigned}; flagged approximate in the lane's own note: ${approx} (${(100*approx/assigned).toFixed(1)}%)`);
console.log(`if every approximate assignment were counted as residue instead:`);
console.log(`  coverage would be ${(100 * (cov - approx) / tot).toFixed(1)}% rather than ${micro.toFixed(1)}%`);

console.log(`\nleast covered applications:`);
for (const a of apps.slice().sort((x, y) => x.pct - y.pct).slice(0, 5))
  console.log(`  ${a.pct.toFixed(1).padStart(5)}%  ${a.app} [${a.slug}]  ${a.c}/${a.n}`);
