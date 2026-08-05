/* Which named protocols compose with EVERYTHING, and which with nothing new? */
import { PARSED_NEW, MECH, CONSUME, bansCond, ungrounded, armedListed } from "./tables.mjs";
import fs from "node:fs";
const E = MECH.slice(), S2 = a => new Set(a.filter(e => E.includes(e)));
const sat = X => PARSED_NEW.every(l => !l.subjects.some(s => X.has(s)) || l.terms.every(t => t.external || t.alts.some(a => X.has(a))));
const warr = X => [...X].every(e => !CONSUME[e] || CONSUME[e].some(c => X.has(c)));

const P = [];
for (const f of fs.readdirSync("/root/DefiElements/corpus50/lanes")) {
  const d = JSON.parse(fs.readFileSync(`/root/DefiElements/corpus50/lanes/${f}`, "utf8"));
  for (const c of d.categories) for (const p of c.protocols) P.push({ name: p.name, cat: c.category, S: S2(p.elements) });
}
const ok = P.filter(p => sat(p.S) && warr(p.S));
const bad = new Map(ok.map(p => [p.name, 0]));
const failedPairs = [];
for (let i = 0; i < ok.length; i++) for (let j = i + 1; j < ok.length; j++) {
  const U = new Set([...ok[i].S, ...ok[j].S]);
  const f = !sat(U) || !warr(U) || ungrounded(U) || (bansCond(U) || []).length || (armedListed(U) || []).length;
  if (f) { bad.set(ok[i].name, bad.get(ok[i].name) + 1); bad.set(ok[j].name, bad.get(ok[j].name) + 1); failedPairs.push([ok[i], ok[j]]); }
}
const universal = ok.filter(p => bad.get(p.name) === 0);
console.log(`protocols that compose with EVERY other in the corpus: ${universal.length}/${ok.length}`);
const byCat = {};
for (const p of universal) (byCat[p.cat] ??= []).push(p.name);
for (const [c, ns] of Object.entries(byCat).sort((a,b)=>b[1].length-a[1].length))
  console.log(`  ${c.slice(0,36).padEnd(37)} ${ns.length}`);
console.log("\ncategories with NO universally-safe member:");
for (const c of [...new Set(ok.map(p=>p.cat))]) if (!byCat[c]) console.log(`  ${c}`);
console.log("\nthe 3 within-category failures:");
for (const [a, b] of failedPairs.filter(([a,b]) => a.cat === b.cat)) console.log(`  ${a.name} + ${b.name}   [${a.cat}]`);
