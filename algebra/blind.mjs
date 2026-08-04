/* Build the blind test set: real protocols and synthetic corruptions, shuffled,
 * unlabelled. The mathematicians classify; we hold the key. */
import fs from "node:fs";

const ROOT = "/root/DefiElements";
const neg = JSON.parse(fs.readFileSync(`${ROOT}/algebra/negative-corpus.json`, "utf8"));

// real protocols from the three decomposition lanes
const real = [];
for (const f of fs.readdirSync(`${ROOT}/corpus50/lanes`)) {
  const d = JSON.parse(fs.readFileSync(`${ROOT}/corpus50/lanes/${f}`, "utf8"));
  for (const c of d.categories)
    for (const p of c.protocols)
      real.push({ syms: [...new Set(p.elements)], label: "REAL", name: p.name, category: c.category });
}

const cases = [
  ...real.map((r, i) => ({ ...r, src: `R${i}` })),
  ...neg.cases.map((n) => ({ syms: n.syms, label: n.family, name: n.id, from: n.from, src: n.id })),
];

// deterministic shuffle
let s = 42;
const rnd = () => (s = (s * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff;
for (let i = cases.length - 1; i > 0; i--) {
  const j = Math.floor(rnd() * (i + 1));
  [cases[i], cases[j]] = [cases[j], cases[i]];
}

const blind = cases.map((c, i) => ({ id: `T${String(i + 1).padStart(3, "0")}`, elements: c.syms }));
const key = cases.map((c, i) => ({ id: `T${String(i + 1).padStart(3, "0")}`, label: c.label, name: c.name, from: c.from ?? null, category: c.category ?? null }));

fs.writeFileSync(`${ROOT}/algebra/blind-test-set.json`, JSON.stringify({
  note: "144 element-sets. Some are real deployed protocols; some are synthetic corruptions. Classify each ADMISSIBLE or INADMISSIBLE under your algebra's validity predicate. You are not told which is which, nor the proportions.",
  cases: blind,
}, null, 2));
fs.writeFileSync(`${ROOT}/algebra/blind-test-KEY.json`, JSON.stringify({ key }, null, 2));

const counts = {};
for (const c of cases) counts[c.label] = (counts[c.label] ?? 0) + 1;
console.error(`blind test set: ${cases.length} cases`);
for (const [k, v] of Object.entries(counts)) console.error(`  ${k.padEnd(10)} ${v}`);
