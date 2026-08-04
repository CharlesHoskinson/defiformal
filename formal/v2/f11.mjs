// F11 - E1: the invariance check  Delta(Fix(Gamma)) subset Fix(Gamma)
//       E2: the downward iteration  x_{n+1} = Gamma(Delta(x_n) join S)
// Delta := Delta^omega throughout (the free repair), verified a genuine kernel.
import * as T from "./tables.mjs";

const E = T.MECH;                       // 58 mechanism elements
const idx = new Map(E.map((s, i) => [s, i]));
const key = S => [...S].sort().join(",");
const D = T.DeltaInf;                   // repaired Delta

// ---------- repair check: Delta^omega is a genuine kernel operator
{
  const rnd = () => new Set(E.filter(() => Math.random() < 0.35));
  let ext = 0, mono = 0, idem = 0, fixsame = 0, N = 20000;
  for (let i = 0; i < N; i++) {
    const X = rnd();
    if (![...D(X)].every(e => X.has(e))) ext++;
    if (key(D(D(X))) !== key(D(X))) idem++;
    const Y = new Set([...X, ...[...E].filter(() => Math.random() < 0.1)]);
    if (![...D(X)].every(e => D(Y).has(e))) mono++;
    // identical fixpoints as one-pass Delta?
    const f1 = T.Delta1(X).size === X.size, fw = D(X).size === X.size;
    if (f1 !== fw) fixsame++;
  }
  console.log("=== F11.0 the free repair: Delta := Delta^omega ===");
  console.log(`over ${N} random sets: contractive violations ${ext}, monotone violations ${mono}, IDEMPOTENT violations ${idem}`);
  console.log(`Fix(Delta^omega) == Fix(Delta^1)?  disagreements: ${fixsame}  -> ${fixsame === 0 ? "IDENTICAL fixpoints, confirmed" : "DIFFER"}`);
}

// ---------- the two candidate closure operators
// (a) gamma = beta . alpha, OP-ORD's Galois closure over the obligation sort
const OB = [];                                   // obligations = non-external terms
const RAISE = new Map(E.map(e => [e, new Set()]));
for (const law of T.PARSED_NEW) {
  law.terms.forEach((t, j) => {
    if (t.external) return;
    const id = law.id + "#" + j; OB.push(id);
    for (const s of law.subjects) if (RAISE.has(s)) RAISE.get(s).add(id);
  });
}
const alpha = X => { const N = new Set(); for (const e of X) for (const o of RAISE.get(e) || []) N.add(o); return N; };
const beta = N => new Set(E.filter(e => [...RAISE.get(e)].every(o => N.has(o))));
const gamma = X => beta(alpha(X));

// (b) Cn = the height-1 definite closure derived in F2 (16 rules)
const DEF = [];
for (const law of T.PARSED_NEW) for (const s of law.subjects) for (const t of law.terms)
  if (!t.external && t.alts.length === 1 && t.alts[0] !== s) DEF.push([s, t.alts[0]]);
const Cn = X => { const Y = new Set(X); let ch = true; while (ch) { ch = false; for (const [b, h] of DEF) if (Y.has(b) && !Y.has(h)) { Y.add(h); ch = true; } } return Y; };

// (c) the closure CONDITION actually scored (L*), which is a family, not an operator
const Gcond = X => T.gammaOpen(X).length === 0;

console.log(`\nobligations: ${OB.length};  definite rules: ${DEF.length}`);
console.log("gamma extensive/idempotent spot-check:",
  [...Array(2000)].every(() => { const X = new Set(E.filter(() => Math.random() < 0.3));
    return [...X].every(e => gamma(X).has(e)) && key(gamma(gamma(X))) === key(gamma(X)); }));

