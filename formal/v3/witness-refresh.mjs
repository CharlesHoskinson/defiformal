// Replacement witnesses under PARSED_NEW for the proofs whose witnesses were
// computed under LSTAR and are invalid under the recorded rows.
import * as T from "../v2/tables.mjs";
const E = T.MECH;

const openP = X => T.PARSED_NEW.filter(l =>
  l.subjects.some(s => X.has(s)) &&
  l.terms.some(t => !t.external && !t.alts.some(a => X.has(a)))).map(l => l.id);
const inR = X => openP(X).length === 0;
const inW = X => T.unwarranted(X).length === 0;
const inRW = X => inR(X) && inW(X);
const S = a => new Set(a);
const str = X => "{" + [...X].sort().join(",") + "}";

function complete(seed, prefer) {
  const X = new Set(seed);
  for (let g = 0; g < 200; g++) {
    let ch = false;
    for (const l of T.PARSED_NEW) {
      if (!l.subjects.some(s => X.has(s))) continue;
      for (const t of l.terms) {
        if (t.external || t.alts.some(a => X.has(a))) continue;
        X.add(t.alts.find(a => prefer.has(a)) ?? t.alts[0]); ch = true;
      }
    }
    if (!ch) break;
  }
  return X;
}

console.log("=== SITE 2  A,B in RnW with A n B not in RnW ===");
let best = null;
for (const l of T.PARSED_NEW)
  for (const t of l.terms) {
    if (t.external || t.alts.length < 2) continue;
    for (const s of l.subjects)
      for (let i = 0; i < t.alts.length; i++)
        for (let j = i + 1; j < t.alts.length; j++) {
          const A = complete([s, t.alts[i]], S([t.alts[i]]));
          const B = complete([s, t.alts[j]], S([t.alts[j]]));
          if (!inRW(A) || !inRW(B)) continue;
          const cap = new Set([...A].filter(x => B.has(x)));
          if (inRW(cap)) continue;
          const size = A.size + B.size;
          if (!best || size < best.size)
            best = { size, law: l.id, s, a1: t.alts[i], a2: t.alts[j], A, B, cap,
                     open: openP(cap), unw: T.unwarranted(cap) };
        }
  }
if (best) {
  console.log("  A     = " + str(best.A) + "   in RnW: " + inRW(best.A));
  console.log("  B     = " + str(best.B) + "   in RnW: " + inRW(best.B));
  console.log("  A n B = " + str(best.cap));
  console.log("  open: " + (best.open.join(",") || "-") + "   unwarranted: " + (best.unw.join(",") || "-"));
  console.log("  law " + best.law + ", subject " + best.s + ", witnesses " + best.a1 + " and " + best.a2);
  const el = [...best.cap];
  let meet = null;
  for (let m = el.length; m >= 0 && !meet; m--) {
    const rec = (start, cur) => {
      if (meet) return;
      if (cur.length === m) { const X = S(cur); if (inRW(X)) meet = X; return; }
      for (let k = start; k < el.length; k++) rec(k + 1, cur.concat(el[k]));
    };
    rec(0, []);
  }
  console.log("  true meet = " + (meet ? str(meet) : "(none)"));
} else console.log("  none found");

console.log("");
console.log("=== SITE 3  X |= Law but Delta^w(X) does not ===");
const dOmega = X => {
  let Y = new Set(X);
  for (let g = 0; g < 100; g++) {
    const u = T.unwarranted(Y);
    if (!u.length) break;
    for (const e of u) Y.delete(e);
  }
  return Y;
};
let s3 = null;
outer:
for (let i = 0; i < E.length; i++)
  for (let j = i + 1; j < E.length; j++)
    for (let k = j + 1; k < E.length; k++)
      for (let m = k + 1; m < E.length; m++) {
        const X = S([E[i], E[j], E[k], E[m]]);
        if (!inR(X)) continue;
        const Y = dOmega(X);
        if (Y.size < X.size && !inR(Y)) {
          s3 = { X, Y, removed: [...X].filter(e => !Y.has(e)), open: openP(Y) };
          break outer;
        }
      }
if (s3) {
  console.log("  X          = " + str(s3.X) + "   |= Law: " + inR(s3.X));
  console.log("  Delta^w(X) = " + str(s3.Y));
  console.log("  removed    = " + s3.removed.join(","));
  console.log("  open in it = " + s3.open.join(","));
} else console.log("  none at size <= 4");
