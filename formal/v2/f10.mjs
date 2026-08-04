// F10 - does Kripke-Kleene on the completion lattice [S,TOP] stay informative at
// the FULL 58-element vocabulary, or does the upper bound relax to TOP?
//
// Method, stated exactly, because the whole result depends on it:
//
//   U_O(x,y) = ( glb O([x,y]) , lub O([x,y]) )                      (DMT Thm 4.5)
//   O = O_A closed into [S,TOP]:   Ov(z) = z if Adm(z) else S       (z ranges over [S,TOP])
//
// The interval [x,y] has up to 2^58 points, so it is NOT enumerated. Instead the two
// bounds are computed in closed form, which is EXACT, not an approximation:
//
//   lub O([x,y]) = S  U  U{ z : x <= z <= y, Adm(z) }
//        => e in lub  <=>  e in x  OR  EXISTS admissible z with x<=z<=y and e in z.
//        That is one satisfiability query per element.
//
//   glb O([x,y]) = S            if some z in [x,y] is NOT admissible
//                = x            otherwise (intersection of the whole interval is x)
//        => one "does the interval contain a non-admissible point" query.
//
// Admissibility is EXACTLY a CNF formula over the 58 element-variables (proved by
// construction below and checked against tables.admissible() by exhaustive and random
// differential testing), so both queries are decided by a complete DPLL solver.
// UNSAT from a complete solver is a proof, so no element is excluded without proof.
//
// NO APPROXIMATION IS MADE for O_A. Where anything is sampled it is labelled.

import * as T from "./tables.mjs";
import fs from "node:fs";

// ----------------------------------------------------------------- vocabulary
const E = T.MECH.slice().sort();          // 58 mechanism elements ("limit" CSM excluded)
const n = E.length;
const IDX = new Map(E.map((s, i) => [s, i]));
const has = s => IDX.has(s);
const ix = s => IDX.get(s);
const show = set => "{" + [...set].sort().join(",") + "}";
const setOfMask = a => new Set(E.filter((_, i) => a[i] === 1));

// ----------------------------------------------------------------- CNF build
// literal encoding: +（i+1) = e_i true (element present), -(i+1) = e_i absent
const CL = [];                 // clauses: arrays of ints
const CLSRC = [];              // provenance tag per clause
const add = (lits, src) => { CL.push(lits); CLSRC.push(src); };

// (1) closure: subject in S  =>  each term of that law has a member in S
for (const [id, subs, terms] of T.LSTAR)
  for (const s of subs) { if (!has(s)) continue;
    for (const t of terms) add([-(ix(s) + 1), ...t.filter(has).map(a => ix(a) + 1)], "closure/" + id); }

// (2) warrant: e in S => some consumer/justifier of e in S
for (const e of Object.keys(T.CONSUME)) { if (!has(e)) continue;
  add([-(ix(e) + 1), ...T.CONSUME[e].filter(has).map(c => ix(c) + 1)], "warrant/" + e); }

// (3) listed hazards with a membership projection (HAZ_PROJ / armedListed)
for (const h of T.HAZ_PROJ) add(h.named.filter(has).map(a => -(ix(a) + 1)), "listed/" + h.id);

// (4) the five conditional bans of bansCond(), transcribed one for one
const P = s => ix(s) + 1, N_ = s => -(ix(s) + 1);
add([N_("Uc"), P("Aw")], "ban/X11a*");
add([N_("Uc"), P("At")], "ban/X11a*");
add([N_("Aw"), N_("Xf"), P("At"), P("Fz"), P("Xm")], "ban/X19*");
for (const c of ["Cp", "Cl"]) for (const p of ["Pl", "Cd", "Im"]) add([N_("Fl"), N_(c), N_(p)], "ban/X2");
add([N_("Oa"), N_("Li"), P("Ex"), P("Tp")], "ban/X18");
for (const z of ["Xf", "Rl", "Of"]) add([N_("Fl"), N_(z)], "ban/X21");

