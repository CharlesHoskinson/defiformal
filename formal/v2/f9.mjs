// F9 - the ultimate approximator U_O, its Kripke-Kleene fixpoint and its
// well-founded fixpoint, brute-forced on a small known-answer instance.
// DMT Thm 4.5: U_O(x,y) = (glb O([x,y]), lub O([x,y])), no hypothesis on O.
import * as T from "./tables.mjs";

const U = ["Fl", "Xm", "Xf", "Rl", "Of", "Au", "Sh", "Ix", "In", "Bs"];
const n = U.length, N = 1 << n, FULL = N - 1;
const setOf = m => new Set(U.filter((_, i) => m & (1 << i)));
const show = m => m === 0 ? "{}" : "{" + U.filter((_, i) => m & (1 << i)).join(",") + "}";
const SETS = []; for (let m = 0; m < N; m++) SETS.push(setOf(m));

const ADM = new Uint8Array(N);
for (let m = 0; m < N; m++) ADM[m] = T.admissible(SETS[m]) ? 1 : 0;
const admList = []; for (let m = 0; m < N; m++) if (ADM[m]) admList.push(m);
console.log(`instance: ${U.join(" ")}   |L| = 2^${n} = ${N}`);
console.log(`|Adm| = ${admList.length}`);
console.log(`is the empty protocol admissible?  ${ADM[0] ? "YES" : "no"}`);
let unionAdm = 0; for (const m of admList) unionAdm |= m;
console.log(`union of all admissible sets = ${show(unionAdm)}  == TOP? ${unionAdm === FULL}`);

// --- the natural "repair" operator, for comparison
const bitsOf = m => SETS[m];
const maskOf = S => { let m = 0; U.forEach((u, i) => { if (S.has(u)) m |= 1 << i; }); return m; };
const Cn = m => { // definite closure over L*
  const X = new Set(bitsOf(m)); let ch = true;
  while (ch) { ch = false; for (const [, subs, terms] of T.LSTAR) if (subs.some(s => X.has(s)))
    for (const t of terms) if (t.length === 1 && !X.has(t[0])) { X.add(t[0]); ch = true; } }
  return maskOf(X);
};
const Dl = m => maskOf(T.Delta1(bitsOf(m)));

// --- candidate operators O with fix(O) related to Adm
const OPS = {
  // O_A: the operator the task asks for - fixpoints EXACTLY the admissible sets
  "O_A (identity on Adm, collapses to bottom off it)": m => ADM[m] ? m : 0,
  // O_R: the natural repair operator, close then strip
  "O_R (Delta o Cn, the natural repair)": m => Dl(Cn(m)),
  // O_H: hybrid - identity on Adm, repair off it
  "O_H (identity on Adm, Delta o Cn off it)": m => ADM[m] ? m : Dl(Cn(m)),
};

