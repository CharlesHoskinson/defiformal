// Is R genuinely intersection-closed under PARSED_NEW, or is that an artifact
// of restricting to size <= 3? A negative result the paper leans on must not be
// replaced by a positive one on the strength of a small-size sample.
import * as T from "../v2/tables.mjs";
const E = T.MECH;

const openP = X => T.PARSED_NEW.filter(l =>
  l.subjects.some(s => X.has(s)) &&
  l.terms.some(t => !t.external && !t.alts.some(a => X.has(a)))).map(l => l.id);
const inR_P = X => openP(X).length === 0;
const inR_L = X => T.gammaOpen(X).length === 0;

const S = a => new Set(a);
console.log("the paper's witness, under each system:");
for (const [name, X] of [["{Op,Tp}", S(["Op", "Tp"])], ["{Ex,Op}", S(["Ex", "Op"])],
                          ["{Op}", S(["Op"])]]) {
  console.log(`  ${name.padEnd(9)} LSTAR:${inR_L(X) ? "model" : "not   "}  ` +
              `PARSED_NEW:${inR_P(X) ? "model" : "not"}  open under PARSED_NEW: ${openP(X).join(",") || "-"}`);
}

// exhaustive at size <= 4
let models = [];
const push = a => { const X = S(a); if (inR_P(X)) models.push(X); };
push([]);
for (let i = 0; i < E.length; i++) {
  push([E[i]]);
  for (let j = i + 1; j < E.length; j++) {
    push([E[i], E[j]]);
    for (let k = j + 1; k < E.length; k++) {
      push([E[i], E[j], E[k]]);
      for (let l = k + 1; l < E.length; l++) push([E[i], E[j], E[k], E[l]]);
    }
  }
}
console.log(`\nPARSED_NEW models of size <= 4: ${models.length}`);
let fail = 0; const ex = [];
for (let a = 0; a < models.length; a++)
  for (let b = a + 1; b < models.length; b++) {
    const cap = new Set([...models[a]].filter(x => models[b].has(x)));
    if (!inR_P(cap)) {
      fail++;
      if (ex.length < 3) ex.push(`{${[...models[a]]}} n {${[...models[b]]}} = {${[...cap]}} open=${openP(cap)}`);
    }
  }
console.log(`intersection-closure failures at size <= 4: ${fail}`);
for (const e of ex) console.log("   ", e);

// random search at larger sizes
let rfail = 0;
let seed = 12345;
const rnd = () => (seed = (seed * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff;
const bigModels = [];
for (let t = 0; t < 200000 && bigModels.length < 4000; t++) {
  const k = 5 + Math.floor(rnd() * 20);
  const arr = [];
  for (const e of E) if (rnd() < k / E.length) arr.push(e);
  const X = S(arr);
  if (inR_P(X)) bigModels.push(X);
}
console.log(`\nrandom larger PARSED_NEW models sampled: ${bigModels.length}`);
const rex = [];
for (let a = 0; a < bigModels.length; a++)
  for (let b = a + 1; b < bigModels.length; b++) {
    const cap = new Set([...bigModels[a]].filter(x => bigModels[b].has(x)));
    if (!inR_P(cap)) { rfail++; if (rex.length < 2) rex.push(`open=${openP(cap)} |cap|=${cap.size}`); }
  }
console.log(`intersection-closure failures among sampled larger models: ${rfail}`);
for (const e of rex) console.log("   ", e);
console.log(rfail || fail
  ? "\nR is NOT intersection-closed under PARSED_NEW; the size<=3 zero is a small-size artifact"
  : "\nno counterexample found at size <= 4 or in the larger sample");
