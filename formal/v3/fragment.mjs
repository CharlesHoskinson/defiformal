// conj:frag asserts "a witnessed lower bound of 11,026 admissible sets is
// exhibited below". Nothing in formal/ computes 11,026 and nothing exhibits the
// family. Try to produce a real witnessed lower bound.
//
// The cleanest witness is a set of elements E0 every subset of which is
// admissible: its powerset is union-closed by construction and sits inside
// Admf, so it exhibits 2^|E0| sets and can be printed in full.
import * as T from "/root/DefiElements/formal/v2/tables.mjs";
import { adm, inRW } from "/root/defiformal/formal/v3/lib.mjs";

const E = T.MECH;

// which single elements are admissible on their own?
const singles = E.filter(e => adm(new Set([e])));
console.log(`elements admissible as singletons: ${singles.length} of ${E.length}`);

// greedily grow a set all of whose subsets are admissible
function powersetAdmissible(arr) {
  const n = arr.length;
  for (let m = 0; m < (1 << n); m++) {
    const X = new Set();
    for (let i = 0; i < n; i++) if (m & (1 << i)) X.add(arr[i]);
    if (!adm(X)) return false;
  }
  return true;
}

let best = [];
// deterministic greedy from each starting element, then keep the largest
for (const start of singles) {
  const cur = [start];
  for (const e of singles) {
    if (cur.includes(e)) continue;
    if (cur.length >= 20) break;               // 2^20 is already far past 11,026
    const trial = cur.concat(e);
    if (trial.length <= 16 && powersetAdmissible(trial)) cur.push(e);
  }
  if (cur.length > best.length) best = cur;
}

console.log(`\nlargest free set found: ${best.length} elements`);
console.log(`  {${best.sort().join(",")}}`);
console.log(`  its powerset has ${Math.pow(2, best.length).toLocaleString("en-US")} members,`);
console.log(`  all admissible, union-closed by construction`);

// how does that compare with the claim?
const claimed = 11026;
const got = Math.pow(2, best.length);
console.log(`\nthe paper claims a witnessed lower bound of ${claimed.toLocaleString("en-US")}`);
console.log(got >= claimed
  ? `  this construction meets it: ${got.toLocaleString("en-US")} >= ${claimed.toLocaleString("en-US")}`
  : `  this construction does NOT reach it: ${got.toLocaleString("en-US")} < ${claimed.toLocaleString("en-US")}`);

// is 11026 a plausible powerset size?
console.log(`\n2^13 = 8,192   2^14 = 16,384   -- 11,026 is not a power of two,`);
console.log(`so whatever produced it was not a free-set powerset.`);
