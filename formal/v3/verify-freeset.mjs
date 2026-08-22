// Verify the paper's free-set claim against the algebra.
//
// Anchored on the conj:frag block: an earlier version of this checker matched a
// different \{Ag,...\} list elsewhere in the paper and reported the paper broken
// when the checker was.
import { readFileSync } from "node:fs";
import { adm } from "./lib.mjs";
import path from "node:path";
import { fileURLToPath } from "node:url";
// Resolved from this file's own location; DEFIFORMAL_ROOT overrides and says so.
const SELF_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const REPO_ROOT = process.env.DEFIFORMAL_ROOT || SELF_ROOT;
if (REPO_ROOT !== SELF_ROOT) console.error(`${path.basename(fileURLToPath(import.meta.url))}: NOTE - reading ${REPO_ROOT} (DEFIFORMAL_ROOT), not ${SELF_ROOT}`);


const tex = readFileSync(`${REPO_ROOT}/paper/atlas.tex`, "utf8");
let fail = 0;
const say = (ok, msg) => { console.log(`  ${ok ? "ok  " : "FAIL"} ${msg}`); if (!ok) fail++; };

const i = tex.indexOf("\\label{conj:frag}");
if (i < 0) { console.log("  FAIL conj:frag not found"); process.exit(1); }
const block = tex.slice(i, tex.indexOf("\\end{conjecture}", i));

const m = block.match(/\\\{([A-Z][a-z](?:,[A-Z][a-z])+)\\\}/);
if (!m) { console.log("  FAIL no element list inside conj:frag"); process.exit(1); }
const els = m[1].split(",").map(s => s.trim());
console.log(`free set printed in conj:frag: ${els.length} elements`);
console.log(`  {${els.join(",")}}`);

let bad = null;
const total = 1 << els.length;
for (let k = 0; k < total; k++) {
  const X = new Set();
  for (let b = 0; b < els.length; b++) if (k & (1 << b)) X.add(els[b]);
  if (!adm(X)) { bad = [...X]; break; }
}
say(bad === null, `all ${total.toLocaleString("en-US")} subsets admissible` +
    (bad ? ` — counterexample {${bad}}` : ""));

const pretty = total.toLocaleString("en-US").replace(/,/g, "{,}");
say(block.includes(pretty), `conj:frag states ${pretty}, which is 2^${els.length}`);
say(block.includes(`2^{${els.length}}`), `conj:frag states the exponent as 2^{${els.length}}`);
say(!tex.includes("11{,}026"), "the retired 11,026 does not reappear anywhere");

console.log(fail ? "\nFREE-SET CLAIM VIOLATED" : "\nFREE-SET CLAIM VERIFIED");
process.exit(fail ? 1 : 0);
