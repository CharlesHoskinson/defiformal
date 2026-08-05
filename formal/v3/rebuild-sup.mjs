/* Rebuild the supplement with twelve category headings holding all sixty
 * profiles uniformly, then the evidence. Round 3, finding 5. */
import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";

const ROOT = "/root/defiformal/expansion";
const V3 = "/root/defiformal/formal/v3";
const NAME = {
  "01-spot-exchange": "Spot exchange", "02-lending": "Lending",
  "03-cdp-stablecoins": "Collateralised-debt stablecoins",
  "04-liquid-staking": "Liquid staking and restaking",
  "05-perpetuals": "Perpetual futures", "06-yield-vaults": "Yield vaults and aggregators",
  "07-bridges": "Bridges", "08-intents": "Intents and aggregation",
  "09-rwa": "Tokenised real-world assets", "10-options": "Options and structured products",
  "11-fiat-stablecoins": "Reserve-backed stablecoins", "12-prediction": "Prediction markets",
};

const L = [
  "% Supplement to \"An algebra of mechanism composition\".",
  "% Generated. Do not edit by hand; see formal/v3/rebuild-sup.mjs.",
  "\\documentclass[11pt]{amsart}",
  "\\usepackage[margin=1.15in]{geometry}",
  "\\usepackage{amsmath,amssymb,amsthm,mathtools}",
  "\\usepackage[hidelinks]{hyperref}",
  "\\theoremstyle{remark}",
  "\\newtheorem{measurement}{Measurement}[section]",
  "\\newtheorem{remark}[measurement]{Remark}",
  "\\newcommand{\\El}{\\mathcal{E}}",
  "\\title{Sixty protocol profiles}",
  "\\date{}",
  "\\begin{document}",
  "\\maketitle",
  "",
  "For each of the sixty protocols this supplement records the construction",
  "exhibited for it, its canonical form, the verdict of the admissibility test,",
  "how many of its recorded obligations the construction discharges, and every",
  "obligation no element of the vocabulary names. Sources follow in",
  "\\S\\ref{sec:evidence}. Profiles are grouped by the category from which the",
  "protocol was sampled, in the order of the article.",
  "",
  "\\tableofcontents",
  "",
];

let count = 0;
for (const [slug, title] of Object.entries(NAME)) {
  const specs = path.join(ROOT, slug, "specs");
  const verd = path.join(ROOT, slug, "verdicts.json");
  if (!fs.existsSync(specs) || !fs.existsSync(verd)) continue;
  const out = execFileSync("node", [path.join(V3, "emit-tex.mjs"), specs, verd],
                           { encoding: "utf8" });
  L.push(`\\section{${title}}`);
  L.push("");
  L.push(out.trim());
  L.push("");
  count += (out.match(/\\subsection\{/g) || []).length;
}

L.push(fs.readFileSync("/root/evidence.tex", "utf8").trim());
L.push("");
L.push("\\end{document}");
fs.writeFileSync("/root/defiformal/paper/supplement.tex", L.join("\n"));
console.log(`supplement rebuilt: 12 category headings, ${count} profiles`);
