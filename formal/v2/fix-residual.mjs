/* Can invariance be fixed?
 *
 * The audit found 33 of 63 (subject, term-alternative) pairs violate "C is the
 * residual of R". My proof of invariance assumed the residual property and is
 * fine AS A PROOF - the data simply did not satisfy its hypothesis.
 *
 * So: compute C as the ACTUAL residual and re-test. If invariance becomes true,
 * the structure theorem is recoverable. But making C larger means more elements
 * have a consumer present, so Delta removes less - and Delta already fires on
 * only 1 of 72 real protocols. The fix may buy structure at the cost of content.
 * Measure both.
 */
import { ROOT, PARSED_NEW, MECH, ELEMS, CONSUME, gammaOpen } from "./tables.mjs";
import fs from "node:fs";

const E = MECH.slice();
const S2 = a => new Set(a);

/* --- the TRUE residual: s consumes e iff s fires a term containing e --- */
const RESID = {};
for (const law of PARSED_NEW) {
  for (const s of law.subjects) {
    for (const t of law.terms) {
      if (t.external) continue;
      for (const e of t.alts) {
        (RESID[e] ??= new Set()).add(s);
      }
    }
  }
}
const residConsumers = e => RESID[e] ? [...RESID[e]] : null;

/* Delta under a given consumer table */
const mkDelta = consumersOf => {
  const step = X => {
    const out = new Set(X);
    for (const e of X) {
      const C = consumersOf(e);
      if (C && !C.some(c => out.has(c))) out.delete(e);
    }
    return out;
  };
  return X => { let a = X, b = step(a); while (b.size !== a.size) { a = b; b = step(a); } return b; };
};

const DeltaOld = mkDelta(e => (CONSUME[e] ? CONSUME[e] : null));
const DeltaNew = mkDelta(residConsumers);

/* --- how far off was the old table? --- */
let missing = 0, total = 0;
for (const e of Object.keys(RESID)) {
  for (const s of RESID[e]) {
    total++;
    if (!CONSUME[e] || !CONSUME[e].includes(s)) missing++;
  }
}
console.log(`residual pairs: ${total}; absent from the shipped table: ${missing} (${Math.round(100*missing/total)}%)`);

/* --- invariance test, the audit's protocol: closed subsets of size <= 4 --- */
function testInvariance(Delta, label) {
  let closed = 0, fail = 0; const witnesses = [];
  const idx = E.map((_, i) => i);
  const rec = (start, cur) => {
    if (cur.length) {
      const X = S2(cur);
      if (gammaOpen(X).length === 0) {
        closed++;
        const Y = Delta(X);
        if (gammaOpen(Y).length > 0) { fail++; if (witnesses.length < 3) witnesses.push([[...X].join(","), [...Y].join(",")]); }
      }
    }
    if (cur.length === 4) return;
    for (let i = start; i < idx.length; i++) rec(i + 1, [...cur, E[i]]);
  };
  rec(0, []);
  console.log(`${label}: closed sets tested ${closed}, invariance FAILURES ${fail}`);
  for (const [x, y] of witnesses) console.log(`    {${x}} -> {${y}}`);
  return { closed, fail };
}

const a = testInvariance(DeltaOld, "shipped C   ");
const b = testInvariance(DeltaNew, "true residual");

/* --- what does the fix cost in discrimination? --- */
const CORPUS = [];
for (const f of fs.readdirSync(`${ROOT}/corpus50/lanes`)) {
  const d = JSON.parse(fs.readFileSync(`${ROOT}/corpus50/lanes/${f}`, "utf8"));
  for (const c of d.categories) for (const p of c.protocols)
    CORPUS.push({ name: p.name, S: S2(p.elements.filter(e => E.includes(e))) });
}
const neg = JSON.parse(fs.readFileSync(`${ROOT}/algebra/negative-corpus.json`, "utf8")).cases;

const score = (Delta, label) => {
  const realFixed = CORPUS.filter(p => Delta(p.S).size === p.S.size).length;
  const negFixed = neg.filter(n => { const X = S2(n.syms.filter(e => E.includes(e))); return Delta(X).size === X.size; }).length;
  console.log(`${label}: real protocols warranted ${realFixed}/${CORPUS.length}  |  synthetic negatives warranted ${negFixed}/${neg.length}`);
  return { realFixed, negFixed };
};
console.log();
const sOld = score(DeltaOld, "shipped C   ");
const sNew = score(DeltaNew, "true residual");

console.log("\n--- verdict ---");
if (b.fail === 0 && a.fail > 0) {
  console.log("Invariance is RECOVERED by using the true residual.");
  const dOld = sOld.realFixed / CORPUS.length - sOld.negFixed / neg.length;
  const dNew = sNew.realFixed / CORPUS.length - sNew.negFixed / neg.length;
  console.log(`Delta's separation (real-minus-negative warranted rate): ${dOld.toFixed(3)} -> ${dNew.toFixed(3)}`);
  console.log(dNew < dOld ? "  ...but the operator discriminates LESS. Structure bought with content."
                          : "  ...and discrimination did not degrade.");
} else if (b.fail > 0) {
  console.log(`Invariance still FAILS under the true residual (${b.fail} counterexamples). Not a data problem.`);
}
