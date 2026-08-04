import * as T from "./tables.mjs";
const key = s => [...s].sort().join(",");
const has = (S, ...xs) => xs.some(x => S.has(x));
const SPLIT = S =>
  !S.has("Fl") &&
  (!S.has("Aw") || has(S, "At", "Fz", "Xm")) && (!S.has("Xf") || has(S, "At", "Fz", "Xm")) &&
  (!S.has("Oa") || has(S, "Ex", "Tp")) && (!S.has("Li") || has(S, "Ex", "Tp"));
const clean = p => new Set(p.syms.filter(x => T.SYMS.has(x)));

console.log("=== F6 coverage on the 72 live decompositions ===");
const liveAdm = T.lanes.filter(p => T.admissible(clean(p)));
const liveF = liveAdm.filter(p => SPLIT(clean(p)));
console.log(`${liveAdm.length}/72 admissible; ${liveF.length} of those lie in the congruence fragment F`);
console.log("admissible but OUTSIDE F:", liveAdm.filter(p => !liveF.includes(p)).map(p => p.name).join(", "));
let pTot = 0, pAdm = 0, pF = 0, falseNeg = 0;
for (let i = 0; i < liveAdm.length; i++) for (let j = i + 1; j < liveAdm.length; j++) {
  pTot++;
  const un = new Set([...clean(liveAdm[i]), ...clean(liveAdm[j])]);
  const ok = T.admissible(un); if (ok) pAdm++;
  const inF = liveF.includes(liveAdm[i]) && liveF.includes(liveAdm[j]);
  if (inF) { pF++; if (!ok) falseNeg++; }
}
console.log(`pairs of admissible live protocols: ${pTot}; union admissible for ${pAdm} (${(100 * pAdm / pTot).toFixed(1)}%)`);
console.log(`certified a priori by F (no re-analysis needed): ${pF} (${(100 * pF / pTot).toFixed(1)}%), of which wrong: ${falseNeg}`);

console.log("\n=== F7: is Uc realizable? ===");
const U = ["Fl", "Xm", "Xf", "Rl", "Of", "Bs", "Sl", "Au", "Gs", "Uc", "Aw", "At", "Cp", "Cl", "Pl", "Cd", "Ix", "Sh", "Ct", "Li"];
const ALL = []; for (let m = 0; m < (1 << U.length); m++) ALL.push(new Set(U.filter((_, i) => m & (1 << i))));
const ADM = ALL.filter(s => T.admissible(s));
const withUc = ADM.filter(s => s.has("Uc"));
console.log(`admissible sets containing Uc in the 2^20 test universe: ${withUc.length} of ${ADM.length}`);
console.log("  smallest witnesses:", withUc.map(key).sort((a, b) => a.split(",").length - b.split(",").length).slice(0, 4));
// under the inverted (as-written) X11a projection: "Uc, Aw, At all present" = hazard armed
const X11a_inverted = S => !(S.has("Uc") && S.has("Aw") && S.has("At"));
const inv = ALL.filter(s => {
  // gamma + delta + ground + the other bans, but X11a read with the inverted polarity
  const [, p] = T.admissible(s, true);
  const h = p.hazard.filter(x => x !== "X11a*");
  return p.closure.length === 0 && p.warrant.length === 0 && !p.ground && h.length === 0 && X11a_inverted(s);
});
console.log(`under the INVERTED X11a reading, admissible sets containing Uc: ${inv.filter(s => s.has("Uc")).length}`);
for (const p of T.lanes.filter(p => p.syms.includes("Uc"))) {
  const [ok, pp] = T.admissible(clean(p), true);
  console.log(`  ${p.name}: admissible=${ok} ${ok ? "" : JSON.stringify(Object.fromEntries(Object.entries(pp).filter(([, v]) => v && v.length !== 0)))}`);
}
console.log("\n=== T1': the gamma/Delta non-commutation obstruction, enumerated ===");
const gclose = S => { // one-pass gamma over the definite fragment of L* (single-alt terms)
  const X = new Set(S);
  let changed = true;
  while (changed) { changed = false;
    for (const [, subs, terms] of T.LSTAR) if (subs.some(s => X.has(s)))
      for (const t of terms) if (t.length === 1 && !X.has(t[0])) { X.add(t[0]); changed = true; } }
  return X;
};
let ncomm = 0, ex = null;
for (const s of ALL) {
  const a = key(T.DeltaInf(gclose(s))), b = key(gclose(T.DeltaInf(s)));
  if (a !== b) { ncomm++; if (!ex) ex = [key(s), a, b]; }
}
console.log(`Delta(gamma(X)) != gamma(Delta(X)) on ${ncomm} of ${ALL.length} sets (${(100 * ncomm / ALL.length).toFixed(2)}%)`);
console.log("  witness X / Delta(gamma X) / gamma(Delta X):", JSON.stringify(ex));
