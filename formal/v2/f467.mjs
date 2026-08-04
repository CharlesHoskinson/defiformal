// F4 (congruence refutation), F6 (T2 - the largest congruence fragment), F7 (Uc).
import * as T from "./tables.mjs";
const key = s => [...s].sort().join(",");
const U = ["Fl", "Xm", "Xf", "Rl", "Of", "Bs", "Sl", "Au", "Gs", "Uc", "Aw", "At", "Cp", "Cl", "Pl", "Cd", "Ix", "Sh", "Ct", "Li"];
// enumerate the FULL 2^20 test universe, not just size<=5
const ALL = [];
for (let m = 0; m < (1 << U.length); m++) ALL.push(new Set(U.filter((_, i) => m & (1 << i))));
const ADM = ALL.filter(s => T.admissible(s));
console.log(`test universe: ${U.join(" ")}`);
console.log(`|2^U| = ${ALL.length}, |Adm| = ${ADM.length}`);

// ---------------- F4: reproduce the congruence refutation on all four closures
console.log("\n=== F4: is Adm closed under join / meet / up / down? ===");
const admSet = new Set(ADM.map(key));
let w = { join: null, meet: null, up: null, down: null }, c = { join: 0, meet: 0, up: 0, down: 0 };
for (let i = 0; i < ADM.length; i++) {
  const a = ADM[i];
  for (const x of U) {
    if (!a.has(x)) { const b = new Set([...a, x]); if (!admSet.has(key(b))) { c.up++; if (!w.up) w.up = [key(a), "+" + x]; } }
    else { const b = new Set([...a].filter(y => y !== x)); if (!admSet.has(key(b))) { c.down++; if (!w.down) w.down = [key(a), "-" + x]; } }
  }
}
for (let i = 0; i < ADM.length; i += 7) for (let j = 0; j < ADM.length; j += 7) {
  const a = ADM[i], b = ADM[j];
  const j1 = new Set([...a, ...b]); if (!admSet.has(key(j1))) { c.join++; if (!w.join) w.join = [key(a), key(b), key(j1)]; }
  const m1 = new Set([...a].filter(x => b.has(x))); if (!admSet.has(key(m1))) { c.meet++; if (!w.meet) w.meet = [key(a), key(b), key(m1)]; }
}
console.log(JSON.stringify(c));
for (const k of Object.keys(w)) console.log(`  ${k}: ${w[k] ? JSON.stringify(w[k]) : "NO COUNTEREXAMPLE"}`);

// which block breaks each union? attribute the failure
console.log("\n  attribution of union failures (sampled 2000):");
const att = {};
let n = 0;
outer: for (let i = 0; i < ADM.length; i++) for (let j = i; j < ADM.length; j++) {
  const un = new Set([...ADM[i], ...ADM[j]]);
  if (admSet.has(key(un))) continue;
  const [, p] = T.admissible(un, true);
  for (const [k, v] of Object.entries(p)) if (v && v.length !== 0) att[k + (k === "hazard" ? ":" + v.join("/") : "")] = (att[k + (k === "hazard" ? ":" + v.join("/") : "")] || 0) + 1;
  if (++n >= 2000) break outer;
}
console.log("   ", JSON.stringify(att));

// ---------------- F6 / T2: the congruence fragment
console.log("\n=== F6 / T2: a union-closed subfamily of Adm ===");
// Theory: only four conditions are not preserved by union.
//   X2 and X21 are prohibitions (downward-closed)  -> delete their trigger atom Fl
//   X19* (Aw & Xf -> At|Fz|Xm) and X18 (Oa & Li -> Ex|Tp) have CONJUNCTIVE antecedents
//     -> replace each by its two single-atom strengthenings, which are union-closed.
// Everything else (Gamma*, Delta, X11a*, Ground) has single-atom antecedents.
const has = (S, ...xs) => xs.some(x => S.has(x));
const SPLIT = S =>
  !S.has("Fl") &&
  (!S.has("Aw") || has(S, "At", "Fz", "Xm")) && (!S.has("Xf") || has(S, "At", "Fz", "Xm")) &&
  (!S.has("Oa") || has(S, "Ex", "Tp")) && (!S.has("Li") || has(S, "Ex", "Tp"));
