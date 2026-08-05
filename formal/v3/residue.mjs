/* Aggregate the residue across every checked construction.
 *
 * Stage 4 asks what the formalism should become. Its input is not an opinion
 * about the vocabulary but the list of obligations that no element discharged,
 * with the application and category each came from. This collects them.
 *
 *   node residue.mjs <expansion-root>            # dirs holding verdicts.json
 *   node residue.mjs <expansion-root> --json out.json
 */
import fs from "node:fs";
import path from "node:path";

function collect(root) {
  const cats = [];
  for (const d of fs.readdirSync(root, { withFileTypes: true })) {
    if (!d.isDirectory()) continue;
    const vp = path.join(root, d.name, "verdicts.json");
    if (!fs.existsSync(vp)) { cats.push({ category: d.name, verdicts: null }); continue; }
    cats.push({ category: d.name, verdicts: JSON.parse(fs.readFileSync(vp, "utf8")) });
  }
  return cats;
}

function main() {
  const root = process.argv[2];
  if (!root) { console.error("usage: node residue.mjs <expansion-root> [--json out.json]"); process.exit(2); }
  const cats = collect(root);
  const rows = [], residue = [];
  let obligations = 0, covered = 0;
  const verdictCount = {};

  for (const c of cats) {
    if (!c.verdicts) { rows.push({ category: c.category, apps: 0, note: "no verdicts.json - stage 3 has not run" }); continue; }
    let o = 0, cv = 0, r = 0;
    for (const v of c.verdicts) {
      o += v.obligationsTotal; cv += v.obligationsCovered; r += v.obligationsUncovered.length;
      verdictCount[v.verdict] = (verdictCount[v.verdict] ?? 0) + 1;
      for (const u of v.obligationsUncovered)
        residue.push({ category: c.category, app: v.app, id: u.id, text: u.text, reason: u.reason });
    }
    obligations += o; covered += cv;
    rows.push({ category: c.category, apps: c.verdicts.length, obligations: o, covered: cv, residue: r,
      coverage: o ? +(100 * cv / o).toFixed(1) : null });
  }

  console.log("category                        apps  obligations  covered  residue  coverage");
  for (const r of rows) {
    if (r.note) { console.log(`${r.category.padEnd(30)}  ${r.note}`); continue; }
    console.log(`${r.category.padEnd(30)} ${String(r.apps).padStart(5)} ${String(r.obligations).padStart(12)} ${String(r.covered).padStart(8)} ${String(r.residue).padStart(8)} ${String(r.coverage).padStart(9)}%`);
  }
  console.log(`\ntotal: ${obligations} obligations, ${covered} covered, ${obligations - covered} residue` +
    (obligations ? `, coverage ${(100 * covered / obligations).toFixed(1)}%` : ""));
  console.log(`verdicts: ${Object.entries(verdictCount).map(([k, v]) => `${k} ${v}`).join(", ") || "(none)"}`);

  /* every residue item, so stage 4 groups from the record rather than from memory */
  console.log(`\n--- residue, ${residue.length} items`);
  for (const r of residue) console.log(`[${r.category}] ${r.app}: ${r.text}`);

  const i = process.argv.indexOf("--json");
  if (i > 0 && process.argv[i + 1]) {
    fs.writeFileSync(process.argv[i + 1], JSON.stringify({ rows, residue, totals: { obligations, covered, verdictCount } }, null, 2));
    console.log(`\nwrote ${process.argv[i + 1]}`);
  }
}
if (import.meta.url === `file://${process.argv[1]}`) main();
