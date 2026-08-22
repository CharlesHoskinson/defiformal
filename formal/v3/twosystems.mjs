import * as T from "../v2/tables.mjs";
const E = T.MECH;

// LSTAR rows are [id, subjects[], terms[][]]; PARSED_NEW rows are objects.
const arcsL = new Set();
for (const [id, subs, terms] of T.LSTAR)
  for (const s of subs) for (const t of terms)
    if (t.length === 1) arcsL.add(`${s}->${t[0]}`);

const arcsP = new Set();
for (const l of T.PARSED_NEW)
  for (const s of l.subjects) for (const t of l.terms)
    if (!t.external && t.alts.length === 1) arcsP.add(`${s}->${t.alts[0]}`);

console.log("LSTAR rows      :", T.LSTAR.length, " definite arcs:", arcsL.size);
console.log("PARSED_NEW rows :", T.PARSED_NEW.length, " definite arcs:", arcsP.size);
console.log("  only in PARSED_NEW:", [...arcsP].filter(a => !arcsL.has(a)).join(", ") || "(none)");
console.log("  only in LSTAR     :", [...arcsL].filter(a => !arcsP.has(a)).join(", ") || "(none)");

const inR_L = X => T.gammaOpen(X).length === 0;
const inR_P = X => !T.PARSED_NEW.some(l =>
  l.subjects.some(s => X.has(s)) &&
  l.terms.some(t => !t.external && !t.alts.some(a => X.has(a))));

let n = 0, dis = 0, mL = 0, mP = 0;
const ex = [];
for (let i = 0; i < E.length; i++)
  for (let j = i + 1; j < E.length; j++)
    for (let k = j + 1; k < E.length; k++) {
      const X = new Set([E[i], E[j], E[k]]);
      n++;
      const a = inR_L(X), b = inR_P(X);
      if (a) mL++;
      if (b) mP++;
      if (a !== b) { dis++; if (ex.length < 5) ex.push(`{${[...X]}}  LSTAR=${a} PARSED_NEW=${b}`); }
    }

console.log(`\n3-element subsets: ${n}`);
console.log(`satisfy requirements under LSTAR     : ${mL}`);
console.log(`satisfy requirements under PARSED_NEW: ${mP}`);
console.log(`the two DISAGREE on                  : ${dis}`);
for (const e of ex) console.log("   ", e);
console.log(dis ? "\nTWO INEQUIVALENT SYSTEMS - round 4 finding 2 CONFIRMED"
                : "\nthe two agree on this fragment");
