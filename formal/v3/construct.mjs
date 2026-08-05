/* v3: the construction checker.
 *
 * Stage 3 of the run asks a precise question for each application: can the
 * paper's algebra construct something that reproduces what the application
 * does? This file answers it mechanically, so that no construction enters the
 * paper on assertion.
 *
 * A CONSTRUCTION is a set X of elements together with a set of functional
 * OBLIGATIONS, each obligation naming the elements that discharge it (or naming
 * none, which is residue). The checker reports:
 *
 *   admissibility   open requirement terms, unwarranted elements, armed
 *                   prohibitions, grounding - the four ways X can fail
 *   canonical form  ex(X) and the elements X derives rather than chooses
 *   coverage        obligations with no element: what the vocabulary cannot say
 *   justification   elements discharging no obligation: what the construction
 *                   carries for no stated reason
 *   minimality      elements whose removal leaves every obligation covered and
 *                   X admissible - a redundant element is a defect in the
 *                   construction, not in the vocabulary
 *   composition     whether X is reachable as a composite of corpus protocols,
 *                   which is the sense of "construct from the paper" that
 *                   exercises Theorem thm:excomp rather than set membership
 *
 * Nothing here is heuristic. Every predicate is the one the paper defines.
 */
import { PARSED_NEW, MECH, CONSUME, ELEMS, bansCond, ungrounded } from "../v2/tables.mjs";
import { validate } from "./validate.mjs";
import fs from "node:fs";

export const E = MECH.slice();
export const asSet = a => new Set(a.filter(e => E.includes(e)));

/* ---------- the four admissibility predicates, as the paper defines them */
export const openRequirements = X => PARSED_NEW.flatMap(l =>
  !l.subjects.some(s => X.has(s)) ? [] :
  l.terms.filter(t => !t.external && !t.alts.some(a => X.has(a)))
         .map(t => ({ law: l.id, term: t.alts, prose: t.prose })));
export const unwarranted = X => [...X].filter(e => CONSUME[e] && !CONSUME[e].some(c => X.has(c))).sort();
export const armed = X => bansCond(X);

export function admissibility(X) {
  const req = openRequirements(X), war = unwarranted(X), haz = armed(X), grd = ungrounded(X);
  return { admissible: !(req.length || war.length || haz.length || grd), req, war, haz, ground: grd };
}

/* ---------- canonical form (Corollary "Canonical form": ex(A) = max_<= A) */
const ARC = new Map();
for (const l of PARSED_NEW) for (const s of l.subjects) for (const t of l.terms)
  if (!t.external && t.alts.length === 1) { if (!ARC.has(s)) ARC.set(s, new Set()); ARC.get(s).add(t.alts[0]); }
const below = a => { const R = new Set(), st = [a];
  while (st.length) { const x = st.pop(); for (const y of ARC.get(x) ?? []) if (!R.has(y)) { R.add(y); st.push(y); } } return R; };
export const DOWN = new Map(E.map(e => [e, below(e)]));
export const ex = A => [...A].filter(a => ![...A].some(b => b !== a && DOWN.get(b).has(a))).sort();
export const cn = A => { const R = new Set(A); for (const a of A) for (const b of DOWN.get(a) ?? []) R.add(b); return R; };
export const oplus = (A, B) => cn(new Set([...A, ...B]));

/* ---------- the corpus, for the composition question */
export function loadCorpus(root = "/root/DefiElements") {
  const P = [];
  const L = `${root}/corpus50/lanes`;
  for (const f of fs.readdirSync(L).sort()) {
    const d = JSON.parse(fs.readFileSync(`${L}/${f}`, "utf8"));
    for (const c of d.categories) for (const p of c.protocols)
      P.push({ name: p.name, cat: c.category, syms: [...new Set(p.elements)].filter(e => E.includes(e)).sort() });
  }
  return P;
}

