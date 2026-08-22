// cor:oplusclosed claims P is closed under composition, "verified on 96,720
// pairs". No committed script produces 96,720 and no natural population gives
// it. Compute the closure check over populations that can be stated exactly.
//
// oplus(X,Y) = Cn(X u Y), so this is not the same as union-closure: Cn adds the
// definite consequences, and the question is whether the result stays in P.
import * as T from "../v2/tables.mjs";
import { inRW } from "./lib.mjs";

const E = T.MECH;

// Cn: close under singleton-term requirements
const ARC = new Map();
for (const l of T.PARSED_NEW)
  for (const s of l.subjects) for (const t of l.terms)
    if (!t.external && t.alts.length === 1) {
      if (!ARC.has(s)) ARC.set(s, new Set());
      ARC.get(s).add(t.alts[0]);
    }
const Cn = X => {
  const R = new Set(X), st = [...X];
  while (st.length) {
    const x = st.pop();
    for (const y of ARC.get(x) ?? []) if (!R.has(y)) { R.add(y); st.push(y); }
  }
  return R;
};

function census(maxSize, label) {
  const M = [];
  const push = a => { const X = new Set(a); if (inRW(X)) M.push(X); };
  push([]);
  for (let i = 0; i < E.length; i++) {
    if (maxSize >= 1) push([E[i]]);
    for (let j = i + 1; maxSize >= 2 && j < E.length; j++) {
      push([E[i], E[j]]);
      for (let k = j + 1; maxSize >= 3 && k < E.length; k++) push([E[i], E[j], E[k]]);
    }
  }
  let pairs = 0, fail = 0;
  let firstFail = null;
  for (let a = 0; a < M.length; a++)
    for (let b = a; b < M.length; b++) {
      pairs++;
      const comp = Cn(new Set([...M[a], ...M[b]]));
      if (!inRW(comp)) {
        fail++;
        if (!firstFail) firstFail = [[...M[a]], [...M[b]], [...comp]];
      }
    }
  console.log(`${label}: ${M.length} members, ${pairs.toLocaleString("en-US")} pairs including the diagonal, ${fail} failures`);
  if (firstFail) console.log("   first failure:", JSON.stringify(firstFail));
  return { members: M.length, pairs, fail };
}

census(1, "members of size <= 1");
census(2, "members of size <= 2");
const r3 = census(3, "members of size <= 3");

console.log("\nthe paper says 96,720 pairs; nothing here produces that.");
console.log(`the exhaustive statement available is: ${r3.pairs.toLocaleString("en-US")} pairs, ${r3.fail} failures`);
