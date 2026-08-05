// The body's headline measurements, checked at their location.
//
// The three summary tables are done. These two carry the paper's central
// empirical claim - which protocols compose and why they fail - and until now
// were only corpus-checked, the state claims.mjs was found in.
//
// Predicates imported from pairs.mjs's source of truth, not reimplemented.
//
// KNOWN WEAKNESS, demonstrated by negtest-measurements.sh: a value is looked for
// anywhere in its measurement block, not at the specific claim. Numeral changes
// are caught. A spelled-out number that occurs twice in one block is not:
// meas:pairs says both "Twenty of the 61 compose" and "twenty protocols at
// none", so changing the first still finds the second and the check passes.
// Anchoring each claim to its sentence is the fix and is not done here.
import { readFileSync, readdirSync } from "node:fs";
import { PARSED_NEW, MECH, CONSUME, bansCond, ungrounded, armedListed }
  from "/root/DefiElements/formal/v2/tables.mjs";

const tex = readFileSync("/root/defiformal/paper/atlas.tex", "utf8");
const E = MECH.slice();
const S2 = a => new Set((a ?? []).filter(e => E.includes(e)));
const sat = X => PARSED_NEW.every(l =>
  !l.subjects.some(s => X.has(s)) || l.terms.every(t => t.external || t.alts.some(a => X.has(a))));
const warranted = X => [...X].every(e => !CONSUME[e] || CONSUME[e].some(c => X.has(c)));

const P = [];
for (const f of readdirSync("/root/DefiElements/corpus50/lanes")) {
  const d = JSON.parse(readFileSync(`/root/DefiElements/corpus50/lanes/${f}`, "utf8"));
  for (const c of d.categories) for (const p of c.protocols)
    P.push({ name: p.name, cat: c.category, S: S2(p.elements) });
}
const ok = P.filter(p => sat(p.S) && warranted(p.S));

let pairs = 0, fails = 0, sameCat = 0;
let byReq = 0, byWar = 0, byGrd = 0;
const armed = new Map();
const partners = new Map(ok.map(p => [p.name, 0]));
for (let i = 0; i < ok.length; i++)
  for (let j = i + 1; j < ok.length; j++) {
    const A = ok[i], B = ok[j], U = new Set([...A.S, ...B.S]);
    pairs++;
    let bad = false;
    if (!sat(U)) { byReq++; bad = true; }
    if (!warranted(U)) { byWar++; bad = true; }
    if (ungrounded(U)) { byGrd++; bad = true; }
    const rows = new Set([...(bansCond(U) ?? []), ...(armedListed(U) ?? [])]);
    if (rows.size) bad = true;
    if (!bad) continue;
    fails++;
    if (A.cat === B.cat) sameCat++;
    for (const r of rows) armed.set(r, (armed.get(r) ?? 0) + 1);
    partners.set(A.name, partners.get(A.name) + 1);
    partners.set(B.name, partners.get(B.name) + 1);
  }
const universal = [...partners.values()].filter(c => c === 0).length;
const maxPartners = Math.max(...partners.values());

let fail = 0;
const say = (o, m) => { console.log(`  ${o ? "ok  " : "FAIL"} ${m}`); if (!o) fail++; };
const block = lab => {
  const m = tex.match(new RegExp("\\\\begin\\{measurement\\}(?:\\[[^\\]]*\\])?\\\\label\\{" +
    lab.replace(":", ":") + "\\}([\\s\\S]*?)\\\\end\\{measurement\\}"));
  return m ? m[1] : null;
};
const lit = n => String(n).replace(/\B(?=(\d{3})+(?!\d))/g, "{,}");
// the paper spells small numbers out in prose, so a numeral-only test reports
// a defect that is not there.
const WORDS = ["zero","one","two","three","four","five","six","seven","eight",
  "nine","ten","eleven","twelve","thirteen","fourteen","fifteen","sixteen",
  "seventeen","eighteen","nineteen","twenty"];
const cap = w => w[0].toUpperCase() + w.slice(1);
const inBlock = (b, n) => {
  if (b.includes(`$${lit(n)}$`) || b.includes(lit(n))) return true;
  if (n < WORDS.length) return b.includes(WORDS[n]) || b.includes(cap(WORDS[n]));
  return false;
};

// ---- meas:pairs -------------------------------------------------------------
const bp = block("meas:pairs");
if (!bp) say(false, "meas:pairs not found");
else {
  console.log("meas:pairs");
  say(inBlock(bp, P.length), `${P.length} protocols`);
  say(inBlock(bp, ok.length), `${ok.length} satisfy requirements and warrants`);
  say(inBlock(bp, pairs), `${lit(pairs)} unordered pairs`);
  say(inBlock(bp, pairs - fails), `${lit(pairs - fails)} compose`);
  say(inBlock(bp, fails), `${fails} do not`);
  say(inBlock(bp, fails - sameCat), `${fails - sameCat} cross-category`);
  say(inBlock(bp, sameCat), `${sameCat} within one category`);
  say(inBlock(bp, universal), `${universal} compose with every other`);
  say(inBlock(bp, maxPartners), `${maxPartners} is the worst partner count`);
  say(byReq === 0 && byWar === 0 && byGrd === 0,
      `no failure through requirements (${byReq}), warrants (${byWar}) or grounding (${byGrd})`);
}

// ---- meas:whereitfails ------------------------------------------------------
const bw = block("meas:whereitfails");
if (!bw) say(false, "meas:whereitfails not found");
else {
  console.log("\nmeas:whereitfails");
  say(inBlock(bw, fails), `${fails} failing pairs`);
  say(inBlock(bw, ok.length), `among ${ok.length} satisfying protocols`);
  for (const row of ["X21", "X2", "X19*"]) {
    const n = armed.get(row) ?? 0;
    say(inBlock(bw, n), `${n} arm ${row}`);
  }
  say((armed.get("X11a*") ?? 0) === 0, `X11a* causes no failure (${armed.get("X11a*") ?? 0})`);
}

console.log(`\narmed rows overall: ${[...armed.entries()].map(([k, v]) => `${k}=${v}`).join(" ")}`);
console.log(fail ? "BODY MEASUREMENTS VIOLATED" : "BODY MEASUREMENTS VERIFIED");
process.exit(fail ? 1 : 0);
