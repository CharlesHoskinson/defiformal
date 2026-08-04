// F3 (final) - exhaustive bounded unlisted-hazard search with the CORRECTED parser
// and the warrant condition, PLUS the corpus test that killed {Fl,Xm}:
// a candidate hazard is only a candidate if NO live protocol contains it.
import * as T from "./tables.mjs";
const K = Number(process.argv[2] ?? 5);
const SYMS = T.MECH;
const attr = s => T.ELEMS[s];
const G12 = new Set(SYMS.filter(x => attr(x).group === "G12"));
const LIVE = T.lanes.map(p => new Set(p.syms));

const stratumMonotone = (S, parsed) => parsed.every(l =>
  l.subjects.filter(x => S.has(x)).every(subj =>
    l.terms.filter(t => !t.external).every(t => {
      const present = t.alts.filter(a => S.has(a));
      return present.length === 0 ? true : present.some(a => attr(a).stratum <= attr(subj).stratum);
    })));
const atomicScope = S => !(S.has("Fl") && [...S].some(x => G12.has(x)));
const expressible = (S, parsed) => parsed.filter(l => l.subjects.some(x => S.has(x)))
  .every(l => l.terms.every(t => !t.external));
const props = {
  stratumInversion: S => !stratumMonotone(S, T.PARSED_NEW),
  atomicScopeBreak: S => !atomicScope(S),
  inexpressible: S => !expressible(S, T.PARSED_NEW),
};
const counts = { total: 0, admissible: 0 };
const minimal = {};
for (const p of Object.keys(props)) { counts[p] = 0; minimal[p] = []; }
const combo = [];
const isSuper = (big, small) => small.every(x => big.includes(x));
function rec(start, k) {
  const S = new Set(combo);
  counts.total++;
  if (T.admissible(S)) {
    counts.admissible++;
    for (const [pn, pf] of Object.entries(props)) {
      if (!pf(S)) continue;
      counts[pn]++;
      if (!minimal[pn].some(mm => isSuper(combo, mm))) minimal[pn].push([...combo]);
    }
  }
  if (k === 0) return;
  for (let i = start; i < SYMS.length; i++) { combo.push(SYMS[i]); rec(i + 1, k - 1); combo.pop(); }
}
const t0 = Date.now();
rec(0, K);
console.log(`=== EXHAUSTIVE, all subsets of the 58-element vocabulary of size <= ${K}  (${((Date.now() - t0) / 1000).toFixed(0)}s) ===`);
console.log("enumerated:", counts.total, " ADMISSIBLE:", counts.admissible);
for (const pn of Object.keys(props)) {
  const raw = minimal[pn];
  const mins = raw.filter((mm, i) => !raw.some((nn, j) => j !== i && nn.length < mm.length && isSuper(mm, nn)));
  const clean = mins.filter(mm => !LIVE.some(L => mm.every(x => L.has(x))));
  const dirty = mins.length - clean.length;
  console.log(`\n${pn}: ${counts[pn]} admissible violating sets, ${mins.length} minimal`);
  console.log(`  fire on >=1 of the 72 live protocols (DEAD, the R1 test): ${dirty}`);
  console.log(`  SURVIVING candidate unlisted hazards (zero live hits): ${clean.length}`);
  if (clean.length) console.log("   ", JSON.stringify(clean.slice(0, 30)));
  // which live protocols kill the rest
  for (const mm of mins.slice(0, 200)) {
    const hits = T.lanes.filter(p => mm.every(x => p.syms.includes(x))).map(p => p.name);
    if (hits.length) { console.log(`    killed: {${mm.join(",")}} <- ${hits.slice(0, 4).join(", ")}${hits.length > 4 ? " +" + (hits.length - 4) : ""}`); break; }
  }
}
