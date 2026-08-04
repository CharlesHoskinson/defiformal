/* A: EXTEND THE BOUND on anti-exchange. Uses the ORIGINAL cl() verbatim - no
 * digraph shortcut - so this is an independent check of the structural proof.
 * Tiers: singletons, pairs, ALL triples, random seeds |S|=4..12, the 72 real
 * protocol sets, and adversarial seeds built to stress the disjunctive laws.
 */
import { PARSED_NEW, MECH, lanes, LAWS, SYMS } from "./tables.mjs";
const E = MECH.slice();

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
const key = S => [...S].sort().join(",");

// memoise cl on singletons: cl(A+x) = A u cl({x}) is NOT assumed; we compute cl fresh.
function tier(name, seeds) {
  const closed = new Map();
  for (const S of seeds) { const c = cl(S); closed.set(key(c), c); }
  let checked = 0; const violations = [];
  for (const A of closed.values()) {
    const out = E.filter(e => !A.has(e));
    const clAx = new Map();
    for (const x of out) clAx.set(x, cl([...A, x]));
    for (const x of out) for (const y of out) {
      if (x === y) continue;
      if (!clAx.get(y).has(x)) continue;       // premise x in cl(A+y)
      checked++;
      if (clAx.get(x).has(y)) violations.push({ A: key(A), x, y });
    }
  }
  const line = `${name.padEnd(34)} seeds=${String(seeds.length).padStart(6)}  closedSets=${String(closed.size).padStart(6)}  premises=${String(checked).padStart(8)}  VIOLATIONS=${violations.length}`;
  console.log(line);
  if (violations.length) {
    console.log("   *** COUNTEREXAMPLE ***");
    for (const v of violations.slice(0, 10)) console.log(`   A={${v.A || "0"}} x=${v.x} y=${v.y}`);
  }
  return { name, seeds: seeds.length, closed: closed.size, checked, violations };
}

const rows = [];
// T0/T1/T2 - the original bound
rows.push(tier("T0 empty+singletons", [[], ...E.map(a => [a])]));
const pairs = []; for (const a of E) for (const b of E) if (a < b) pairs.push([a, b]);
rows.push(tier("T1 all pairs (original bound)", pairs));
// T2 ALL triples
const triples = [];
for (let i = 0; i < E.length; i++) for (let j = i + 1; j < E.length; j++) for (let k = j + 1; k < E.length; k++) triples.push([E[i], E[j], E[k]]);
rows.push(tier("T2 ALL triples", triples));
// T3 random 4..12
let seed = 987654321;
const rnd = () => (seed = (seed * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff;
const rand = [];
for (let n = 0; n < 40000; n++) {
  const k = 4 + Math.floor(rnd() * 9);
  const s = new Set(); while (s.size < k) s.add(E[Math.floor(rnd() * E.length)]);
  rand.push([...s]);
}
rows.push(tier("T3 random |S|=4..12 (40k)", rand));
// T4 the 72 real protocol sets
const real = [...new Set(lanes.map(p => p.syms.filter(s => SYMS.has(s)).join(",")))].filter(Boolean).map(s => s.split(","));
rows.push(tier(`T4 real protocol sets (${real.length})`, real));
// T5 adversarial: seeds saturating the SUBJECTS of every disjunctive law, plus
// seeds that hold every subject of >=2 laws at once, plus complements.
const subs = [...new Set(PARSED_NEW.flatMap(l => l.subjects))].filter(s => E.includes(s));
const disjSubs = [...new Set(PARSED_NEW.filter(l => l.terms.some(t => !t.external && t.alts.length > 1)).flatMap(l => l.subjects))].filter(s => E.includes(s));
const adv = [];
adv.push(subs, disjSubs, E.slice());                          // all subjects; all disjunctive subjects; everything
for (const s of subs) for (const t of subs) if (s < t) adv.push([s, t]);
for (const law of PARSED_NEW) if (law.subjects.length) adv.push(law.subjects.filter(x => E.includes(x)));
// every subject-set union one arbitrary other element
for (const s of subs) for (const e of E) adv.push([s, e]);
// complements of singletons (maximally large closed-ish sets)
for (const a of E) adv.push(E.filter(x => x !== a));
// all 4-subsets of the subject set (the only elements that can force anything)
for (let i = 0; i < subs.length; i++) for (let j = i+1; j < subs.length; j++) for (let k = j+1; k < subs.length; k++) for (let l = k+1; l < subs.length; l++) adv.push([subs[i],subs[j],subs[k],subs[l]]);
rows.push(tier("T5 adversarial (subject-saturating)", adv.filter(a => a.length)));

console.log("\n--- summary ---");
const tot = rows.reduce((a, r) => a + r.checked, 0), viol = rows.reduce((a, r) => a + r.violations.length, 0);
const cs  = rows.reduce((a, r) => a + r.closed, 0);
console.log(`total closed sets tested (with overlap): ${cs}`);
console.log(`total anti-exchange premise instances : ${tot}`);
console.log(`total VIOLATIONS                      : ${viol}`);
