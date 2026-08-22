/* Classify every conditional prohibition by clause polarity, properly.
 *
 * Horn      : at most one POSITIVE literal
 * dual-Horn : at most one NEGATIVE literal
 * A forbidden configuration F is the clause ¬F, so a purely conjunctive F of
 * positive atoms gives a purely negative clause, which is Horn.
 */
import { asSet, admissibility } from "./construct.mjs";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
// Resolved from this file's own location; DEFIFORMAL_ROOT overrides and says so.
const SELF_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const REPO_ROOT = process.env.DEFIFORMAL_ROOT || SELF_ROOT;
if (REPO_ROOT !== SELF_ROOT) console.error(`${path.basename(fileURLToPath(import.meta.url))}: NOTE - reading ${REPO_ROOT} (DEFIFORMAL_ROOT), not ${SELF_ROOT}`);


/* Each row as its forbidden configuration: positive atoms that must be present,
 * and negative atoms that must be ABSENT for the row to fire. */
const ROWS = {
  X2:    { present: [["Fl"], ["Cp","Cl"], ["Pl","Cd","Im"]], absent: [] },
  X21:   { present: [["Fl"], ["Xf","Rl","Of"]],              absent: [] },
  X18:   { present: [["Oa"], ["Li"]],                        absent: ["Ex","Tp"] },
  "X19*":{ present: [["Aw"], ["Xf"]],                        absent: ["At","Fz","Xm"] },
  "X11a*":{present: [["Uc"]],                                absent: ["Aw","At"] },
};

console.log("row    clause form (negation of the forbidden configuration)            class");
for (const [id, r] of Object.entries(ROWS)) {
  /* ¬(⋀ present ∧ ⋀ ¬absent) = ⋁ ¬present ∨ ⋁ absent, distributed over the
   * disjunctive present-groups into a CNF whose clauses each take one atom per group */
  const neg = r.present.length;          // one negative literal per present group
  const pos = r.absent.length;           // absent atoms appear positively
  const cls = pos <= 1 ? (neg <= 1 ? "Horn and dual-Horn" : "Horn")
                       : (neg <= 1 ? "dual-Horn" : "neither");
  const form = r.present.map(g => g.map(a => `¬${a}`).join("/")).join(" ∨ ")
             + (r.absent.length ? " ∨ " + r.absent.join(" ∨ ") : "");
  console.log(`${id.padEnd(6)} ${form.padEnd(62)} ${cls}`);
}

/* attribute the observed failures */
const P = [];
const L = `${REPO_ROOT}/corpus50/lanes`;
for (const f of fs.readdirSync(L).sort()) {
  const d = JSON.parse(fs.readFileSync(path.join(L, f), "utf8"));
  for (const c of d.categories) for (const p of c.protocols)
    P.push({ name: p.name, syms: [...new Set(p.elements)] });
}
const ok = P.filter(p => { const a = admissibility(asSet(p.syms)); return !a.req.length && !a.war.length; });
const count = {};
let pairs = 0, fails = 0;
for (let i = 0; i < ok.length; i++) for (let j = i + 1; j < ok.length; j++) {
  pairs++;
  const a = admissibility(new Set([...asSet(ok[i].syms), ...asSet(ok[j].syms)]));
  if (a.admissible) continue;
  fails++;
  for (const h of new Set(a.haz)) count[h] = (count[h] ?? 0) + 1;
}
console.log(`\n${pairs} pairs, ${fails} failures. Attribution (a pair may arm more than one row):`);
const HORN = new Set(["X2", "X21"]);
let horn = 0, mixed = 0;
for (const [k, v] of Object.entries(count).sort((a, b) => b[1] - a[1])) {
  const cls = HORN.has(k) ? "purely negative, Horn" : "mixed polarity, neither";
  console.log(`  ${k.padEnd(6)} ${String(v).padStart(4)}   ${cls}`);
  if (HORN.has(k)) horn += v; else mixed += v;
}
console.log(`\nfailures arming a Horn row:  ${horn}`);
console.log(`failures arming a mixed row: ${mixed}`);
