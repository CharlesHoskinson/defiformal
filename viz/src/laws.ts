/* The law engine.
 *
 * The 29 laws have been decorative strings until now. They are actually a
 * constraint system: each law fires when one of its subjects is present, and
 * then demands a conjunction of terms, each of which may be a disjunction of
 * element symbols. Parsing them turns the atlas from a picture into something
 * that can pass or fail.
 *
 * Everything downstream needs this — closure for the shadow, seating order for
 * the lock-up, the shape of what is missing when a composition pies.
 */
import { ELEMENTS, HAZARDS, LAWS, type Element } from "./data";

const SYMS = new Set(ELEMENTS.map((e) => e.sym));

/** One requirement term: a disjunction of symbols, or an unresolvable clause. */
export interface Term {
  alts: string[];      // element symbols that would satisfy it
  prose: string;       // the raw text, for terms with no element (e.g. "exit-liquidity")
  external: boolean;   // true when nothing in the table can satisfy it
}

export interface ParsedLaw {
  id: string;
  rule: string;
  subjects: string[];  // symbols that trigger the law; empty = prose subject
  subjectProse: string;
  terms: Term[];
}

/** strip isotope braces and annotations: At{subject=x} -> At */
const bare = (s: string) => s.replace(/\{[^}]*\}/g, "").replace(/[()]/g, "").trim();

function parseSide(side: string): Term[] {
  // split on + at top level; the laws never nest parentheses
  return side.split("+").map((chunk) => {
    const raw = chunk.trim();
    const alts = raw
      .split("|")
      .map((a) => bare(a))
      .filter((a) => SYMS.has(a));
    return { alts, prose: raw, external: alts.length === 0 };
  });
}

export const PARSED: ParsedLaw[] = LAWS.map((l) => {
  const [lhs, rhs = ""] = l.rule.split("→");
  const subjects = (lhs || "")
    .split("|")
    .map((s) => bare(s))
    .filter((s) => SYMS.has(s));
  return {
    id: l.id,
    rule: l.rule,
    subjects,
    subjectProse: (lhs || "").trim(),
    terms: parseSide(rhs),
  };
});

/* ------------------------------------------------------------ evaluation */

export interface TermResult extends Term { satisfied: boolean; by: string | null }
export interface LawResult {
  law: ParsedLaw;
  firedBy: string[];            // which present symbols triggered it
  terms: TermResult[];
  satisfied: boolean;           // all non-external terms met
  missing: TermResult[];
}

/** Evaluate every law against a set of element symbols. */
export function evaluate(present: string[]): LawResult[] {
  const S = new Set(present);
  const out: LawResult[] = [];
  for (const law of PARSED) {
    const firedBy = law.subjects.filter((s) => S.has(s));
    if (!firedBy.length) continue;
    const terms: TermResult[] = law.terms.map((t) => {
      const by = t.alts.find((a) => S.has(a)) ?? null;
      // an external term cannot be judged from the element set, so it never
      // fails the composition - it becomes residue instead
      return { ...t, satisfied: t.external ? true : !!by, by };
    });
    const missing = terms.filter((t) => !t.satisfied);
    out.push({ law, firedBy, terms, satisfied: missing.length === 0, missing });
  }
  return out;
}

/** Does this set close under the laws it triggers? */
export function closes(present: string[]) {
  const res = evaluate(present);
  const open = res.filter((r) => !r.satisfied);
  return { ok: open.length === 0, results: res, open };
}

/** Hazard rules whose named elements are all present — the joint that will not close.
 *
 *  Polarity matters and an earlier version of this got it backwards. Some rules
 *  describe an element being ABSENT ("Uc with no Aw, At, collateral or
 *  reputation"; "bridged into a representation with no destination-side Aw").
 *  For those, "all named elements present" inverts the meaning. Rules whose text
 *  negates are skipped rather than guessed at — a hazard we cannot evaluate from
 *  membership is residue, not a clean bill of health.
 */
const NEGATED = /\b(no|without|absent|lacking|missing|never)\b/i;

export interface ArmedHazard { id: string; combo: string; cls: string; evaluable: boolean }

