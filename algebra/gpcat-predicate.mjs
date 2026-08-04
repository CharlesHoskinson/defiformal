#!/usr/bin/env node

import { readFile, writeFile } from "node:fs/promises";
import { pathToFileURL } from "node:url";

/** The 58 mechanism symbols. CSM and the contested register are not members. */
export const MECHANISMS = new Set([
  "Sh", "Ix", "Rb",
  "Cp", "Wg", "St", "Cl", "Pm",
  "Ob", "Rf", "Ba", "In",
  "Ag", "Fl",
  "Pl", "Im", "Cd", "Uc", "Ft",
  "Ct", "Li", "Ad", "Sl", "Bs",
  "Pf", "Op", "Tr", "Cv", "Py", "Sv", "Dp",
  "Ex", "Tp", "Oa", "At",
  "Sr", "Ep", "Wq",
  "Em", "Fd",
  "Tg", "Up", "Gp", "Au", "Gs",
  "Xm", "Xf", "Rl", "Of",
  "Rd", "Ps", "As",
  "Aw", "Sb", "Sd", "Fz",
  "Rs", "Vl",
]);

/**
 * Element-expressible projection of viz/src/laws.ts. A law fires when any
 * subject is present and closes when every term meets at least one alternative.
 * Prose-only terms and prose-only subjects are deliberately outside this
 * support predicate, exactly as in the reference evaluator.
 */
export const REQUIREMENTS = [
  { id: "L1", subjects: ["Pl", "Im", "Cd", "Pf", "Op"], terms: [["Ex", "Tp", "At"], ["Ct"], ["Li", "Ad", "Sl", "Bs"]] },
  { id: "L2", subjects: ["Pl"], terms: [["Sh", "Ix"]] },
  { id: "L3", subjects: ["Uc"], terms: [["Aw"], ["At"], ["Bs", "Tr"]] },
  { id: "L4", subjects: ["Pf"], terms: [["Ex"], ["Ct"], ["Li"], ["Ad", "Sl", "Bs"]] },
  { id: "L5", subjects: ["Py"], terms: [["Sh", "Ix", "Rb"], ["Ep"], ["Rd"]] },
  { id: "L6", subjects: ["Tr"], terms: [["Sv"]] },
  { id: "L7", subjects: ["Cd"], terms: [["Rd", "Ps"]] },
  { id: "L8", subjects: ["Xf"], terms: [["Xm"]] },
  { id: "L15", subjects: ["Up"], terms: [["Tg"]] },
  { id: "L19", subjects: ["Of"], terms: [["Xm"], ["Xf"], ["Bs", "Sl"]] },
  { id: "L20", subjects: ["Rl"], terms: [["Au"]] },
  { id: "L21", subjects: ["Gs"], terms: [["Au"]] },
];

/**
 * Forbidden typed subgraphs (NACs) visible in a bare support set.
 * The first three reproduce the current table's membership projection,
 * including its documented reversed polarity for X11a and X19. The last three
 * are the exhaustively established atomicity witnesses and L21 erratum.
 */
export const NACS = [
  { id: "X2", elements: ["Fl", "Cp", "Cl", "Pl", "Cd"] },
  { id: "X11a", elements: ["Uc", "Aw", "At"] },
  { id: "X19", elements: ["Xf", "Aw"] },
  { id: "N-ATOMIC-XM", elements: ["Fl", "Xm"] },
  { id: "N-ATOMIC-RL", elements: ["Fl", "Au", "Rl"] },
  { id: "ERR-L21", elements: ["Au", "Gs"] },
];

const intersects = (support, alternatives) => alternatives.some((sym) => support.has(sym));

export function evaluateSupport(elements) {
  if (!Array.isArray(elements) || !elements.every((sym) => typeof sym === "string")) {
    throw new TypeError("elements must be an array of strings");
  }

  const support = new Set(elements);
  const unknown = [...support].filter((sym) => !MECHANISMS.has(sym)).sort();
  const openLaws = [];
  for (const law of REQUIREMENTS) {
    if (!intersects(support, law.subjects)) continue;
    const missing = law.terms.filter((term) => !intersects(support, term));
    if (missing.length > 0) openLaws.push({ id: law.id, missing });
  }

  const matchedNacs = NACS
    .filter((nac) => nac.elements.every((sym) => support.has(sym)))
    .map(({ id }) => id);

  return {
    ok: unknown.length === 0 && openLaws.length === 0 && matchedNacs.length === 0,
    support: [...support],
    unknown,
    openLaws,
    matchedNacs,
  };
}

export function classify(elements) {
  return evaluateSupport(elements).ok ? "ADMISSIBLE" : "INADMISSIBLE";
}

export async function classifyFile(inputPath, outputPath) {
  const parsed = JSON.parse(await readFile(inputPath, "utf8"));
  if (!parsed || !Array.isArray(parsed.cases)) throw new TypeError("input must contain a cases array");

  const ids = parsed.cases.map(({ id }) => id);
  if (!ids.every((id) => typeof id === "string") || new Set(ids).size !== ids.length) {
    throw new TypeError("case ids must be unique strings");
  }

  const verdicts = parsed.cases.map(({ id, elements }) => ({
    id,
    verdict: classify(elements),
  }));
  await writeFile(outputPath, `${JSON.stringify({ verdicts }, null, 2)}\n`, "utf8");
  return verdicts;
}

const invokedAsScript = process.argv[1]
  && import.meta.url === pathToFileURL(process.argv[1]).href;
if (invokedAsScript) {
  const inputPath = process.argv[2] ?? "algebra/blind-test-set.json";
  const outputPath = process.argv[3] ?? "algebra/verdicts/GP-CAT.json";
  const verdicts = await classifyFile(inputPath, outputPath);
  const admitted = verdicts.filter(({ verdict }) => verdict === "ADMISSIBLE").length;
  console.log(`wrote ${verdicts.length} verdicts: ${admitted} ADMISSIBLE, ${verdicts.length - admitted} INADMISSIBLE`);
}
