// meas:closureprops under both systems, exhaustively over subsets of size <= 3.
// The paper states 179,864,061 pairs and 68,058 intersection failures; both are
// LSTAR's. Recompute under PARSED_NEW, which is the system the paper says it
// uses.
import * as T from "/root/DefiElements/formal/v2/tables.mjs";
const E = T.MECH;

const inR_L = X => T.gammaOpen(X).length === 0;
const inR_P = X => !T.PARSED_NEW.some(l =>
  l.subjects.some(s => X.has(s)) &&
  l.terms.some(t => !t.external && !t.alts.some(a => X.has(a))));

function run(label, inR) {
  const models = [];
  const push = arr => { const X = new Set(arr); if (inR(X)) models.push(X); };
  push([]);
  for (let i = 0; i < E.length; i++) {
    push([E[i]]);
    for (let j = i + 1; j < E.length; j++) {
      push([E[i], E[j]]);
      for (let k = j + 1; k < E.length; k++) push([E[i], E[j], E[k]]);
    }
  }
  const n = models.length;
  const pairs = n * (n + 1) / 2;              // unordered pairs including the diagonal
  let interFail = 0, unionFail = 0;
  for (let a = 0; a < n; a++) {
    for (let b = a; b < n; b++) {
      const A = models[a], B = models[b];
      const cap = new Set([...A].filter(x => B.has(x)));
      if (!inR(cap)) interFail++;
      const cup = new Set([...A, ...B]);
      if (!inR(cup)) unionFail++;
    }
  }
  console.log(`${label}: models=${n}  pairs=${pairs.toLocaleString("en-US")}  ` +
              `intersection-closure failures=${interFail.toLocaleString("en-US")}  ` +
              `union-closure failures=${unionFail}`);
  return { n, pairs, interFail, unionFail };
}

const L = run("LSTAR      ", inR_L);
const P = run("PARSED_NEW ", inR_P);

console.log("\npaper currently states: 179,864,061 pairs and 68,058 intersection failures");
console.log("LSTAR reproduces the paper:", L.pairs === 179864061 && L.interFail === 68058);
console.log("\nreplacement figures for meas:closureprops under PARSED_NEW:");
console.log(`  pairs                    ${P.pairs.toLocaleString("en-US")}`);
console.log(`  intersection failures    ${P.interFail.toLocaleString("en-US")}`);
console.log(`  union failures           ${P.unionFail}`);
