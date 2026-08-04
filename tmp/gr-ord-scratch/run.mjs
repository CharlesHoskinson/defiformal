/**
 * GR-ORD: order-theoretic algebra of DeFi composition
 * Recipes A/B + ADMISSIBLE(X) classification of 156 blind cases.
 *
 * Scratch only. Deliverables written to algebra/verdicts and algebra/reports.
 */
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const ROOT = "/root/DefiElements";
const OUT_DIR = join(ROOT, "tmp/gr-ord-scratch");

// ---------------------------------------------------------------------------
// Load sources (Node 24 type-stripping, same pattern as formal/probe.mjs)
// ---------------------------------------------------------------------------
const data = await import(new URL("../../viz/src/data.ts", import.meta.url));
const protoSrc = await import(new URL("../../viz/src/protocols.ts", import.meta.url));

const MECHANISMS = data.ELEMENTS.filter((e) => e.status !== "limit");
const SYMS = MECHANISMS.map((e) => e.sym);
const SYM_SET = new Set(SYMS);
const ATTR = new Map(MECHANISMS.map((e) => [e.sym, e]));
const G12 = new Set(MECHANISMS.filter((e) => e.group === "G12").map((e) => e.sym));
// G12 should be Xm, Xf, Rl, Of
console.log("mechanisms", SYMS.length, "G12", [...G12].sort().join(","));

// ---------------------------------------------------------------------------
// Law parser — identical to viz/src/laws.ts
// ---------------------------------------------------------------------------
const bare = (s) => s.replace(/\{[^}]*\}/g, "").replace(/[()]/g, "").trim();

function parseSide(side) {
  return side.split("+").map((chunk) => {
    const raw = chunk.trim();
    const alts = raw
      .split("|")
      .map((a) => bare(a))
      .filter((a) => SYM_SET.has(a));
    return { alts, prose: raw, external: alts.length === 0 };
  });
}

function parseLaws(sourceLaws) {
  return sourceLaws.map((l) => {
    const [lhs, rhs = ""] = l.rule.split("→");
    const subjects = (lhs || "")
      .split("|")
      .map((s) => bare(s))
      .filter((s) => SYM_SET.has(s));
    return {
      id: l.id,
      rule: l.rule,
      subjects,
      subjectProse: (lhs || "").trim(),
      terms: parseSide(rhs),
    };
  });
}

const PARSED_BASE = parseLaws(data.LAWS);
const FIREABLE = PARSED_BASE.filter((l) => l.subjects.length > 0);
const UNFIREABLE = PARSED_BASE.filter((l) => l.subjects.length === 0).map((l) => l.id);
console.log("fireable laws", FIREABLE.length, "unfireable", UNFIREABLE.join(","));

// L19b: Xf → Aw  (promote X19 polarity-correct as a positive requirement)
const L19B = {
  id: "L19b",
  rule: "Xf → Aw",
  subjects: ["Xf"],
  subjectProse: "Xf",
  terms: [{ alts: ["Aw"], prose: "Aw", external: false }],
};

// Laws used for ADMISSIBLE closure: fireable + L19b
const PARSED_ADMISSIBLE = [...FIREABLE, L19B];

// ---------------------------------------------------------------------------
// Evaluation — identical to laws.ts evaluate / closes / armedHazards
// ---------------------------------------------------------------------------
function evaluate(present, laws = PARSED_BASE.filter((l) => l.subjects.length > 0)) {
  const S = new Set(present);
  const out = [];
  for (const law of laws) {
    const firedBy = law.subjects.filter((s) => S.has(s));
    if (!firedBy.length) continue;
    const terms = law.terms.map((t) => {
      const by = t.alts.find((a) => S.has(a)) ?? null;
      return { ...t, satisfied: t.external ? true : !!by, by };
    });
    const missing = terms.filter((t) => !t.satisfied);
    out.push({ law, firedBy, terms, satisfied: missing.length === 0, missing });
  }
  return out;
}

function closes(present, laws) {
  const res = evaluate(present, laws);
  const open = res.filter((r) => !r.satisfied);
  return { ok: open.length === 0, results: res, open };
}