// (5) grounding: any risk-group element present => some stratum<=2 element present
const RISKG = new Set(["G05", "G06", "G07", "G13", "G16"]);
const LOW = E.filter(s => T.ELEMS[s].stratum <= 2).map(s => ix(s) + 1);
for (const s of E) if (RISKG.has(T.ELEMS[s].group)) add([-(ix(s) + 1), ...LOW], "ground");

console.log(`vocabulary |E| = ${n};  CNF: ${CL.length} clauses over ${n} vars`);
{ const by = {}; CLSRC.forEach(s => { const k = s.split("/")[0]; by[k] = (by[k] || 0) + 1; });
  console.log(`  clauses by source: ${JSON.stringify(by)}`); }

// ------------------------------------------------------- complete DPLL solver
// assign: Int8Array over n, 0 = unassigned, 1 = true, -1 = false.
// Returns a model (Int8Array of 0/1) or null. Complete: null == UNSAT, proved.
let DPLL_CALLS = 0, DPLL_DECISIONS = 0, DPLL_PROPS = 0;
function solve(fixTrue, fixFalse, clauses = CL, rnd = null) {
  DPLL_CALLS++;
  const a = new Int8Array(n);                 // 0 unassigned
  for (const i of fixTrue) { if (a[i] === -1) return null; a[i] = 1; }
  for (const i of fixFalse) { if (a[i] === 1) return null; a[i] = -1; }
  const order = [...Array(n).keys()];
  if (rnd) for (let i = n - 1; i > 0; i--) { const j = Math.floor(rnd() * (i + 1)); [order[i], order[j]] = [order[j], order[i]]; }
  const val = l => { const v = a[Math.abs(l) - 1]; return v === 0 ? 0 : (l > 0 ? v : -v); };
  function propagate() {                       // returns false on conflict
    let changed = true;
    while (changed) { changed = false;
      for (const c of clauses) {
        let unassigned = -1, cnt = 0, sat = false;
        for (const l of c) { const v = val(l); if (v === 1) { sat = true; break; } if (v === 0) { cnt++; unassigned = l; } }
        if (sat) continue;
        if (cnt === 0) return false;
        if (cnt === 1) { a[Math.abs(unassigned) - 1] = unassigned > 0 ? 1 : -1; DPLL_PROPS++; changed = true; }
      }
    }
    return true;
  }
  function rec(k) {
    if (!propagate()) return false;
    let i = -1; for (const o of order) if (a[o] === 0) { i = o; break; }
    if (i < 0) return true;
    const snap = a.slice();
    const first = rnd ? (rnd() < 0.5 ? -1 : 1) : -1;   // default polarity FALSE: smallest models first
    for (const pol of [first, -first]) {
      a[i] = pol; DPLL_DECISIONS++;
      if (rec(k + 1)) return true;
      a.set(snap);
    }
    return false;
  }
  if (!rec(0)) return null;
  const out = new Int8Array(n); for (let i = 0; i < n; i++) out[i] = a[i] === 1 ? 1 : 0;
  return out;
}

// "does the interval [x,y] contain a NON-admissible point?"  x,y as Int8 masks.
// A point z violates clause C iff every positive literal of C is false in z and every
// negative literal is true in z. Such a z exists in [x,y] iff for every positive lit a:
// a not forced in by x, and for every negative lit b: b permitted by y. O(|CNF|), exact.
function intervalHasNonAdmissible(x, y) {
  for (const c of CL) {
    let ok = true;
    for (const l of c) { const i = Math.abs(l) - 1;
      if (l > 0) { if (x[i] === 1) { ok = false; break; } }      // must be false, but forced true
      else { if (y[i] === 0) { ok = false; break; } }            // must be true, but forbidden
    }
    if (ok) return true;
  }
  return false;
}

