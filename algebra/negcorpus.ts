/* Build the negative corpus.
 *
 * A coverage score computed only over real protocols rewards an algebra that
 * accepts everything. Grammar engineering has known this for decades and always
 * pairs coverage with an overgeneration rate against ungrammatical input. We
 * have no ungrammatical input, so this generates it.
 *
 * Five families, in descending order of how much they hurt:
 *
 *   KNOCKOUT   a real protocol minus one element that a fired law required.
 *              Positive and negative differ by ONE symbol. If an algebra
 *              accepts both, its validity predicate is not reading the laws.
 *   ARMED      a real protocol plus the elements that arm a hazard rule.
 *   INVERTED   deep elements with their foundations removed - a stratum
 *              inversion that should be unbuildable.
 *   HYBRID     half of one protocol spliced with half of another. These are
 *              NOT in anyone's pretraining data, which is the point: the gap
 *              between an algebra's accuracy on real protocols and on hybrids
 *              is its contamination signature.
 *   RANDOM     size-matched random subsets. The control. An algebra that
 *              accepts these at the rate it accepts real protocols has learned
 *              nothing at all.
 */
import { ELEMENTS, HAZARDS } from "../viz/src/data";
import { PROTOCOLS } from "../viz/src/protocols";
import { closes, armedHazards, PARSED } from "../viz/src/laws";

const SYMS = ELEMENTS.map((e) => e.sym);
const STRATUM = new Map(ELEMENTS.map((e) => [e.sym, e.stratum]));

/* deterministic PRNG - the corpus must be reproducible or it is not a benchmark */
let seed = 20260804;
const rnd = () => (seed = (seed * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff;
const pick = <T,>(a: T[]) => a[Math.floor(rnd() * a.length)];

interface Neg {
  id: string;
  family: "KNOCKOUT" | "ARMED" | "INVERTED" | "HYBRID" | "RANDOM";
  syms: string[];
  from: string;
  why: string;
  /** what our own engine says - the mathematicians are NOT given this */
  engineRejects: boolean;
}

const out: Neg[] = [];
const seen = new Set<string>();
const key = (s: string[]) => [...s].sort().join(",");

const add = (n: Neg) => {
  const k = key(n.syms);
  if (seen.has(k)) return;
  seen.add(k);
  out.push(n);
};

/* ---------------------------------------------------------------- KNOCKOUT */
/* For each protocol that closes, remove one element that some fired law
 * actually depended on. Removing a symbol nothing needed proves nothing. */
for (const p of PROTOCOLS) {
  const base = p.syms;
  if (!closes(base).ok) continue;              // only knock out from a clean base
  const load = new Set<string>();
  for (const law of PARSED) {
    if (!law.subjects.some((s) => base.includes(s))) continue;
    for (const t of law.terms) {
      const hits = t.alts.filter((a) => base.includes(a));
      if (hits.length === 1) load.add(hits[0]); // sole satisfier - load bearing
    }
  }
  for (const sym of load) {
    const syms = base.filter((s) => s !== sym);
    add({
      id: `KO-${p.id}-${sym}`,
      family: "KNOCKOUT",
      syms,
      from: p.name,
      why: `${p.name} with ${sym} removed. ${sym} was the sole satisfier of a requirement term, so this differs from a working protocol by exactly one symbol.`,
      engineRejects: !closes(syms).ok,
    });
  }
}

/* ------------------------------------------------------------------- ARMED */
for (const h of HAZARDS) {
  const named = [...new Set((h.combo.match(/\b[A-Z][a-z]{1,2}\b/g) || []).filter((m) => SYMS.includes(m)))];
  if (named.length < 2) continue;
  for (const p of PROTOCOLS.slice(0, 6)) {
    const syms = [...new Set([...p.syms, ...named])];
    if (key(syms) === key(p.syms)) continue;   // already armed; no new information
    add({
      id: `AR-${h.id}-${p.id}`,
      family: "ARMED",
      syms,
      from: p.name,
      why: `${p.name} extended until hazard ${h.id} is fully armed (${named.join(" + ")}). ${h.combo}`,
      engineRejects: armedHazards(syms).length > 0 || !closes(syms).ok,
    });
  }
}

/* ---------------------------------------------------------------- INVERTED */
/* Deep elements with nothing beneath them. If stratum means anything at all,
 * these are unbuildable. If an algebra accepts them, stratum is decoration. */
const deep = SYMS.filter((s) => (STRATUM.get(s) ?? 0) >= 3);
for (let i = 0; i < 12; i++) {
  const syms = Array.from({ length: 3 + Math.floor(rnd() * 3) }, () => pick(deep));
  const u = [...new Set(syms)];
  if (u.length < 3) continue;
  add({
    id: `IN-${i}`,
    family: "INVERTED",
    syms: u,
    from: "-",
    why: `Only S3+ elements, no foundation. Unbuildable if stratum is a real prerequisite depth rather than an annotation.`,
    engineRejects: !closes(u).ok,
  });
}

/* ------------------------------------------------------------------ HYBRID */
/* Uncontaminated by construction - these protocols do not exist. */
for (let i = 0; i < PROTOCOLS.length; i++) {
  for (let j = i + 1; j < PROTOCOLS.length; j++) {
    if (rnd() > 0.35) continue;
    const a = PROTOCOLS[i], b = PROTOCOLS[j];
    const syms = [...new Set([
      ...a.syms.slice(0, Math.ceil(a.syms.length / 2)),
      ...b.syms.slice(Math.floor(b.syms.length / 2)),
    ])];
    add({
      id: `HY-${a.id}-${b.id}`,
      family: "HYBRID",
      syms,
      from: `${a.name} x ${b.name}`,
      why: `Front half of ${a.name} spliced with back half of ${b.name}. Does not exist, so it cannot have been memorised.`,
      engineRejects: !closes(syms).ok || armedHazards(syms).length > 0,
    });
  }
}

/* ------------------------------------------------------------------ RANDOM */
const sizes = PROTOCOLS.map((p) => p.syms.length);
for (let i = 0; i < 20; i++) {
  const n = pick(sizes);
  const s = new Set<string>();
  while (s.size < n) s.add(pick(SYMS));
  const syms = [...s];
  add({
    id: `RA-${i}`,
    family: "RANDOM",
    syms,
    from: "-",
    why: `Size-matched random subset (${n} symbols). The control: acceptance here at the rate real protocols are accepted means no discriminating power.`,
    engineRejects: !closes(syms).ok || armedHazards(syms).length > 0,
  });
}

/* ------------------------------------------------------------------ report */
const byFam: Record<string, { n: number; rej: number }> = {};
for (const n of out) {
  byFam[n.family] ??= { n: 0, rej: 0 };
  byFam[n.family].n++;
  if (n.engineRejects) byFam[n.family].rej++;
}

const posRej = PROTOCOLS.filter((p) => !closes(p.syms).ok).length;

console.log(JSON.stringify({
  generated: "deterministic, seed 20260804",
  positives: { n: PROTOCOLS.length, rejectedByEngine: posRej },
  negatives: { n: out.length, byFamily: byFam },
  cases: out,
}, null, 2));

console.error("--- negative corpus ---");
console.error(`positives: ${PROTOCOLS.length}, of which our own engine rejects ${posRej}`);
for (const [f, v] of Object.entries(byFam)) {
  console.error(`${f.padEnd(9)} n=${String(v.n).padStart(3)}  engine rejects ${v.rej}/${v.n} (${Math.round(100 * v.rej / v.n)}%)`);
}
console.error(`TOTAL negatives: ${out.length}`);
