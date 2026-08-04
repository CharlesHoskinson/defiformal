// F1 - verify the OP-ORD ablation independently, plus P14 (the parser fix).
import * as T from "./tables.mjs";
const S = c => T.setOf(c);
const R = T.REAL.map(S), O = T.OTHER.map(S);
const ratio = (a, b) => (b === 0 ? Infinity : (a / R.length) / (b / O.length));
const score = pred => {
  const a = R.filter(pred).length, b = O.filter(pred).length;
  return { real: a, ro: (a / R.length).toFixed(3), other: b, oo: (b / O.length).toFixed(3), ratio: ratio(a, b).toFixed(2) };
};

console.log("=== P14: the parser fix, measured on the 72 real decompositions ===");
const laneSets = T.lanes.map(p => new Set(p.syms));
console.log("closes under OLD parser:", laneSets.filter(T.closesOld).length, "/ 72");
console.log("closes under NEW parser:", laneSets.filter(T.closesNew).length, "/ 72");
for (const lid of ["L6", "L7", "L8", "L14", "L15"]) {
  const rejOld = laneSets.filter(s => T.openTerms(s, T.PARSED_OLD).some(x => x[0] === lid)).length;
  const rejNew = laneSets.filter(s => T.openTerms(s, T.PARSED_NEW).some(x => x[0] === lid)).length;
  console.log(`  ${lid}: rejects ${rejOld}/72 old -> ${rejNew}/72 new`);
}
// the "6/12 -> 9/12" claim is about element-expressible law ROWS, not protocols
const fireable = p => p.filter(l => l.subjects.length > 0);
const decidable = p => fireable(p).filter(l => l.terms.some(t => !t.external));
console.log("fireable laws:", fireable(T.PARSED_OLD).length, "| with >=1 decidable term: old",
  decidable(T.PARSED_OLD).length, "new", decidable(T.PARSED_NEW).length);

console.log("\n=== F1: blocks alone (independent re-implementation) ===");
const blocks = {
  "G (closure)": s => T.gammaOpen(s).length === 0,
  "D (warrant)": s => T.unwarranted(s).length === 0,
  "Ban+Cond": s => T.bansCond(s).length === 0,
  "Ground": s => !T.ungrounded(s),
};
for (const [k, f] of Object.entries(blocks)) console.log(k.padEnd(14), JSON.stringify(score(f)));
console.log("G AND D".padEnd(14), JSON.stringify(score(s => blocks["G (closure)"](s) && blocks["D (warrant)"](s))));
console.log("\n=== drop one ===");
for (const k of Object.keys(blocks))
  console.log(("without " + k).padEnd(22), JSON.stringify(score(s => Object.entries(blocks).every(([j, f]) => j === k || f(s)))));
console.log("\nall four".padEnd(22), JSON.stringify(score(s => T.admissible(s))));

console.log("\n=== reference baselines on the same split ===");
console.log("accept everything ", JSON.stringify(score(() => true)));
console.log("ref closure OLD   ", JSON.stringify(score(T.closesOld)));
console.log("ref closure NEW   ", JSON.stringify(score(T.closesNew)));
console.log("ref OLD + hazards ", JSON.stringify(score(s => T.closesOld(s) && T.armedListed(s).length === 0)));

console.log("\n=== is the product super-multiplicative? ===");
const rG = R.filter(blocks["G (closure)"]).length / R.length, oG = O.filter(blocks["G (closure)"]).length / O.length;
const rD = R.filter(blocks["D (warrant)"]).length / R.length, oD = O.filter(blocks["D (warrant)"]).length / O.length;
console.log("ratio(G)*ratio(D) if independent =", ((rG / oG) * (rD / oD)).toFixed(2));
const both = score(s => blocks["G (closure)"](s) && blocks["D (warrant)"](s));
console.log("observed ratio(G AND D)          =", both.ratio);
// correlation of the two rejections on the negatives
const a = O.filter(s => !blocks["G (closure)"](s)).length, b = O.filter(s => !blocks["D (warrant)"](s)).length;
const ab = O.filter(s => !blocks["G (closure)"](s) && !blocks["D (warrant)"](s)).length;
console.log(`negatives: G rejects ${a}, D rejects ${b}, both ${ab}, expected-if-independent ${(a * b / O.length).toFixed(1)}`);

console.log("\n=== robustness: 2000 bootstrap resamples of the 156-case split ===");
const rnd = (n) => Math.floor(Math.random() * n);
let rs = [];
for (let i = 0; i < 2000; i++) {
  let ra = 0, ob = 0;
  for (let j = 0; j < R.length; j++) if (T.admissible(R[rnd(R.length)])) ra++;
  for (let j = 0; j < O.length; j++) if (T.admissible(O[rnd(O.length)])) ob++;
  rs.push(ob === 0 ? Infinity : (ra / R.length) / (ob / O.length));
}
rs.sort((x, y) => x - y);
const finite = rs.filter(Number.isFinite);
console.log(`median ${rs[1000].toFixed(2)}  p2.5 ${rs[50].toFixed(2)}  p97.5 ${rs[1949] === Infinity ? "inf" : rs[1949].toFixed(2)}  (${rs.length - finite.length}/2000 resamples had zero false accepts)`);

console.log("\n=== false rejects among the 72 real ===");
for (const c of T.REAL) {
  const [ok, p] = T.admissible(S(c), true);
  if (!ok) console.log("  FR", c.id, (T.LANESETS.get([...new Set(c.elements)].sort().join(",")) || []).join("/"),
    JSON.stringify(Object.fromEntries(Object.entries(p).filter(([, v]) => v && v.length !== 0))));
}
console.log("\n=== false accepts among the 84 other ===");
for (const c of T.OTHER) if (T.admissible(S(c))) console.log("  FA", c.id, [...S(c)].sort().join(" "));