// ---------- E1: INVARIANCE   Delta(Fix(Gamma)) subset Fix(Gamma)
function invariance(name, G, sampler, label) {
  const seen = new Map();
  for (const X of sampler()) { const C = G(X); seen.set(key(C), C); }
  let held = 0, failed = 0; const witnesses = [];
  for (const C of seen.values()) {
    const d = D(C);
    if (key(G(d)) === key(d)) held++;
    else { failed++; if (witnesses.length < 4) witnesses.push([key(C), key(d), key(G(d))]); }
  }
  const pct = (100 * held / seen.size).toFixed(2);
  console.log(`\n--- E1 ${name} over ${label}: |Fix(Gamma) sampled| = ${seen.size}`);
  console.log(`    Delta(C) in Fix(Gamma):  ${held}/${seen.size} = ${pct}%   ${failed === 0 ? "*** INVARIANCE HOLDS ***" : "INVARIANCE FAILS"}`);
  for (const w of witnesses) console.log(`      witness C={${w[0]}}  Delta(C)={${w[1]}}  Gamma(Delta(C))={${w[2]}}`);
  return { held, total: seen.size, failed };
}
const sampleAll58 = function* () {
  for (let i = 0; i < E.length; i++) { yield new Set([E[i]]);
    for (let j = i + 1; j < E.length; j++) { yield new Set([E[i], E[j]]);
      for (let k = j + 1; k < E.length; k++) yield new Set([E[i], E[j], E[k]]); } }
  for (const p of T.lanes) yield new Set(p.syms.filter(s => T.SYMS.has(s)));
  for (let r = 0; r < 200000; r++) yield new Set(E.filter(() => Math.random() < 0.25));
};
console.log("\n=== F11.1 EXPERIMENT 1: invariance ===");
invariance("Gamma = gamma (Galois, OP-ORD s1.3)", gamma, sampleAll58, "all <=3-subsets + 72 lanes + 200k random, 58 elements");
invariance("Gamma = Cn (definite, height 1)", Cn, sampleAll58, "same sample");

// exhaustive over a 20-element universe, relative closure
const U20 = ["Fl","Xm","Xf","Rl","Of","Bs","Sl","Au","Gs","Uc","Aw","At","Cp","Cl","Pl","Cd","Ix","Sh","Ct","Li"];
const ALL20 = []; for (let m = 0; m < (1 << 20); m++) ALL20.push(m);
const setOf20 = m => new Set(U20.filter((_, i) => m & (1 << i)));
{
  const fixCn = new Set(); const store = [];
  for (const m of ALL20) { const X = setOf20(m); const C = Cn(X); const k = key(C);
    if ([...C].every(e => U20.includes(e)) && !fixCn.has(k)) { fixCn.add(k); store.push(C); } }
  let held = 0; const w = [];
  for (const C of store) { const d = D(C); if (key(Cn(d)) === key(d)) held++; else if (w.length < 3) w.push([key(C), key(d), key(Cn(d))]); }
  console.log(`\n--- E1 EXHAUSTIVE, Gamma = Cn, universe 2^20, closures staying inside U: |Fix| = ${store.length}`);
  console.log(`    invariance: ${held}/${store.length} = ${(100 * held / store.length).toFixed(2)}%  ${held === store.length ? "*** HOLDS ***" : "FAILS"}`);
  for (const x of w) console.log(`      witness C={${x[0]}} Delta(C)={${x[1]}} Cn(Delta C)={${x[2]}}`);
}
// and the family that actually matters: does Delta preserve the SCORED closure condition?
{
  let held = 0, tot = 0; const w = [];
  for (const m of ALL20) { const X = setOf20(m); if (!Gcond(X)) continue; tot++;
    const d = D(X); if (Gcond(d)) held++; else if (w.length < 4) w.push([key(X), key(d), JSON.stringify(T.gammaOpen(d))]); }
  console.log(`\n--- E1' does Delta preserve the SCORED closure condition Gamma(X) (L*)?  ${held}/${tot} = ${(100 * held / tot).toFixed(2)}%`);
  for (const x of w) console.log(`      witness X={${x[0]}} Delta(X)={${x[1]}} now open: ${x[2]}`);
}

