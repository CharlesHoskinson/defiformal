/* Where do the 72 real protocols sit in the structure?
 *
 * The structure is: a complete lattice of Gamma/Delta-fixed sets, with a clutter
 * of forbidden sets removed. This asks the only question that matters about it --
 * do the 12 categories correspond to ANYTHING in that structure, or is category
 * a fact about the observer rather than the object?
 */
import { closesNew, gammaOpen, unwarranted, DeltaInf, armedListed, admissible, MECH } from "./tables.mjs";
import fs from "node:fs";

const CORPUS = [];
for (const f of fs.readdirSync("/root/DefiElements/corpus50/lanes")) {
  const d = JSON.parse(fs.readFileSync(`/root/DefiElements/corpus50/lanes/${f}`, "utf8"));
  for (const c of d.categories)
    for (const p of c.protocols)
      CORPUS.push({ name: p.name, cat: c.category, S: new Set(p.elements.filter(e => MECH.includes(e))) });
}

const rows = CORPUS.map(p => {
  const open = gammaOpen(p.S);
  const unw = unwarranted(p.S);
  const armed = armedListed(p.S);
  return {
    ...p, n: p.S.size,
    closed: open.length === 0, nOpen: open.length,
    warranted: unw.length === 0, nUnw: unw.length,
    hazard: armed.length > 0,
    adm: admissible(p.S),
  };
});

const pct = (n, d) => `${Math.round(100 * n / d)}%`;
console.log(`corpus: ${rows.length} protocols, ${new Set(rows.map(r => r.cat)).size} categories\n`);
console.log(`Gamma-closed:  ${rows.filter(r => r.closed).length}/${rows.length}  (${pct(rows.filter(r=>r.closed).length, rows.length)})`);
console.log(`warranted:     ${rows.filter(r => r.warranted).length}/${rows.length}  (${pct(rows.filter(r=>r.warranted).length, rows.length)})`);
console.log(`hazard-free:   ${rows.filter(r => !r.hazard).length}/${rows.length}`);
console.log(`ADMISSIBLE:    ${rows.filter(r => r.adm).length}/${rows.length}  (${pct(rows.filter(r=>r.adm).length, rows.length)})`);

// --- is category visible in the structure? ---
console.log("\n--- by category: does the structure separate them? ---");
const cats = [...new Set(rows.map(r => r.cat))];
console.log("category".padEnd(34), "n", "adm", "closed", "warr", "medSize");
for (const c of cats) {
  const g = rows.filter(r => r.cat === c);
  const sizes = g.map(r => r.n).sort((a, b) => a - b);
  console.log(
    c.slice(0, 33).padEnd(34),
    String(g.length).padStart(2),
    String(g.filter(r => r.adm).length).padStart(3),
    String(g.filter(r => r.closed).length).padStart(6),
    String(g.filter(r => r.warranted).length).padStart(4),
    String(sizes[Math.floor(sizes.length / 2)]).padStart(7),
  );
}

// --- the containment poset: is it within-category or across? ---
let within = 0, across = 0;
const pairs = [];
for (const a of rows) for (const b of rows) {
  if (a === b || a.n >= b.n) continue;
  if ([...a.S].every(e => b.S.has(e))) {
    pairs.push([a, b]);
    if (a.cat === b.cat) within++; else across++;
  }
}
console.log(`\ncontainment pairs: ${pairs.length}  within-category ${within}  ACROSS-category ${across}`);
console.log("across-category containments are the interesting ones - a protocol in one");
console.log("category whose mechanism set is a strict subset of one in another:");
for (const [a, b] of pairs.filter(([a, b]) => a.cat !== b.cat).slice(0, 8))
  console.log(`  ${a.name} (${a.cat.slice(0,18)}) < ${b.name} (${b.cat.slice(0,18)})`);

// --- can category be predicted from the element set at all? ---
const bySet = new Map();
for (const r of rows) {
  const k = [...r.S].sort().join(",");
  if (!bySet.has(k)) bySet.set(k, []);
  bySet.get(k).push(r);
}
const collide = [...bySet.values()].filter(v => v.length > 1);
const crossCat = collide.filter(v => new Set(v.map(r => r.cat)).size > 1);
console.log(`\nidentical element sets: ${collide.length} groups; spanning >1 category: ${crossCat.length}`);
for (const g of crossCat) console.log(`  ${g.map(r => `${r.name} [${r.cat.slice(0,20)}]`).join("  ==  ")}`);
