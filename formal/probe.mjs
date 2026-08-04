// Exhaustive bounded probe over the FULL 58-element vocabulary.
// Independent of viz/src/laws.ts: reuses formal/analyze.mjs parsing only.
import { parseOperationalLaws, closureResult, extractHazardProjection } from "./analyze.mjs";

const data = await import(new URL("../viz/src/data.ts", import.meta.url));
const protoSrc = await import(new URL("../viz/src/protocols.ts", import.meta.url));
const mech = data.ELEMENTS.filter(e => e.status !== "limit");
const SYMS = mech.map(e => e.sym);
const attr = new Map(mech.map(e => [e.sym, e]));
const laws = parseOperationalLaws(mech, data.LAWS);
const hz = data.HAZARDS.map(h => extractHazardProjection(h, new Set(SYMS)))
  .filter(h => h.projectionEligible);

const closed = s => closureResult(s, laws).ok;
const hazardFree = s => hz.every(h => !h.elements.every(e => s.has(e)));
const stratumMonotone = s => laws.every(l => l.subjects.filter(x=>s.has(x)).every(subj =>
  l.terms.filter(t=>!t.external).every(t => {
    const present = t.alternatives.filter(a=>s.has(a));
    return present.length===0 ? true : present.some(a => attr.get(a).stratum <= attr.get(subj).stratum);
  })));
const G12 = new Set(SYMS.filter(x => attr.get(x).group === "G12"));
const atomicScope = s => !(s.has("Fl") && [...s].some(x => G12.has(x)));
const expressible = s => laws.filter(l=>l.subjects.some(x=>s.has(x)))
  .every(l => l.externalTerms===0 && l.mixedTerms===0);

// ---- exhaustive enumeration of all subsets of size <= K over all 58 elements
const K = Number(process.argv[2] ?? 4);
const props = {
  stratumInversion: s => !stratumMonotone(s),
  atomicScopeBreak: s => !atomicScope(s),
  inexpressible:    s => !expressible(s),
};
const minimal = { stratumInversion: [], atomicScopeBreak: [], inexpressible: [] };
const counts  = { total: 0, closed: 0, closedSafe: 0,
                  stratumInversion: 0, atomicScopeBreak: 0, inexpressible: 0 };
const isSuper = (big, small) => small.every(x => big.includes(x));

const combo = [];
function rec(start, k) {
  if (combo.length >= 0) {
    const s = new Set(combo);
    counts.total++;
    const c = closed(s);
    if (c) counts.closed++;
    const safe = c && hazardFree(s);
    if (safe) {
      counts.closedSafe++;
      for (const [name, p] of Object.entries(props)) {
        if (p(s)) {
          counts[name]++;
          minimal[name].push([...combo]);
        }
      }
    }
  }
  if (combo.length === k) return;
  for (let i = start; i < SYMS.length; i++) { combo.push(SYMS[i]); rec(i+1, k); combo.pop(); }
}
rec(0, K);
console.log("=== EXHAUSTIVE BOUNDED SEARCH: all subsets of the full 58-element vocabulary, size <= " + K);
console.log(JSON.stringify(counts));
for (const n of Object.keys(minimal)) {
  const all = minimal[n].sort((a,b)=>a.length-b.length);
  const min = all.filter(c => !all.some(o => o.length < c.length && isSuper(c, o)));
  console.log("MINIMAL " + n + " (closed AND hazardFree AND violating), " + min.length + " minimal of " + all.length + " total: " +
    JSON.stringify(min.slice(0,60)));
}

// ---- Q13: cycles in the law-derived requirement relation (ALL alternatives)
const edges = new Map(SYMS.map(s=>[s,new Set()]));
for (const l of laws) for (const subj of l.subjects)
  for (const t of l.terms.filter(t=>!t.external)) for (const a of t.alternatives)
    if (a !== subj) edges.get(subj).add(a);
const found = [];
const state = new Map(); const stack = [];
const dfs = n => { state.set(n,1); stack.push(n);
  for (const m of edges.get(n)??[]) {
    if (state.get(m)===1) found.push(stack.slice(stack.indexOf(m)).join("->")+"->"+m);
    else if (!state.get(m)) dfs(m);
  } stack.pop(); state.set(n,2); };
for (const s of SYMS) if (!state.get(s)) dfs(s);
console.log("=== Q13 cycles in FULL law relation (subject -> every alternative, all 58 elements): " +
  (found.length ? JSON.stringify(found) : "NONE - the relation is a DAG"));
const self = SYMS.filter(s => edges.get(s).has(s));
console.log("Q13 self-loops: " + JSON.stringify(self));
const terra = new Set(protoSrc.PROTOCOLS.find(p=>p.id==="terra").syms);
console.log("Q13 Terra elements: " + JSON.stringify([...terra]) +
  " out-edges within Terra: " + JSON.stringify(
    [...terra].map(s=>[s,[...edges.get(s)].filter(x=>terra.has(x))]).filter(x=>x[1].length)));

// ---- Q14: completions of partial protocols over the full vocabulary
const closureOfSet = s => { // least closed superset via fixpoint using FIRST alternative? not canonical
  return null; };
console.log("=== Q14 union/intersection over the FULL vocabulary (sampled pairs)");
// verify union-closure on random closed pairs from full vocabulary
let unionFail = null, interFail = null, tries = 0;
const rnd = () => { const s = new Set(); for (const x of SYMS) if (Math.random()<0.25) s.add(x); return s; };
const pool = [];
while (pool.length < 4000 && tries < 400000) { tries++; const s = rnd(); if (closed(s)) pool.push(s); }
for (let i=0;i<pool.length && !unionFail;i++) for (let j=i+1;j<pool.length;j++) {
  const u = new Set([...pool[i],...pool[j]]); if (!closed(u)) { unionFail=[[...pool[i]],[...pool[j]]]; break; }
}
outer: for (let i=0;i<pool.length;i++) for (let j=i+1;j<pool.length;j++) {
  const m = new Set([...pool[i]].filter(x=>pool[j].has(x)));
  if (!closed(m)) { interFail=[[...pool[i]].join(","),[...pool[j]].join(","),[...m].join(",")]; break outer; }
}
console.log("closed sets sampled: " + pool.length + " (from " + tries + " random draws)");
console.log("union counterexample: " + (unionFail?JSON.stringify(unionFail):"NONE among all C(n,2) sampled pairs"));
console.log("intersection counterexample: " + (interFail?JSON.stringify(interFail):"none found"));
console.log("empty set closed: " + closed(new Set()) + " ; full vocabulary closed: " + closed(new Set(SYMS)) +
  " ; full vocabulary hazardFree: " + hazardFree(new Set(SYMS)));
