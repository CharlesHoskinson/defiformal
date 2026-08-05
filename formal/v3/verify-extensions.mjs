/* Recompute every number in the paper's extensions section from the committed
 * classification, so the section satisfies invariant 1 the way the rest does.
 *
 * The stage-4 script that produced these read RESIDUE.json from a Windows path
 * and asserted a population of 385, so it cannot re-run inside the repo and
 * would fail now that the residue has grown to 686. algebra/stage4/tagged.json
 * is the frozen artefact of that classification and is committed; this reads it.
 */
import fs from "node:fs";

const T = JSON.parse(fs.readFileSync("/root/defiformal/algebra/stage4/tagged.json", "utf8"));

/* group code -> kind of repair, as Definition "Kinds of repair" names them */
const KIND = {
  PARTY: "c", LEGAL: "c", FLOW: "c", ASSET: "c",
  MANDATE: "a", TRUST: "a", LOSS: "a", INSTR: "a", ADJUD: "a",
  CONSTR: "b", OPAQUE: "b", QUANT: "b",
  LEVEL: "d", DOMAIN: "c",
};

const n = T.length;
const byGroup = {}, byKind = {}, cats = {}, apps = {};
for (const t of T) {
  const g = t.g;
  byGroup[g] = (byGroup[g] ?? 0) + 1;
  const k = KIND[g] ?? "?";
  byKind[k] = (byKind[k] ?? 0) + 1;
  (cats[g] ??= new Set()).add(t.category);
  (apps[g] ??= new Set()).add(t.app);
}

const pct = x => (100 * x / n).toFixed(1);
let fail = 0;
const check = (what, got, want) => {
  const ok = String(got) === String(want);
  console.log(`${ok ? "ok  " : "FAIL"} ${what}: ${got}${ok ? "" : ` (paper says ${want})`}`);
  if (!ok) fail++;
};

console.log(`classified residue obligations: ${n}`);
check("population", n, 385);
console.log(`\ngroup sizes: ${Object.entries(byGroup).sort((a,b)=>b[1]-a[1]).map(([g,c])=>`${g} ${c}`).join(", ")}`);
console.log(`categories per group: ${Object.entries(cats).map(([g,s])=>`${g} ${s.size}`).join(", ")}`);

console.log(`\nby kind of repair:`);
for (const [k, label] of [["a","new element"],["c","new sort"],["b","new constraint form"],["d","new level"]])
  console.log(`  (${k}) ${label.padEnd(20)} ${byKind[k]}  ${pct(byKind[k])}%`);
check("kinds partition the population", Object.values(byKind).reduce((a,b)=>a+b,0), n);

check("new element count",        byKind.a, 172);
check("new element share",        pct(byKind.a), "44.7");
check("new sort count",           byKind.c, 134);
check("new sort share",           pct(byKind.c), "34.8");
check("new constraint form count", byKind.b, 51);
check("new constraint form share", pct(byKind.b), "13.2");
check("new level count",          byKind.d, 28);
check("new level share",          pct(byKind.d), "7.3");

/* the party sort as the paper scopes it: PARTY + FLOW + the holder half of LEGAL */
const party = (byGroup.PARTY ?? 0) + (byGroup.FLOW ?? 0);
console.log(`\nparty-sort core groups (PARTY+FLOW): ${party}`);
check("bounded mandate count", byGroup.MANDATE, 27);
check("bounded mandate categories", cats.MANDATE.size, 6);
check("discharge-by-construction count", byGroup.CONSTR, 11);
check("discharge-by-construction categories", cats.CONSTR.size, 4);
check("unnamed-mechanism count", byGroup.INSTR, 82);
check("unnamed-mechanism categories", cats.INSTR.size, 7);
check("unnamed-mechanism applications", apps.INSTR.size, 26);

console.log(`\n${fail} mismatch(es) against the paper`);
process.exit(fail ? 1 : 0);
