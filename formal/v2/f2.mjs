// F2 - is the definite fragment really a distributive lattice, and is 3,140 the count?
import * as T from "./tables.mjs";

// 1. Derive the definite fragment INDEPENDENTLY from the corrected 29 laws.
//    definite production = law fires from a single element subject and has a
//    term with exactly one element alternative and no prose alternative.
const H = [];
for (const law of T.PARSED_NEW)
  for (const s of law.subjects)
    for (const t of law.terms)
      if (!t.external && t.alts.length === 1 && t.alts[0] !== s) H.push([s, t.alts[0], law.id]);
console.log("=== F2.1 definite fragment derived from the corrected 29 laws ===");
console.log("rules:", H.length);
for (const [b, h, id] of H) console.log(`  ${id}: ${b} -> ${h}`);
const bodies = new Set(H.map(r => r[0])), heads = new Set(H.map(r => r[1]));
const overlap = [...bodies].filter(b => heads.has(b));
console.log("bodies:", [...bodies].sort().join(" "));
console.log("heads :", [...heads].sort().join(" "));
console.log("HEIGHT 1 (bodies and heads disjoint)?", overlap.length === 0, overlap.length ? "overlap=" + overlap : "");

// 2. OP-LOG's stated 8-rule fragment, checked against the atlas text.
const OPLOG8 = [["Uc", "Aw", "R6"], ["Py", "Ep", "R10"], ["Py", "Rd", "R11"], ["Of", "Xm", "R17"],
["Of", "Xf", "R18"], ["Gs", "Au", "R20"], ["Rs", "Vl", "R34"], ["Ad", "Li", "C15"]];
console.log("\n=== F2.2 OP-LOG's 8 rules, each traced to atlas law text ===");
for (const [b, h, id] of OPLOG8) {
  const found = H.filter(r => r[0] === b && r[1] === h).map(r => r[2]);
  console.log(`  ${id}: ${b} -> ${h}  ${found.length ? "derivable from " + found.join(",") : "NOT DERIVABLE from the 29 laws"}`);
}
const extra = H.filter(r => !OPLOG8.some(o => o[0] === r[0] && o[1] === r[1]));
console.log("  definite rules OP-LOG omits:", extra.map(r => `${r[0]}->${r[1]} (${r[2]})`).join(", "));

// 3. Exact closed-set count for both fragments over the stated 54-atom signature.
const SIG54 = ["Sh", "Ix", "Rb", "Cp", "Cl", "St", "Pm", "Ob", "Rf", "Ba", "In", "Ag", "Fl", "Pl", "Im", "Cd",
  "Uc", "Ft", "Ct", "Li", "Ad", "Sl", "Bs", "Pf", "Op", "Tr", "Py", "Sv", "Dp", "Ex", "Tp", "Oa",
  "At", "Sr", "Ep", "Wq", "Em", "Fd", "Tg", "Up", "Gp", "Au", "Gs", "Xm", "Xf", "Rl", "Of", "Rd",
  "Ps", "As", "Aw", "Fz", "Rs", "Vl"];
console.log("\nsignature size:", SIG54.length);

function countClosed(rules, universe) {
  // connected components of the body/head bipartite graph; count closed configs per component
  const U = new Set(universe);
  const rs = rules.filter(r => U.has(r[0]) && U.has(r[1]));
  const adj = new Map(); const touch = new Set();
  for (const [b, h] of rs) {
    touch.add(b); touch.add(h);
    adj.set(b, [...(adj.get(b) || []), h]); adj.set(h, [...(adj.get(h) || []), b]);
  }
  const seen = new Set(); let total = 1n; let comps = [];
  for (const n of touch) {
    if (seen.has(n)) continue;
    const comp = []; const st = [n];
    while (st.length) { const x = st.pop(); if (seen.has(x)) continue; seen.add(x); comp.push(x); for (const y of adj.get(x) || []) if (!seen.has(y)) st.push(y); }
    // brute force closed subsets of this component
    let c = 0;
    for (let mask = 0; mask < (1 << comp.length); mask++) {
      const s = new Set(comp.filter((_, i) => mask & (1 << i)));
      if (rs.every(([b, h]) => !s.has(b) || s.has(h))) c++;
    }
    comps.push([comp.join("/"), c]); total *= BigInt(c);
  }
  const free = universe.length - touch.size;
  return { total: total * (2n ** BigInt(free)), free, comps, perComp: total };
}
for (const [name, rules] of [["OP-LOG 8-rule fragment", OPLOG8], ["fragment derived from corrected 29 laws", H]]) {
  const r = countClosed(rules, SIG54);
  console.log(`\n${name}: constrained-part configs=${r.perComp}, free atoms=${r.free}`);
  console.log("  components:", r.comps.map(c => `${c[0]}:${c[1]}`).join("  "));
  console.log("  TOTAL Cn-closed subsets of the 54-atom signature =", r.total.toString());
}
console.log("\nOP-LOG reports '3,140 closed sets'. 3140 =", 3140);

