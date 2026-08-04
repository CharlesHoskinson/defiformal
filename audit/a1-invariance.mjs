// AUDIT M1: is the invariance measurement vacuous? and is 2^20 really exhaustive?
import * as T from "/root/DefiElements/formal/v2/tables.mjs";
const E = T.MECH;
const key = S => [...S].sort().join(",");
const D = T.DeltaInf;

console.log("|MECH| =", E.length, " |SYMS| =", T.SYMS.size);

// rebuild Cn exactly as f11 does
const DEF = [];
for (const law of T.PARSED_NEW) for (const s of law.subjects) for (const t of law.terms)
  if (!t.external && t.alts.length === 1 && t.alts[0] !== s) DEF.push([s, t.alts[0]]);
const Cn = X => { const Y = new Set(X); let ch = true; while (ch) { ch = false; for (const [b,h] of DEF) if (Y.has(b) && !Y.has(h)) { Y.add(h); ch = true; } } return Y; };
console.log("definite rules:", DEF.length, JSON.stringify(DEF));

const U20 = ["Fl","Xm","Xf","Rl","Of","Bs","Sl","Au","Gs","Uc","Aw","At","Cp","Cl","Pl","Cd","Ix","Sh","Ct","Li"];
const setOf20 = m => new Set(U20.filter((_,i) => m & (1<<i)));

// ---- TEST 3 re-derivation
let allDistinct = new Set(), insideDistinct = new Set(), escaped = new Set();
const store = [];
for (let m = 0; m < (1<<20); m++) {
  const C = Cn(setOf20(m)); const k = key(C);
  allDistinct.add(k);
  if ([...C].every(e => U20.includes(e))) { if (!insideDistinct.has(k)) { insideDistinct.add(k); store.push(C); } }
  else escaped.add(k);
}
console.log("\n=== TEST3 re-derivation ===");
console.log("subsets enumerated:", 1<<20);
console.log("distinct Cn-closures overall:", allDistinct.size);
console.log("distinct closures INSIDE U20 (the tested set):", insideDistinct.size);
console.log("distinct closures ESCAPING U20 (DISCARDED, untested):", escaped.size);
console.log("fraction of 2^20 subsets whose closure escapes and is thus untested:");
let nEsc=0; for (let m=0;m<(1<<20);m++){ const C=Cn(setOf20(m)); if(![...C].every(e=>U20.includes(e))) nEsc++; }
console.log("  subsets discarded:", nEsc, "=", (100*nEsc/(1<<20)).toFixed(2)+"%");

// ---- vacuity: does Delta ever move on the tested sets?
let moved=0, held=0, movedAndHeld=0;
for (const C of store) {
  const d = D(C);
  const m = d.size !== C.size;
  if (m) moved++;
  if (key(Cn(d)) === key(d)) { held++; if (m) movedAndHeld++; }
}
console.log("\nTEST3 tested closures:", store.length);
console.log("  Delta actually removed something:", moved, "(" + (100*moved/store.length).toFixed(2) + "%)");
console.log("  invariance held:", held, "/", store.length);
console.log("  NON-TRIVIAL cases (Delta moved AND invariance held):", movedAndHeld);
console.log("  => vacuous cases (Delta = identity, invariance trivially true):", store.length - moved);