function analyse(label, O) {
  const Ov = new Int32Array(N); for (let m = 0; m < N; m++) Ov[m] = O(m);
  const fix = []; for (let m = 0; m < N; m++) if (Ov[m] === m) fix.push(m);
  const fixIsAdm = fix.length === admList.length && fix.every(m => ADM[m]);
  console.log(`\n================ ${label} ================`);
  console.log(`|fix(O)| = ${fix.length};  fix(O) == Adm ?  ${fixIsAdm}`);
  if (!fixIsAdm) {
    const extra = fix.filter(m => !ADM[m]).slice(0, 4).map(show);
    const missing = admList.filter(m => Ov[m] !== m).slice(0, 4).map(show);
    console.log(`   extra fixpoints: ${extra.join(" ")}${extra.length ? "" : "none"}   admissible non-fixpoints: ${missing.join(" ")}${missing.length ? "" : "none"}`);
  }

  // ---- ultimate approximator, tabulated over all consistent pairs
  const glb = new Int32Array(N * N).fill(-1), lub = new Int32Array(N * N).fill(-1);
  for (let x = 0; x < N; x++) {
    const rest = FULL & ~x;
    // iterate y over supersets of x
    let sub = rest;
    while (true) {
      const y = x | sub;
      // enumerate z in [x,y]
      let g = FULL, l = 0, s2 = y & ~x;
      while (true) {
        const z = x | s2, v = Ov[z]; g &= v; l |= v;
        if (s2 === 0) break; s2 = (s2 - 1) & (y & ~x);
      }
      glb[x * N + y] = g; lub[x * N + y] = l;
      if (sub === 0) break; sub = (sub - 1) & rest;
    }
  }
  const A1 = (x, y) => glb[x * N + y], A2 = (x, y) => lub[x * N + y];

  // ---- Kripke-Kleene: <=_p-least fixpoint of U_O, iterate from (bottom, top)
  let x = 0, y = FULL, steps = 0;
  const trace = [`(${show(x)}, ${show(y)})`];
  while (steps < 200) {
    const nx = A1(x, y), ny = A2(x, y);
    if (nx === x && ny === y) break;
    x = nx; y = ny; steps++; trace.push(`(${show(x)}, ${show(y)})`);
    if (!((x & ~y) === 0)) { trace.push("INCONSISTENT"); break; }
  }
  console.log(`Kripke-Kleene: ${trace.join("  ->  ")}`);
  console.log(`  KK = (${show(x)}, ${show(y)})   ${x === 0 && y === FULL ? "== (BOTTOM, TOP): TOTAL COLLAPSE" : "informative?"}`);
  console.log(`  KK interval size = ${1 << popcount(y & ~x)} of ${N} candidates (${(100 * (1 << popcount(y & ~x)) / N).toFixed(1)}%)`);

  // ---- stable revision and the well-founded fixpoint
  // St(x,y) = ( lfp_z A1(z,y) , lfp_z A2(x,z) ).
  // Convention, stated: the lower lfp starts at bottom; the upper lfp starts at x,
  // which is the least point of the sublattice on which [x,z] is non-empty. Both
  // maps are monotone, so both least fixpoints exist and are reached by iteration.
  const stable = (px, py) => {
    let z = 0; for (let k = 0; k < 200; k++) { const w = A1(z, py); if (w === z) break; z = w; }
    let w = px; for (let k = 0; k < 200; k++) { const v = A2(px, w); if (v === w) break; w = v; }
    return [z, w];
  };
  let sx = 0, sy = FULL, st = 0;
  const strace = [`(${show(sx)}, ${show(sy)})`];
  while (st < 200) {
    const [nx2, ny2] = stable(sx, sy);
    if (nx2 === sx && ny2 === sy) break;
    sx = nx2; sy = ny2; st++; strace.push(`(${show(sx)}, ${show(sy)})`);
  }
  console.log(`well-founded: ${strace.join("  ->  ")}`);
  const isFix = A1(sx, sy) === sx && A2(sx, sy) === sy;
  console.log(`  WF = (${show(sx)}, ${show(sy)})   fixpoint of U_O? ${isFix}   exact (sx==sy)? ${sx === sy}`);
  console.log(`  WF verdict: ${sx === 0 && sy === FULL ? "(BOTTOM, TOP) - TOTAL COLLAPSE, zero information"
    : sx === sy ? `total and exact, but it names exactly one protocol: ${show(sx)}`
      : `partial: ${popcount(sy & ~sx)} atoms undecided of ${n}`}`);
  // how much does WF actually decide?
  const decided = n - popcount(sy & ~sx);
  console.log(`  atoms decided by WF: ${decided}/${n};  admissible sets inside the WF interval: ${admList.filter(m => (sx & ~m) === 0 && (m & ~sy) === 0).length} of ${admList.length}`);
  return { kk: [x, y], wf: [sx, sy] };
}
function popcount(v) { let c = 0; while (v) { v &= v - 1; c++; } return c; }

for (const [label, O] of Object.entries(OPS)) analyse(label, O);