const NEGATED = /\b(no|without|absent|lacking|missing|never)\b/i;

function armedHazards(present) {
  const S = new Set(present);
  const out = [];
  for (const h of data.HAZARDS) {
    const named = [
      ...new Set(
        (h.combo.match(/\b[A-Z][a-z]{1,2}\b/g) || []).filter((m) => SYM_SET.has(m))
      ),
    ];
    if (named.length < 2) continue;
    if (NEGATED.test(h.combo)) continue;
    if (named.every((m) => S.has(m))) {
      out.push({ id: h.id, combo: h.combo, cls: h.cls, evaluable: true, named });
    }
  }
  return out;
}

// List which hazards are evaluable under the reference engine
const EVAL_HAZARDS = [];
for (const h of data.HAZARDS) {
  const named = [
    ...new Set(
      (h.combo.match(/\b[A-Z][a-z]{1,2}\b/g) || []).filter((m) => SYM_SET.has(m))
    ),
  ];
  if (named.length < 2) continue;
  if (NEGATED.test(h.combo)) continue;
  EVAL_HAZARDS.push({ id: h.id, named });
}
console.log(
  "evaluable hazards (ref engine)",
  EVAL_HAZARDS.map((h) => h.id).join(", ")
);

// X21: Fl co-present with any G12 element
function x21Armed(present) {
  const S = new Set(present);
  if (!S.has("Fl")) return false;
  return [...G12].some((g) => S.has(g));
}

// ---------------------------------------------------------------------------
// ADMISSIBLE predicate
// ---------------------------------------------------------------------------
function closedWithL19b(present) {
  return closes(present, PARSED_ADMISSIBLE).ok;
}

function hazardFreeWithX21(present) {
  if (armedHazards(present).length > 0) return false;
  if (x21Armed(present)) return false;
  // deliberately NOT adding {Au,Gs} stratum inversion
  return true;
}

function ADMISSIBLE(X) {
  return closedWithL19b(X) && hazardFreeWithX21(X);
}

function baselineAdmissible(X) {
  // closure under 25 fireable laws only + reference armedHazards only
  return closes(X, FIREABLE).ok && armedHazards(X).length === 0;
}

// X11a subsumption check under L3
// L3: Uc → Aw + At{...} + (Bs|Tr) + obligor
// A set that is closed under L3 and contains Uc must have Aw, At, and (Bs|Tr).
// X11a arms when Uc is present WITHOUT Aw, At, collateral, reputation.
// Therefore any L3-closed set with Uc cannot arm the intended X11a condition.
// Promoting X11a to a law is a no-op for closed sets.
const X11A_SUBSUMED =
  "X11a is already subsumed by L3 for closed sets: L3 forces Aw + At + (Bs|Tr) whenever Uc is present; the residual 'reputation' and 'obligor' clauses are prose/external and cannot be evaluated from membership either way. Promoting X11a is a no-op; no L11a-prime added.";

// ---------------------------------------------------------------------------
// Recipe A — formal context from real protocols
// ---------------------------------------------------------------------------
function loadCorpusProtocols() {
  const out = [];
  const laneFiles = [
    "lane1-dex-lending-cdp-lsd.json",
    "lane2-perps-yield-bridges-intents.json",
    "lane3-rwa-options-stables-prediction.json",
  ];
  for (const f of laneFiles) {
    const d = JSON.parse(readFileSync(join(ROOT, "corpus50/lanes", f), "utf8"));
    for (const cat of d.categories || []) {
      for (const pr of cat.protocols || []) {
        out.push({
          name: pr.name,
          source: "corpus50/" + f,
          elements: (pr.elements || []).filter((e) => SYM_SET.has(e)),
          rawElements: pr.elements || [],
        });
      }
    }
  }
  return out;
}

function loadVizProtocols() {
  return protoSrc.PROTOCOLS.map((p) => ({
    name: p.name,
    source: "viz/protocols.ts",
    elements: (p.syms || []).filter((e) => SYM_SET.has(e)),
    rawElements: p.syms || [],
  }));
}

