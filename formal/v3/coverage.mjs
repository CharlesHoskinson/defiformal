/* Council finding 7: the paper asserts that the vocabulary's resolution is
 * inversely correlated with capital, and never measures it.
 *
 * The run now has an obligation-level coverage figure per category, which is a
 * far better resolution proxy than element counts. Capital is not in the corpus
 * as a number, but the ranking basis is, so what CAN be measured honestly is
 * coverage against category, and whether the categories the paper calls
 * capital-heavy are in fact the poorly covered ones.
 *
 *   node coverage.mjs <expansion-root>
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
// Resolved from this file's own location; DEFIFORMAL_ROOT overrides and says so.
const SELF_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const REPO_ROOT = process.env.DEFIFORMAL_ROOT || SELF_ROOT;
if (REPO_ROOT !== SELF_ROOT) console.error(`${path.basename(fileURLToPath(import.meta.url))}: NOTE - reading ${REPO_ROOT} (DEFIFORMAL_ROOT), not ${SELF_ROOT}`);


const root = process.argv[2] || `${REPO_ROOT}/expansion`;
const rows = [];
for (const slug of fs.readdirSync(root).filter(d => /^\d\d-/.test(d))) {
  const vp = path.join(root, slug, "verdicts.json");
  if (!fs.existsSync(vp)) continue;
  const V = JSON.parse(fs.readFileSync(vp, "utf8"));
  const tot = V.reduce((a, v) => a + v.obligationsTotal, 0);
  const cov = V.reduce((a, v) => a + v.obligationsCovered, 0);
  const els = new Set(V.flatMap(v => v.construction));
  rows.push({ slug, apps: V.length, tot, cov, pct: 100 * cov / tot, elements: els.size,
    perApp: +(els.size / V.length).toFixed(2) });
}
rows.sort((a, b) => a.pct - b.pct);

console.log("category                 apps  obligations  covered  coverage  distinct elements");
for (const r of rows)
  console.log(`${r.slug.padEnd(24)} ${String(r.apps).padStart(4)} ${String(r.tot).padStart(12)} ${String(r.cov).padStart(8)} ${(r.pct.toFixed(1) + "%").padStart(9)} ${String(r.elements).padStart(18)}`);

const tot = rows.reduce((a, r) => a + r.tot, 0), cov = rows.reduce((a, r) => a + r.cov, 0);
console.log(`\ntotal ${cov}/${tot} = ${(100 * cov / tot).toFixed(1)}%`);

/* Spearman rank correlation between coverage and footprint size, which is the
 * only pair of quantities both of which the corpus actually contains. */
const rank = (key) => {
  const s = [...rows].sort((a, b) => a[key] - b[key]);
  const m = new Map(); s.forEach((r, i) => m.set(r.slug, i + 1)); return m;
};
const rc = rank("pct"), re = rank("elements");
const n = rows.length;
const d2 = rows.reduce((a, r) => a + (rc.get(r.slug) - re.get(r.slug)) ** 2, 0);
const rho = 1 - (6 * d2) / (n * (n * n - 1));
console.log(`Spearman rho(coverage, distinct elements used) = ${rho.toFixed(3)} over ${n} categories`);
console.log(`  (a positive rho means categories the vocabulary covers well are also the ones`);
console.log(`   it spends more distinct symbols on -- resolution and coverage moving together)`);
