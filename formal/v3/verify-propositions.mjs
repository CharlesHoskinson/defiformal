/* Verify council findings 4, 5 and 6 against the predicates, not the prose. */
import { asSet, admissibility, ex } from "/root/defiformal/formal/v3/construct.mjs";
import { MECH, HAZ_PROJ } from "/root/defiformal/formal/v2/tables.mjs";

const A = a => admissibility(asSet(a));

console.log("=== finding 4: are the two witnesses right, and does non-closure kill search?");
for (const X of [["Cp","Sh","Fl"],["Cp","Sh","Fl","Pl"],["Aw","Xf","At"],["Aw","Xf"]]) {
  const r = A(X);
  console.log(`  {${X.join(",")}} admissible=${r.admissible} armed=${JSON.stringify(r.haz)} openTerms=${r.req.length}`);
}
console.log("  -> both witnesses hold. Non-closure invalidates MONOTONE greedy search.");
console.log("     Increasing-cardinality enumeration with a fresh admissibility check still works:");
{
  /* demonstrate: find a minimal admissible cover by cardinality enumeration */
  const U = ["Sh","Ix","Rb","Pl","Ct","Ex","Tp","At","Li","Ad","Sl","Bs","Wq","Rd","Im","Ps"];
  const OBL = [["Sh","Ix","Rb"],["Pl"],["Ct"],["Ex","Tp","At"],["Li","Ad","Sl","Bs"],["Wq","Rd","Im","Ps"]];
  const covers = X => OBL.every(d => d.some(e => X.has(e)));
  let found = null;
  for (let k = 1; k <= 8 && !found; k++) {
    for (let m = 0; m < (1 << U.length); m++) {
      const bits = U.filter((_, i) => m & (1 << i));
      if (bits.length !== k) continue;
      const X = new Set(bits);
      if (covers(X) && A(bits).admissible) { found = bits; break; }
    }
  }
  console.log(`     smallest admissible cover by enumeration: {${found.join(",")}} at size ${found.length}`);
}

console.log("\n=== finding 5: is the recorded clutter itself downward closed?");
const rows = HAZ_PROJ.map(h => h.named);
console.log(`  enforceable prohibition rows (element sets): ${JSON.stringify(rows)}`);
let cw = null;
for (const H of rows) for (const e of H) {
  const sub = H.filter(x => x !== e);
  if (sub.length && !rows.some(R => R.length === sub.length && R.every(x => sub.includes(x)))) { cw = [H, sub]; break; }
}
if (cw) console.log(`  a proper subset of a listed row that is NOT itself listed: {${cw[1].join(",")}} < {${cw[0].join(",")}}`);
console.log("  -> the clutter is an antichain of MINIMAL forbidden sets, so it is not downward closed.");
console.log("     what is downward closed is its MODEL CLASS: if X models the prohibitions so does every subset.");
{
  /* the model class is downward closed: exhaustive over a 12-element universe */
  const U = ["Fl","Cp","Cl","Pl","Cd","Im","Xf","Rl","Of","Oa","Li","Ex"];
  let bad = 0, n = 0;
  for (let m = 0; m < (1 << U.length); m++) {
    const X = U.filter((_, i) => m & (1 << i));
    if (A(X).haz.length) continue;         // X models the prohibitions
    n++;
    for (const e of X) if (A(X.filter(x => x !== e)).haz.length) bad++;
  }
  console.log(`     exhaustive over ${1 << U.length} subsets: ${n} model the prohibitions, ${bad} have a subset that does not`);
}

console.log("\n=== finding 6: are there minimal constructions using elements outside the declared 16?");
{
  const U16 = ["Sh","Ix","Rb","Pl","Ct","Ex","Tp","At","Li","Ad","Sl","Bs","Wq","Rd","Im","Ps"];
  const OBL = [["Sh","Ix","Rb"],["Pl"],["Ct"],["Ex","Tp","At"],["Li","Ad","Sl","Bs"],["Wq","Rd","Im","Ps"]];
  const covers = X => OBL.every(d => d.some(e => X.has(e)));
  /* add a few support elements that discharge NO obligation, and see whether any
     minimal construction uses one */
  const EXTRA = ["Cp", "Cl", "Sr", "Ep"];
  const U = [...U16, ...EXTRA];
  const minimal = [];
  for (let m = 0; m < (1 << U.length); m++) {
    const bits = U.filter((_, i) => m & (1 << i));
    if (bits.length > 7) continue;
    const X = new Set(bits);
    if (!covers(X) || !A(bits).admissible) continue;
    const isMin = !bits.some(e => {
      const Y = bits.filter(x => x !== e);
      return covers(new Set(Y)) && A(Y).admissible;
    });
    if (isMin && bits.some(e => EXTRA.includes(e))) minimal.push(bits);
  }
  console.log(`  minimal constructions (size<=7) using a support element outside the declared alternatives: ${minimal.length}`);
  for (const m of minimal.slice(0, 4)) console.log(`    {${m.join(",")}}`);
  console.log("  -> the count of 60 is over the DECLARED universe; it is not all minimal");
  console.log("     constructions permitted by the definitions, because an element may be");
  console.log("     carried for admissibility while discharging no obligation.");
}