function normalizeName(n) {
  return n
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, " ")
    .trim();
}

function buildContext() {
  const viz = loadVizProtocols();
  const corpus = loadCorpusProtocols();
  const all = [...viz, ...corpus];
  // Dedup by normalized name; prefer corpus (richer) over viz when both present
  const byName = new Map();
  for (const p of all) {
    const key = normalizeName(p.name);
    if (!byName.has(key)) {
      byName.set(key, p);
    } else {
      // merge: keep first, note collision
      const prev = byName.get(key);
      prev._collision = (prev._collision || 0) + 1;
      // prefer the one with more elements if names collide
      if (p.elements.length > prev.elements.length) {
        p._collision = prev._collision;
        byName.set(key, p);
      }
    }
  }
  const objects = [...byName.values()];
  return {
    objects,
    vizCount: viz.length,
    corpusCount: corpus.length,
    totalRaw: all.length,
    afterDedup: objects.length,
    collisions: objects.filter((o) => o._collision).length,
  };
}

function recipeA(ctx) {
  // Ext(m) = set of object indices containing m
  const G = ctx.objects;
  const ext = new Map(SYMS.map((m) => [m, new Set()]));
  for (let i = 0; i < G.length; i++) {
    for (const m of G[i].elements) {
      if (ext.has(m)) ext.get(m).add(i);
    }
  }

  // Ext sizes
  const extSize = Object.fromEntries(SYMS.map((m) => [m, ext.get(m).size]));

  // Empty extent
  const ungrounded = SYMS.filter((m) => ext.get(m).size === 0);

  // Mutual: Ext(m) = Ext(m2), m < m2, both nonempty (or both empty)
  const mutual = [];
  for (let i = 0; i < SYMS.length; i++) {
    for (let j = i + 1; j < SYMS.length; j++) {
      const m = SYMS[i],
        m2 = SYMS[j];
      const a = ext.get(m),
        b = ext.get(m2);
      if (a.size === 0 && b.size === 0) continue; // both ungrounded — note separately
      if (a.size !== b.size) continue;
      let eq = true;
      for (const x of a) if (!b.has(x)) {
        eq = false;
        break;
      }
      if (eq) mutual.push({ m, m2, support: a.size, protocols: [...a].map((k) => G[k].name) });
    }
  }

  // Both empty mutual pairs (type-level no-evidence redundancy candidates)
  const bothEmpty = [];
  for (let i = 0; i < SYMS.length; i++) {
    for (let j = i + 1; j < SYMS.length; j++) {
      if (ext.get(SYMS[i]).size === 0 && ext.get(SYMS[j]).size === 0) {
        bothEmpty.push([SYMS[i], SYMS[j]]);
      }
    }
  }

  // Strict Ext(m) ⊂ Ext(m2), m appears in >= 2 objects
  const strict = [];
  for (const m of SYMS) {
    const a = ext.get(m);
    if (a.size < 2) continue;
    for (const m2 of SYMS) {
      if (m === m2) continue;
      const b = ext.get(m2);
      if (b.size <= a.size) continue; // need proper subset of a larger
      let sub = true;
      for (const x of a) if (!b.has(x)) {
        sub = false;
        break;
      }
      if (sub) {
        strict.push({
          m,
          m2,
          support_m: a.size,
          support_m2: b.size,
          implication: `${m} ⇒ ${m2}`,
        });
      }
    }
  }
  // sort by support_m desc, then by support_m2 asc (tighter)
  strict.sort((x, y) => y.support_m - x.support_m || x.support_m2 - y.support_m2);

  // Interesting ones: not already written as unit implications in laws,
  // and not "almost everything implies Up/Gp" noise if too universal
  // We'll report top interesting after filtering super-common consequents maybe later

  return { extSize, ungrounded, mutual, bothEmpty, strict, G_count: G.length };
}

