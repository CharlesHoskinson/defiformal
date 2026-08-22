/* USE the theorem. ex(A) = max_<=(A) is the canonical form of a protocol.
 * Compute it for all 72 and see what it says about named protocols. */
import { ROOT, PARSED_NEW, MECH } from "./tables.mjs";
import fs from "node:fs";

const E = MECH.slice();
/* definite arcs: single-alternative terms */
const ARC = new Map();
for (const l of PARSED_NEW) for (const s of l.subjects) for (const t of l.terms) {
  if (!t.external && t.alts.length === 1) { if (!ARC.has(s)) ARC.set(s, new Set()); ARC.get(s).add(t.alts[0]); }
}
const below = a => { const R = new Set(); const st = [a];
  while (st.length) { const x = st.pop(); for (const y of ARC.get(x) ?? []) if (!R.has(y)) { R.add(y); st.push(y); } } return R; };
const DOWN = new Map(E.map(e => [e, below(e)]));
const ex = A => [...A].filter(a => ![...A].some(b => b !== a && DOWN.get(b).has(a))).sort();

const CORPUS = [];
for (const f of fs.readdirSync(`${ROOT}/corpus50/lanes`)) {
  const d = JSON.parse(fs.readFileSync(`${ROOT}/corpus50/lanes/${f}`, "utf8"));
  for (const c of d.categories) for (const p of c.protocols)
    CORPUS.push({ name: p.name, cat: c.category, S: [...new Set(p.elements.filter(e => E.includes(e)))] });
}

const rows = CORPUS.map(p => ({ ...p, g: ex(p.S) })).map(r => ({ ...r, drop: r.S.length - r.g.length }));
console.log(`arcs ${[...ARC.values()].reduce((n,s)=>n+s.size,0)}, elements with a strict below-set: ${[...DOWN.values()].filter(s=>s.size).length}`);
console.log(`protocols where the canonical form is strictly smaller: ${rows.filter(r=>r.drop>0).length}/${rows.length}\n`);

console.log("protocols the theorem actually compresses:");
for (const r of rows.filter(x=>x.drop>0).sort((a,b)=>b.drop-a.drop))
  console.log(`  ${r.name.slice(0,34).padEnd(35)} ${String(r.S.length).padStart(2)} -> ${String(r.g.length).padStart(2)}   dropped: ${r.S.filter(e=>!r.g.includes(e)).join(",")}`);

/* do canonical forms collide where full sets did not, or separate where they did? */
const key = a => a.slice().sort().join(",");
const byFull = new Map(), byGen = new Map();
for (const r of rows) {
  (byFull.get(key(r.S)) ?? byFull.set(key(r.S), []).get(key(r.S))).push(r);
  (byGen.get(key(r.g)) ?? byGen.set(key(r.g), []).get(key(r.g))).push(r);
}
const coll = m => [...m.values()].filter(v => v.length > 1);
console.log(`\ncollisions on full element sets: ${coll(byFull).length} groups`);
console.log(`collisions on canonical forms:  ${coll(byGen).length} groups`);
for (const g of coll(byGen)) {
  const nw = !coll(byFull).some(f => f[0].name === g[0].name && f.length === g.length);
  console.log(`  ${nw ? "NEW " : "    "}${g.map(r=>r.name.slice(0,26)).join("  ==  ")}`);
}
/* composition demo on two named protocols */
const pick = n => rows.find(r => r.name.startsWith(n));
const A = pick("Aave"), B = pick("Uniswap");
if (A && B) {
  const u = [...new Set([...A.g, ...B.g])];
  const comp = ex(u);
  console.log(`\ncomposition, worked: ${A.name} (+) ${B.name}`);
  console.log(`  ex(A)      = {${A.g.join(",")}}`);
  console.log(`  ex(B)      = {${B.g.join(",")}}`);
  console.log(`  ex(A(+)B)  = {${comp.join(",")}}   dropped from the union: ${u.filter(e=>!comp.includes(e)).join(",") || "(none)"}`);
}