/* ---------- coverage, justification, minimality */
function coverage(spec) {
  const obligations = spec.functionalObligations ?? [];
  const X = asSet(spec.construction);
  const uncovered = [], covered = [], misdeclared = [];
  for (const o of obligations) {
    const els = (o.elements ?? []).filter(e => E.includes(e));
    const bad = (o.elements ?? []).filter(e => !E.includes(e));
    if (bad.length) misdeclared.push({ id: o.id, notElements: bad });
    if (!els.length) { uncovered.push(o); continue; }
    const present = els.filter(e => X.has(e));
    if (!present.length) uncovered.push({ ...o, reason: "declared elements absent from the construction" });
    else covered.push({ id: o.id, by: present });
  }
  const used = new Set(covered.flatMap(c => c.by));
  const unjustified = [...X].filter(e => !used.has(e)).sort();
  return { obligations: obligations.length, covered, uncovered, unjustified, misdeclared };
}

function minimality(spec) {
  const X = asSet(spec.construction);
  const base = coverage(spec);
  if (!admissibility(X).admissible) return { checked: false, why: "construction is not admissible; minimality is not asked of an inadmissible set" };
  const redundant = [];
  for (const e of X) {
    const Y = new Set([...X].filter(x => x !== e));
    const cov = coverage({ ...spec, construction: [...Y] });
    if (cov.uncovered.length > base.uncovered.length) continue;      // dropping e loses an obligation
    if (!admissibility(Y).admissible) continue;                       // dropping e breaks admissibility
    redundant.push(e);
  }
  return { checked: true, redundant, minimal: redundant.length === 0 };
}

/* ---------- can the construction be reached by composing corpus protocols?
 * Exact for k <= 3 over the corpus, which is 72 + 2556 + 59640 unions. */
function compositional(spec, corpus, maxK = 3) {
  const target = cn(asSet(spec.construction));
  const key = S => [...S].sort().join(",");
  const T = key(target);
  const hits = [];
  const n = corpus.length;
  for (let i = 0; i < n; i++) {
    const A = cn(new Set(corpus[i].syms));
    if (key(A) === T) hits.push({ k: 1, parts: [corpus[i].name] });
    if (maxK < 2) continue;
    for (let j = i + 1; j < n; j++) {
      const AB = oplus(A, new Set(corpus[j].syms));
      if (AB.size > target.size) continue;
      if (key(AB) === T) hits.push({ k: 2, parts: [corpus[i].name, corpus[j].name] });
      if (maxK < 3) continue;
      for (let l = j + 1; l < n; l++) {
        const ABC = oplus(AB, new Set(corpus[l].syms));
        if (ABC.size > target.size) continue;
        if (key(ABC) === T) hits.push({ k: 3, parts: [corpus[i].name, corpus[j].name, corpus[l].name] });
      }
    }
  }
  /* the weaker question: which corpus protocols are contained in the target,
   * i.e. what the construction could be assembled from even if no exact
   * decomposition exists */
  const parts = corpus.filter(p => p.syms.every(s => target.has(s)))
    .map(p => ({ name: p.name, cat: p.cat, size: p.syms.length }))
    .sort((a, b) => b.size - a.size).slice(0, 12);
  const union = new Set(corpus.filter(p => p.syms.every(s => target.has(s))).flatMap(p => p.syms));
  return {
    exact: hits.slice(0, 8), exactFound: hits.length,
    containedProtocols: parts,
    containedCount: corpus.filter(p => p.syms.every(s => target.has(s))).length,
    notSuppliedByAnyContainedProtocol: [...target].filter(e => !union.has(e)).sort(),
  };
}

/* ---------- the verdict */
export function verify(spec, corpus) {
  const X = asSet(spec.construction);
  const notElements = spec.construction.filter(e => !E.includes(e));
  const adm = admissibility(X);
  const cov = coverage(spec);
  const min = minimality(spec);
  const comp = corpus ? compositional(spec, corpus) : null;
  const g = ex(X);
  return {
    app: spec.app, category: spec.category,
    construction: [...X].sort(), size: X.size, notElements,
    admissible: adm.admissible,
    openRequirementTerms: adm.req.map(r => `${r.law}:${r.term.join("|")}`),
    unwarrantedElements: adm.war,
    armedProhibitions: adm.haz,
    ungrounded: adm.ground,
    canonicalForm: g, derived: [...X].filter(e => !g.includes(e)).sort(),
    obligationsTotal: cov.obligations,
    obligationsCovered: cov.covered.length,
    obligationsUncovered: cov.uncovered.map(o => ({ id: o.id, text: o.text, reason: o.reason ?? "no element names it" })),
    unjustifiedElements: cov.unjustified,
    misdeclared: cov.misdeclared,
    minimality: min,
    composition: comp,
    verdict: verdictOf(adm, cov, min),
  };
}

