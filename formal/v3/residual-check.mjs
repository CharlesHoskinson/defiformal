// The paper says both that War IS obtained as the residual of the requirement
// relation (sec 264) and that it is NOT the residual (sec 731). One is wrong.
//
// The consumer relation C is the shipped CONSUME table. The residual of R is
// the relation that pairs an element with the subjects that can require it:
// e is "consumed by" s exactly when some law with subject s has a term in which
// e appears as an alternative. Build that and compare.
import * as T from "../v2/tables.mjs";

const residual = {};
for (const l of T.PARSED_NEW)
  for (const t of l.terms) {
    if (t.external) continue;
    for (const alt of t.alts) {
      (residual[alt] ??= new Set());
      for (const s of l.subjects) residual[alt].add(s);
    }
  }

const C = T.CONSUME;
const elems = T.MECH;

let sameKeys = 0, diffKeys = 0, onlyC = [], onlyR = [], differ = [];
for (const e of elems) {
  const c = new Set(C[e] ?? []);
  const r = residual[e] ?? new Set();
  const hasC = (C[e] ?? []).length > 0, hasR = r.size > 0;
  if (!hasC && !hasR) continue;
  if (hasC && !hasR) { onlyC.push(e); continue; }
  if (!hasC && hasR) { onlyR.push(e); continue; }
  const eq = c.size === r.size && [...c].every(x => r.has(x));
  if (eq) sameKeys++;
  else { diffKeys++; if (differ.length < 6) differ.push([e, [...c].sort(), [...r].sort()]); }
}

console.log("elements with a CONSUME entry:", elems.filter(e => (C[e] ?? []).length).length);
console.log("elements with a residual entry:", Object.keys(residual).length);
console.log("");
console.log("both defined and EQUAL   :", sameKeys);
console.log("both defined and DIFFER  :", diffKeys);
console.log("only in CONSUME          :", onlyC.length, onlyC.slice(0, 8).join(",") || "-");
console.log("only in the residual     :", onlyR.length, onlyR.slice(0, 8).join(",") || "-");

console.log("\nexamples where they differ:");
for (const [e, c, r] of differ) {
  console.log(`  ${e}`);
  console.log(`     CONSUME  = {${c.join(",")}}`);
  console.log(`     residual = {${r.join(",")}}`);
}

const identical = diffKeys === 0 && onlyC.length === 0 && onlyR.length === 0;
console.log("\n" + (identical
  ? "C IS the residual: the sec-731 sentence is wrong"
  : "C is NOT the residual: the sec-264 sentence is wrong"));
