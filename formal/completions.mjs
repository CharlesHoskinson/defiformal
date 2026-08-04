// Q14: how many legal completions does a partial protocol have?
// A completion = a MINIMAL closed superset (only required elements added).
import { parseOperationalLaws, closureResult, extractHazardProjection } from "./analyze.mjs";
const data = await import(new URL("../viz/src/data.ts", import.meta.url));
const protoSrc = await import(new URL("../viz/src/protocols.ts", import.meta.url));
const mech = data.ELEMENTS.filter(e => e.status !== "limit");
const SYMS = mech.map(e => e.sym);
const laws = parseOperationalLaws(mech, data.LAWS);
const hz = data.HAZARDS.map(h => extractHazardProjection(h, new Set(SYMS)))
  .filter(h => h.projectionEligible);
const closed = s => closureResult(s, laws).ok;
const hazardFree = a => { const s = a instanceof Set ? a : new Set(a); return hz.every(h => !h.elements.every(e => s.has(e))); };

// enumerate all minimal closed supersets by branching on unsatisfied disjunctive terms
function completions(base, cap = 100000) {
  const out = []; const seen = new Set();
  const work = [new Set(base)];
  while (work.length) {
    if (out.length > cap) break;
    const s = work.pop();
    const r = closureResult(s, laws);
    if (r.ok) {
      const key = [...s].sort().join(",");
      if (!seen.has(key)) { seen.add(key); out.push([...s].sort()); }
      continue;
    }
    // pick the first missing term and branch on each alternative
    const v = r.violated[0];
    const t = v.missing[0];
    for (const alt of t.alternatives) { const n = new Set(s); n.add(alt); work.push(n); }
  }
  // keep only minimal ones
  const min = out.filter(c => !out.some(o => o.length < c.length && o.every(x => c.includes(x))));
  return min;
}
console.log("=== Q14: minimal legal completions of each corpus protocol (full 58-element vocabulary)");
for (const p of protoSrc.PROTOCOLS) {
  const base = new Set(p.syms);
  const comps = completions(base);
  const safe = comps.filter(hazardFree);
  console.log([p.id.padEnd(11),
    "closed=" + String(closed(base)).padEnd(5),
    "minimalCompletions=" + String(comps.length).padStart(2),
    "hazardFree=" + String(safe.length).padStart(2),
    "added=" + JSON.stringify(comps.map(c => c.filter(x => !base.has(x))))].join(" "));
}
console.log("");
console.log("=== Q14: completions of every SINGLE element (the substitution space of one mechanism)");
const rows = SYMS.map(s => { const c = completions(new Set([s])); return [s, c.length, c.filter(hazardFree).length, c]; });
for (const [s,n,ns,c] of rows.filter(r => r[1] !== 1 || r[3][0].length !== 1))
  console.log("  " + s.padEnd(3) + " completions=" + String(n).padStart(2) + " hazardFree=" + String(ns).padStart(2) +
    " -> " + JSON.stringify(c.map(x=>x.join("+"))));
console.log("elements with exactly one trivial completion (themselves): " +
  rows.filter(r => r[1] === 1 && r[3][0].length === 1).length + " of " + SYMS.length);
const dead = rows.filter(r => r[2] === 0);
console.log("elements with ZERO hazard-free completion: " + JSON.stringify(dead.map(r=>r[0])));
