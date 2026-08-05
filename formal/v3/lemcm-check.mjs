// lem:cm claims: for a single implication A -> B with B non-empty, the induced
// closure system is union-stable iff |A| = 1, or A = {} and |B| = 1.
//
// Round five gives two counterexamples. Check both by brute force over a small
// universe: build the closure induced by A -> B and test union-stability on all
// pairs of closed sets.
const U = ["a", "b", "c", "d"];
const subsets = () => {
  const out = [];
  for (let m = 0; m < (1 << U.length); m++)
    out.push(new Set(U.filter((_, i) => m & (1 << i))));
  return out;
};
const sup = (X, A) => [...A].every(x => X.has(x));
const close = (X, A, B) => {           // least superset satisfying A -> B
  const R = new Set(X);
  for (let g = 0; g < 10; g++) if (sup(R, A)) for (const b of B) R.add(b);
  return R;
};
const eq = (X, Y) => X.size === Y.size && [...X].every(x => Y.has(x));

function unionStable(A, B) {
  const closed = subsets().filter(X => eq(close(X, A, B), X));
  for (const X of closed) for (const Y of closed) {
    const u = new Set([...X, ...Y]);
    if (!eq(close(u, A, B), u)) return false;
  }
  return true;
}

const show = (A, B, note) => {
  const st = unionStable(new Set(A), new Set(B));
  const lemma = (A.length === 1) || (A.length === 0 && B.length === 1);
  console.log(`A={${A}} B={${B}}  union-stable=${st}  lemma predicts=${lemma}` +
              (st !== lemma ? "   <-- LEMMA WRONG" : "") + `   ${note}`);
};

console.log("counterexample 1: B subset of A, so the implication is tautological");
show(["a", "b"], ["a"], "|A|=2, closure is the identity");
show(["a", "b", "c"], ["b", "c"], "|A|=3, closure is the identity");

console.log("\ncounterexample 2: A empty, closure is X -> X u B");
show([], ["a", "b"], "|B|=2");
show([], ["a", "b", "c"], "|B|=3");

console.log("\nthe case the paper actually uses: singleton premise");
show(["a"], ["b"], "|A|=1");
show(["a"], ["b", "c"], "|A|=1, |B|=2");

console.log("\nand a genuine failure, which is what the lemma is for");
show(["a", "b"], ["c"], "|A|=2, B not inside A");
