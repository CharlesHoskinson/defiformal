#!/usr/bin/env node
/**
 * GR-CAT classifier: ADMISSIBLE(S) := closed(S) && !X18(S)
 * Reuses formal/analyze.mjs closure engine verbatim; only X18 is added here.
 */
import { readFile, writeFile, mkdir } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, "..");

const { parseOperationalLaws, closureResult } = await import(
  new URL("../formal/analyze.mjs", import.meta.url)
);
const data = await import(new URL("../viz/src/data.ts", import.meta.url));
const { ELEMENTS, LAWS } = data;

const mechanisms = ELEMENTS.filter((e) => e.status !== "limit");
const parsedLaws = parseOperationalLaws(mechanisms, LAWS);

/** X18: Oa as sole truth for high-frequency liquidation */
function x18(S) {
  return S.has("Oa") && S.has("Li") && !S.has("Ex") && !S.has("Tp") && !S.has("At");
}

function admissible(S) {
  return closureResult(S, parsedLaws).ok && !x18(S);
}

// ---- load blind test set ----
const blindPath = join(__dirname, "blind-test-set.json");
const blind = JSON.parse(await readFile(blindPath, "utf8"));
if (!Array.isArray(blind.cases) || blind.cases.length !== 156) {
  throw new Error(`Expected 156 cases, got ${blind.cases?.length}`);
}

const verdicts = blind.cases.map(({ id, elements }) => ({
  id,
  verdict: admissible(new Set(elements)) ? "ADMISSIBLE" : "INADMISSIBLE",
}));

const outPath = join(__dirname, "verdicts", "GR-CAT.json");
await mkdir(dirname(outPath), { recursive: true });
await writeFile(outPath, `${JSON.stringify({ verdicts }, null, 2)}\n`);

// ---- redundant generator (law-fingerprint) check ----
const byFingerprint = new Map();
for (const mech of mechanisms) {
  const sym = mech.sym;
  const asSubject = parsedLaws
    .filter((law) => law.subjects.includes(sym))
    .map((law) => law.id)
    .sort();
  const asAlternative = parsedLaws
    .filter((law) =>
      law.terms.some((term) => term.alternatives.includes(sym))
    )
    .map((law) => law.id)
    .sort();
  const fingerprint = JSON.stringify([asSubject, asAlternative]);
  if (!byFingerprint.has(fingerprint)) byFingerprint.set(fingerprint, []);
  byFingerprint.get(fingerprint).push(sym);
}

const duplicateGroups = [...byFingerprint.values()].filter((g) => g.length > 1);
let dupSummary;
if (duplicateGroups.length === 0) {
  dupSummary = `no two of the ${mechanisms.length} elements share an identical law-fingerprint`;
} else {
  dupSummary =
    `exact duplicate law-fingerprint groups: ` +
    duplicateGroups.map((g) => `{${g.sort().join(", ")}}`).join("; ");
}

// ---- self-assessment on hardcoded probable-real IDs ----
const PROBABLE_REAL = new Set([
  "T002", "T004", "T006", "T007", "T008", "T011", "T014", "T015", "T018", "T020",
  "T021", "T023", "T025", "T027", "T031", "T032", "T034", "T035", "T038", "T040",
  "T041", "T045", "T047", "T048", "T049", "T054", "T056", "T058", "T059", "T065",
  "T066", "T068", "T069", "T072", "T074", "T076", "T077", "T081", "T082", "T085",
  "T086", "T087", "T088", "T093", "T094", "T095", "T097", "T098", "T099", "T100",
  "T101", "T104", "T106", "T107", "T109", "T111", "T113", "T118", "T119", "T120",
  "T124", "T128", "T133", "T135", "T136", "T140", "T141", "T142", "T146", "T147",
  "T148", "T149",
]);

const REAL_MATCH_COUNT = PROBABLE_REAL.size; // 72
const OTHER_COUNT = 156 - REAL_MATCH_COUNT; // 84

const verdictById = new Map(verdicts.map((v) => [v.id, v.verdict]));

const realIds = [...PROBABLE_REAL];
const otherIds = verdicts.map((v) => v.id).filter((id) => !PROBABLE_REAL.has(id));

const realAdmit = realIds.filter((id) => verdictById.get(id) === "ADMISSIBLE").length;
const otherAdmit = otherIds.filter((id) => verdictById.get(id) === "ADMISSIBLE").length;
const totalAdmit = verdicts.filter((v) => v.verdict === "ADMISSIBLE").length;

const round1 = (n) => Math.round(n * 10) / 10;
const realAdmitPct = round1((realAdmit / REAL_MATCH_COUNT) * 100);
const otherAdmitPct = round1((otherAdmit / OTHER_COUNT) * 100);
const totalAdmitPct = round1((totalAdmit / 156) * 100);

let ratio;
if (otherAdmitPct === 0) {
  ratio = "undefined (0% noise acceptance)";
} else {
  ratio = Math.round((realAdmitPct / otherAdmitPct) * 100) / 100;
}

const admissibleIds = verdicts
  .filter((v) => v.verdict === "ADMISSIBLE")
  .map((v) => v.id);

// stdout report for the implementer
console.log(
  JSON.stringify({
    dupSummary,
    realMatchCount: REAL_MATCH_COUNT,
    otherCount: OTHER_COUNT,
    realAdmitPct,
    otherAdmitPct,
    ratio,
    totalAdmit,
    totalAdmitPct,
  })
);
console.log(JSON.stringify(admissibleIds));
console.log(verdicts.length);
