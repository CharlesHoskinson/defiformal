// F7 (corrected universe). The 20-element OP-ORD test universe cannot contain any
// admissible Uc set at all, because L3's fourth term (Sv|Ft|Fz|Ep|Tr) has no member
// in it. That is a universe artifact, not a result. Redo over a universe that can.
import * as T from "./tables.mjs";
const key = s => [...s].sort().join(",");
const U = ["Uc", "Aw", "At", "Ct", "Ft", "Ep", "Sv", "Tr", "Fz", "Bs", "Sh", "Ix", "Rb", "Ex", "Cp", "Xf", "Xm", "Rd", "Ps", "Py"];
const ALL = []; for (let m = 0; m < (1 << U.length); m++) ALL.push(new Set(U.filter((_, i) => m & (1 << i))));
const ADM = ALL.filter(s => T.admissible(s));
const withUc = ADM.filter(s => s.has("Uc"));
console.log(`universe: ${U.join(" ")}`);
console.log(`|2^U|=${ALL.length} |Adm|=${ADM.length} |Adm containing Uc|=${withUc.length}`);
const sorted = withUc.map(key).sort((a, b) => a.split(",").length - b.split(",").length);
console.log("smallest admissible Uc witnesses:", sorted.slice(0, 6));
// inverted-polarity reading of X11a as written ("Uc with no Aw, At, ..." projected as
// all-named-present = armed) -- the projection bug P12 identifies
const inv = ALL.filter(s => {
  const [, p] = T.admissible(s, true);
  const h = p.hazard.filter(x => x !== "X11a*");
  const armedInverted = s.has("Uc") && s.has("Aw") && s.has("At");
  return p.closure.length === 0 && p.warrant.length === 0 && !p.ground && h.length === 0 && !armedInverted;
});
console.log(`under the INVERTED X11a projection: |Adm|=${inv.length}, containing Uc = ${inv.filter(s => s.has("Uc")).length}`);
console.log("\nlive Uc protocols under the corrected model:");
for (const p of T.lanes.filter(p => p.syms.includes("Uc"))) {
  const s = new Set(p.syms.filter(x => T.SYMS.has(x)));
  const [ok, pp] = T.admissible(s, true);
  console.log(`  ${p.name} {${[...s].sort().join(" ")}}: admissible=${ok}`);
}