export function armedHazards(present: string[]): ArmedHazard[] {
  const S = new Set(present);
  const out: ArmedHazard[] = [];
  for (const h of HAZARDS) {
    const named = [...new Set(
      (h.combo.match(/\b[A-Z][a-z]{1,2}\b/g) || []).filter((m) => SYMS.has(m))
    )];
    if (named.length < 2) continue;                 // not evaluable from membership
    if (NEGATED.test(h.combo)) continue;            // polarity is inverted; skip
    if (named.every((m) => S.has(m))) {
      out.push({ id: h.id, combo: h.combo, cls: h.cls, evaluable: true });
    }
  }
  return out;
}

/** Hazard rules that membership alone cannot decide — reported, never hidden. */
export function inevaluableHazards(): string[] {
  return HAZARDS.filter((h) => {
    const named = [...new Set(
      (h.combo.match(/\b[A-Z][a-z]{1,2}\b/g) || []).filter((m) => SYMS.has(m))
    )];
    return named.length < 2 || NEGATED.test(h.combo);
  }).map((h) => h.id);
}

/** Laws whose subject is prose, so they can never fire from element membership. */
export function unfireableLaws(): string[] {
  return PARSED.filter((l) => l.subjects.length === 0).map((l) => l.id);
}

/* --------------------------------------------------------------- closure */

/** Transitive closure of requirements beneath an element — Photogram's shadow. */
export function closureOf(sym: string, depth = 6): { reached: Set<string>; forks: string[][] } {
  const reached = new Set<string>();
  const forks: string[][] = [];
  let frontier = [sym];
  for (let d = 0; d < depth && frontier.length; d++) {
    const next: string[] = [];
    for (const cur of frontier) {
      for (const law of PARSED) {
        if (!law.subjects.includes(cur)) continue;
        for (const t of law.terms) {
          if (t.external) continue;
          if (t.alts.length > 1) forks.push(t.alts);
          for (const a of t.alts) {
            if (!reached.has(a) && a !== sym) { reached.add(a); next.push(a); }
          }
        }
      }
    }
    frontier = next;
  }
  return { reached, forks };
}

/** How many laws require this element — Weight's in-degree. */
export function inDegree(sym: string): number {
  let n = 0;
  for (const law of PARSED) {
    for (const t of law.terms) if (t.alts.includes(sym)) { n++; break; }
  }
  return n;
}

export const IN_DEGREE: Record<string, number> = Object.fromEntries(
  ELEMENTS.map((e) => [e.sym, inDegree(e.sym)])
);

/* ------------------------------------------------------------ seating order */

/** The order the joints close in: a required element seats before the element
 *  that requires it, regardless of the causal order it was composed in. */
export function seatingOrder(present: string[]): string[] {
  const S = new Set(present);
  const need = new Map<string, Set<string>>();
  for (const sym of present) need.set(sym, new Set());
  for (const law of PARSED) {
    for (const subj of law.subjects) {
      if (!S.has(subj)) continue;
      for (const t of law.terms) {
        const hit = t.alts.find((a) => S.has(a));
        if (hit && hit !== subj) need.get(subj)!.add(hit);
      }
    }
  }
  const out: string[] = [];
  const seen = new Set<string>();
  const visit = (s: string, guard: Set<string>) => {
    if (seen.has(s) || guard.has(s)) return;   // guard breaks reflexive cycles
    guard.add(s);
    for (const dep of need.get(s) ?? []) visit(dep, guard);
    guard.delete(s);
    seen.add(s);
    out.push(s);
  };
  for (const s of present) visit(s, new Set());
  return out;
}

/** Elements that sit in a requirement cycle — the reflexive bind. */
export function cycles(present: string[]): string[][] {
  const S = new Set(present);
  const edges = new Map<string, string[]>();
  for (const law of PARSED) {
    for (const subj of law.subjects) {
      if (!S.has(subj)) continue;
      const outs: string[] = [];
      for (const t of law.terms) {
        const hit = t.alts.find((a) => S.has(a));
        if (hit) outs.push(hit);
      }
      edges.set(subj, [...(edges.get(subj) ?? []), ...outs]);
    }
  }
  const found: string[][] = [];
  const stack: string[] = [];
  const state = new Map<string, number>();
  const dfs = (n: string) => {
    state.set(n, 1); stack.push(n);
    for (const m of edges.get(n) ?? []) {
      if (state.get(m) === 1) found.push(stack.slice(stack.indexOf(m)));
      else if (!state.get(m)) dfs(m);
    }
    stack.pop(); state.set(n, 2);
  };
  for (const s of present) if (!state.get(s)) dfs(s);
  return found;
}

export function symsOf(list: Element[]) { return list.map((e) => e.sym); }
