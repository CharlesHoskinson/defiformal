// F3 - exhaustive bounded search for UNLISTED hazards, with the CORRECTED parser
// and the warrant condition. Same bound and same three invariant families as the
// old run (formal/probe.mjs), so the two are directly comparable.
import * as T from "./tables.mjs";
const K = Number(process.argv[2] ?? 5);
const SYMS = T.MECH;
const attr = s => T.ELEMS[s];
const G12 = new Set(SYMS.filter(x => attr(x).group === "G12"));

// the three candidate-hazard invariants, verbatim in intent from probe.mjs
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
// gates: OLD = closed+hazard-free (what the old run used); NEW = full admissibility
const gates = {
  "A_old(closed_oldparser + listed-hazard-free)": S => T.closesOld(S) && T.armedListed(S).length === 0,
  "B_closed_newparser + listed-hazard-free": S => T.closesNew(S) && T.armedListed(S).length === 0,
  "C_ADMISSIBLE (Gamma* + Delta + Ban/Cond + Ground)": S => T.admissible(S),
};

const counts = { total: 0 };
const minimal = {};
for (const g of Object.keys(gates)) for (const p of Object.keys(props)) { counts[g + "|" + p] = 0; minimal[g + "|" + p] = []; }
for (const g of Object.keys(gates)) counts[g] = 0;

const combo = [];
const isSuper = (big, small) => small.every(x => big.includes(x));
function rec(start, k) {
  const S = new Set(combo);
  counts.total++;
  const gv = {};
  for (const [gn, gf] of Object.entries(gates)) { gv[gn] = gf(S); if (gv[gn]) counts[gn]++; }
  for (const [pn, pf] of Object.entries(props)) {
    if (!pf(S)) continue;
    for (const gn of Object.keys(gates)) {
      if (!gv[gn]) continue;
      const key = gn + "|" + pn;
      counts[key]++;
      if (!minimal[key].some(mm => isSuper(combo, mm))) minimal[key].push([...combo]);
    }
  }
  if (k === 0) return;
  for (let i = start; i < SYMS.length; i++) { combo.push(SYMS[i]); rec(i + 1, k - 1); combo.pop(); }
}
rec(0, K);

console.log(`=== EXHAUSTIVE: all subsets of the 58-element vocabulary of size <= ${K} ===`);
console.log("total subsets enumerated:", counts.total);
for (const gn of Object.keys(gates)) {
  console.log(`\n--- gate ${gn}: ${counts[gn]} sets pass ---`);
  for (const pn of Object.keys(props)) {
    const key = gn + "|" + pn;
    const mins = minimal[key].filter((mm, i) => !minimal[key].some((nn, j) => j !== i && nn.length < mm.length && isSuper(mm, nn)));
    console.log(`  ${pn}: ${counts[key]} violating, ${mins.length} minimal` +
      (mins.length && mins.length <= 40 ? " -> " + JSON.stringify(mins) : mins.length ? " -> first 12 " + JSON.stringify(mins.slice(0, 12)) : ""));
  }
}
console.log("\n=== the old prize, re-evaluated ===");
for (const w of [["Fl", "Xm"], ["Fl", "Au", "Rl"], ["Au", "Gs"]]) {
  const S = new Set(w);
  const [ok, p] = T.admissible(S, true);
  console.log(` {${w.join(",")}}: closesOld=${T.closesOld(S)} closesNew=${T.closesNew(S)} ADMISSIBLE=${ok} ` +
    JSON.stringify(Object.fromEntries(Object.entries(p).filter(([, v]) => v && v.length !== 0))));
}
console.log("\nlisted hazards that survive the membership projection:", T.HAZ_PROJ.map(h => h.id + "{" + h.named.join(",") + "}").join(" "));