// ---------- E2: the downward iteration
console.log("\n=== F11.2 EXPERIMENT 2: downward iteration  x_{n+1} = Gamma(Delta(x_n) join S) ===");
function downward(Sarr, universe, G) {
  const Uset = new Set(universe);
  const S = new Set(Sarr);
  let x = new Set(universe);
  const seenK = new Set(); let steps = 0;
  while (steps < 200) {
    const next = new Set([...G(new Set([...D(x), ...S]))].filter(e => Uset.has(e)));
    const k = key(next); if (k === key(x)) break; if (seenK.has(k)) { x = next; break; }
    seenK.add(k); x = next; steps++;
  }
  return { x, steps };
}
// 10-element instance, exhaustive ground truth (same as F9)
const U10 = ["Fl","Xm","Xf","Rl","Of","Au","Sh","Ix","In","Bs"];
function report(universe, seeds, label) {
  const ALL = []; const n = universe.length;
  for (let m = 0; m < (1 << n); m++) ALL.push(new Set(universe.filter((_, i) => m & (1 << i))));
  const ADM = ALL.filter(s => T.admissible(s));
  console.log(`\n--- ${label}: |L|=2^${n}, |Adm|=${ADM.length}`);
  console.log("  seed            |compl| x_inf                                     sound? |x_inf| exactUB slack");
  for (const s of seeds) {
    const S = new Set(s);
    const compl = ADM.filter(X => [...S].every(e => X.has(e)));
    let exactUB = new Set(); for (const X of compl) for (const e of X) exactUB.add(e);
    const { x } = downward(s, universe, Cn);
    const sound = compl.every(X => [...X].every(e => x.has(e)));
    const slack = [...x].filter(e => !exactUB.has(e)).length;
    console.log(`  {${s.join(",").padEnd(12)}} ${String(compl.length).padStart(5)}  {${[...x].sort().join(",").padEnd(38)}} ${String(sound).padEnd(6)} ${String(x.size).padStart(6)} ${String(exactUB.size).padStart(7)} ${String(slack).padStart(5)}`);
  }
}
report(U10, [["Of"],["Rl"],["Fl","Xm"],["Rl","Of"],["Uc"],["Pl"]].filter(s => s.every(e => U10.includes(e))), "10-element instance (F9 seeds)");
report(U20, [["Of"],["Rl"],["Fl","Xm"],["Rl","Of"],["Uc"],["Pl"],["Cd"],["Li"]], "20-element instance");

// 58 elements: soundness against exhaustive size<=4 completions and the 72 live protocols
console.log("\n--- 58 elements: soundness of x_inf against exhaustively enumerated admissible sets (size <= 4) ---");
const small = [];
(function rec(start, cur) {
  if (cur.length) { const S = new Set(cur); if (T.admissible(S)) small.push([...cur]); }
  if (cur.length === 4) return;
  for (let i = start; i < E.length; i++) { cur.push(E[i]); rec(i + 1, cur); cur.pop(); }
})(0, []);
console.log(`admissible sets of size <=4 over all 58 elements: ${small.length}`);
for (const s of [["Of"],["Rl"],["Fl","Xm"],["Uc"],["Pl"],["Cd"]]) {
  const S = new Set(s);
  const compl = small.filter(X => s.every(e => X.includes(e)));
  const live = T.lanes.filter(p => s.every(e => p.syms.includes(e)) && T.admissible(new Set(p.syms.filter(x => T.SYMS.has(x)))));
  const { x, steps } = downward(s, E, Cn);
  const soundSmall = compl.every(X => X.every(e => x.has(e)));
  const soundLive = live.every(p => p.syms.filter(y => T.SYMS.has(y)).every(e => x.has(e)));
  let ub = new Set(); for (const X of compl) for (const e of X) ub.add(e);
  for (const p of live) for (const e of p.syms) if (T.SYMS.has(e)) ub.add(e);
  console.log(`  seed {${s.join(",")}}: steps=${steps} |x_inf|=${x.size}/58  sound vs ${compl.length} small completions: ${soundSmall}  vs ${live.length} live protocols: ${soundLive}  excluded=${58 - x.size}  slack vs observed UB=${[...x].filter(e => !ub.has(e)).length}`);
  if (s.join() === "Fl,Xm") console.log(`     x_inf excludes: ${E.filter(e => !x.has(e)).join(" ")}`);
}