// ---------------------------------------------------------------------------
// Recipe B — Horn unit implications + redundancy
// ---------------------------------------------------------------------------
function extractUnitImplications(laws) {
  // multiset of {lawId, subject, alt}
  const units = [];
  for (const law of laws) {
    for (const subj of law.subjects) {
      for (const t of law.terms) {
        if (t.external) continue;
        if (t.alts.length === 1) {
          units.push({ lawId: law.id, subject: subj, alt: t.alts[0], term: t.prose });
        }
      }
    }
  }
  return units;
}

function unitClosure(start, units) {
  // forward chaining
  const S = new Set(start);
  let changed = true;
  while (changed) {
    changed = false;
    for (const u of units) {
      if (S.has(u.subject) && !S.has(u.alt)) {
        S.add(u.alt);
        changed = true;
      }
    }
  }
  return S;
}

function recipeB() {
  const unitsRaw = extractUnitImplications(FIREABLE);
  // Also report laws with only multi-alt or external terms
  const lawProfile = FIREABLE.map((law) => {
    const singletonTerms = law.terms.filter((t) => !t.external && t.alts.length === 1);
    const multiTerms = law.terms.filter((t) => !t.external && t.alts.length >= 2);
    const externalTerms = law.terms.filter((t) => t.external);
    return {
      id: law.id,
      subjects: law.subjects,
      singletonCount: singletonTerms.length,
      multiCount: multiTerms.length,
      externalCount: externalTerms.length,
      singletonTerms: singletonTerms.map((t) => t.alts[0]),
      multiTerms: multiTerms.map((t) => t.alts),
    };
  });

  // Dedup by subject->alt first (keep first law id). Pairwise multiset
  // redundancy would drop both copies of an identical implication; the
  // minimal Horn basis needs one representative of each distinct unit.
  const seen = new Map();
  const units = [];
  const duplicateUnits = [];
  for (const u of unitsRaw) {
    const key = `${u.subject}->${u.alt}`;
    if (seen.has(key)) {
      duplicateUnits.push({ ...u, duplicateOf: seen.get(key).lawId });
    } else {
      seen.set(key, u);
      units.push(u);
    }
  }

  // Test each unique unit implication s->a for redundancy: a in cl_rest({s})
  const redundant = [];
  const nonRedundant = [];
  for (let i = 0; i < units.length; i++) {
    const u = units[i];
    const rest = units.filter((_, j) => j !== i);
    const cl = unitClosure([u.subject], rest);
    if (cl.has(u.alt)) {
      redundant.push(u);
    } else {
      nonRedundant.push(u);
    }
  }

  // Which laws contribute at least one non-redundant unit (from unique set)
  const lawsWithNR = new Set(nonRedundant.map((u) => u.lawId));
  const lawsWithAnyUnit = new Set(unitsRaw.map((u) => u.lawId));
  // A law is "only redundant" if it has singleton terms but none survive into NR
  const lawsOnlyRedundant = [...lawsWithAnyUnit].filter((id) => {
    const hasSingleton = lawProfile.find((p) => p.id === id)?.singletonCount > 0;
    return hasSingleton && !lawsWithNR.has(id);
  });
  // Also flag laws whose only contribution was a duplicate of another law's unit
  // and no unique non-redundant unit of their own remains
  const lawsNoSingleton = FIREABLE.filter(
    (l) => !(lawProfile.find((p) => p.id === l.id)?.singletonCount > 0)
  ).map((l) => l.id);

  return {
    unitCountRaw: unitsRaw.length,
    unitCountUnique: units.length,
    unitsRaw,
    units,
    duplicateUnits,
    redundant,
    nonRedundant,
    uniqueNR: nonRedundant, // already unique
    lawsWithNR: [...lawsWithNR].sort(),
    lawsOnlyRedundant: lawsOnlyRedundant.sort(),
    lawsNoSingleton: lawsNoSingleton.sort(),
    unfireable: UNFIREABLE,
    lawProfile,
  };
}