const F = ADM.filter(SPLIT);
console.log(`|F| (Adm intersect the split-antecedent, Fl-free condition) = ${F.length}  (${(100 * F.length / ADM.length).toFixed(1)}% of Adm)`);
const fkey = new Set(F.map(key));
let bad = 0, badw = null;
for (let i = 0; i < F.length; i++) for (let j = i; j < F.length; j++) {
  const un = new Set([...F[i], ...F[j]]);
  if (!fkey.has(key(un))) { bad++; if (!badw) badw = [key(F[i]), key(F[j]), key(un)]; }
}
console.log(`union counterexamples inside F: ${bad}` + (badw ? " e.g. " + JSON.stringify(badw) : ""));
console.log(`=> F is${bad ? " NOT" : ""} closed under union, so (+) IS a congruence for admissibility on F.` );
// is it a sublattice? meet
let badm = 0, badmw = null;
for (let i = 0; i < F.length; i++) for (let j = i; j < F.length; j++) {
  const mm = new Set([...F[i]].filter(x => F[j].has(x)));
  if (!fkey.has(key(mm))) { badm++; if (!badmw) badmw = [key(F[i]), key(F[j]), key(mm)]; }
}
console.log(`intersection counterexamples inside F: ${badm}` + (badmw ? " e.g. " + JSON.stringify(badmw) : ""));

// upper bound on any union-closed subfamily: drop elements that participate in a failure
const involved = new Set();
for (let i = 0; i < ADM.length; i++) for (let j = i; j < ADM.length; j++) {
  const un = new Set([...ADM[i], ...ADM[j]]);
  if (!admSet.has(key(un))) { involved.add(key(ADM[i])); involved.add(key(ADM[j])); }
}
console.log(`\nAdm members that participate in NO bad union at all: ${ADM.length - involved.size} of ${ADM.length}`);
console.log(`(that set is an upper bound on any union-closed subfamily containing it only if it is itself closed;`);
const safe = ADM.filter(s => !involved.has(key(s)));
const skey = new Set(safe.map(key));
let sb = 0; for (let i = 0; i < safe.length; i++) for (let j = i; j < safe.length; j++) if (!skey.has(key(new Set([...safe[i], ...safe[j]])))) sb++;
console.log(` it has ${sb} internal union failures.)`);
console.log(`F subset of safe? ${F.every(s => skey.has(key(s)))}`);

// coverage on the corpus
const liveF = T.lanes.filter(p => { const s = new Set(p.syms); return T.admissible(s) && SPLIT(s); });
const liveAdm = T.lanes.filter(p => T.admissible(new Set(p.syms)));
console.log(`\nlive protocols: ${liveAdm.length}/72 admissible, of those ${liveF.length} lie in the congruence fragment F`);
console.log(`  outside F: ${liveAdm.filter(p => !liveF.includes(p)).map(p => p.name).slice(0, 25).join(", ")}`);
// and pairwise: how many of the C(n,2) live pairs compose without re-analysis
let pOK = 0, pTot = 0, pAdm = 0;
for (let i = 0; i < liveAdm.length; i++) for (let j = i + 1; j < liveAdm.length; j++) {
  pTot++;
  const un = new Set([...liveAdm[i].syms, ...liveAdm[j].syms]);
  if (T.admissible(un)) pAdm++;
  if (liveF.includes(liveAdm[i]) && liveF.includes(liveAdm[j])) pOK++;
}
console.log(`live pairs: ${pTot} total, ${pAdm} whose union is admissible, ${pOK} certified by F without re-analysis`);

// ---------------- F7: does Uc survive?
console.log("\n=== F7: is Uc realizable? ===");
const withUc = ADM.filter(s => s.has("Uc"));
console.log(`admissible sets containing Uc in the 2^20 test universe: ${withUc.length}`);
console.log("  smallest:", withUc.map(key).sort((a, b) => a.split(",").length - b.split(",").length).slice(0, 5));
// under the UNCORRECTED X11a polarity (the membership projection that had it backwards)
const X11a_old = S => !(S.has("Uc") && S.has("Aw") && S.has("At"));  // "all named present" reading
const oldAdm = ALL.filter(s => { const [ok] = T.admissible(s, true); return ok && X11a_old(s); });
console.log(`under the INVERTED X11a projection, admissible sets containing Uc: ${oldAdm.filter(s => s.has("Uc")).length}`);
// live Uc protocols
const ucLive = T.lanes.filter(p => p.syms.includes("Uc"));
for (const p of ucLive) {
  const [ok, pp] = T.admissible(new Set(p.syms), true);
  console.log(`  ${p.name}: admissible=${ok} ${ok ? "" : JSON.stringify(Object.fromEntries(Object.entries(pp).filter(([, v]) => v && v.length !== 0)))}`);
}
