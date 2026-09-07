// v2 tables: independent re-extraction of the atlas from viz/src/data.ts,
// with the CORRECTED parser (mixed terms are residue) and the OP-ORD warrant table.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
// Resolved from this file's own location so the harnesses run in any clone.
// Was "/root/DefiElements", which made every README reproduce command fail.
export const SELF_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
export const ROOT = process.env.DEFIFORMAL_ROOT || SELF_ROOT;
// This module feeds every published figure. A stale DEFIFORMAL_ROOT would
// silently compute them from another tree, so the override announces itself.
if (ROOT !== SELF_ROOT) console.error(`tables.mjs: NOTE - reading ${ROOT} (DEFIFORMAL_ROOT), not ${SELF_ROOT}`);
const src = fs.readFileSync(`${ROOT}/viz/src/data.ts`, "utf8");

// ---------- elements
export const ELEMS = {};
const RE = /\{\s*id:\s*"([^"]+)",\s*sym:\s*"([^"]+)",\s*name:\s*"([^"]*)",\s*group:\s*"([^"]+)",\s*stratum:\s*(\d),\s*atom:\s*"([NRI])",\s*status:\s*"([a-z]+)"/g;
let m;
while ((m = RE.exec(src))) {
  const [, id, sym, name, group, stratum, atom, status] = m;
  ELEMS[sym] = { id, sym, name, group, stratum: +stratum, atom, status };
}
export const SYMS = new Set(Object.keys(ELEMS));
export const MECH = Object.values(ELEMS).filter(e => e.status !== "limit").map(e => e.sym);

// ---------- laws
export const LAWS = [];
for (const l of src.matchAll(/\{\s*id:\s*"(L\d+)",\s*rule:\s*"([^"]+)"/g)) LAWS.push({ id: l[1], rule: l[2] });

// ---------- hazards
export const HAZ = [];
for (const h of src.matchAll(/\{\s*id:\s*"(X\d+[ab]?)",\s*combo:\s*"([^"]+)",\s*cls:\s*"([FHU])"/g))
  HAZ.push({ id: h[1], combo: h[2], cls: h[3] });

const bare = s => s.replace(/\{[^}]*\}/g, "").replace(/[()]/g, "").trim();

// ---------- THE PARSER. Two variants, so the fix is measurable.
function parseSide(side, corrected) {
  return side.split("+").map(chunk => {
    const raw = chunk.trim();
    const parts = raw.split("|").map(bare);
    const alts = parts.filter(a => SYMS.has(a));
    const mixed = alts.length > 0 && alts.length < parts.length;
    // OLD: external <=> no element alternative at all (a mixed term hard-required its element)
    // NEW: external <=> no element alternative, OR a prose alternative sits beside one
    const external = corrected ? (alts.length === 0 || mixed) : (alts.length === 0);
    return { alts, prose: raw, external, mixed };
  });
}
function parseLaws(corrected) {
  return LAWS.map(l => {
    const [lhs, rhs = ""] = l.rule.split("→");
    const subjects = (lhs || "").split("|").map(bare).filter(s => SYMS.has(s));
    return { id: l.id, rule: l.rule, subjects, terms: parseSide(rhs, corrected) };
  });
}
export const PARSED_NEW = parseLaws(true);
export const PARSED_OLD = parseLaws(false);

export function openTerms(S, parsed) {
  const out = [];
  for (const law of parsed) {
    if (!law.subjects.some(s => S.has(s))) continue;
    for (const t of law.terms) {
      if (t.external) continue;
      if (!t.alts.some(a => S.has(a))) out.push([law.id, t.prose]);
    }
  }
  return out;
}
export const closesNew = S => openTerms(S, PARSED_NEW).length === 0;
export const closesOld = S => openTerms(S, PARSED_OLD).length === 0;

// ---------- listed hazards, membership projection
const NEGRE = /\b(no|without|absent|lacking|missing|never)\b/i;
export const HAZ_PROJ = HAZ.map(h => {
  const named = [...new Set((h.combo.match(/\b[A-Z][a-z]{1,2}\b/g) || []).filter(x => SYMS.has(x)))];
  return { ...h, named, eligible: named.length >= 2 && !NEGRE.test(h.combo) };
}).filter(h => h.eligible);
export const armedListed = S => HAZ_PROJ.filter(h => h.named.every(e => S.has(e))).map(h => h.id);

// ---------- OP-ORD corrected law system L* (report OP-ORD section 2)
const PRICE = ["Ex", "Tp", "At", "Oa", "Sv", "Cl", "Cp", "St", "Wg"];
const INDEX = ["Ex", "Tp", "Oa", "At"];
const LOSS = ["Li", "Ad", "Sl", "Bs"];
const TERMINAL = ["Sl", "Ad", "Bs", "Tr", "Cv", "Wq", "Rd", "Ps", "Sv", "Im", "Of"];
export const LSTAR = [
  ["L1a", ["Pl", "Im", "Cd", "Pf", "Op"], [PRICE]],
  ["L1c", ["Pl", "Im", "Cd", "Pf"], [["Ct"]]],
  ["L1d", ["Pl", "Im", "Cd", "Pf"], [LOSS]],
  ["L2", ["Pl"], [["Sh", "Ix", "Rb"], TERMINAL]],
  ["L3", ["Uc"], [["Aw"], ["At"], ["Bs", "Tr", "Sv", "Ft", "Ct"], ["Sv", "Ft", "Fz", "Ep", "Tr"]]],
  ["L4", ["Pf"], [INDEX, ["Ct"], ["Li", "Ad", "Sl", "Bs"]]],
  ["L5", ["Py"], [["Sh", "Ix", "Rb"], ["Ep"], ["Rd"]]],
  ["L7", ["Cd"], [["Rd", "Ps", "Li", "Ad", "Sl", "Bs"]]],
  ["L19", ["Of"], [["Xm"], ["Xf"], ["Bs", "Sl"]]],
  ["L20", ["Rl"], [["Au"]]],
  ["L21", ["Gs"], [["Au"]]],
];

// ---------- the 27 warrant rows (OP-ORD section 4, residual C)
export const CONSUME = {
  Ct: ["Pl", "Im", "Cd", "Uc", "Ft", "Pf", "Op", "Dp", "Tr", "Cv", "Rs", "Vl", "Pm", "Ob", "Fl", "Rd"],
  Li: ["Ct"],
  Ad: ["Ct", "Pf", "Ob"],
  Sl: ["Pl", "Im", "Cd", "Uc", "Ft", "Pf", "Op", "Tr", "Cv", "Rs", "Vl", "Ob", "Dp", "Bs", "Ct", "Xf", "Xm"],
  Bs: ["Pl", "Im", "Cd", "Uc", "Pf", "Op", "Rs", "Vl", "In", "Of", "Xm", "Xf", "Cv", "Tr", "Ob", "Ct", "Sl", "Rl", "Ba", "Ft", "Wq"],
  Tp: ["Cp", "Cl", "St", "Wg", "Pm", "Ob"],
  Ex: ["Ct", "Li", "Ad", "Pf", "Op", "Pm", "Cd", "Pl", "Im", "Uc", "Ft", "As", "Ps", "Rd", "Tr", "Cv", "Sl", "Bs", "Vl", "Dp", "Py", "Sv", "Rl", "Oa", "Rs", "Sr", "Cl", "St", "Wg", "Cp", "Ob", "Of", "In"],
  Xm: ["Xf", "Rs", "In", "Of", "Rl", "Vl", "Ob", "Sb", "Up", "Tg", "Gp"],
  Sv: ["Tr", "Pl", "Im", "Uc", "Ft", "Cv", "Op", "Cd", "Rl", "Sh", "Ep", "Wq"],
  Ps: ["At", "Cd", "Rd", "Xf", "Fz", "Aw", "Ix", "Sr"],
  As: ["Ex", "Tp", "Oa", "At"],
  Fl: ["Cp", "Cl", "St", "Wg", "Pm", "Pl", "Im", "Cd", "Ob", "Ag", "Sh", "Ix"],
  Of: ["Xf", "In", "Rl", "Xm"],
  Pf: ["Ct", "Ob", "Pm", "Ex"],
  Op: ["Ct", "Ob", "Ex", "Sh", "Rf", "Pm", "Cl"],
  Py: ["Ix", "Sh", "Rb", "Ft"],
  Tr: ["Pl", "Im", "Uc", "Ft", "Cd", "Cv", "Rs", "Vl", "Sh", "Ix", "Sv", "Dp"],
  Cv: ["Pl", "Im", "Cd", "Uc", "Bs", "Sh"],
  Rl: ["In", "Xf", "Xm", "Of", "Au", "Ob", "Rf"],
  Gs: ["Au", "Ob", "In", "Rl", "Aw"],
  Vl: ["Rs", "Bs", "Sl", "Sh", "Wq", "Ep", "Rb", "Ix", "Xf", "Ob"],
  Ft: ["Sh", "Ix", "Rb", "Py", "Ep", "At", "Sv", "Uc", "Tr"],
  Rb: ["Sh", "Ix", "Vl", "Pl", "Im", "Cd", "Ps", "Rd"],
  Pl: ["Sh", "Ix", "Rb"],
  Im: ["Sh", "Ix", "Rb", "Ct"],
  Uc: ["Sh", "Ix", "Rb", "Ft"],
  Cd: ["Sh", "Ix", "Rb", "Rd", "Ps", "As"],
};
export const DEPENDENT = new Set(Object.keys(CONSUME));

// ---------- the operators
const has = (S, ...xs) => xs.some(x => S.has(x));
export const gammaOpen = S => {
  const out = [];
  for (const [id, subs, terms] of LSTAR)
    if (subs.some(s => S.has(s)))
      for (const t of terms) if (!has(S, ...t)) out.push([id, t.join("|")]);
  return out;
};
export const unwarranted = S => [...S].filter(e => CONSUME[e] && !has(S, ...CONSUME[e])).sort();
// Delta as a kernel operator: strip unwarranted dependents to a fixed point
export const Delta1 = S => new Set([...S].filter(e => !(CONSUME[e] && !has(S, ...CONSUME[e]))));
export function DeltaInf(S) { let X = S, Y = Delta1(X); while (Y.size !== X.size) { X = Y; Y = Delta1(X); } return X; }
export const bansCond = S => {
  const o = [];
  if (S.has("Uc") && !(S.has("Aw") && S.has("At"))) o.push("X11a*");
  if (S.has("Aw") && S.has("Xf") && !has(S, "At", "Fz", "Xm")) o.push("X19*");
  if (S.has("Fl") && has(S, "Cp", "Cl") && has(S, "Pl", "Cd", "Im")) o.push("X2");
  if (S.has("Oa") && S.has("Li") && !has(S, "Ex", "Tp")) o.push("X18");
  if (S.has("Fl") && has(S, "Xf", "Rl", "Of")) o.push("X21");
  return o.concat(armedListed(S));
};
const RISKG = new Set(["G05", "G06", "G07", "G13", "G16"]);
export const ungrounded = S => [...S].some(e => RISKG.has(ELEMS[e].group)) && ![...S].some(e => ELEMS[e].stratum <= 2);

// SUPERSEDED for anything the paper reports. This reads gammaOpen, i.e. the
// reduced 11-row L*; every published figure is computed against the recorded
// 29-row system through formal/v3/construct.mjs's `admissibility`. The two
// disagree on 387 of the 30,856 subsets tested, and the disagreement reaches the
// results: under L* the applied section's agreement on {Ct, Ex, Li} weakens to
// {Ct} and Ct becomes primitive in a fourth protocol (REFEREE-B, B4). Kept
// because the L* comparison is itself reported as a robustness check -- use it
// deliberately, not by reaching for the first admissibility predicate in the
// repository. See paper/atlas.tex, remark [Method].
export function admissible(S, parts = false) {
  const f = gammaOpen(S), w = unwarranted(S), h = bansCond(S), g = ungrounded(S);
  const ok = !(f.length || w.length || h.length || g);
  return parts ? [ok, { closure: f, warrant: w, hazard: h, ground: g }] : ok;
}

// ---------- corpora
export const blind = JSON.parse(fs.readFileSync(`${ROOT}/algebra/blind-test-set.json`, "utf8")).cases;
export const lanes = [];
for (const f of fs.readdirSync(`${ROOT}/corpus50/lanes`).sort()) {
  const d = JSON.parse(fs.readFileSync(`${ROOT}/corpus50/lanes/${f}`, "utf8"));
  for (const c of d.categories) for (const p of c.protocols)
    lanes.push({ name: p.name, cat: c.category, syms: [...new Set(p.elements)].sort() });
}
export const LANESETS = new Map();
for (const p of lanes) {
  const k = p.syms.join(",");
  LANESETS.set(k, [...(LANESETS.get(k) || []), p.name]);
}
// split the blind set into "real" (set-matches a lane decomposition) and "other"
const avail = new Map([...LANESETS].map(([k, v]) => [k, v.length]));
export const REAL = [], OTHER = [];
for (const c of blind) {
  const k = [...new Set(c.elements)].sort().join(",");
  if ((avail.get(k) || 0) > 0) { avail.set(k, avail.get(k) - 1); REAL.push(c); } else OTHER.push(c);
}
export const setOf = c => new Set(c.elements.filter(e => SYMS.has(e)));