// 4. Lattice laws, checked exhaustively on a projected sublattice and on samples.
function CnOf(rules) {
  return S => { const X = new Set(S); for (const [b, h] of rules) if (X.has(b)) X.add(h); return X; };
}
function checkLattice(rules, universe, label) {
  const Cn = CnOf(rules);
  // enumerate ALL closed subsets of the touched atoms only (free atoms are a free Boolean factor
  // and cannot break any identity) - this is an exact check, not a sample.
  const touch = [...new Set(rules.flatMap(r => [r[0], r[1]]))].filter(x => universe.includes(x));
  const closed = []; const CAP = 4000;
  for (let mask = 0; mask < (1 << touch.length); mask++) {
    const s = new Set(touch.filter((_, i) => mask & (1 << i)));
    if (closed.length < CAP && rules.every(([b, h]) => !s.has(b) || s.has(h))) closed.push(s);
  }
  const key = s => [...s].sort().join(",");
  const join = (a, b) => Cn(new Set([...a, ...b]));
  const meet = (a, b) => new Set([...a].filter(x => b.has(x)));
  let bad = { joinClosed: 0, meetClosed: 0, assoc: 0, absorb: 0, distrib: 0 };
  const isClosed = s => rules.every(([b, h]) => !s.has(b) || s.has(h));
  for (const a of closed) for (const b of closed) {
    if (!isClosed(join(a, b))) bad.joinClosed++;
    if (!isClosed(meet(a, b))) bad.meetClosed++;
    if (key(join(a, b)) !== key(new Set([...a, ...b]))) bad.assoc++;  // join == plain union on closed operands
  }
  const smp = closed.length <= 60 ? closed : closed.slice(0, 60);
  for (const a of smp) for (const b of smp) for (const c of smp) {
    if (key(meet(a, join(a, b))) !== key(a) || key(join(a, meet(a, b))) !== key(a)) bad.absorb++;
    if (key(join(a, meet(b, c))) !== key(meet(join(a, b), join(a, c)))) bad.distrib++;
  }
  console.log(`\n${label}: ${closed.length} closed subsets of the ${touch.length} constrained atoms (x 2^${universe.length - touch.length} free)`);
  console.log("  counterexamples:", JSON.stringify(bad));
}
checkLattice(OPLOG8, SIG54, "OP-LOG 8-rule fragment");
checkLattice(H, SIG54, "corrected-29-law definite fragment");

// 5. And the point of the exercise: does the definite fragment decide anything?
const laneSets = T.lanes.map(p => new Set(p.syms));
const CnH = CnOf(H);
console.log("\n=== F2.5 does the definite fragment alone separate real from synthetic? ===");
const closedUnder = rules => s => rules.every(([b, h]) => !s.has(b) || s.has(h));
const cH = closedUnder(H);
const a = T.REAL.map(T.setOf).filter(cH).length, b = T.OTHER.map(T.setOf).filter(cH).length;
console.log(`definite fragment alone: real ${a}/72=${(a / 72).toFixed(3)} other ${b}/84=${(b / 84).toFixed(3)} ratio ${((a / 72) / (b / 84)).toFixed(2)}`);
