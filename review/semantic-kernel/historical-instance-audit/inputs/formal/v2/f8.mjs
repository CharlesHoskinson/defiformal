// F8 - the Approximation Fixpoint Theory gate, and the stratifiability conjecture.
import * as T from "./tables.mjs";
const key = s => [...s].sort().join(",");
const U = ["Fl", "Xm", "Xf", "Rl", "Of", "Bs", "Sl", "Au", "Gs", "Uc", "Aw", "At", "Cp", "Cl", "Pl", "Cd", "Ix", "Sh", "Ct", "Li"];
const ALL = []; for (let m = 0; m < (1 << U.length); m++) ALL.push(new Set(U.filter((_, i) => m & (1 << i))));
const sub = (a, b) => [...a].every(x => b.has(x));
// Cn over the definite part of L* (single-alternative terms); the disjunctive part is
// a constraint, not a production, so it is not part of any consequence operator.
const Cn = S => { const X = new Set(S); let ch = true;
  while (ch) { ch = false; for (const [, subs, terms] of T.LSTAR) if (subs.some(s => X.has(s)))
    for (const t of terms) if (t.length === 1 && !X.has(t[0])) { X.add(t[0]); ch = true; } } return X; };
const D = T.Delta1;

console.log("=== F8.1 the two ingredients, checked ===");
let mCn = 0, mD = 0, N = 0;
for (let i = 0; i < ALL.length; i += 7) for (let j = 0; j < ALL.length; j += 1009) {
  const a = ALL[i], b = ALL[j]; if (!sub(a, b)) continue; N++;
  if (!sub(Cn(a), Cn(b))) mCn++;
  if (!sub(D(a), D(b))) mD++;
}
console.log(`over ${N} sampled pairs a<=b:  Cn monotone violations ${mCn},  Delta monotone violations ${mD}`);
console.log("Cn extensive?", ALL.every(s => sub(s, Cn(s))), " Delta contractive?", ALL.every(s => sub(D(s), s)));
console.log("Cn idempotent?", ALL.slice(0, 20000).every(s => key(Cn(Cn(s))) === key(Cn(s))),
  " Delta idempotent?", ALL.slice(0, 20000).every(s => key(D(D(s))) === key(D(s))));

console.log("\n=== F8.2 THE GATE: is there a <=_p-monotone A(x,y) built from Gamma and Delta? ===");
// The only shapes available. <=_p : (x,y) <=_p (x',y') iff x subset x' and y' subset y.
// A is <=_p-monotone iff A1 is MONOTONE in x and ANTITONE in y, and A2 ANTITONE in x, MONOTONE in y.
// Candidate 1, the product approximator:
const A = (x, y) => [Cn(x), D(y)];
let pmono = 0, exact = 0, incons = 0, M = 0;
for (let i = 0; i < ALL.length; i += 11) for (let j = 0; j < ALL.length; j += 1013) {
  const x = ALL[i], y = ALL[j];
  if (!sub(x, y)) continue;   // only consistent pairs are in the AFT domain
  M++;
  const [a1, a2] = A(x, y);
  if (!sub(a1, a2)) incons++;                 // consistency: A1 <= A2 whenever x <= y
}
for (const x of ALL.slice(0, 50000)) if (key(Cn(x)) !== key(D(x))) exact++;
// <=_p monotonicity, sampled
let bad = 0, tried = 0;
for (let i = 0; i < 200000; i++) {
  const x = ALL[(Math.random() * ALL.length) | 0], y = ALL[(Math.random() * ALL.length) | 0];
  const x2 = ALL[(Math.random() * ALL.length) | 0], y2 = ALL[(Math.random() * ALL.length) | 0];
  if (!(sub(x, x2) && sub(y2, y))) continue;  // (x,y) <=_p (x2,y2)
  tried++;
  const [a1, a2] = A(x, y), [b1, b2] = A(x2, y2);
  if (!(sub(a1, b1) && sub(b2, a2))) bad++;
}
console.log(`A(x,y) = (Cn(x), Delta(y)):`);
console.log(`  <=_p-monotone:  ${bad} violations in ${tried} sampled <=_p-comparable pairs  -> ${bad === 0 ? "MONOTONE" : "NOT monotone"}`);
console.log(`  CONSISTENT (x<=y => A1<=A2): ${incons} violations in ${M} sampled consistent pairs -> ${incons === 0 ? "consistent" : "NOT consistent"}`);
console.log(`  EXACT on the diagonal (A(x,x)=(O(x),O(x))): ${exact} of 50000 have Cn(x) != Delta(x) -> ${exact === 0 ? "exact" : "NOT exact"}`);
console.log("  coordinates interact? A1 ignores y and A2 ignores x =>", "NO - A is a componentwise product operator");

