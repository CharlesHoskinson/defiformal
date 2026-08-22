// meas:latticeconf -- "Over 175,230 pairs from R n W there are 0 union-closure violations.
// Meet is not intersection. The count is the paper's to state, not this
// script's to duplicate - a copy here is how it went stale."
// cor:lattice -- R n W union-closed, contains empty and TOP, hence a complete lattice.
import * as L from "./lib.mjs";

console.log("=== meas:latticeconf / cor:lattice ===\n");

const EMPTY = new Set(), TOP = new Set(L.E);
console.log("empty in R n W :", L.inRW(EMPTY));
console.log("TOP   in R n W :", L.inRW(TOP));
console.log("TOP   admissible (i.e. also in H) :", L.adm(TOP));

for (const seed of [1, 2, 3]) {
  const pool = L.sample(L.inRW, 3000, 0.18, seed);
  let n = 0, uv = 0, iv = 0;
  for (let i = 0; i < pool.length; i++) for (let j = i + 1; j < Math.min(pool.length, i + 60); j++) {
    n++;
    if (!L.inRW(L.uni(pool[i], pool[j]))) uv++;
    if (!L.inRW(L.cap(pool[i], pool[j]))) iv++;
  }
  console.log(`\nseed=${seed}  |pool|=${pool.length}  pairs=${n}`);
  console.log(`  union-closure violations        : ${uv}   [paper: 0]`);
  console.log(`  intersection (meet != cap) viol : ${iv}`);
}

// EXHAUSTIVE over R n W members of size <= 3
const small = [];
(function rec(start, cur) {
  const X = new Set(cur);
  if (L.inRW(X)) small.push(X);
  if (cur.length === 3) return;
  for (let i = start; i < L.E.length; i++) { cur.push(L.E[i]); rec(i + 1, cur); cur.pop(); }
})(0, []);
let en = 0, eu = 0, ei = 0;
for (let i = 0; i < small.length; i++) for (let j = i; j < small.length; j++) {
  en++;
  if (!L.inRW(L.uni(small[i], small[j]))) eu++;
  if (!L.inRW(L.cap(small[i], small[j]))) ei++;
}
console.log(`\nEXHAUSTIVE over (R n W)-members of size<=3: |pool|=${small.length}, pairs=${en}`);
console.log(`  union-closure violations : ${eu}`);
console.log(`  intersection violations  : ${ei}`);
