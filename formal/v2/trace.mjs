/* Does compatibility reduce to prohibition traces?
 *
 * We PROVED R n W is union-closed (dual-Horn, Cor:lattice). So for A,B in R n W,
 * A u B is automatically in R n W. The ONLY way A (+) B can fail admissibility is
 * a prohibition H covered by A u B but by neither alone.
 *
 * Hence:  A ~ B   iff   for every prohibition H,  H not-subset-of  A u B.
 *
 * Define the TRACE t(A) = (H1 n A, H2 n A, ...). Then compatibility depends only
 * on traces, so G_+ is a BLOW-UP of a small graph on the trace space. Blow-ups of
 * perfect graphs are perfect. With few enforceable prohibitions the trace space
 * is tiny and the perfection question becomes a finite check instead of an
 * enumeration of |Adm| ~ 10^15.
 *
 * This verifies the premise and computes the quotient graph.
 */
import { PARSED_NEW, MECH, HAZ_PROJ, admissible } from "./tables.mjs";

const E = MECH.slice();
const S2 = a => new Set(a);
const sat = X => PARSED_NEW.every(l =>
  !l.subjects.some(s => X.has(s)) || l.terms.every(t => t.external || t.alts.some(a => X.has(a))));

/* the enforceable prohibitions: rows that are genuine positive element sets */
const HS = HAZ_PROJ.filter(h => h.named.length >= 2).map(h => ({ id: h.id, set: S2(h.named) }));
console.log(`enforceable prohibition rows: ${HS.length}`);
for (const h of HS) console.log(`   ${h.id}: {${[...h.set].join(",")}}`);

/* --- premise check: is R n W really union-closed on samples? --- */
let rng = 12345; const rnd = () => (rng = (rng * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff;
const sample = [];
while (sample.length < 4000) {
  const n = 1 + Math.floor(rnd() * 10);
  const X = new Set(); while (X.size < n) X.add(E[Math.floor(rnd() * E.length)]);
  if (sat(X)) sample.push(X);
}
let unionFail = 0;
for (let i = 0; i < 3000; i++) {
  const A = sample[Math.floor(rnd() * sample.length)], B = sample[Math.floor(rnd() * sample.length)];
  if (!sat(new Set([...A, ...B]))) unionFail++;
}
console.log(`\nunion-closure of the law models: ${unionFail} failures in 3000 pairs`);

/* --- the reduction: does A~B depend only on traces? --- */
const trace = A => HS.map(h => [...h.set].filter(e => A.has(e)).sort().join("")).join("|");
const compatible = (A, B) => { const U = new Set([...A, ...B]); return HS.every(h => ![...h.set].every(e => U.has(e))); };

const byTrace = new Map();
for (const A of sample) { const t = trace(A); if (!byTrace.has(t)) byTrace.set(t, []); byTrace.get(t).push(A); }
console.log(`distinct traces among ${sample.length} sampled law-models: ${byTrace.size}`);

let inconsistent = 0, tested = 0;
const traces = [...byTrace.keys()];
for (const t1 of traces) for (const t2 of traces) {
  const g1 = byTrace.get(t1), g2 = byTrace.get(t2);
  const ref = compatible(g1[0], g2[0]);
  for (let k = 0; k < Math.min(6, g1.length); k++)
    for (let m = 0; m < Math.min(6, g2.length); m++) {
      tested++;
      if (compatible(g1[k], g2[m]) !== ref) inconsistent++;
    }
}
console.log(`trace-determinacy: ${inconsistent} inconsistencies in ${tested} checks`);

/* --- the quotient graph on traces, and is it perfect? --- */
const n = traces.length;
const adj = traces.map(t1 => traces.map(t2 => compatible(byTrace.get(t1)[0], byTrace.get(t2)[0]) ? 1 : 0));
let edges = 0; for (let i = 0; i < n; i++) for (let j = i + 1; j < n; j++) edges += adj[i][j];
console.log(`\nquotient graph: ${n} vertices, ${edges} edges (density ${(2*edges/(n*(n-1))).toFixed(3)})`);

/* odd holes of length 5 and 7 in the quotient - finite and cheap */
function findOddHole(len) {
  const path = [];
  const rec = d => {
    if (d === len) {
      const a = path[0], z = path[len-1];
      if (!adj[a][z]) return null;
      return [...path];
    }
    for (let v = (d ? path[0] + 1 : 0); v < n; v++) {
      if (path.includes(v)) continue;
      if (d > 0 && !adj[path[d-1]][v]) continue;
      let ok = true;
      for (let k = 0; k < d - 1; k++) if (adj[path[k]][v]) { ok = false; break; }
      if (!ok) continue;
      path.push(v); const r = rec(d + 1); if (r) return r; path.pop();
    }
    return null;
  };
  return rec(0);
}
for (const L of [5, 7]) {
  const h = findOddHole(L);
  console.log(`odd hole of length ${L}: ${h ? "FOUND -> " + h.map(i => traces[i] || "(empty)").join(" - ") : "none"}`);
}
console.log("\nIf the premise holds and the quotient is small and hole-free, G_+ is a");
console.log("blow-up of a perfect graph, hence perfect - conj:perfect becomes a theorem.");
