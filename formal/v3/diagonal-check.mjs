// thm:bilattice turns on |R n W| >= 2: the diagonal is a product only if the
// set has at most one element. Check the side condition rather than assert it,
// and check the two obvious witnesses.
import * as T from "../v2/tables.mjs";
import { inRW } from "./lib.mjs";

const empty = new Set();
const top = new Set(T.MECH);
console.log("empty set in R n W :", inRW(empty));
console.log("full set  in R n W :", inRW(top));

// count members at small size, enough to establish |R n W| >= 2 concretely
const E = T.MECH;
let n = 0;
for (let i = 0; i < E.length; i++) if (inRW(new Set([E[i]]))) n++;
console.log("singletons in R n W:", n);
console.log("so |R n W| >= 2   :", (inRW(empty) && inRW(top)) || n >= 2);

// and the diagonal is closed under coordinatewise meet/join, which is why the
// argument must exclude it by HOW it is built, not by a closure property
console.log("\nnote: the diagonal IS closed under coordinatewise operations,");
console.log("so no closure property can exclude it; the argument has to be about");
console.log("which constructions are permitted from R (x) W.");
