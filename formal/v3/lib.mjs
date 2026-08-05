// v3 shared harness. Model classes (not operators), per paper section "Model classes, not operators".
import * as T from "/root/DefiElements/formal/v2/tables.mjs";

export const E = T.MECH;
export const ELEMS = T.ELEMS;
export const T_ = T;

// --- membership in the model classes, as CLAUSE SATISFACTION (no operator anywhere)
// Requirements under the RECORDED 29-row system (T.PARSED_NEW), which is what
// the paper states every figure uses. This previously called T.gammaOpen, which
// reads the reduced 11-row LSTAR; the two disagree on 387 of the 30,856
// three-element subsets, so the structural measurements below and the
// constructions in construct.mjs were computing in different models.
// Semantics are construct.mjs's, including the !external filter.
export const openReq = X => T.PARSED_NEW.flatMap(l =>
  !l.subjects.some(s => X.has(s)) ? [] :
  l.terms.filter(t => !t.external && !t.alts.some(a => X.has(a)))
         .map(t => [l.id, t.alts.join("|")]));
export const inR = X => openReq(X).length === 0;                // X |= Law  (requirements)
export const inW = X => T.unwarranted(X).length === 0;          // X |= War  (warrants)
export const grounded = X => !T.ungrounded(X);                  // X |= grounding clauses
export const inH = X => T.bansCond(X).length === 0;             // X |= Haz  (prohibitions, as shipped)
export const inRW = X => inR(X) && inW(X);
export const adm = X => inR(X) && inW(X) && inH(X) && grounded(X);

export const uni = (A, B) => new Set([...A, ...B]);
export const cap = (A, B) => new Set([...A].filter(x => B.has(x)));
export const key = S => [...S].sort().join(",");
export const S = (...xs) => new Set(xs);

// --- deterministic RNG (mulberry32). The v2 probes used Math.random(); the paper's exact
// counts are therefore not reproducible. We fix a seed and report it.
export function rng(seed) {
  let a = seed >>> 0;
  return () => { a |= 0; a = (a + 0x6D2B79F5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296; };
}

// draw up to `n` distinct members of a class by rejection sampling at density p
export function sample(pred, n, p, seed, budget = 4000000) {
  const r = rng(seed), out = [], seen = new Set();
  for (let i = 0; i < budget && out.length < n; i++) {
    const X = new Set(E.filter(() => r() < p));
    if (!pred(X)) continue;
    const k = key(X); if (seen.has(k)) continue;
    seen.add(k); out.push(X);
  }
  return out;
}