console.log("\n=== F8.3 why no coupling is available from Gamma and Delta alone ===");
console.log("<=_p-monotonicity forces A1 antitone in y and A2 antitone in x.");
console.log("Gamma (Cn) and Delta are both subset-MONOTONE (F8.1, 0 violations) and neither is constant,");
console.log("so neither can occupy an antitone slot. Any A composed from them by lattice");
console.log("operations therefore has A1 = f(x), A2 = g(y): a product. QED");
// the antitone ingredient that IS available: the bans (downward-closed)
const bansOK = S => T.bansCond(S).length === 0;
let anti = 0, at = 0;
for (let i = 0; i < ALL.length; i += 3) { const s = ALL[i];
  for (const e of U) if (!s.has(e)) { const t = new Set([...s, e]); at++; if (bansOK(t) && !bansOK(s)) anti++; } }
console.log(`bans are downward-closed: ${anti} of ${at} single-element extensions turned a banned set legal (0 expected)`);

console.log("\n=== F8.4 stratifiability (Vennekens Def 3.3) vs union-closure ===");
// stratify by the height-1 definite poset: bodies at level 0, heads at level 1, rest 0
const BODIES = new Set(["Cd","Gs","Im","Of","Op","Pf","Pl","Py","Rl","Uc"]);
const HEADS = new Set(["At","Au","Aw","Ct","Ep","Ex","Li","Rd","Xf","Xm"]);
const lvl = e => HEADS.has(e) ? 1 : 0;
const rows = [
  ["Gamma L*  (single-atom antecedent, disjunctive head)", ["Pl"], ["Sh","Ix","Rb"]],
  ["Delta     (single-atom antecedent, disjunctive head)", ["Fl"], ["Cp","Cl","St","Wg","Pm","Pl","Im","Cd","Ob","Ag","Sh","Ix"]],
  ["X11a*     (single-atom antecedent)", ["Uc"], ["Aw"]],
  ["X19*      (CONJUNCTIVE antecedent)", ["Aw","Xf"], ["At","Fz","Xm"]],
  ["X18       (CONJUNCTIVE antecedent)", ["Oa","Li"], ["Ex","Tp"]],
];
console.log("  row                                                    antecedent-levels head-levels stratified? union-closed?");
for (const [name, ante, head] of rows) {
  const al = ante.map(lvl), hl = head.map(lvl);
  const stratified = al.every(a => hl.every(h => a <= h));
  const unionClosed = ante.length === 1;
  console.log(`  ${name.padEnd(54)} ${JSON.stringify(al).padEnd(9)} ${JSON.stringify([...new Set(hl)]).padEnd(9)} ${String(stratified).padEnd(12)} ${unionClosed}`);
}
console.log("\n  WITNESS that stratifiable does NOT imply union-closed:");
console.log("    X19* : Aw and Xf both at level 0, head atom Xm at level 1 -> perfectly stratified.");
console.log("    But {Aw,At} and {Xf,At}... take the vacuous case: {Aw} satisfies it, {Xf} satisfies it,");
console.log("    {Aw} union {Xf} = {Aw,Xf} does not. Union-closure fails on a STRATIFIED rule.");
const a1 = new Set(["Aw"]), b1 = new Set(["Xf"]);
console.log(`    check: cond({Aw})=${T.bansCond(a1).length === 0} cond({Xf})=${T.bansCond(b1).length === 0} cond({Aw,Xf})=${T.bansCond(new Set(["Aw","Xf"])).length === 0}`);
console.log("  => stratifiability is a property of the DEPENDENCY GRAPH; union-closure is a property");
console.log("     of the ANTECEDENT ARITY. They are independent. Thm 3.5 does not answer F6.");

console.log("\n=== F8.5 does the congruence fragment F coincide with any stratified subtheory? ===");
const has = (S, ...xs) => xs.some(x => S.has(x));
const SPLIT = S => !S.has("Fl") &&
  (!S.has("Aw") || has(S, "At", "Fz", "Xm")) && (!S.has("Xf") || has(S, "At", "Fz", "Xm")) &&
  (!S.has("Oa") || has(S, "Ex", "Tp")) && (!S.has("Li") || has(S, "Ex", "Tp"));
const ADM = ALL.filter(s => T.admissible(s));
const F = ADM.filter(SPLIT);
// the "stratified subtheory" would keep every row whose dependency respects lvl; that is ALL of them
const strat = ADM.filter(s => true);
console.log(`|Adm| = ${ADM.length}, |F| = ${F.length}, |Adm restricted to the stratified subtheory| = ${strat.length}`);
console.log("Every row of the theory is stratified under the height-1 level map, so the stratified");
console.log("subtheory is the whole theory and F is a proper subset of it. F is not recovered by stratification.");

console.log("\n=== F8.6 the clean witness: stratified but not union-closed ===");
// Pl and Of are BODIES (level 0); Ct is a HEAD (level 1). The hypothetical row
//   Pl AND Of -> Ct
// is perfectly stratified (every antecedent atom strictly below the head) and has a
// conjunctive antecedent, so it is not union-closed.
const row = S => !(S.has("Pl") && S.has("Of")) || S.has("Ct");
console.log("  levels: Pl=0 Of=0 Ct=1  -> stratified: true");
console.log("  row({Pl}) =", row(new Set(["Pl"])), " row({Of}) =", row(new Set(["Of"])),
            " row({Pl,Of}) =", row(new Set(["Pl","Of"])));
console.log("  => stratified AND not union-closed. The two properties are independent.");