console.log("\n================ why this is forced, not an accident ================");
console.log(`1. The empty protocol is admissible (no law fires, nothing is unwarranted,`);
console.log(`   no ban is armed, nothing is ungrounded): ADM[{}] = ${ADM[0]}.`);
console.log(`2. Therefore O({}) = {} for EVERY operator whose fixpoints are the admissible sets.`);
console.log(`3. The Kripke-Kleene iteration starts at (BOTTOM, TOP), whose interval is all of L`);
console.log(`   and therefore contains {}. So its lower bound is glb O(L) <= O({}) = BOTTOM.`);
console.log(`4. Every atom of this instance occurs in some admissible set (union = TOP: ${unionAdm === FULL}),`);
console.log(`   so the upper bound is lub O(L) >= union of Adm = TOP.`);
console.log(`   => U_O(BOTTOM,TOP) = (BOTTOM,TOP) and KK = (BOTTOM,TOP), for ANY such O.`);
console.log(`This is a theorem about the atlas, not a property of one chosen O.`);
// verify claim 4 atom by atom
const missingAtom = U.filter((_, i) => !(unionAdm & (1 << i)));
console.log(`atoms in NO admissible set: ${missingAtom.length ? missingAtom.join(",") : "none"}`);

// ---------------------------------------------------------------- salvage test
// The collapse is driven by {} being a fixpoint at the bottom of L. The real
// question an integrator asks is bounded: "I already have S; what follows?"
// That lives in the sublattice [S, TOP], where {} is not present.
console.log("\n================ salvage: AFT on the COMPLETION lattice [S, TOP] ================");
function seeded(seedSyms, O) {
  const seed = maskOf(new Set(seedSyms));
  const free = FULL & ~seed;
  const pts = []; let s = free; while (true) { pts.push(seed | s); if (s === 0) break; s = (s - 1) & free; }
  const inL = new Uint8Array(N); for (const p of pts) inL[p] = 1;
  const Ov = new Int32Array(N); for (const p of pts) Ov[p] = O(p) | seed;   // O closed into [S,TOP]
  const A1 = (x, y) => { let g = FULL, s2 = y & ~x; while (true) { const z = x | s2; if (inL[z]) g &= Ov[z]; if (s2 === 0) break; s2 = (s2 - 1) & (y & ~x); } return g | seed; };
  const A2 = (x, y) => { let l = 0, s2 = y & ~x; while (true) { const z = x | s2; if (inL[z]) l |= Ov[z]; if (s2 === 0) break; s2 = (s2 - 1) & (y & ~x); } return l | seed; };
  let x = seed, y = FULL;
  for (let k = 0; k < 100; k++) { const nx = A1(x, y), ny = A2(x, y); if (nx === x && ny === y) break; x = nx; y = ny; }
  const stable = (px, py) => { let z = seed; for (let k = 0; k < 100; k++) { const w = A1(z, py); if (w === z) break; z = w; }
                               let w = px;   for (let k = 0; k < 100; k++) { const v = A2(px, w); if (v === w) break; w = v; } return [z, w]; };
  let sx = seed, sy = FULL; for (let k = 0; k < 100; k++) { const [a, b] = stable(sx, sy); if (a === sx && b === sy) break; sx = a; sy = b; }
  const admIn = admList.filter(m => (seed & ~m) === 0);
  const admInWF = admIn.filter(m => (sx & ~m) === 0 && (m & ~sy) === 0);
  console.log(`seed ${show(seed)}: |[S,TOP]| = ${pts.length}, admissible completions = ${admIn.length}`);
  console.log(`  KK = (${show(x)}, ${show(y)})  ${x === seed && y === FULL ? "= (bottom_L, top_L): COLLAPSE" : "informative"}`);
  console.log(`  WF = (${show(sx)}, ${show(sy)})  decided beyond the seed: ${popcount(sx & ~seed)} in / ${popcount(FULL & ~sy)} out;  admissible completions inside WF: ${admInWF.length}/${admIn.length}`);
}
for (const seed of [["Pl"], ["Uc"], ["Of"], ["Rl"], ["Fl", "Xm"], ["Of", "Rl"]]) seeded(seed, m => ADM[m] ? m : 0);
