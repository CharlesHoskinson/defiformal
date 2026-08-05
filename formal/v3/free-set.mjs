// Extend the 16-element free set as far as it goes. A free set is one whose
// every subset is admissible; its powerset is then a union-closed family inside
// Admf and can be exhibited by naming the elements.
import * as T from "/root/DefiElements/formal/v2/tables.mjs";
import { adm } from "/root/defiformal/formal/v3/lib.mjs";

const E = T.MECH;
let cur = ["Ag", "At", "Ba", "Cl", "Cp", "Ep", "In", "Ix",
           "Oa", "Ob", "Pm", "Rf", "Sh", "Sr", "St", "Wg"];

// verify the starting set exhaustively
function allSubsetsAdmissible(arr) {
  const n = arr.length;
  for (let m = 0; m < (1 << n); m++) {
    const X = new Set();
    for (let i = 0; i < n; i++) if (m & (1 << i)) X.add(arr[i]);
    if (!adm(X)) return false;
  }
  return true;
}
console.log("starting set of %d verified free: %s", cur.length, allSubsetsAdmissible(cur));

let added = true;
while (added && cur.length < 22) {
  added = false;
  for (const e of E) {
    if (cur.includes(e)) continue;
    const trial = cur.concat(e);
    if (allSubsetsAdmissible(trial)) {
      cur = trial;
      added = true;
      console.log("  extended to %d with %s", cur.length, e);
      break;
    }
  }
}

console.log("\nmaximal free set reached: %d elements", cur.length);
console.log("  {%s}", cur.slice().sort().join(","));
console.log("  powerset size 2^%d = %s", cur.length,
            Math.pow(2, cur.length).toLocaleString("en-US"));

// confirm no single further element can be added
const blockers = E.filter(e => !cur.includes(e)).filter(e => !allSubsetsAdmissible(cur.concat(e)));
console.log("  elements that cannot be added: %d of %d remaining",
            blockers.length, E.length - cur.length);
console.log("  maximal:", blockers.length === E.length - cur.length);
