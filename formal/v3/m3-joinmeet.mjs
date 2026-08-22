// prop:joinmeet -- "In R n W the join of A and B is A u B and the meet is Delta^omega(A n B).
// Meet is not intersection: {Cp,Fl} and {Cl,Fl} both lie in R n W while {Fl} does not."
import * as L from "./lib.mjs";
import * as T from "../v2/tables.mjs";

console.log("=== prop:joinmeet ===\n");

// --- the stated witness
for (const s of [["Cp", "Fl"], ["Cl", "Fl"], ["Fl"]]) {
  const X = new Set(s);
  console.log(`{${s.join(",")}}  in R: ${L.inR(X)}  in W: ${L.inW(X)}  in RnW: ${L.inRW(X)}` +
    (L.inRW(X) ? "" : `   open=${JSON.stringify(T.gammaOpen(X))} unwarranted=${JSON.stringify(T.unwarranted(X))}`));
}
{
  const A = new Set(["Cp", "Fl"]), B = new Set(["Cl", "Fl"]);
  const I = L.cap(A, B), D = T.DeltaInf(I);
  console.log(`  A n B = {${L.key(I)}};  Delta^w(A n B) = {${L.key(D)}};  in RnW: ${L.inRW(D)}`);
}

// --- the true meet: largest member of R n W contained in A n B (well-defined by union-closure)
function trueMeet(I) {
  const xs = [...I], k = xs.length;
  if (k > 20) return null;
  let best = new Set();
  for (let m = 0; m < (1 << k); m++) {
    const C = new Set(); for (let i = 0; i < k; i++) if (m & (1 << i)) C.add(xs[i]);
    if (C.size <= best.size) continue;
    if (L.inRW(C)) best = C;
  }
  return best;
}

// --- general test: is Delta^omega(A n B) the meet?
let n = 0, notInRW = 0, notMeet = 0, ok = 0;
let wit1 = null, wit2 = null;
const pool = L.sample(L.inRW, 900, 0.14, 11);
outer:
for (let i = 0; i < pool.length; i++) for (let j = i + 1; j < Math.min(pool.length, i + 12); j++) {
  const A = pool[i], B = pool[j], I = L.cap(A, B);
  if (I.size > 18) continue;
  const D = T.DeltaInf(I);
  const M = trueMeet(I);
  if (M === null) continue;
  n++;
  const dOK = L.inRW(D);
  if (!dOK) { notInRW++; if (!wit1) wit1 = [A, B, I, D]; }
  if (L.key(D) !== L.key(M)) { notMeet++; if (!wit2) wit2 = [A, B, I, D, M]; }
  else ok++;
  if (n >= 4000) break outer;
}
console.log(`\ntested ${n} pairs (|A n B| <= 18, true meet computed exhaustively over subsets)`);
console.log(`  Delta^w(A n B) NOT in R n W          : ${notInRW}`);
console.log(`  Delta^w(A n B) != true meet          : ${notMeet}`);
console.log(`  Delta^w(A n B) == true meet          : ${ok}`);
if (wit1) console.log(`  witness (not in RnW): A={${L.key(wit1[0])}} B={${L.key(wit1[1])}}\n     A n B = {${L.key(wit1[2])}}\n     Delta^w = {${L.key(wit1[3])}}  open=${JSON.stringify(T.gammaOpen(wit1[3]))}`);
if (wit2) console.log(`  witness (not the meet): A={${L.key(wit2[0])}} B={${L.key(wit2[1])}}\n     A n B   = {${L.key(wit2[2])}}\n     Delta^w = {${L.key(wit2[3])}}\n     trueMeet= {${L.key(wit2[4])}}`);

// --- minimal witness search over small sets
console.log("\nminimal counterexample search over R n W members of size <= 4:");
const small = [];
(function rec(start, cur) {
  const X = new Set(cur);
  if (L.inRW(X)) small.push(X);
  if (cur.length === 4) return;
  for (let i = start; i < L.E.length; i++) { cur.push(L.E[i]); rec(i + 1, cur); cur.pop(); }
})(0, []);
let found = 0;
outer2:
for (let i = 0; i < small.length; i++) for (let j = i + 1; j < small.length; j++) {
  const I = L.cap(small[i], small[j]);
  if (I.size === 0) continue;
  const D = T.DeltaInf(I), M = trueMeet(I);
  if (L.key(D) !== L.key(M)) {
    console.log(`  A={${L.key(small[i])}} B={${L.key(small[j])}} AnB={${L.key(I)}} Delta^w={${L.key(D)}} trueMeet={${L.key(M)}} Delta^w in RnW=${L.inRW(D)}`);
    if (++found >= 5) break outer2;
  }
}
if (!found) console.log("  none found at size <= 4");
