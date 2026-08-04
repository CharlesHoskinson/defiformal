/* Is Fix(Gamma) a CONVEX GEOMETRY?
 *
 * We already know Fix(Gamma) is a Moore family (closed under intersection) and
 * that admissible sets are accessible (8240/8240). A Moore family is a convex
 * geometry exactly when its closure operator satisfies ANTI-EXCHANGE:
 *
 *   for closed A and distinct x,y not in A:
 *       x in cl(A + y)   =>   y not in cl(A + x)
 *
 * Convex geometries are worth chasing because every closed set has a UNIQUE
 * minimal generator (its extreme points). That is a canonical form for a
 * protocol, which is what "say something mathematical about a composite" needs.
 *
 * This tests it directly. A single counterexample kills it, and a counterexample
 * is more useful than a pass because it names the pair that breaks it.
 */
import { PARSED_NEW, MECH } from "./tables.mjs";

const E = MECH.slice();

/* The definite (height-1) closure: a term forces its alternative only when the
 * term is a singleton. Disjunctive terms force nothing - that is exactly why the
 * positive theory is weak, and it is also what makes Cn a genuine closure. */
function cl(S) {
  const X = new Set(S);
  let grew = true;
  while (grew) {
    grew = false;
    for (const law of PARSED_NEW) {
      if (!law.subjects.some(s => X.has(s))) continue;
      for (const t of law.terms) {
        if (t.external || t.alts.length !== 1) continue;
        if (!X.has(t.alts[0])) { X.add(t.alts[0]); grew = true; }
      }
    }
  }
  return X;
}

const eq = (a, b) => a.size === b.size && [...a].every(x => b.has(x));

/* enumerate closed sets reachable from small seeds - the full lattice is far too
 * large, so state the bound rather than pretend to exhaustiveness */
const closed = new Map();
const addClosed = S => { const c = cl(S); closed.set([...c].sort().join(","), c); };
addClosed([]);
for (const a of E) addClosed([a]);
for (const a of E) for (const b of E) if (a < b) addClosed([a, b]);

console.log(`ground set: ${E.length} elements`);
console.log(`closed sets tested: ${closed.size} (from all singletons and pairs)`);

let checked = 0, violations = [];
for (const A of closed.values()) {
  const out = E.filter(e => !A.has(e));
  for (const x of out) {
    const clx = cl([...A, x]);
    for (const y of out) {
      if (x === y) continue;
      const cly = cl([...A, y]);
      if (!cly.has(x)) continue;          // premise: x in cl(A+y)
      checked++;
      if (clx.has(y)) {                    // anti-exchange demands y NOT in cl(A+x)
        violations.push({ A: [...A].sort().join(","), x, y });
      }
    }
  }
}

console.log(`\nanti-exchange premises found: ${checked}`);
console.log(`VIOLATIONS: ${violations.length}`);
if (violations.length === 0) {
  console.log("\n=> anti-exchange HOLDS on the tested closed sets.");
  console.log("   Fix(Gamma) is a CONVEX GEOMETRY on this bound.");
  console.log("   Consequence: every closed set has a unique minimal generator.");
} else {
  console.log("\n=> anti-exchange FAILS. Not a convex geometry. Witnesses:");
  for (const v of violations.slice(0, 8))
    console.log(`   A={${v.A || "0"}}  x=${v.x}  y=${v.y}   (x in cl(A+y) AND y in cl(A+x))`);
  const pairs = new Set(violations.map(v => [v.x, v.y].sort().join("~")));
  console.log(`   distinct offending pairs: ${pairs.size} -> ${[...pairs].slice(0, 10).join("  ")}`);
}

/* Unique minimal generators: the property we actually want. Test it directly,
 * because it can hold even where anti-exchange fails on some region. */
let uniq = 0, multi = 0, examples = [];
for (const A of closed.values()) {
  if (A.size === 0 || A.size > 8) continue;
  const gens = [];
  const arr = [...A];
  for (let mask = 1; mask < (1 << arr.length); mask++) {
    const G = arr.filter((_, i) => mask & (1 << i));
    if (eq(cl(G), A)) gens.push(G);
  }
  const minSize = Math.min(...gens.map(g => g.length));
  const minimal = gens.filter(g => g.length === minSize);
  if (minimal.length === 1) uniq++;
  else { multi++; if (examples.length < 4) examples.push({ A: arr.sort().join(","), n: minimal.length }); }
}
console.log(`\nunique minimal generator: ${uniq} closed sets; NON-unique: ${multi}`);
for (const e of examples) console.log(`   {${e.A}} has ${e.n} distinct minimal generators`);
