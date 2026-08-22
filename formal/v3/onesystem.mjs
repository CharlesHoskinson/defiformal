// After pointing lib.mjs at PARSED_NEW, the structural harness and the
// construction checker must decide requirement membership identically.
import { inR } from "./lib.mjs";
import { openRequirements } from "./construct.mjs";
import * as T from "../v2/tables.mjs";

const E = T.MECH;
let n = 0, bad = 0;
const ex = [];
for (let i = 0; i < E.length; i++)
  for (let j = i + 1; j < E.length; j++)
    for (let k = j + 1; k < E.length; k++) {
      const X = new Set([E[i], E[j], E[k]]);
      n++;
      const a = inR(X), b = openRequirements(X).length === 0;
      if (a !== b) { bad++; if (ex.length < 5) ex.push(`{${[...X]}} lib=${a} construct=${b}`); }
    }
console.log("3-subsets checked:", n);
console.log("lib.inR vs construct.openRequirements disagree:", bad);
for (const e of ex) console.log("   ", e);
console.log(bad ? "STILL TWO SYSTEMS" : "ONE SYSTEM: lib and construct agree everywhere");
process.exit(bad ? 1 : 0);