function verdictOf(adm, cov, min) {
  if (!adm.admissible) return "INADMISSIBLE";
  if (cov.uncovered.length && cov.uncovered.length === cov.obligations) return "VACUOUS";
  if (cov.uncovered.length) return "PARTIAL";
  if (min.checked && !min.minimal) return "ADMISSIBLE-REDUNDANT";
  return "COMPLETE";
}

/* ---------- CLI: verify every spec in a directory */
function main() {
  const dir = process.argv[2];
  if (!dir) { console.error("usage: node construct.mjs <dir-of-specs.json> [--json out.json]"); process.exit(2); }
  const corpus = loadCorpus();
  const specs = []; let rejected = 0;
  for (const f of fs.readdirSync(dir).sort()) if (f.endsWith(".json")) {
    const d = JSON.parse(fs.readFileSync(`${dir}/${f}`, "utf8"));
    for (const s of Array.isArray(d) ? d : [d]) {
      const v = validate(s, f);
      if (!v.ok) { console.error(`REJECTED ${f} [${s.app}]: ${v.err.join("; ")}`); rejected++; continue; }
      specs.push(s);
    }
  }
  if (rejected) console.error(`${rejected} spec(s) rejected as malformed; they are not counted below.\n`);
  const out = specs.map(s => verify(s, corpus));
  for (const r of out) {
    console.log(`\n=== ${r.app}  [${r.category}]  ${r.verdict}`);
    console.log(`  X (${r.size}) = {${r.construction.join(",")}}   ex(X) = {${r.canonicalForm.join(",")}}`);
    if (r.notElements.length) console.log(`  NOT ELEMENTS: ${r.notElements.join(",")}`);
    if (!r.admissible) {
      if (r.openRequirementTerms.length) console.log(`  open requirement terms: ${r.openRequirementTerms.join("  ")}`);
      if (r.unwarrantedElements.length) console.log(`  unwarranted: ${r.unwarrantedElements.join(",")}`);
      if (r.armedProhibitions.length) console.log(`  armed prohibitions: ${r.armedProhibitions.join(",")}`);
      if (r.ungrounded) console.log(`  ungrounded`);
    }
    console.log(`  obligations: ${r.obligationsCovered}/${r.obligationsTotal} covered`);
    for (const o of r.obligationsUncovered) console.log(`     RESIDUE ${o.id}: ${String(o.text).slice(0, 96)}`);
    if (r.unjustifiedElements.length) console.log(`  carried for no stated obligation: ${r.unjustifiedElements.join(",")}`);
    if (r.minimality.checked && !r.minimality.minimal) console.log(`  redundant (droppable): ${r.minimality.redundant.join(",")}`);
    if (r.composition) {
      console.log(`  exact compositions from the corpus (k<=3): ${r.composition.exactFound}`);
      for (const h of r.composition.exact) console.log(`     k=${h.k}: ${h.parts.join("  (+)  ")}`);
      console.log(`     corpus protocols contained in the construction: ${r.composition.containedCount}`);
      if (r.composition.notSuppliedByAnyContainedProtocol.length)
        console.log(`     supplied by no contained corpus protocol: ${r.composition.notSuppliedByAnyContainedProtocol.join(",")}`);
    }
  }
  const i = process.argv.indexOf("--json");
  if (i > 0 && process.argv[i + 1]) { fs.writeFileSync(process.argv[i + 1], JSON.stringify(out, null, 2)); console.log(`\nwrote ${process.argv[i + 1]}`); }
  const bad = out.filter(r => r.verdict === "INADMISSIBLE" || r.verdict === "VACUOUS").length;
  console.log(`\n${out.length} constructions: ${out.filter(r=>r.verdict==="COMPLETE").length} complete, ${out.filter(r=>r.verdict==="PARTIAL").length} partial, ${out.filter(r=>r.verdict==="ADMISSIBLE-REDUNDANT").length} redundant, ${bad} inadmissible or vacuous`);
}
if (import.meta.url === `file://${process.argv[1]}`) main();
