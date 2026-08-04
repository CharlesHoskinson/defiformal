import { readFileSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

import { ELEMENTS, HAZARDS, LAWS } from "../viz/src/data.ts";
import { PROTOCOLS } from "../viz/src/protocols.ts";

const ROOT = fileURLToPath(new URL("../", import.meta.url));
const BLIND_PATH = `${ROOT}algebra/blind-test-set.json`;
const VERDICT_PATH = `${ROOT}algebra/verdicts/GP-ORD.json`;

export const elements = ELEMENTS.filter((element) => element.status !== "limit");
const SYMS = new Set(elements.map((element) => element.sym));
const NEGATED = /\b(no|without|absent|lacking|missing|never)\b/i;
const ATOMIC_G12 = new Set(["Xm", "Xf", "Rl", "Of"]);

const bare = (text) => text.replace(/\{[^}]*\}/g, "").replace(/[()]/g, "").trim();

function parseTerms(side) {
  return side.split("+").map((chunk, index) => {
    const prose = chunk.trim();
    const alts = prose
      .split("|")
      .map(bare)
      .filter((alt) => SYMS.has(alt));
    return { index, alts, prose, external: alts.length === 0 };
  });
}

export const parsedLaws = LAWS.map((law) => {
  const [lhs = "", rhs = ""] = law.rule.split("→");
  return {
    id: law.id,
    rule: law.rule,
    subjects: lhs.split("|").map(bare).filter((subject) => SYMS.has(subject)),
    subjectProse: lhs.trim(),
    terms: parseTerms(rhs),
  };
});

export const hazardRows = HAZARDS.map((hazard) => {
  const named = [...new Set(
    (hazard.combo.match(/\b[A-Z][a-z]{1,2}\b/g) ?? []).filter((token) => SYMS.has(token)),
  )];
  return { ...hazard, named, negated: NEGATED.test(hazard.combo) };
});

export function evaluateClosure(present) {
  const set = new Set(present);
  const fired = parsedLaws
    .map((law) => {
      const firedBy = law.subjects.filter((subject) => set.has(subject));
      if (firedBy.length === 0) return null;
      const terms = law.terms.map((term) => {
        const by = term.alts.find((alt) => set.has(alt)) ?? null;
        return { ...term, by, satisfied: term.external || by !== null };
      });
      const missing = terms.filter((term) => !term.satisfied);
      return { law, firedBy, terms, missing, satisfied: missing.length === 0 };
    })
    .filter(Boolean);
  const open = fired.filter((result) => !result.satisfied);
  return { ok: open.length === 0, fired, open };
}

export function evaluateWrittenHazards(present) {
  const set = new Set(present);
  const armed = [];
  for (const hazard of hazardRows) {
    if (hazard.id === "X11a") {
      if (
        set.has("Uc")
        && !set.has("Aw")
        && !set.has("At")
        && !set.has("Bs")
        && !set.has("Tr")
      ) armed.push(hazard.id);
      continue;
    }
    if (hazard.id === "X19") continue;
    if (hazard.named.length < 2) continue;
    if (hazard.negated) continue;
    if (hazard.named.every((symbol) => set.has(symbol))) armed.push(hazard.id);
  }
  return armed;
}

export function classify(present) {
  const outOfSignature = [...new Set(present.filter((symbol) => !SYMS.has(symbol)))];
  const reasons = {
    outOfSignature,
    openLawIds: [],
    hazardIds: [],
    atomicScope: false,
    x11a: false,
  };
  if (outOfSignature.length > 0) return { verdict: "INADMISSIBLE", reasons };

  const closure = evaluateClosure(present);
  reasons.openLawIds = closure.open.map((result) => result.law.id);
  reasons.hazardIds = evaluateWrittenHazards(present);
  reasons.x11a = reasons.hazardIds.includes("X11a");
  const set = new Set(present);
  reasons.atomicScope = set.has("Fl") && [...ATOMIC_G12].some((symbol) => set.has(symbol));
  const ok = closure.ok && reasons.hazardIds.length === 0 && !reasons.atomicScope;
  return { verdict: ok ? "ADMISSIBLE" : "INADMISSIBLE", reasons, closure };
}

export function analyzeBlindSet() {
  const source = JSON.parse(readFileSync(BLIND_PATH, "utf8"));
  const cases = source.cases.map((testCase) => ({
    id: testCase.id,
    elements: testCase.elements,
    ...classify(testCase.elements),
  }));
  return { cases };
}

