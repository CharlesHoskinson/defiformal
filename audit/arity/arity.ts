/* Clause arity census.
 *
 * Schaefer: constraints closed under the MEDIAN (majority) operation are exactly
 * the bijunctive ones - and bijunctive means every clause has at most 2 literals.
 * A bijunctive system lives in a median algebra, which is a genuinely nice
 * structure with a real theory. Whether we get one is not a matter of taste; it
 * is a matter of how wide our clauses actually are. Count them.
 */
import { LAWS, HAZARDS, ELEMENTS } from "./data.ts";

const SYMS = new Set(ELEMENTS.map((e) => e.sym));
const bare = (s: string) => s.replace(/\{[^}]*\}/g, "").replace(/[()]/g, "").trim();

interface Clause { id: string; kind: "req" | "haz"; width: number; pos: number; neg: number; text: string }
const clauses: Clause[] = [];

for (const l of LAWS) {
  const [lhs, rhs = ""] = l.rule.split("→");
  const subj = (lhs || "").split("|").map(bare).filter((s) => SYMS.has(s));
  if (!subj.length) continue;
  for (const chunk of rhs.split("+")) {
    const parts = chunk.split("|").map(bare);
    const alts = parts.filter((a) => SYMS.has(a));
    if (!alts.length || alts.length < parts.length) continue;  // prose / mixed -> residue
    // clause is  (~s1 & ... ) -> (a1 | a2 | ...) == ~subj_i v a1 v a2 ...
    // one clause per subject
    for (const s of subj) {
      clauses.push({ id: l.id, kind: "req", width: 1 + alts.length, pos: alts.length, neg: 1, text: `${s} -> ${alts.join("|")}` });
    }
  }
}

for (const h of HAZARDS) {
  const named = [...new Set((h.combo.match(/\b[A-Z][a-z]{1,2}\b/g) || []).filter((m) => SYMS.has(m)))];
  if (named.length < 2) continue;
  clauses.push({ id: h.id, kind: "haz", width: named.length, pos: 0, neg: named.length, text: `NOT(${named.join(" & ")})` });
}

const hist = new Map<number, number>();
for (const c of clauses) hist.set(c.width, (hist.get(c.width) ?? 0) + 1);

console.log(`total element-expressible clauses: ${clauses.length}`);
console.log(`  requirements: ${clauses.filter((c) => c.kind === "req").length}`);
console.log(`  hazards:      ${clauses.filter((c) => c.kind === "haz").length}`);
console.log("\nwidth histogram (literals per clause):");
for (const w of [...hist.keys()].sort((a, b) => a - b)) {
  console.log(`  ${String(w).padStart(2)} literals: ${String(hist.get(w)).padStart(3)} ${"#".repeat(hist.get(w)!)}`);
}
const bi = clauses.filter((c) => c.width <= 2).length;
console.log(`\nBIJUNCTIVE (width <= 2): ${bi}/${clauses.length} = ${Math.round(100 * bi / clauses.length)}%`);
console.log(`widest clause: ${Math.max(...clauses.map((c) => c.width))} literals`);
const widest = clauses.reduce((a, b) => (b.width > a.width ? b : a));
console.log(`  -> ${widest.id}: ${widest.text}`);
console.log("\nIf this is not ~100% bijunctive, median algebras are out and we");
console.log("should stop hoping for a single well-behaved container.");
