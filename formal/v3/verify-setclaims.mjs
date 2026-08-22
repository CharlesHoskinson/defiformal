// Round five, blocker 7: the gates did not fail on the manuscript errors they
// claim to detect. The proof of the closure proposition asserted that two sets
// lie in H when neither does, and thirteen checkers passed.
//
// None of them read the paper's SET-MEMBERSHIP claims. This one does: it finds
// every claim of the form "{A,B,C} ... lie(s) in <class>" in atlas.tex and
// decides it against the algebra.
import { readFileSync } from "node:fs";
import { inR, inW, inH, inRW, adm, grounded } from "./lib.mjs";
import * as T from "../v2/tables.mjs";
import path from "node:path";
import { fileURLToPath } from "node:url";
// Resolved from this file's own location; DEFIFORMAL_ROOT overrides and says so.
const SELF_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const REPO_ROOT = process.env.DEFIFORMAL_ROOT || SELF_ROOT;
if (REPO_ROOT !== SELF_ROOT) console.error(`${path.basename(fileURLToPath(import.meta.url))}: NOTE - reading ${REPO_ROOT} (DEFIFORMAL_ROOT), not ${SELF_ROOT}`);


const tex = readFileSync(`${REPO_ROOT}/paper/atlas.tex`, "utf8");
const E = new Set(T.MECH);

const CLASS = {
  "\\mathcal{R}": ["R", inR],
  "\\mathcal{W}": ["W", inW],
  "\\mathcal{H}": ["H", inH],
  "\\Pos": ["Pos", inRW],
  "\\Adm": ["Adm_0", X => inR(X) && inW(X) && inH(X)],
  "\\Admf": ["Adm", adm],
};

// a braced element list: {Aa,Bb,Cc}
const SET = "\\\\\\{([A-Z][a-z](?:\\s*,\\s*[A-Z][a-z])*)\\\\\\}";
// "<set> and <set> ... lie in <class>"  |  "<set> ... lies in <class>"
const PAT = new RegExp(
  SET + "\\$?\\s*(?:and|,)?\\s*(?:\\$?" + SET + "\\$?)?" +
  "[^.]{0,120}?\\b(?:lie|lies|both lie|all lie)\\s+in\\s+\\$?(" +
  Object.keys(CLASS).map(k => k.replace(/[\\{}]/g, m => "\\" + m)).join("|") + ")",
  "g");

const parse = s => new Set(s.split(",").map(x => x.trim()));
let checked = 0;
const bad = [];

let m;
while ((m = PAT.exec(tex)) !== null) {
  const cls = m[3];
  const [name, pred] = CLASS[cls];
  for (const raw of [m[1], m[2]]) {
    if (!raw) continue;
    const X = parse(raw);
    if ([...X].some(e => !E.has(e))) continue;      // not an element list
    checked++;
    if (!pred(X)) {
      const armed = T.bansCond(X);
      bad.push(`{${[...X].sort()}} is claimed in ${name} and is not` +
               (armed.length ? ` (arms ${armed.join(",")})` : ""));
    }
  }
}

console.log(`set-membership claims found in atlas.tex: ${checked}`);
for (const b of bad) console.log("  FAIL " + b);
console.log(bad.length
  ? `\nSET CLAIMS VIOLATED (${bad.length} of ${checked})`
  : `\nSET CLAIMS VERIFIED (${checked} of ${checked})`);
process.exit(bad.length ? 1 : 0);
