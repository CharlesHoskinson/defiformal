// thm:excomp -- is acyclicity actually NEEDED, or is it decoration?
// The Lean proof `ex_reachCl_union_ex` takes antisymmetry as a hypothesis. Machine-check that
// it cannot be dropped, on the smallest digraph with a 2-cycle.
const V = ["x", "y", "z"];
const ARCS = [["x", "y"], ["y", "x"], ["x", "z"], ["y", "z"]];   // x <-> y, both -> z
const adj = new Map();
for (const [a, b] of ARCS) { if (!adj.has(a)) adj.set(a, []); adj.get(a).push(b); }
const reach = s => { const seen = new Set([s]), q = [s];
  while (q.length) { const v = q.pop(); for (const w of (adj.get(v) || [])) if (!seen.has(w)) { seen.add(w); q.push(w); } }
  return seen; };
const key = S => [...S].sort().join(",");
const ex = S => new Set([...S].filter(a => ![...S].some(b => b !== a && reach(b).has(a))));
const maxOf = S => new Set([...S].filter(a => ![...S].some(b => b !== a && reach(b).has(a))));

const A = new Set(["z"]), B = new Set(["x", "y", "z"]);   // both CLOSED, as thm:excomp requires
const AB = new Set([...A, ...B]);
console.log("digraph: x<->y, x->z, y->z   (one non-trivial SCC {x,y})");
console.log("A =", key(A), " closed?", key(new Set([...A].flatMap(s => [...reach(s)]))) === key(A));
console.log("B =", key(B), " closed?", key(new Set([...B].flatMap(s => [...reach(s)]))) === key(B));
console.log("ex(A)      =", "{" + key(ex(A)) + "}");
console.log("ex(B)      =", "{" + key(ex(B)) + "}");
console.log("LHS ex(AuB)=", "{" + key(ex(AB)) + "}");
const rhs = maxOf(new Set([...ex(A), ...ex(B)]));
console.log("RHS max(exA u exB) =", "{" + key(rhs) + "}");
console.log("thm:excomp holds here?", key(ex(AB)) === key(rhs));