// ---------------------------------------------------------------------------
// Classify blind set
// ---------------------------------------------------------------------------
function classifyBlind() {
  const blind = JSON.parse(
    readFileSync(join(ROOT, "algebra/blind-test-set.json"), "utf8")
  );
  const cases = blind.cases;
  if (cases.length !== 156) {
    throw new Error(`expected 156 cases, got ${cases.length}`);
  }
  const verdicts = [];
  let adm = 0;
  let baseAdm = 0;
  const reasons = { openLaws: 0, hazards: 0, x21: 0, l19b: 0 };
  for (const c of cases) {
    const els = c.elements.filter((e) => SYM_SET.has(e));
    const base = baselineAdmissible(els);
    if (base) baseAdm++;
    const closedBase = closes(els, FIREABLE).ok;
    const closed19 = closedWithL19b(els);
    const haz = armedHazards(els);
    const x21 = x21Armed(els);
    const ok = closed19 && haz.length === 0 && !x21;
    if (ok) adm++;
    else {
      if (!closedBase) reasons.openLaws++;
      else if (!closed19) reasons.l19b++;
      else if (haz.length) reasons.hazards++;
      else if (x21) reasons.x21++;
    }
    verdicts.push({
      id: c.id,
      verdict: ok ? "ADMISSIBLE" : "INADMISSIBLE",
    });
  }
  // sort by id
  verdicts.sort((a, b) => a.id.localeCompare(b.id));
  return {
    verdicts,
    admissibleCount: adm,
    baselineAdmissibleCount: baseAdm,
    inadmissibleCount: 156 - adm,
    reasons,
  };
}

// ---------------------------------------------------------------------------
// Run everything
// ---------------------------------------------------------------------------
console.log("\n=== RECIPE A ===");
const ctx = buildContext();
console.log(
  JSON.stringify(
    {
      vizCount: ctx.vizCount,
      corpusCount: ctx.corpusCount,
      totalRaw: ctx.totalRaw,
      afterDedup: ctx.afterDedup,
      collisions: ctx.collisions,
    },
    null,
    2
  )
);
const A = recipeA(ctx);
console.log("ungrounded", A.ungrounded.join(", ") || "(none)");
console.log("mutual count", A.mutual.length);
console.log("mutual pairs", JSON.stringify(A.mutual, null, 2));
console.log("strict implications (m support>=2)", A.strict.length);
// interesting: exclude trivial Up/Gp sinks that almost everything has?
const topStrict = A.strict.slice(0, 40);
console.log("top strict", JSON.stringify(topStrict, null, 2));

// Filter interesting: consequent not Up/Gp OR support_m2 not huge relative
// Also list all with support_m >= 3 and consequent "interesting"
const interestingStrict = A.strict
  .filter((s) => s.support_m >= 2)
  .filter((s) => {
    // drop pure Up/Gp/Tg noise if support_m2 is > half the corpus
    if ((s.m2 === "Up" || s.m2 === "Gp") && s.support_m2 >= ctx.afterDedup * 0.5) return false;
    return true;
  })
  .slice(0, 25);
console.log("interesting strict", JSON.stringify(interestingStrict, null, 2));

// Extent sizes for report
const extentTable = SYMS.map((m) => ({ m, n: A.extSize[m] })).sort(
  (a, b) => a.n - b.n || a.m.localeCompare(b.m)
);
console.log("extent zero", extentTable.filter((x) => x.n === 0).map((x) => x.m));
console.log("extent one", extentTable.filter((x) => x.n === 1).map((x) => `${x.m}:${x.n}`));

console.log("\n=== RECIPE B ===");
const B = recipeB();
console.log(
  JSON.stringify(
    {
      unitCountRaw: B.unitCountRaw,
      unitCountUnique: B.unitCountUnique,
      duplicateUnits: B.duplicateUnits,
      redundantCount: B.redundant.length,
      nonRedundantCount: B.nonRedundant.length,
      uniqueNR: B.uniqueNR.map((u) => `${u.subject}->${u.alt} (${u.lawId})`),
      lawsWithNR: B.lawsWithNR,
      lawsOnlyRedundant: B.lawsOnlyRedundant,
      lawsNoSingleton: B.lawsNoSingleton,
      unfireable: B.unfireable,
    },
    null,
    2
  )
);
console.log("unique units", JSON.stringify(B.units, null, 2));
console.log("redundant units", JSON.stringify(B.redundant, null, 2));
console.log("law profile", JSON.stringify(B.lawProfile, null, 2));