function lawSignatures() {
  const signatures = new Map();
  for (const element of elements) {
    const subject = parsedLaws
      .filter((law) => law.subjects.includes(element.sym))
      .map((law) => law.id)
      .sort();
    const required = [];
    for (const law of parsedLaws) {
      for (const term of law.terms) {
        if (term.alts.includes(element.sym)) required.push(`${law.id}:${term.index}`);
      }
    }
    const hazards = [];
    for (const hazard of hazardRows) {
      const decidable = hazard.id === "X11a"
        || (hazard.id !== "X19" && hazard.named.length >= 2 && !hazard.negated);
      if (decidable && hazard.named.includes(element.sym)) hazards.push(hazard.id);
    }
    if (element.sym === "Fl" || ATOMIC_G12.has(element.sym)) hazards.push("X21");
    const signature = JSON.stringify([subject, required.sort(), hazards.sort()]);
    signatures.set(element.sym, { subject, required: required.sort(), hazards: hazards.sort(), signature });
  }
  return signatures;
}

function redundantClasses() {
  const signatures = lawSignatures();
  const classes = new Map();
  for (const element of elements) {
    const key = signatures.get(element.sym).signature;
    if (!classes.has(key)) classes.set(key, []);
    classes.get(key).push({
      sym: element.sym,
      name: element.name,
      group: element.group,
      stratum: element.stratum,
    });
  }
  return [...classes.values()].filter((members) => members.length > 1);
}

export function computeSummary() {
  const blind = analyzeBlindSet().cases;
  const admissible = blind.filter((entry) => entry.verdict === "ADMISSIBLE").length;
  const hazardCounts = {};
  const lawCounts = {};
  for (const entry of blind) {
    for (const id of entry.reasons.hazardIds) hazardCounts[id] = (hazardCounts[id] ?? 0) + 1;
    for (const id of entry.reasons.openLawIds) lawCounts[id] = (lawCounts[id] ?? 0) + 1;
  }
  const calibration = PROTOCOLS.map((protocol) => {
    const result = classify(protocol.syms);
    return {
      id: protocol.id,
      dead: Boolean(protocol.dead),
      closed: result.reasons.openLawIds.length === 0,
      openLawIds: result.reasons.openLawIds,
      hazardFree: result.reasons.hazardIds.length === 0,
      hazardIds: result.reasons.hazardIds,
      atomicScopeClean: !result.reasons.atomicScope,
      verdict: result.verdict,
    };
  });
  const fullVocabulary = evaluateClosure(elements.map((element) => element.sym));
  const terra = calibration.find((protocol) => protocol.id === "terra");
  return {
    schema: {
      elements: elements.length,
      laws: parsedLaws.length,
      fireableLaws: parsedLaws.filter((law) => law.subjects.length > 0).map((law) => law.id),
      unfireableLaws: parsedLaws.filter((law) => law.subjects.length === 0).map((law) => law.id),
      fullVocabulary: {
        fired: fullVocabulary.fired.length,
        firedIds: fullVocabulary.fired.map((result) => result.law.id),
        satisfied: fullVocabulary.fired.filter((result) => result.satisfied).length,
        closed: fullVocabulary.ok,
      },
      hazards: hazardRows.map(({ id, named, negated }) => ({ id, named, negated })),
      thresholdNegated: hazardRows.filter((hazard) => hazard.named.length >= 2 && hazard.negated).map((hazard) => hazard.id),
      belowThresholdNegated: hazardRows.filter((hazard) => hazard.named.length < 2 && hazard.negated).map((hazard) => hazard.id),
    },
    blind: {
      total: blind.length,
      admissible,
      inadmissible: blind.length - admissible,
      acceptancePercent: 100 * admissible / blind.length,
      outOfSignature: blind
        .filter((entry) => entry.reasons.outOfSignature.length > 0)
        .map((entry) => ({ id: entry.id, symbols: entry.reasons.outOfSignature })),
      open: blind.filter((entry) => entry.reasons.openLawIds.length > 0).length,
      hazardArmed: blind.filter((entry) => entry.reasons.hazardIds.length > 0).length,
      hazardCounts,
      atomicScope: blind.filter((entry) => entry.reasons.atomicScope).length,
      x11aOnClosed: blind.filter((entry) => entry.reasons.x11a && entry.reasons.openLawIds.length === 0).length,
      lawCounts,
    },
    calibration,
    calibrationCounts: {
      aliveAccepted: calibration.filter((entry) => !entry.dead && entry.verdict === "ADMISSIBLE").length,
      aliveTotal: calibration.filter((entry) => !entry.dead).length,
      deadRejected: calibration.filter((entry) => entry.dead && entry.verdict === "INADMISSIBLE").length,
      deadTotal: calibration.filter((entry) => entry.dead).length,
    },
    terra,
    redundantClasses: redundantClasses(),
  };
}

function writeVerdicts() {
  const verdicts = analyzeBlindSet().cases.map(({ id, verdict }) => ({ id, verdict }));
  writeFileSync(VERDICT_PATH, `${JSON.stringify({ verdicts }, null, 2)}\n`);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  if (process.argv.includes("--write-verdicts")) writeVerdicts();
  process.stdout.write(`${JSON.stringify(computeSummary(), null, 2)}\n`);
}
