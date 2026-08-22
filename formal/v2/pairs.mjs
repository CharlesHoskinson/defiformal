/* Which of the 72 real protocols actually compose? The composability question,
 * asked of named systems rather than of abstract sets. */
import { ROOT, PARSED_NEW, MECH, CONSUME, admissible, bansCond, ungrounded, armedListed } from "./tables.mjs";
import fs from "node:fs";

const E = MECH.slice();
const S2 = a => new Set(a.filter(e => E.includes(e)));
const sat = X => PARSED_NEW.every(l =>
  !l.subjects.some(s => X.has(s)) || l.terms.every(t => t.external || t.alts.some(a => X.has(a))));
const warranted = X => [...X].every(e => !CONSUME[e] || CONSUME[e].some(c => X.has(c)));

const P = [];
for (const f of fs.readdirSync(`${ROOT}/corpus50/lanes`)) {
  const d = JSON.parse(fs.readFileSync(`${ROOT}/corpus50/lanes/${f}`, "utf8"));
  for (const c of d.categories) for (const p of c.protocols)
    P.push({ name: p.name, cat: c.category, S: S2(p.elements) });
}
const ok = P.filter(p => sat(p.S) && warranted(p.S));
console.log(`protocols satisfying laws+warrants: ${ok.length}/${P.length}`);

let n = 0, fail = 0; const why = {}; const failed = [];
for (let i = 0; i < ok.length; i++) for (let j = i + 1; j < ok.length; j++) {
  const A = ok[i], B = ok[j], U = new Set([...A.S, ...B.S]);
  n++;
  const bad = [];
  if (!sat(U)) bad.push("laws");
  if (!warranted(U)) bad.push("warrants");
  if (ungrounded(U)) bad.push("grounding");
  const bc = bansCond(U); if (bc && bc.length) bad.push("bansCond");
  const al = armedListed(U); if (al && al.length) bad.push("listedHaz");
  if (bad.length) { fail++; const k = bad.join("+"); why[k] = (why[k] ?? 0) + 1; failed.push({ A, B, bad }); }
}
console.log(`\npairs: ${n}   compose cleanly: ${n - fail} (${Math.round(100*(n-fail)/n)}%)   fail: ${fail}`);
console.log("failure attribution:"); for (const [k, v] of Object.entries(why).sort((a,b)=>b[1]-a[1])) console.log(`   ${k.padEnd(24)} ${v}`);

/* which named protocols are most often incompatible? */
const cnt = new Map();
for (const f of failed) for (const p of [f.A, f.B]) cnt.set(p.name, (cnt.get(p.name) ?? 0) + 1);
console.log("\nmost frequently incompatible protocols:");
for (const [nm, c] of [...cnt.entries()].sort((a,b)=>b[1]-a[1]).slice(0, 10))
  console.log(`   ${nm.slice(0,38).padEnd(39)} ${c} of ${ok.length-1} partners`);

/* cross-category vs within */
let wc = 0, ac = 0;
for (const f of failed) (f.A.cat === f.B.cat ? wc++ : ac++);
console.log(`\nfailures within a category: ${wc}   across categories: ${ac}`);

console.log("\nsample failing pairs:");
for (const f of failed.slice(0, 6))
  console.log(`   ${f.A.name.slice(0,26)} + ${f.B.name.slice(0,26)}  ->  ${f.bad.join(",")}`);