// Check L3 vs X11a explicitly
console.log("\n=== X11a / L3 ===");
console.log(X11A_SUBSUMED);
// Demo: {Uc} fails L3; {Uc,Aw,At,Bs} closes L3 and would not arm intended X11a
const demo1 = closes(["Uc"], FIREABLE);
const demo2 = closes(["Uc", "Aw", "At", "Bs"], FIREABLE);
console.log("Uc alone open?", !demo1.ok, demo1.open.map((o) => o.law.id));
console.log("Uc+Aw+At+Bs closed?", demo2.ok);

// Witness meet-not-intersection (sanity)
const meetWit = closes(["Xm", "Xf", "Of"], FIREABLE);
console.log("meet witness {Xm,Xf,Of} closed?", meetWit.ok, meetWit.open.map((o) => o.law.id));

// L19b effect on {Xm,Xf}
console.log("{Xm,Xf} closed base?", closes(["Xm", "Xf"], FIREABLE).ok);
console.log("{Xm,Xf} closed L19b?", closedWithL19b(["Xm", "Xf"]));
console.log("{Xm,Xf,Aw} closed L19b?", closedWithL19b(["Xm", "Xf", "Aw"]));
console.log("{Xm,Xf,Aw} armed ref?", armedHazards(["Xm", "Xf", "Aw"]));

// X21
console.log("X21 {Fl,Xm}?", x21Armed(["Fl", "Xm"]));
console.log("X21 {Fl,Au,Rl}?", x21Armed(["Fl", "Au", "Rl"]));
console.log("X21 {Fl}?", x21Armed(["Fl"]));

console.log("\n=== CLASSIFY ===");
const C = classifyBlind();
console.log(
  JSON.stringify(
    {
      admissible: C.admissibleCount,
      baseline: C.baselineAdmissibleCount,
      inadmissible: C.inadmissibleCount,
      reasons: C.reasons,
    },
    null,
    2
  )
);

// Write verdicts
const verdictPath = join(ROOT, "algebra/verdicts/GR-ORD.json");
writeFileSync(verdictPath, JSON.stringify({ verdicts: C.verdicts }, null, 2) + "\n");
console.log("wrote", verdictPath, C.verdicts.length);

// Write analysis dump for the report
const dump = {
  mechanisms: SYMS.length,
  G12: [...G12],
  evaluableHazards: EVAL_HAZARDS,
  unfireable: UNFIREABLE,
  X11A_SUBSUMED,
  recipeA: {
    vizCount: ctx.vizCount,
    corpusCount: ctx.corpusCount,
    totalRaw: ctx.totalRaw,
    afterDedup: ctx.afterDedup,
    collisions: ctx.collisions,
    objectNames: ctx.objects.map((o) => o.name),
    ungrounded: A.ungrounded,
    mutual: A.mutual,
    bothEmptyCount: A.bothEmpty.length,
    strict: A.strict,
    interestingStrict,
    extSize: A.extSize,
  },
  recipeB: {
    unitCountRaw: B.unitCountRaw,
    unitCountUnique: B.unitCountUnique,
    unitsRaw: B.unitsRaw,
    units: B.units,
    duplicateUnits: B.duplicateUnits,
    redundant: B.redundant,
    nonRedundant: B.nonRedundant,
    uniqueNR: B.uniqueNR,
    lawsWithNR: B.lawsWithNR,
    lawsOnlyRedundant: B.lawsOnlyRedundant,
    lawsNoSingleton: B.lawsNoSingleton,
    unfireable: B.unfireable,
    lawProfile: B.lawProfile,
  },
  classify: {
    admissibleCount: C.admissibleCount,
    baselineAdmissibleCount: C.baselineAdmissibleCount,
    inadmissibleCount: C.inadmissibleCount,
    reasons: C.reasons,
  },
};
writeFileSync(join(OUT_DIR, "analysis.json"), JSON.stringify(dump, null, 2));
console.log("wrote analysis dump");
console.log("DONE");