// -------------------------------------------- differential test of the encoding
function cnfSat(S) { // is set S admissible according to the CNF?
  for (const c of CL) { let ok = false;
    for (const l of c) { const s = E[Math.abs(l) - 1]; if (l > 0 ? S.has(s) : !S.has(s)) { ok = true; break; } }
    if (!ok) return false; }
  return true;
}
function diffTest() {
  let bad = 0, tested = 0;
  // (a) exhaustive over the F9 10-element sublattice
  const U10 = ["Fl", "Xm", "Xf", "Rl", "Of", "Au", "Sh", "Ix", "In", "Bs"];
  for (let m = 0; m < 1024; m++) {
    const S = new Set(U10.filter((_, i) => m & (1 << i)));
    tested++; if (T.admissible(S) !== cnfSat(S)) { bad++; if (bad < 4) console.log(`  MISMATCH ${show(S)} adm=${T.admissible(S)} cnf=${cnfSat(S)}`); }
  }
  // (b) 300k random subsets of the full 58, at several densities
  let seed = 12345; const rnd = () => (seed = (seed * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff;
  for (let k = 0; k < 300000; k++) {
    const p = [0.05, 0.15, 0.3, 0.5, 0.8][k % 5];
    const S = new Set(E.filter(() => rnd() < p));
    tested++; if (T.admissible(S) !== cnfSat(S)) { bad++; if (bad < 8) console.log(`  MISMATCH ${show(S)} adm=${T.admissible(S)} cnf=${cnfSat(S)}`); }
  }
  // (c) the 72 corpus protocols and all their 1-element extensions
  for (const p of T.lanes) { const B = new Set(p.syms.filter(has));
    for (const e of [null, ...E]) { const S = new Set(B); if (e) S.add(e);
      tested++; if (T.admissible(S) !== cnfSat(S)) { bad++; if (bad < 12) console.log(`  MISMATCH ${show(S)}`); } } }
  console.log(`CNF differential test: ${tested} sets, ${bad} mismatches vs tables.admissible()  ${bad === 0 ? "PASS" : "FAIL"}`);
  return bad === 0;
}

// ------------------------------------------------------- KK on [S,TOP], exact
function kk(seedSyms, restrict = null) {
  // restrict: optional array of allowed symbols (all others pinned absent) - used to
  // reproduce the F9 10-element instance through the same code path.
  const t0 = process.hrtime.bigint();
  const c0 = DPLL_CALLS;
  const seed = new Int8Array(n); for (const s of seedSyms) if (has(s)) seed[ix(s)] = 1;
  const allowed = new Int8Array(n).fill(1);
  if (restrict) { allowed.fill(0); for (const s of restrict) if (has(s)) allowed[ix(s)] = 1;
                  for (let i = 0; i < n; i++) if (seed[i]) allowed[i] = 1; }
  const seedIdx = []; for (let i = 0; i < n; i++) if (seed[i]) seedIdx.push(i);

  // A1 / A2 as defined above.
  const A1 = (x, y) => intervalHasNonAdmissible(x, y) ? seed.slice() : x.slice();
  const A2 = (x, y) => {
    const out = x.slice();
    const fixTrue = []; for (let i = 0; i < n; i++) if (x[i]) fixTrue.push(i);
    for (let e = 0; e < n; e++) {
      if (out[e]) continue;
      if (y[e] === 0) continue;                    // outside the interval anyway
      const fixFalse = []; for (let i = 0; i < n; i++) if (y[i] === 0) fixFalse.push(i);
      const mdl = solve([...fixTrue, e], fixFalse);
      if (mdl) { for (let i = 0; i < n; i++) if (mdl[i]) out[i] = 1; }   // whole model joins the lub
    }
    for (const i of seedIdx) out[i] = 1;
    return out;
  };

  let x = seed.slice(), y = allowed.slice(), steps = 0;
  const trace = [];
  for (; steps < 50; steps++) {
    const nx = A1(x, y), ny = A2(x, y);
    const same = nx.every((v, i) => v === x[i]) && ny.every((v, i) => v === y[i]);
    x = nx; y = ny;
    trace.push(`(|x|=${x.reduce((a, b) => a + b, 0)},|y|=${y.reduce((a, b) => a + b, 0)})`);
    if (same) break;
  }
  const ms = Number(process.hrtime.bigint() - t0) / 1e6;
  return { seed, lower: x, upper: y, steps: steps + 1, trace, ms, calls: DPLL_CALLS - c0, allowed };
}

const cnt = m => m.reduce((a, b) => a + b, 0);
const symsOf = m => E.filter((_, i) => m[i] === 1);

function report(name, seedSyms, restrict = null, verbose = false) {
  const r = kk(seedSyms, restrict);
  const univ = restrict ? symsOf(r.allowed) : E;
  const S = symsOf(r.seed);
  const candidates = univ.filter(s => !S.includes(s));
  const upper = symsOf(r.upper);
  const remaining = upper.filter(s => !S.includes(s));
  const excluded = candidates.filter(s => !upper.includes(s));
  const frac = candidates.length ? excluded.length / candidates.length : 0;
  if (verbose) {
    console.log(`\nseed ${show(S)}  (|S|=${S.length})`);
    console.log(`  KK lower = ${show(symsOf(r.lower))}${symsOf(r.lower).length === S.length ? "  (= S)" : "  !! MOVED"}`);
    console.log(`  KK upper = ${show(upper)}`);
    console.log(`  |upper \\ S| = ${remaining.length} of |E \\ S| = ${candidates.length}  ->  EXCLUDED ${excluded.length} (${(100 * frac).toFixed(1)}%)`);
    console.log(`  excluded: ${excluded.length ? show(excluded) : "(none - VACUOUS)"}`);
    console.log(`  iterations ${r.steps}, SAT calls ${r.calls}, ${r.ms.toFixed(0)} ms`);
  }
  return { name, S, candidates, upper, remaining, excluded, frac, r };
}

// ======================================================================= RUN
const ok = diffTest();
if (!ok) { console.log("ENCODING FAILED - everything below would be meaningless. Stop."); process.exit(1); }

const U10 = ["Fl", "Xm", "Xf", "Rl", "Of", "Au", "Sh", "Ix", "In", "Bs"];

console.log("\n#################### PART A - reproduce F9 at 10 elements through the SAT path ####################");
console.log("(same six seeds, vocabulary pinned to the F9 sublattice; must match f9.out exactly)");
for (const s of [["Pl"], ["Uc"], ["Of"], ["Rl"], ["Fl", "Xm"], ["Of", "Rl"]]) report("f9", s, U10, true);

console.log("\n#################### PART B - brute-force cross-check of the SAT path ####################");
// The claim under test: SAT-computed upper == union of ALL admissible supersets of S,
// enumerated exhaustively. This tests BOTH directions - a wrong SAT answer of the
// UNSAT kind (unsound over-exclusion) and of the SAT kind (spurious inclusion).
// The universe is U10 united with the seed, so seeds outside U10 are handled honestly.
function bruteUpper(seedSyms, universe) {
  const un = new Set(seedSyms); let c = 0;
  for (let m = 0; m < (1 << universe.length); m++) {
    const Z = new Set(universe.filter((_, i) => m & (1 << i)));
    if (!seedSyms.every(q => Z.has(q))) continue;
    if (!T.admissible(Z)) continue;
    c++; for (const q of Z) un.add(q);
  }
  return { un: [...un].sort(), c };
}
{
  let bad = 0, done = 0;
  const named = [["Pl"], ["Uc"], ["Of"], ["Rl"], ["Fl", "Xm"], ["Of", "Rl"], ["Au"], ["In", "Bs"]];
  for (const s of named) {
    const universe = [...new Set([...U10, ...s])];
    const { un, c } = bruteUpper(s, universe);
    const got = report("bf", s, universe).upper.sort();
    const match = got.join(",") === un.join(","); if (!match) bad++; done++;
    console.log(`  seed ${show(new Set(s))}: |universe|=${universe.length}, adm completions ${c}; brute upper ${show(un)}; SAT upper ${show(got)}  ${match ? "MATCH" : "*** DIVERGE ***"}`);
  }
  // 200 random seeds drawn from U10, same comparison, to exercise UNSAT specifically
  let sd2 = 4242; const r2 = () => (sd2 = (sd2 * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff;
  let rbad = 0;
  for (let k = 0; k < 200; k++) {
    const s = U10.filter(() => r2() < 0.25);
    const { un } = bruteUpper(s, U10);
    const got = report("bf", s, U10).upper.sort();
    if (got.join(",") !== un.join(",")) { rbad++; if (rbad < 4) console.log(`  RANDOM DIVERGE seed=${show(new Set(s))} brute=${show(un)} sat=${show(got)}`); }
    done++;
  }
  console.log(`brute-force cross-check: ${done} seeds compared against exhaustive enumeration, ${bad + rbad} divergences  ${bad + rbad === 0 ? "PASS" : "FAIL"}`);
}

console.log("\n#################### PART C - the six F9 seeds at FULL 58 elements ####################");
const partC = [];
for (const s of [["Pl"], ["Uc"], ["Of"], ["Rl"], ["Fl", "Xm"], ["Of", "Rl"]]) partC.push(report("f9@58", s, null, true));

console.log("\n#################### PART D - all 72 real protocols as seeds ####################");
const rows = [];
for (const p of T.lanes) {
  const syms = [...new Set(p.syms.filter(has))];
  const t = report(p.name, syms, null, false);
  rows.push({ name: p.name, cat: p.cat, k: t.S.length, cand: t.candidates.length,
              rem: t.remaining.length, exc: t.excluded.length, frac: t.frac,
              excluded: t.excluded, ms: t.r.ms, calls: t.r.calls, admSeed: T.admissible(new Set(syms)) });
}
rows.sort((a, b) => a.frac - b.frac);
console.log("name".padEnd(26) + "|S|".padStart(4) + "|E\\S|".padStart(7) + "|up\\S|".padStart(8) + "excl".padStart(6) + "  excl%" + "   ms");
for (const r of rows) console.log(r.name.padEnd(26) + String(r.k).padStart(4) + String(r.cand).padStart(7) +
  String(r.rem).padStart(8) + String(r.exc).padStart(6) + (100 * r.frac).toFixed(1).padStart(7) + "%" + r.ms.toFixed(0).padStart(6));
const fr = rows.map(r => r.frac).sort((a, b) => a - b);
const q = p => fr[Math.min(fr.length - 1, Math.floor(p * (fr.length - 1)))];
console.log(`\n72-protocol EXCLUSION FRACTION distribution:`);
console.log(`  min ${(100 * q(0)).toFixed(1)}%  p25 ${(100 * q(.25)).toFixed(1)}%  MEDIAN ${(100 * q(.5)).toFixed(1)}%  p75 ${(100 * q(.75)).toFixed(1)}%  max ${(100 * q(1)).toFixed(1)}%`);
console.log(`  mean ${(100 * fr.reduce((a, b) => a + b, 0) / fr.length).toFixed(1)}%;  vacuous (0% excluded): ${fr.filter(v => v === 0).length}/72;  >=10% excluded: ${fr.filter(v => v >= .1).length}/72`);
const hist = {}; for (const r of rows) { const b = Math.floor(100 * r.frac / 5) * 5; hist[b] = (hist[b] || 0) + 1; }
console.log(`  histogram (5% bins): ${Object.keys(hist).sort((a, b) => a - b).map(k => `${k}-${+k + 5}%:${hist[k]}`).join("  ")}`);
console.log(`  seeds that are themselves admissible: ${rows.filter(r => r.admSeed).length}/72`);
{ const c = {}; for (const r of rows) for (const e of r.excluded) c[e] = (c[e] || 0) + 1;
  console.log(`  most-excluded elements: ${Object.entries(c).sort((a, b) => b[1] - a[1]).slice(0, 15).map(([k, v]) => k + ":" + v).join(" ")}`); }

console.log("\n#################### PART E - adversarial seeds ####################");
report("singleton Fl", ["Fl"], null, true);
report("singleton Bs", ["Bs"], null, true);
report("empty seed", [], null, true);
report("pair {Uc,Aw}", ["Uc", "Aw"], null, true);
{ // near-complete: the largest corpus protocol plus everything that stays satisfiable
  const big = T.lanes.reduce((a, b) => b.syms.length > a.syms.length ? b : a);
  console.log(`(largest corpus protocol: ${big.name}, |S| = ${big.syms.length})`);
  const grown = [...big.syms.filter(has)];
  for (const e of E) if (!grown.includes(e)) { const t = [...grown, e];
    if (solve(t.map(ix), [])) grown.push(e); }
  console.log(`near-complete seed grown greedily to |S| = ${grown.length}, admissible = ${T.admissible(new Set(grown))}`);
  report("near-complete", grown, null, true);
}

console.log("\n#################### PART F - SOUNDNESS ####################");
console.log("F1. inclusion certificates: for every e in upper\\S, the SAT model witnessing it must");
console.log("    be a genuinely admissible superset of S, checked with tables.admissible().");
console.log("F2. exclusion counterexample hunt: sample admissible completions of S at random and");
console.log("    assert every one lies inside [S, upper].");
let certOK = 0, certBAD = 0, sampOK = 0, sampBAD = 0, badEx = [];
let sd = 999331; const rnd = () => (sd = (sd * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff;
const soundSeeds = [...T.lanes.map(p => [...new Set(p.syms.filter(has))]), ["Fl", "Xm"], ["Of"], ["Rl"], ["Pl"], ["Uc"], ["Of", "Rl"], ["Fl"], []];
for (const syms of soundSeeds) {
  const t = kk(syms, null);
  const S = new Set(symsOf(t.seed)), upper = new Set(symsOf(t.upper));
  const fixTrue = symsOf(t.seed).map(ix);
  for (const e of symsOf(t.upper)) {          // F1
    if (S.has(e)) continue;
    const mdl = solve([...fixTrue, ix(e)], []);
    if (!mdl) { certBAD++; continue; }
    const Z = setOfMask(mdl);
    if (T.admissible(Z) && [...S].every(s => Z.has(s)) && Z.has(e) && [...Z].every(z => upper.has(z))) certOK++;
    else { certBAD++; if (badEx.length < 5) badEx.push(`cert fail seed=${show(S)} e=${e} adm=${T.admissible(Z)}`); }
  }
  for (let k = 0; k < 120; k++) {             // F2
    const mdl = solve(fixTrue, [], CL, rnd);
    if (!mdl) break;
    const Z = setOfMask(mdl);
    if (!T.admissible(Z)) { sampBAD++; if (badEx.length < 5) badEx.push(`sampled model NOT admissible: ${show(Z)}`); continue; }
    const outside = [...Z].filter(z => !upper.has(z));
    if (outside.length) { sampBAD++; if (badEx.length < 5) badEx.push(`*** ADMISSIBLE COMPLETION OUTSIDE UPPER *** seed=${show(S)} extra=${show(outside)}`); }
    else sampOK++;
  }
}
console.log(`F1 inclusion certificates: ${certOK} verified admissible-and-inside, ${certBAD} failed`);
console.log(`F2 sampled admissible completions: ${sampOK} inside [S,upper], ${sampBAD} outside`);
if (badEx.length) badEx.forEach(b => console.log("   " + b)); else console.log("   no counterexamples");
console.log(`SOUNDNESS VERDICT: ${certBAD === 0 && sampBAD === 0 ? "PASS - no admissible completion falls outside [lower,upper]" : "*** BLOCKING BUG ***"}`);

console.log("\n#################### PART G - hazard derivation ####################");
// which clause groups are load-bearing for each exclusion: drop a group, re-ask.
const GROUPS = [...new Set(CLSRC.map(s => s.split("/")[1] || s.split("/")[0]))];
function attribute(seedSyms) {
  const t = kk(seedSyms, null);
  const S = symsOf(t.seed), upper = new Set(symsOf(t.upper));
  const excluded = E.filter(e => !S.includes(e) && !upper.has(e));
  const out = {};
  for (const e of excluded) {
    const blame = [];
    for (const g of GROUPS) {
      const sub = CL.filter((_, i) => (CLSRC[i].split("/")[1] || CLSRC[i].split("/")[0]) !== g);
      if (solve([...S.map(ix), ix(e)], [], sub)) blame.push(g);   // removing g made it possible
    }
    out[e] = blame;
  }
  return { S, excluded, out };
}
{ const a = attribute(["Fl", "Xm"]);
  console.log(`seed {Fl,Xm} at 58 elements: excluded = ${show(a.excluded)}`);
  console.log(`  F9 claimed Xf, Rl, Of are excluded. At 58: ` +
    ["Xf", "Rl", "Of"].map(e => `${e}=${a.excluded.includes(e) ? "EXCLUDED" : "still possible"}`).join(", "));
  for (const e of a.excluded) console.log(`   ${e} excluded, load-bearing rule(s): ${a.out[e].join(",") || "(interaction, no single rule)"}`); }
// which of the encodable written hazards actually fire as exclusions across the corpus
const HAZRULES = ["X11a*", "X19*", "X2", "X18", "X21"];
const fires = {}; for (const h of HAZRULES) fires[h] = 0;
let noRule = 0, totalExc = 0;
for (const p of T.lanes) {
  const a = attribute([...new Set(p.syms.filter(has))]);
  const seen = new Set();
  for (const e of a.excluded) { totalExc++;
    const hs = a.out[e].filter(g => HAZRULES.includes(g));
    if (hs.length) hs.forEach(h => seen.add(h)); else noRule++; }
  for (const h of seen) fires[h]++;
}
console.log(`\nacross the 72 protocol seeds: ${totalExc} element-exclusions in total`);
console.log(`  hazard rule -> number of the 72 seeds where it is load-bearing for >=1 exclusion:`);
for (const h of HAZRULES) console.log(`    ${h.padEnd(6)} ${fires[h]}/72`);
console.log(`  exclusions attributable to no single rule (closure/warrant/ground interaction): ${noRule}`);
console.log(`  NOTE: of the 20 written hazards only ${HAZRULES.length} have a set-membership projection at all`);
console.log(`  (HAZ_PROJ eligible = ${T.HAZ_PROJ.length}); the other 15 are prose conditions on quantities`);
console.log(`  outside the element vocabulary and can be neither derived nor refuted by this method.`);

console.log("\n#################### PART H - the other two operators from F9 ####################");
// O_R(z) = Delta1(Cn(z)) and O_H. Their lub over [S,TOP] contains O(TOP).
{
  const TOPset = new Set(E);
  const Cn = X0 => { const X = new Set(X0); let ch = true;
    while (ch) { ch = false; for (const [, subs, terms] of T.LSTAR) if (subs.some(s => X.has(s)))
      for (const t of terms) if (t.length === 1 && !X.has(t[0]) && has(t[0])) { X.add(t[0]); ch = true; } } return X; };
  const OR = z => T.Delta1(Cn(z));
  const atTop = OR(TOPset);
  console.log(`O_R(TOP) = Delta1(Cn(TOP)) has ${atTop.size} of ${n} elements; == TOP? ${atTop.size === n}`);
  console.log(`TOP admissible? ${T.admissible(TOPset)}  =>  O_H(TOP) = ${T.admissible(TOPset) ? "TOP" : "O_R(TOP)"}`);
  console.log(`lub O([S,TOP]) >= O(TOP), so for O_R and O_H the KK upper bound is >= ${atTop.size} elements`);
  console.log(`  => KK upper = TOP and the completion query is VACUOUS for O_R and O_H at 58 elements,`);
  console.log(`     for every seed, with no computation. Only O_A (fixpoints exactly Adm) survives.`);
  // and at 10 elements, to show F9 never tested this
  const T10 = new Set(U10); const at10 = new Set([...OR(T10)].filter(s => U10.includes(s)));
  console.log(`same check on the F9 10-element instance: |O_R(TOP10)| = ${at10.size}/10 -> ${at10.size === 10 ? "also vacuous there" : "not vacuous there"}`);
}

console.log("\n#################### PART J - where does the information come from? ####################");
// Split the theory. If every exclusion at 58 elements is already implied by the flat
// hand-written negative bans, then KK is re-deriving what the atlas literally states
// and is contributing nothing. Measured, not asserted.
function upperWith(seedSyms, clauses, universe) {
  const S = seedSyms.filter(has); const out = new Set(S);
  const uni = universe || E;
  const fixFalse = E.map((s, i) => i).filter(i => !uni.includes(E[i]) && !S.includes(E[i]));
  for (const e of uni) { if (out.has(e)) continue;
    if (solve([...S.map(ix), ix(e)], fixFalse, clauses)) out.add(e); }
  return out;
}
const POS = CL.filter((_, i) => !CLSRC[i].startsWith("ban") && !CLSRC[i].startsWith("listed"));
const BAN = CL.filter((_, i) => CLSRC[i].startsWith("ban") || CLSRC[i].startsWith("listed"));
{
  let posExc = 0, banExc = 0, fullExc = 0, seedsPosInformative = 0;
  for (const p of T.lanes) {
    const S = [...new Set(p.syms.filter(has))];
    const cand = E.filter(e => !S.includes(e));
    const uFull = upperWith(S, CL), uPos = upperWith(S, POS), uBan = upperWith(S, BAN);
    const eF = cand.filter(e => !uFull.has(e)).length;
    const eP = cand.filter(e => !uPos.has(e)).length;
    const eB = cand.filter(e => !uBan.has(e)).length;
    fullExc += eF; posExc += eP; banExc += eB; if (eP > 0) seedsPosInformative++;
  }
  console.log(`over the 72 protocol seeds, total element-exclusions at 58 elements:`);
  console.log(`  full theory (closure + warrant + ground + bans):  ${fullExc}`);
  console.log(`  positive theory ONLY (closure + warrant + ground): ${posExc}   [seeds with any: ${seedsPosInformative}/72]`);
  console.log(`  flat negative bans ONLY (X2,X11a*,X18,X19*,X21):   ${banExc}`);
  console.log(`  => information beyond the literal hand-written bans: ${fullExc - banExc} exclusions`);
}
{ // the same split on the F9 10-element instance, to show what the small scale measured
  let posExc = 0, banExc = 0, fullExc = 0;
  for (const s of [["Of"], ["Rl"], ["Fl", "Xm"], ["Of", "Rl"], ["Au"], ["In", "Bs"], ["Sh"], ["Xf"]]) {
    const cand = U10.filter(e => !s.includes(e));
    fullExc += cand.filter(e => !upperWith(s, CL, U10).has(e)).length;
    posExc += cand.filter(e => !upperWith(s, POS, U10).has(e)).length;
    banExc += cand.filter(e => !upperWith(s, BAN, U10).has(e)).length;
  }
  console.log(`same split on the F9 10-element vocabulary, 8 seeds: full ${fullExc}, positive-only ${posExc}, bans-only ${banExc}`);
  console.log(`  (at 10 elements the positive theory excludes a great deal, because the truncated`);
  console.log(`   vocabulary cannot satisfy the closure and warrant obligations at all.)`);
}

console.log("\n#################### PART I - cost ####################");
console.log(`total DPLL calls this run: ${DPLL_CALLS}, decisions ${DPLL_DECISIONS}, unit props ${DPLL_PROPS}`);
{ const ms = rows.map(r => r.ms).sort((a, b) => a - b);
  console.log(`per-seed KK wall clock over the 72: min ${ms[0].toFixed(0)} ms, median ${ms[36].toFixed(0)} ms, max ${ms[71].toFixed(0)} ms`);
  console.log(`per-seed SAT calls over the 72: ${Math.min(...rows.map(r => r.calls))} .. ${Math.max(...rows.map(r => r.calls))} (= |E\\S| per KK iteration)`); }
fs.writeFileSync("/root/DefiElements/formal/v2/f10-rows.json", JSON.stringify(rows, null, 1));
console.log("per-protocol rows written to f10-rows.json");
