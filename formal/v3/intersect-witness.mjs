// Is R intersection-closed under PARSED_NEW?
//
// Enumerating pairs at size <= 4 is 2.3e10 comparisons and does not finish.
// It is also the wrong method: a counterexample can be CONSTRUCTED.
//
// R is defined by clauses "if a subject of l is present, some alternative of a
// term of l is present". So take a law l with subject s and a term with two
// alternatives a1 != a2. Build A from {s,a1} and B from {s,a2}, each completed
// to a model. Then s is in A n B, and if neither a1 nor a2 survives the
// intersection, that term is open and A n B is not a model.
import * as T from "../v2/tables.mjs";
const E = T.MECH;

const openP = X => T.PARSED_NEW.filter(l =>
  l.subjects.some(s => X.has(s)) &&
  l.terms.some(t => !t.external && !t.alts.some(a => X.has(a)))).map(l => l.id);
const inR = X => openP(X).length === 0;

// complete a seed to a model by repeatedly satisfying an open term with its
// first alternative; deterministic, and it terminates because each step adds
// an element.
function complete(seed, prefer) {
  const X = new Set(seed);
  for (let guard = 0; guard < 200; guard++) {
    let changed = false;
    for (const l of T.PARSED_NEW) {
      if (!l.subjects.some(s => X.has(s))) continue;
      for (const t of l.terms) {
        if (t.external || t.alts.some(a => X.has(a))) continue;
        const pick = t.alts.find(a => prefer.has(a)) ?? t.alts[0];
        X.add(pick); changed = true;
      }
    }
    if (!changed) break;
  }
  return inR(X) ? X : null;
}

const found = [];
for (const l of T.PARSED_NEW) {
  for (const t of l.terms) {
    if (t.external || t.alts.length < 2) continue;
    for (const s of l.subjects) {
      for (let i = 0; i < t.alts.length && found.length < 4; i++) {
        for (let j = i + 1; j < t.alts.length && found.length < 4; j++) {
          const a1 = t.alts[i], a2 = t.alts[j];
          const A = complete([s, a1], new Set([a1]));
          const B = complete([s, a2], new Set([a2]));
          if (!A || !B) continue;
          const cap = new Set([...A].filter(x => B.has(x)));
          if (!inR(cap)) {
            found.push({ law: l.id, s, a1, a2,
                         A: [...A].sort(), B: [...B].sort(),
                         cap: [...cap].sort(), open: openP(cap) });
          }
        }
      }
    }
  }
}

console.log(`constructed counterexamples found: ${found.length}`);
for (const f of found.slice(0, 3)) {
  console.log(`\n  law ${f.law}, subject ${f.s}, alternatives ${f.a1} vs ${f.a2}`);
  console.log(`    A      = {${f.A}}   (|A|=${f.A.length})`);
  console.log(`    B      = {${f.B}}   (|B|=${f.B.length})`);
  console.log(`    A n B  = {${f.cap}}`);
  console.log(`    open   = ${f.open.join(",")}`);
}
console.log(found.length
  ? "\nR is NOT intersection-closed under PARSED_NEW. The size<=3 zero is a small-size artefact."
  : "\nno counterexample constructible this way");
