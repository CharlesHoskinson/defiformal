/* Build viz/src/corpus.ts from the three decomposition lanes.
 *
 * The visualization's spine is "same parts, different protocol", so the object
 * that matters most is not the protocol list - it is the COLLISION: sets of
 * distinct protocols that decompose to the identical element set. Those are
 * computed here rather than hand-listed, so they cannot drift from the data.
 */
import fs from "node:fs";

const LANES = "/root/DefiElements/corpus50/lanes";
const out = [];
for (const f of fs.readdirSync(LANES).sort()) {
  const d = JSON.parse(fs.readFileSync(`${LANES}/${f}`, "utf8"));
  for (const c of d.categories) {
    for (const p of c.protocols) {
      out.push({
        name: p.name,
        category: c.category,
        syms: [...new Set(p.elements)].sort(),
        rank: p.rank_basis ?? "",
        residue: (p.residue ?? []).length,
        forced: (p.forced ?? []).map((x) => x.symbol),
        orderKnown: !!p.order_known,
      });
    }
  }
}

// collisions: identical element sets across distinct protocols
const byKey = new Map();
for (const p of out) {
  const k = p.syms.join(",");
  if (!byKey.has(k)) byKey.set(k, []);
  byKey.get(k).push(p);
}
const collisions = [...byKey.entries()]
  .filter(([, v]) => v.length > 1)
  .map(([k, v]) => ({ syms: k.split(","), members: v.map((p) => p.name), categories: [...new Set(v.map((p) => p.category))] }))
  .sort((a, b) => b.members.length - a.members.length);

// subset relations: strictly-contained element sets (SparkLend ⊂ Aave)
const subsets = [];
for (const a of out) for (const b of out) {
  if (a === b || a.syms.length >= b.syms.length) continue;
  if (a.syms.every((s) => b.syms.includes(s))) subsets.push({ inner: a.name, outer: b.name, gap: b.syms.length - a.syms.length });
}

const ts = `/* GENERATED from corpus50/lanes - do not edit by hand.
 * 72 protocol decompositions, 12 categories, ranked from DefiLlama and rwa.xyz
 * on 2026-08-04. Collisions and subset relations are computed, not asserted.
 */
export interface CorpusProtocol {
  name: string; category: string; syms: string[]; rank: string;
  residue: number; forced: string[]; orderKnown: boolean;
}
export interface Collision { syms: string[]; members: string[]; categories: string[] }

export const CORPUS: CorpusProtocol[] = ${JSON.stringify(out, null, 2)};

/** Distinct protocols that decompose to the IDENTICAL element set.
 *  This is the spine of the argument: same parts, different protocol. */
export const COLLISIONS: Collision[] = ${JSON.stringify(collisions, null, 2)};

/** Strict containment - one protocol's elements are a proper subset of another's. */
export const SUBSETS = ${JSON.stringify(subsets.slice(0, 40), null, 2)};

export const CATEGORIES = ${JSON.stringify([...new Set(out.map((p) => p.category))], null, 2)};
`;

fs.writeFileSync("/root/DefiElements/viz/src/corpus.ts", ts);
console.error(`protocols: ${out.length}`);
console.error(`categories: ${new Set(out.map((p) => p.category)).size}`);
console.error(`collision groups: ${collisions.length}`);
for (const c of collisions) console.error(`  [${c.members.length}] ${c.members.join(" = ")}`);
console.error(`subset pairs: ${subsets.length}`);
for (const s of subsets.slice(0, 6)) console.error(`  ${s.inner} SUBSET-OF ${s.outer} (+${s.gap})`);
