// meas:closureprops  --  "{Op,Tp} and {Ex,Op} both satisfy Law, their intersection {Op}
// does not (L1a unsatisfied). Sampling 194,775 pairs from R: 1,923 fail intersection-closure,
// 0 fail union-closure."
import * as L from "./lib.mjs";
import * as T from "/root/DefiElements/formal/v2/tables.mjs";

console.log("=== meas:closureprops ===\n");

// --- part 1: the stated witness
const A = L.S("Op", "Tp"), B = L.S("Ex", "Op"), I = L.cap(A, B);
console.log("witness  {Op,Tp} in R :", L.inR(A));
console.log("witness  {Ex,Op} in R :", L.inR(B));
console.log("witness  {Op}    in R :", L.inR(I), " open terms:", JSON.stringify(T.gammaOpen(I)));

// --- part 2: EXHAUSTIVE over all pairs of R-members of size <= 3 (stronger than sampling)
const small = [];
(function rec(start, cur) {
  const X = new Set(cur);
  if (L.inR(X)) small.push(X);
  if (cur.length === 3) return;
  for (let i = start; i < L.E.length; i++) { cur.push(L.E[i]); rec(i + 1, cur); cur.pop(); }
})(0, []);
let en = 0, eu = 0, ei = 0;
for (let i = 0; i < small.length; i++) for (let j = i; j < small.length; j++) {
  en++;
  if (!L.inR(L.uni(small[i], small[j]))) eu++;
  if (!L.inR(L.cap(small[i], small[j]))) ei++;
}
console.log(`\nEXHAUSTIVE over R-members of size<=3: |pool| = ${small.length}, pairs (i<=j) = ${en}`);
console.log(`  union-closure failures        : ${eu}`);
console.log(`  intersection-closure failures : ${ei}  (${(100 * ei / en).toFixed(3)}%)`);

// --- part 3: the paper's sampled figure, re-run with a FIXED seed
for (const seed of [1, 2, 3]) {
  const pool = L.sample(L.inR, 3000, 0.18, seed);
  let n = 0, uv = 0, iv = 0;
  for (let i = 0; i < pool.length; i++) for (let j = i + 1; j < Math.min(pool.length, i + 60); j++) {
    n++;
    if (!L.inR(L.uni(pool[i], pool[j]))) uv++;
    if (!L.inR(L.cap(pool[i], pool[j]))) iv++;
  }
  console.log(`\nSAMPLED (seed=${seed}, |pool|=${pool.length}, v2 probe4 pairing scheme): pairs ${n}`);
  console.log(`  union-closure failures        : ${uv}`);
  console.log(`  intersection-closure failures : ${iv}`);
}

// --- part 4: is the union-closure claim contradicted anywhere? adversarial search
let advU = 0, advI = 0, advN = 0, witI = null;
const pool2 = L.sample(L.inR, 4000, 0.35, 77);
for (let i = 0; i < pool2.length; i++) for (let j = i + 1; j < Math.min(pool2.length, i + 40); j++) {
  advN++;
  if (!L.inR(L.uni(pool2[i], pool2[j]))) advU++;
  if (!L.inR(L.cap(pool2[i], pool2[j]))) { advI++; if (!witI) witI = [pool2[i], pool2[j]]; }
}
console.log(`\nADVERSARIAL (density 0.35, seed 77): pairs ${advN}, union failures ${advU}, inter failures ${advI}`);
if (witI) console.log(`  first intersection witness: {${L.key(witI[0])}} ^ {${L.key(witI[1])}} = {${L.key(L.cap(witI[0], witI[1]))}}`);
